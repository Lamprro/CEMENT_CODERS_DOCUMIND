-- Supabase mới: chạy 01_create_tables.sql trước 02_seed.sql.
BEGIN;

CREATE TABLE public.analyses (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  user_id uuid,
  guest_session_hash text,
  title text DEFAULT 'Phân tích mới' NOT NULL,
  topic_id uuid,
  specialization_id uuid,
  prompt_template_id uuid,
  custom_prompt text,
  quiz_enabled boolean DEFAULT false NOT NULL,
  status text DEFAULT 'draft' NOT NULL,
  validation_report jsonb DEFAULT '{}'::jsonb NOT NULL,
  error_code text,
  error_message text,
  model_provider text,
  model_name text,
  confirmed_at timestamp with time zone,
  completed_at timestamp with time zone,
  expires_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  quiz_settings jsonb DEFAULT '{"types": ["multiple_choice"], "difficulty": "mixed", "questionCount": 20}'::jsonb NOT NULL,
  finalization_lease_until timestamp with time zone,
  PRIMARY KEY (id),
  CHECK (((((user_id IS NOT NULL))::integer + ((guest_session_hash IS NOT NULL))::integer) = 1))
);

CREATE TABLE public.analysis_activity (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  analysis_id uuid NOT NULL,
  actor text NOT NULL,
  label text NOT NULL,
  model text,
  status text NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  completed_at timestamp with time zone,
  CHECK ((actor = ANY (ARRAY['ai', 'system']))),
  CHECK ((length(label) <= 300)),
  PRIMARY KEY (id),
  CHECK ((status = ANY (ARRAY['running', 'succeeded', 'failed'])))
);

CREATE TABLE public.analysis_chunks (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  analysis_id uuid NOT NULL,
  input_id uuid NOT NULL,
  chunk_index integer NOT NULL,
  title text,
  content text NOT NULL,
  char_start integer DEFAULT 0 NOT NULL,
  char_end integer DEFAULT 0 NOT NULL,
  status text DEFAULT 'pending' NOT NULL,
  retry_count integer DEFAULT 0 NOT NULL,
  error_message text,
  generated_content jsonb,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  quiz_finished boolean DEFAULT false NOT NULL,
  quiz_batches integer DEFAULT 0 NOT NULL,
  quiz_lease_until timestamp with time zone,
  CHECK ((chunk_index >= 0)),
  UNIQUE (input_id, chunk_index),
  PRIMARY KEY (id),
  CHECK ((retry_count >= 0))
);

CREATE TABLE public.analysis_inputs (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  analysis_id uuid NOT NULL,
  input_kind text NOT NULL,
  original_name text,
  mime_type text,
  byte_size bigint DEFAULT 0 NOT NULL,
  storage_bucket text,
  storage_path text,
  original_text text,
  normalized_text text,
  edited_text text,
  status text DEFAULT 'staged' NOT NULL,
  validation_report jsonb DEFAULT '{}'::jsonb NOT NULL,
  metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
  "position" integer DEFAULT 0 NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  ingest_lease_until timestamp with time zone,
  CHECK ((byte_size >= 0)),
  CHECK ((input_kind = ANY (ARRAY['file', 'pasted_text']))),
  PRIMARY KEY (id),
  CHECK ((((input_kind = 'pasted_text') AND (original_text IS NOT NULL)) OR ((input_kind = 'file') AND ((storage_path IS NOT NULL) OR (original_name IS NOT NULL)))))
);

CREATE TABLE public.analysis_results (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  analysis_id uuid NOT NULL,
  version integer DEFAULT 1 NOT NULL,
  schema_version text DEFAULT '1.0' NOT NULL,
  result_json jsonb NOT NULL,
  summary text,
  source_metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
  is_current boolean DEFAULT true NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  UNIQUE (analysis_id, version),
  PRIMARY KEY (id),
  CHECK ((version > 0)),
  CHECK (((jsonb_typeof(result_json) = 'object') AND (jsonb_typeof((result_json -> 'sections')) = 'array')))
);

CREATE TABLE public.api_rate_limits (
  key_hash text NOT NULL,
  window_started_at timestamp with time zone NOT NULL,
  hits integer NOT NULL,
  expires_at timestamp with time zone NOT NULL,
  CHECK ((hits > 0)),
  PRIMARY KEY (key_hash)
);

CREATE TABLE public.chat_messages (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  analysis_id uuid NOT NULL,
  role text NOT NULL,
  content text NOT NULL,
  citations jsonb DEFAULT '[]'::jsonb NOT NULL,
  metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  PRIMARY KEY (id),
  CHECK ((role = ANY (ARRAY['user', 'assistant', 'system'])))
);

CREATE TABLE public.exports (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  analysis_id uuid NOT NULL,
  result_id uuid,
  format text NOT NULL,
  status text DEFAULT 'ready' NOT NULL,
  storage_bucket text,
  storage_path text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CHECK ((format = ANY (ARRAY['json', 'markdown', 'html', 'pdf', 'docx']))),
  PRIMARY KEY (id),
  CHECK ((status = ANY (ARRAY['pending', 'ready', 'failed'])))
);

CREATE TABLE public.gemini_model_health (
  scope text NOT NULL,
  model text NOT NULL,
  failures integer DEFAULT 0 NOT NULL,
  generation bigint DEFAULT 0 NOT NULL,
  open_until timestamp with time zone,
  probe_until timestamp with time zone,
  last_status integer,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CHECK ((failures >= 0)),
  CHECK (((length(model) >= 1) AND (length(model) <= 100))),
  PRIMARY KEY (scope, model),
  CHECK ((length(scope) = 64))
);

CREATE TABLE public.generated_assets (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  analysis_id uuid NOT NULL,
  result_id uuid,
  asset_type text NOT NULL,
  title text,
  source text,
  metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
  storage_bucket text,
  storage_path text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CHECK ((asset_type = ANY (ARRAY['latex', 'mermaid', 'plantuml', 'code', 'image', 'other']))),
  PRIMARY KEY (id)
);

CREATE TABLE public.llm_exchanges (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  analysis_id uuid NOT NULL,
  chunk_id uuid,
  prompt_template_id uuid,
  purpose text NOT NULL,
  provider text NOT NULL,
  model text NOT NULL,
  attempt integer DEFAULT 1 NOT NULL,
  request_payload jsonb DEFAULT '{}'::jsonb NOT NULL,
  response_payload jsonb,
  input_tokens integer,
  output_tokens integer,
  latency_ms integer,
  status text DEFAULT 'started' NOT NULL,
  error_message text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CHECK ((attempt > 0)),
  PRIMARY KEY (id)
);

CREATE TABLE public.profiles (
  id uuid NOT NULL,
  username text,
  display_name text,
  avatar_url text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  PRIMARY KEY (id),
  UNIQUE (username)
);

CREATE TABLE public.prompt_templates (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  purpose text NOT NULL,
  topic_id uuid,
  specialization_id uuid,
  version integer DEFAULT 1 NOT NULL,
  name text NOT NULL,
  system_prompt text NOT NULL,
  user_prompt_template text NOT NULL,
  output_schema jsonb DEFAULT '{}'::jsonb NOT NULL,
  model_config jsonb DEFAULT '{}'::jsonb NOT NULL,
  is_active boolean DEFAULT true NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  PRIMARY KEY (id),
  CHECK ((purpose = ANY (ARRAY['section_generation', 'quiz_generation', 'chat', 'repair', 'topic_detection']))),
  UNIQUE (purpose, name, version),
  CHECK ((version > 0))
);

CREATE TABLE public.quiz_attempts (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  quiz_id uuid NOT NULL,
  user_id uuid,
  guest_session_hash text,
  answers jsonb DEFAULT '{}'::jsonb NOT NULL,
  score numeric(5,2),
  total_questions integer DEFAULT 0 NOT NULL,
  status text DEFAULT 'in_progress' NOT NULL,
  started_at timestamp with time zone DEFAULT now() NOT NULL,
  submitted_at timestamp with time zone,
  CHECK (((((user_id IS NOT NULL))::integer + ((guest_session_hash IS NOT NULL))::integer) = 1)),
  PRIMARY KEY (id)
);

CREATE TABLE public.quiz_questions (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  quiz_id uuid NOT NULL,
  question_index integer NOT NULL,
  question_type text DEFAULT 'multiple_choice' NOT NULL,
  prompt text NOT NULL,
  options jsonb DEFAULT '[]'::jsonb NOT NULL,
  answer jsonb NOT NULL,
  explanation text,
  difficulty text,
  source_chunk_id uuid,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CHECK ((difficulty = ANY (ARRAY['easy', 'medium', 'hard']))),
  PRIMARY KEY (id),
  CHECK ((question_index >= 0)),
  CHECK ((question_type = ANY (ARRAY['multiple_choice', 'true_false', 'short_answer']))),
  UNIQUE (quiz_id, question_index)
);

CREATE TABLE public.quizzes (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  analysis_id uuid NOT NULL,
  result_id uuid,
  title text DEFAULT 'Ôn tập nhanh' NOT NULL,
  settings jsonb DEFAULT '{}'::jsonb NOT NULL,
  status text DEFAULT 'ready' NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  PRIMARY KEY (id),
  CHECK ((status = ANY (ARRAY['draft', 'ready', 'failed'])))
);

CREATE TABLE public.topic_specializations (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  topic_id uuid NOT NULL,
  parent_id uuid,
  name text NOT NULL,
  slug text NOT NULL,
  description text,
  is_active boolean DEFAULT true NOT NULL,
  sort_order integer DEFAULT 0 NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  PRIMARY KEY (id),
  UNIQUE (topic_id, slug)
);

CREATE TABLE public.topics (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  code text NOT NULL,
  name text NOT NULL,
  description text,
  is_active boolean DEFAULT true NOT NULL,
  sort_order integer DEFAULT 0 NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  UNIQUE (code),
  PRIMARY KEY (id)
);

CREATE TABLE public.validation_rules (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  code text NOT NULL,
  stage text NOT NULL,
  severity text NOT NULL,
  description text NOT NULL,
  config jsonb DEFAULT '{}'::jsonb NOT NULL,
  is_active boolean DEFAULT true NOT NULL,
  sort_order integer DEFAULT 0 NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  UNIQUE (code),
  PRIMARY KEY (id),
  CHECK ((severity = ANY (ARRAY['info', 'warning', 'error']))),
  CHECK ((stage = ANY (ARRAY['input', 'structure', 'output', 'quiz'])))
);

ALTER TABLE analyses ADD FOREIGN KEY (prompt_template_id) REFERENCES prompt_templates(id) ON DELETE SET NULL;
ALTER TABLE analyses ADD FOREIGN KEY (specialization_id) REFERENCES topic_specializations(id) ON DELETE SET NULL;
ALTER TABLE analyses ADD FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE SET NULL;
ALTER TABLE analyses ADD FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE analysis_activity ADD FOREIGN KEY (analysis_id) REFERENCES analyses(id) ON DELETE CASCADE;
ALTER TABLE analysis_chunks ADD FOREIGN KEY (analysis_id) REFERENCES analyses(id) ON DELETE CASCADE;
ALTER TABLE analysis_chunks ADD FOREIGN KEY (input_id) REFERENCES analysis_inputs(id) ON DELETE CASCADE;
ALTER TABLE analysis_inputs ADD FOREIGN KEY (analysis_id) REFERENCES analyses(id) ON DELETE CASCADE;
ALTER TABLE analysis_results ADD FOREIGN KEY (analysis_id) REFERENCES analyses(id) ON DELETE CASCADE;
ALTER TABLE chat_messages ADD FOREIGN KEY (analysis_id) REFERENCES analyses(id) ON DELETE CASCADE;
ALTER TABLE exports ADD FOREIGN KEY (analysis_id) REFERENCES analyses(id) ON DELETE CASCADE;
ALTER TABLE exports ADD FOREIGN KEY (result_id) REFERENCES analysis_results(id) ON DELETE SET NULL;
ALTER TABLE generated_assets ADD FOREIGN KEY (analysis_id) REFERENCES analyses(id) ON DELETE CASCADE;
ALTER TABLE generated_assets ADD FOREIGN KEY (result_id) REFERENCES analysis_results(id) ON DELETE CASCADE;
ALTER TABLE llm_exchanges ADD FOREIGN KEY (analysis_id) REFERENCES analyses(id) ON DELETE CASCADE;
ALTER TABLE llm_exchanges ADD FOREIGN KEY (chunk_id) REFERENCES analysis_chunks(id) ON DELETE SET NULL;
ALTER TABLE llm_exchanges ADD FOREIGN KEY (prompt_template_id) REFERENCES prompt_templates(id) ON DELETE SET NULL;
ALTER TABLE profiles ADD FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE prompt_templates ADD FOREIGN KEY (specialization_id) REFERENCES topic_specializations(id) ON DELETE SET NULL;
ALTER TABLE prompt_templates ADD FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE SET NULL;
ALTER TABLE quiz_attempts ADD FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE;
ALTER TABLE quiz_attempts ADD FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE quiz_questions ADD FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE;
ALTER TABLE quiz_questions ADD FOREIGN KEY (source_chunk_id) REFERENCES analysis_chunks(id) ON DELETE SET NULL;
ALTER TABLE quizzes ADD FOREIGN KEY (analysis_id) REFERENCES analyses(id) ON DELETE CASCADE;
ALTER TABLE quizzes ADD FOREIGN KEY (result_id) REFERENCES analysis_results(id) ON DELETE SET NULL;
ALTER TABLE topic_specializations ADD FOREIGN KEY (parent_id) REFERENCES topic_specializations(id) ON DELETE SET NULL;
ALTER TABLE topic_specializations ADD FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE;
CREATE INDEX analyses_guest_created_idx ON public.analyses USING btree (guest_session_hash, created_at DESC) WHERE (guest_session_hash IS NOT NULL);
CREATE INDEX analyses_prompt_template_fk_idx ON public.analyses USING btree (prompt_template_id);
CREATE INDEX analyses_specialization_fk_idx ON public.analyses USING btree (specialization_id);
CREATE INDEX analyses_status_idx ON public.analyses USING btree (status, updated_at);
CREATE INDEX analyses_topic_fk_idx ON public.analyses USING btree (topic_id);
CREATE INDEX analyses_user_created_idx ON public.analyses USING btree (user_id, created_at DESC) WHERE (user_id IS NOT NULL);
CREATE INDEX analysis_activity_analysis_created_idx ON public.analysis_activity USING btree (analysis_id, created_at DESC);
CREATE INDEX analysis_chunks_analysis_idx ON public.analysis_chunks USING btree (analysis_id, chunk_index);
CREATE INDEX analysis_inputs_analysis_idx ON public.analysis_inputs USING btree (analysis_id, "position");
CREATE UNIQUE INDEX analysis_results_one_current_idx ON public.analysis_results USING btree (analysis_id) WHERE is_current;
CREATE INDEX api_rate_limits_expiry_idx ON public.api_rate_limits USING btree (expires_at);
CREATE INDEX chat_messages_analysis_idx ON public.chat_messages USING btree (analysis_id, created_at);
CREATE INDEX exports_analysis_idx ON public.exports USING btree (analysis_id, created_at DESC);
CREATE INDEX exports_result_fk_idx ON public.exports USING btree (result_id);
CREATE INDEX generated_assets_analysis_idx ON public.generated_assets USING btree (analysis_id, asset_type);
CREATE INDEX generated_assets_result_fk_idx ON public.generated_assets USING btree (result_id);
CREATE INDEX llm_exchanges_analysis_idx ON public.llm_exchanges USING btree (analysis_id, created_at);
CREATE INDEX llm_exchanges_chunk_fk_idx ON public.llm_exchanges USING btree (chunk_id);
CREATE INDEX llm_exchanges_prompt_fk_idx ON public.llm_exchanges USING btree (prompt_template_id);
CREATE INDEX prompt_templates_lookup_idx ON public.prompt_templates USING btree (purpose, topic_id, specialization_id, is_active);
CREATE INDEX prompt_templates_specialization_fk_idx ON public.prompt_templates USING btree (specialization_id);
CREATE INDEX prompt_templates_topic_fk_idx ON public.prompt_templates USING btree (topic_id);
CREATE INDEX quiz_attempts_quiz_idx ON public.quiz_attempts USING btree (quiz_id, started_at DESC);
CREATE INDEX quiz_attempts_user_fk_idx ON public.quiz_attempts USING btree (user_id);
CREATE INDEX quiz_questions_quiz_idx ON public.quiz_questions USING btree (quiz_id, question_index);
CREATE INDEX quiz_questions_source_chunk_fk_idx ON public.quiz_questions USING btree (source_chunk_id);
CREATE INDEX quizzes_analysis_idx ON public.quizzes USING btree (analysis_id, created_at DESC);
CREATE INDEX quizzes_result_fk_idx ON public.quizzes USING btree (result_id);
CREATE INDEX topic_specializations_parent_fk_idx ON public.topic_specializations USING btree (parent_id);
CREATE INDEX topic_specializations_parent_idx ON public.topic_specializations USING btree (topic_id, parent_id, sort_order);

CREATE OR REPLACE FUNCTION public.consume_api_quota(p_key text, p_limit integer, p_window_seconds integer)
 RETURNS TABLE(allowed boolean, retry_after integer)
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
declare counter public.api_rate_limits%rowtype;
begin
  if p_limit < 1 or p_window_seconds < 1 or length(p_key) <> 64 then raise exception 'invalid quota'; end if;
  insert into public.api_rate_limits as r(key_hash,window_started_at,hits,expires_at)
  values(p_key,clock_timestamp(),1,clock_timestamp()+make_interval(secs=>p_window_seconds))
  on conflict(key_hash) do update set
    hits=case when r.expires_at <= clock_timestamp() then 1 else r.hits+1 end,
    window_started_at=case when r.expires_at <= clock_timestamp() then clock_timestamp() else r.window_started_at end,
    expires_at=case when r.expires_at <= clock_timestamp() then clock_timestamp()+make_interval(secs=>p_window_seconds) else r.expires_at end
  returning * into counter;
  return query select counter.hits<=p_limit,greatest(1,ceil(extract(epoch from (counter.expires_at-clock_timestamp())))::integer);
end; $function$
;
REVOKE ALL ON FUNCTION consume_api_quota(text,integer,integer) FROM PUBLIC, anon, authenticated;
CREATE OR REPLACE FUNCTION public.gemini_circuit_event(p_scope text, p_model text, p_event text, p_generation bigint DEFAULT NULL::bigint, p_status integer DEFAULT NULL::integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
declare
  h public.gemini_model_health%rowtype;
  t timestamptz := clock_timestamp();
  allowed boolean := false;
begin
  if p_event not in ('claim', 'success', 'failure') then
    raise exception 'Invalid circuit event';
  end if;
  insert into public.gemini_model_health(scope, model) values(p_scope, p_model)
    on conflict (scope, model) do nothing;
  select * into h from public.gemini_model_health
    where scope = p_scope and model = p_model for update;
  if p_event = 'claim' then
    if h.open_until is null then
      allowed := true;
    elsif h.open_until <= t and (h.probe_until is null or h.probe_until <= t) then
      h.generation := h.generation + 1;
      h.probe_until := t + interval '90 seconds';
      allowed := true;
    end if;
  elsif p_generation = h.generation then
    if p_event = 'success' and (h.open_until is null or h.probe_until is not null) then
      if h.probe_until is not null then h.generation := h.generation + 1; end if;
      h.failures := 0;
      h.open_until := null;
      h.probe_until := null;
      h.last_status := null;
    elsif p_event = 'failure' and (h.open_until is null or h.probe_until is not null) then
      h.failures := h.failures + 1;
      h.last_status := p_status;
      if h.failures >= 5 or h.probe_until is not null then
        h.open_until := t + interval '5 minutes';
        h.probe_until := null;
        h.generation := h.generation + 1;
      end if;
    end if;
  end if;
  update public.gemini_model_health set failures = h.failures,
    generation = h.generation, open_until = h.open_until,
    probe_until = h.probe_until, last_status = h.last_status, updated_at = t
    where scope = p_scope and model = p_model;
  return jsonb_build_object('allowed', allowed, 'generation', h.generation,
    'failures', h.failures, 'openUntil', h.open_until,
    'retryAfter', case when h.open_until is null then 0
      else greatest(1, ceil(extract(epoch from (greatest(h.open_until, coalesce(h.probe_until, h.open_until)) - t)))::integer) end);
end;
$function$
;
REVOKE ALL ON FUNCTION gemini_circuit_event(text,text,text,bigint,integer) FROM PUBLIC, anon, authenticated;
CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  insert into public.profiles (id, display_name, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'display_name', new.raw_user_meta_data ->> 'full_name'),
    new.raw_user_meta_data ->> 'avatar_url'
  ) on conflict (id) do nothing;
  return new;
end;
$function$
;
REVOKE ALL ON FUNCTION handle_new_user() FROM PUBLIC, anon, authenticated;
CREATE OR REPLACE FUNCTION public.set_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
begin
  new.updated_at = now();
  return new;
end;
$function$
;
REVOKE ALL ON FUNCTION set_updated_at() FROM PUBLIC, anon, authenticated;
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION handle_new_user();
CREATE TRIGGER analyses_updated_at BEFORE UPDATE ON public.analyses FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER chunks_updated_at BEFORE UPDATE ON public.analysis_chunks FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER inputs_updated_at BEFORE UPDATE ON public.analysis_inputs FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER prompts_updated_at BEFORE UPDATE ON public.prompt_templates FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER quizzes_updated_at BEFORE UPDATE ON public.quizzes FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER specializations_updated_at BEFORE UPDATE ON public.topic_specializations FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER topics_updated_at BEFORE UPDATE ON public.topics FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER validation_rules_updated_at BEFORE UPDATE ON public.validation_rules FOR EACH ROW EXECUTE FUNCTION set_updated_at();
GRANT EXECUTE ON FUNCTION public.consume_api_quota(text,integer,integer), public.gemini_circuit_event(text,text,text,bigint,integer) TO service_role;
INSERT INTO storage.buckets(id,name,public,file_size_limit,allowed_mime_types) VALUES('analysis-assets','analysis-assets',false,10485760,ARRAY['image/svg+xml','image/png','image/jpeg','image/webp']) ON CONFLICT(id) DO NOTHING;
INSERT INTO storage.buckets(id,name,public,file_size_limit,allowed_mime_types) VALUES('analysis-exports','analysis-exports',false,20971520,ARRAY['text/markdown','text/html','application/vnd.openxmlformats-officedocument.wordprocessingml.document','application/zip','application/json','application/pdf']) ON CONFLICT(id) DO NOTHING;
INSERT INTO storage.buckets(id,name,public,file_size_limit,allowed_mime_types) VALUES('analysis-inputs','analysis-inputs',false,20971520,ARRAY['application/pdf','application/vnd.openxmlformats-officedocument.wordprocessingml.document','text/plain','image/png','image/jpeg']) ON CONFLICT(id) DO NOTHING;
NOTIFY pgrst, 'reload schema';

ALTER TABLE public.analyses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analysis_activity ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analysis_chunks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analysis_inputs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analysis_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.api_rate_limits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gemini_model_health ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.generated_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.llm_exchanges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prompt_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.topic_specializations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.validation_rules ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON public.analyses, public.analysis_activity, public.analysis_chunks, public.analysis_inputs, public.analysis_results, public.api_rate_limits, public.chat_messages, public.exports, public.gemini_model_health, public.generated_assets, public.llm_exchanges, public.profiles, public.prompt_templates, public.quiz_attempts, public.quiz_questions, public.quizzes, public.topic_specializations, public.topics, public.validation_rules FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.analyses, public.analysis_activity, public.analysis_chunks, public.analysis_inputs, public.analysis_results, public.api_rate_limits, public.chat_messages, public.exports, public.gemini_model_health, public.generated_assets, public.llm_exchanges, public.profiles, public.prompt_templates, public.quiz_attempts, public.quiz_questions, public.quizzes, public.topic_specializations, public.topics, public.validation_rules TO service_role;
GRANT USAGE ON SCHEMA public TO service_role;
COMMIT;
