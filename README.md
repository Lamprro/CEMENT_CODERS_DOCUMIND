# DocuMind

DocuMind là không gian học tập từ tài liệu: đọc nội dung, kiểm tra bản trích xuất, phân tích bằng AI, tạo quiz, hỏi đáp theo nguồn và xuất báo cáo. Người dùng có thể làm việc với tư cách khách hoặc đăng nhập để quản lý lịch sử theo tài khoản.

[Ứng dụng](https://cement-coders-documind.vercel.app/) · [Mã nguồn](https://github.com/Lamprro/CEMENT_CODERS_DOCUMIND)

## Chức năng

- Nhận PDF, Word `.docx`, văn bản, mã nguồn, CSV và ảnh PNG/JPEG.
- Đọc tài liệu theo từng bước có checkpoint để tiếp tục khi yêu cầu bị gián đoạn.
- Xem và sửa nội dung trích xuất trước khi xác nhận phân tích.
- Tự nhận diện chủ đề; hỗ trợ danh mục IT và chuyên ngành, dùng prompt chung cho nội dung khác.
- Phân tích theo mức Nhanh, Tiêu chuẩn hoặc Chuyên sâu; hiển thị tổng quan và từng mục chi tiết.
- Tạo quiz trắc nghiệm hoặc đúng/sai, chọn độ khó, chấm điểm trên máy chủ và lưu lượt làm bài.
- Hỏi đáp theo tài liệu, kèm căn cứ và lịch sử hội thoại.
- Lưu ảnh công thức, sơ đồ và xuất PDF, DOCX, HTML, JSON hoặc Markdown ZIP.
- Theo dõi tiến độ, hoạt động xử lý và thống kê các lần gọi AI.

## Công nghệ

| Thành phần | Công nghệ |
| --- | --- |
| Giao diện và API | Next.js 15.5.26, React 19.3.0, TypeScript |
| Database, tài khoản, lưu tệp | Supabase PostgreSQL, Auth, Storage |
| AI | Gemini; chế độ `mock` cho demo |
| Đọc tài liệu | `pdf-lib`, `mammoth`, parser văn bản và CSV |
| Ảnh công thức và sơ đồ | MathJax, Mermaid, Resvg, Sharp |
| Xuất báo cáo | PDFKit, `docx`, JSZip |
| Triển khai | Vercel, tích hợp GitHub |

## Luồng sử dụng

1. Tải tệp hoặc dán văn bản, chọn yêu cầu phân tích và cấu hình quiz.
2. Bấm **Kiểm tra tài liệu** để đọc nguồn và xem nội dung đã trích xuất.
3. Kiểm tra, chỉnh sửa nội dung và chủ đề nếu cần.
4. Xác nhận để bắt đầu phân tích AI.
5. Xem kết quả, làm quiz, hỏi đáp hoặc tải báo cáo.

Việc đọc ảnh/PDF có thể gọi Gemini ngay ở bước kiểm tra tài liệu. Bước xác nhận phía sau dùng để bắt đầu phân tích nội dung và tạo quiz.

### Cách đọc từng loại đầu vào

| Đầu vào | Xử lý trước khi phân tích |
| --- | --- |
| Văn bản dán, TXT, Markdown, JSON, XML, YAML, HTML, mã nguồn | Code đọc và chuẩn hóa văn bản. |
| CSV | Code parse dữ liệu thành bảng. |
| Word `.docx` | Code đọc chữ và bảng; ảnh nhúng, Office Math, sơ đồ/SmartArt/biểu đồ được gửi AI xử lý. |
| PDF với `LLM_PROVIDER=gemini` | Code tách từng trang, gửi mỗi trang PDF cho Gemini đọc chữ, bảng, công thức và sơ đồ. |
| PNG, JPG, JPEG | Gửi ảnh cho Gemini nhận diện nội dung. |

Word được ghép lại theo thứ tự khối nguồn, kể cả khi các khối xử lý song song. Thứ tự đọc được giữ; bố cục và tọa độ của trang gốc không được tái tạo nguyên vẹn. Ảnh trang trí được phân loại để bỏ qua khỏi nội dung kiến thức.

PDF ở chế độ `mock` chỉ đọc lớp chữ bằng `pdf-parse` hoặc trả nội dung demo. Markdown/HTML chứa đường dẫn ảnh được đọc như văn bản; hệ thống chưa tự tải ảnh ở các đường dẫn đó. Word `.doc` cũ cần chuyển sang `.docx` hoặc PDF.

## Cài đặt tại máy

### Yêu cầu

- Node.js **22 trở lên**; có thể dùng Node.js **24.x** đồng nhất với môi trường Vercel.
- npm và Git.
- Một project Supabase đã có cấu trúc DocuMind.
- Gemini API key nếu dùng AI thật.

### Lấy mã nguồn và cài thư viện

```bash
git clone https://github.com/Lamprro/CEMENT_CODERS_DOCUMIND.git
cd CEMENT_CODERS_DOCUMIND
npm ci
```

### Cấu hình

Tạo `app.properties` từ [app.properties.example](app.properties.example). Với PowerShell:

```powershell
Copy-Item app.properties.example app.properties
```

Điền các biến ở mục bên dưới. Có thể dùng `.env.local` theo định dạng `KEY=value` thay cho `app.properties`. Biến đã có trong môi trường chạy được ưu tiên; bộ nạp `app.properties` chỉ bổ sung biến chưa được đặt.

```bash
npm run dev
```

Mở [http://localhost:3000](http://localhost:3000). Sau khi đổi cấu hình, khởi động lại ứng dụng.

## Biến môi trường

### Cấu hình chính

| Biến | Cách cấu hình |
| --- | --- |
| `NEXT_PUBLIC_SUPABASE_URL` | Project URL của Supabase. |
| `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` | Publishable key dùng cho trình duyệt. |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Legacy anon key, dùng khi không cấu hình publishable key. Chỉ cần một trong hai khóa công khai. |
| `SUPABASE_SERVICE_ROLE_KEY` | Service role key dùng riêng ở máy chủ cho database và Storage. |
| `LLM_PROVIDER` | `gemini` để gọi AI thật; `mock` để chạy demo. File mẫu mặc định là `mock`. |
| `GEMINI_API_KEY` | API key từ Google AI Studio; bắt buộc khi dùng `gemini`. |
| `CRON_SECRET` | Chuỗi ngẫu nhiên dùng xác thực tác vụ dọn dữ liệu. Cần cấu hình khi triển khai cron trên Vercel. |

Lấy URL và khóa trong phần cấu hình project Supabase. Service role key không được đặt vào biến có tiền tố `NEXT_PUBLIC_`. Xem [hướng dẫn API keys của Supabase](https://supabase.com/docs/guides/getting-started/api-keys).

Tạo `CRON_SECRET` bằng Node.js rồi điền kết quả vào cấu hình:

```bash
node -e "console.log(require('node:crypto').randomBytes(32).toString('hex'))"
```

### Tùy chọn xử lý

| Biến | Mặc định | Ý nghĩa |
| --- | --- | --- |
| `GEMINI_MODEL` | Trống | Ưu tiên một model cụ thể; để trống để dùng cơ chế chọn model của hệ thống. |
| `GEMINI_FALLBACK_MODELS` | Trống | Các model dự phòng, phân cách bằng dấu phẩy. |
| `LLM_CONCURRENCY` | `3` | Mức xử lý song song; bước đọc tài liệu giới hạn tối đa 4. |
| `GUEST_SESSION_TTL_HOURS` | `24` | Thời gian tồn tại của phiên khách. |
| `MAX_UPLOAD_MB` | `20` | Giới hạn tệp ở bước trích xuất phía máy chủ, tính bằng MB. |
| `MAX_VISION_MB` | `8` | Giới hạn mỗi trang hoặc ảnh gửi Vision, tính bằng MB. |
| `MAX_PDF_PAGES` | `200` | Số trang PDF tối đa. |
| `MAX_EXTRACTED_MEDIA_MB` | `64` | Tổng dữ liệu ảnh nhúng được trích xuất từ Word, tính bằng MB. |
| `MAX_ANALYSIS_CHARS` | `500000` | Giới hạn nội dung sau trích xuất. |
| `MAX_CHUNK_CHARS` | `12000` | Kích thước khối văn bản khi chia tài liệu. |
| `MIN_MAJOR_SECTION_CHARS` | `2500` | Ngưỡng chia theo mục lớn của tài liệu. |
| `CHUNK_OVERLAP_CHARS` | `500` | Số ký tự chồng lấn giữa các khối khi cần. |
| `LLM_LOG_CONTENT` | `false` | Bật `true` để lưu nội dung request/response AI trong log. |
| `LLM_LOG_RETENTION_DAYS` | `30` | Thời gian giữ log trước khi cron dọn dữ liệu. |

Giao diện và API tạo phiên hiện giới hạn **10 tệp, 20 MB mỗi tệp và 500.000 ký tự văn bản dán** trong [src/lib/limits.ts](src/lib/limits.ts). Nếu thay đổi giới hạn tải lên, cần đồng bộ code kiểm tra đầu vào và cấu hình Storage; chỉ đổi `MAX_UPLOAD_MB` chưa thay đổi tất cả các lớp kiểm tra.

Không commit `app.properties`, `.env`, `.env.local` hoặc khóa thật. Các file cấu hình riêng đã được loại khỏi Git bằng `.gitignore`.

## Database và Storage

### Khởi tạo Supabase mới

Trong SQL Editor của một project Supabase mới, chạy lần lượt:

1. [database/01_create_tables.sql](database/01_create_tables.sql): tạo 19 bảng, quan hệ, chỉ mục, quyền truy cập, các hàm/trigger cần cho runtime và 3 bucket private.
2. [database/02_seed.sql](database/02_seed.sql): thêm dữ liệu danh mục và prompt từ dự án mẫu.

File seed gồm **1 chủ đề IT, 73 chuyên ngành, 43 prompt và 7 quy tắc kiểm tra**. Chạy lại trên database vừa khởi tạo sẽ bỏ qua các ID đã có. File không tạo tài khoản mẫu hoặc sao chép tài liệu của người dùng.

`01_create_tables.sql` dành cho database mới chưa có bảng DocuMind. Với database đang hoạt động, cần cập nhật cấu trúc theo thay đổi cụ thể thay vì chạy lại toàn bộ file tạo bảng. Supabase quản lý sẵn các schema `auth` và `storage`; hai file này sử dụng chúng.

### Nhóm bảng

| Nhóm | Bảng |
| --- | --- |
| Hồ sơ | `profiles` |
| Danh mục và cấu hình | `topics`, `topic_specializations`, `prompt_templates`, `validation_rules` |
| Phân tích | `analyses`, `analysis_inputs`, `analysis_chunks`, `analysis_results`, `analysis_activity` |
| Ảnh và xuất file | `generated_assets`, `exports` |
| Quiz | `quizzes`, `quiz_questions`, `quiz_attempts` |
| Hội thoại và log | `chat_messages`, `llm_exchanges` |
| Kiểm soát runtime | `api_rate_limits`, `gemini_model_health` |

Backend kiểm tra quyền sở hữu phiên trước khi truy cập dữ liệu bằng service role. Các bảng khởi tạo có RLS và không cấp quyền đọc/ghi trực tiếp cho client; việc thao tác dữ liệu đi qua API của ứng dụng.

### Lưu tệp

| Bucket private | Nội dung |
| --- | --- |
| `analysis-inputs` | Tệp đầu vào và văn bản nguồn. |
| `analysis-assets` | Ảnh công thức và sơ đồ đã dựng. |
| `analysis-exports` | Báo cáo đã xuất. |

Upload từ giao diện dùng signed upload URL tới Supabase Storage. Liên kết xem ảnh và tải báo cáo có thời hạn; hệ thống tạo lại liên kết khi cần.

### Cấu hình đăng nhập

Trong Supabase Auth, bật phương thức email/password và cấu hình URL:

- Local: `http://localhost:3000` và callback `http://localhost:3000/auth/callback`.
- Production: Site URL là domain ứng dụng; thêm `https://<domain>/auth/callback` vào Redirect URLs.
- Preview: bổ sung URL callback của môi trường preview nếu cần kiểm tra đăng nhập ở đó.

Nếu bật xác nhận email, người dùng cần xác nhận trước khi đăng nhập. Xem [hướng dẫn Redirect URLs](https://supabase.com/docs/guides/auth/redirect-urls).

## Quiz và xuất báo cáo

Quiz mặc định **20 câu**, tối thiểu **1 câu**. Giao diện không đặt trần số câu cố định; AI tạo tối đa 20 câu mỗi đợt trên từng phần nguồn. Số câu thực tế có thể thấp hơn yêu cầu nếu nguồn thiếu thông tin, câu bị trùng hoặc không đạt cấu hình độ khó/loại câu. Hệ thống lưu số lượng còn thiếu và thông báo trên giao diện.

Công thức và sơ đồ được dựng thành PNG, lưu vào Storage trước khi hoàn tất phân tích. Khi mở kết quả cũ, hệ thống thử bổ sung các ảnh còn thiếu. Bước xuất báo cáo chỉ lấy ảnh đã lưu; nếu ảnh chưa sẵn sàng, yêu cầu xuất được dừng để tránh thiếu nội dung.

| Định dạng | Nội dung xuất |
| --- | --- |
| PDF | Văn bản, bảng và ảnh công thức/sơ đồ được nhúng trong PDF. |
| DOCX | Tài liệu Word có văn bản, bảng và ảnh đã chuẩn bị. |
| HTML | Trang HTML có ảnh PNG nhúng, không cần dựng lại công thức khi mở. |
| Markdown | File ZIP gồm `report.md` và thư mục `images`; giải nén toàn bộ trước khi mở. |
| JSON | Dữ liệu có cấu trúc, giữ mã nguồn LaTeX/Mermaid và không yêu cầu dựng ảnh. |

PlantUML chưa có bộ dựng ảnh phía máy chủ; cần chuyển thành Mermaid trước khi xuất định dạng cần ảnh. Mã công thức/sơ đồ không hợp lệ cần được xử lý lại trước khi xuất.

## Triển khai Vercel

1. Import repository GitHub vào Vercel.
2. Chọn **Framework Preset: Next.js**, thư mục chứa `package.json` làm **Root Directory**.
3. Đặt **Production Branch: `main`**, Node.js **24.x** và bật **Fluid Compute** cho các tác vụ AI.
4. Dùng **Install Command: `npm ci`**, **Build Command: `npm run build`**; giữ Output Directory theo mặc định của Next.js.
5. Nhập các biến cấu hình trong **Environment Variables**, chọn `LLM_PROVIDER=gemini` nếu dùng AI thật. Cấu hình Production và Preview theo nhu cầu.
6. Deploy, cập nhật Supabase Auth bằng domain mới, rồi kiểm tra đăng nhập và một phiên phân tích.

Có thể import file `.env` vào phần Environment Variables; không cần đưa file chứa khóa lên GitHub. Sau khi thay đổi biến của một deployment đã có, cần deploy lại để áp dụng. Xem [Environment Variables](https://vercel.com/docs/environment-variables).

### Tự động build và deploy

Sau khi liên kết GitHub và chọn `main` làm nhánh Production:

- Push hoặc merge vào `main` sẽ kích hoạt build và deploy Production.
- Các nhánh khác tạo Preview deployment để kiểm tra trước khi merge.
- Nếu build thất bại, xem Build Logs để sửa nguyên nhân trước khi triển khai lại.

Tích hợp Git của Vercel đã xử lý luồng này; repository không cần workflow GitHub Actions riêng cho việc deploy. Xem [Deploying Git Repositories](https://vercel.com/docs/git).

Push file SQL lên GitHub **không tự thực thi SQL trong Supabase**. Việc cập nhật database được thực hiện riêng với thay đổi đã kiểm tra.

### Cron dọn dữ liệu

[vercel.json](vercel.json) cấu hình `GET /api/cron/cleanup` chạy hằng ngày lúc **00:00 UTC, tức 07:00 giờ Việt Nam**.

Cron xác thực bằng header `Authorization: Bearer <CRON_SECRET>`, dọn phiên hết hạn cùng tệp liên quan, log AI quá thời gian lưu và bản ghi hạn mức đã hết hạn. Local không tự chạy lịch cron của Vercel.

## Lệnh phát triển

| Lệnh | Mục đích |
| --- | --- |
| `npm ci` | Cài đúng phiên bản theo `package-lock.json`. |
| `npm run dev` | Chạy môi trường phát triển. |
| `npm run lint` | Kiểm tra quy tắc code. |
| `npm run typecheck` | Kiểm tra TypeScript. |
| `npm run build` | Build production. |
| `npm start` | Chạy bản production sau khi build. |

Trước khi đưa thay đổi vào `main`, chạy lint, typecheck và build, sau đó kiểm tra luồng bị ảnh hưởng. Giữ các file kiểm tra tạm tại máy; không đưa dữ liệu người dùng, khóa hoặc file sinh tự động vào commit.

## Cấu trúc thư mục

```text
database/              Hai file SQL tạo cấu trúc và dữ liệu mẫu
public/fonts/          Font dùng cho giao diện và báo cáo
src/app/               Trang Next.js và các API route
src/components/        Thành phần giao diện
src/hooks/             Điều phối workspace, tiến độ và phiên làm việc
src/lib/               Đọc tài liệu, AI, database, quiz và xuất báo cáo
app.properties.example Mẫu cấu hình local
next.config.mjs        Nạp cấu hình và đóng gói thư viện phía máy chủ
vercel.json            Lịch cron Vercel
```

## Xử lý lỗi thường gặp

| Hiện tượng | Kiểm tra |
| --- | --- |
| Ứng dụng đang chạy demo | Kiểm tra `LLM_PROVIDER`; file mẫu mặc định `mock`. |
| Không đăng nhập được | URL/khóa công khai Supabase, trạng thái xác nhận email và Redirect URLs. |
| Báo thiếu bảng, hàm hoặc prompt | Database phải có đủ cấu trúc và seed; kiểm tra `consume_api_quota`, `gemini_circuit_event` và các prompt chung. |
| Gemini báo hạn mức hoặc tạm thời không sẵn sàng | Kiểm tra quota của API key và cấu hình model. Hệ thống có checkpoint và model dự phòng; tiếp tục phiên khi dịch vụ hoạt động trở lại. |
| Tệp quá lớn hoặc PDF quá nhiều trang | Giảm kích thước hoặc chia tài liệu; kiểm tra giới hạn file, trang và từng đơn vị Vision. |
| Xuất báo cáo báo ảnh chưa sẵn sàng | Mở lại kết quả để bổ sung ảnh, kiểm tra công thức/sơ đồ chưa dựng được rồi thử xuất lại. |
| Phiên khách hết hạn | Mặc định 24 giờ; đăng nhập để quản lý phiên theo tài khoản. |
| Vercel chưa nhận cấu hình mới | Kiểm tra biến đúng môi trường và deploy lại. |

`GET /api/health` trả trạng thái API, provider và giới hạn đầu vào. Để kiểm tra đầy đủ kết nối database, Storage và Gemini, cần thực hiện một phiên từ tải nguồn đến xuất báo cáo.
