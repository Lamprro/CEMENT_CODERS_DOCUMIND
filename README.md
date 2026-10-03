# DocuMind

## Chạy local

- Node.js 22 trở lên; chạy `npm ci`.
- Copy `app.properties.example` thành `app.properties`, điền Supabase và Gemini.
- Chạy `npm run dev`.
- Kiểm tra: `npm run lint`, `npm run typecheck`, `npm run build`.

## Chức năng

Đăng ký/đăng nhập, đọc tài liệu theo checkpoint, duyệt và sửa đầu vào, phân tích AI, chat theo nguồn, quiz và chấm điểm, lịch sử phiên, xuất PDF/DOCX/Markdown ZIP/HTML/JSON. File và ảnh lưu trong Supabase Storage private.

## Vercel

- Import repository, nhánh production `main`, framework Next.js, thư mục gốc repository.
- Install: `npm ci`; build: `npm run build`; Node.js 24.x; bật Fluid Compute.
- Thêm biến trong Vercel Environment Variables: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` (hoặc anon key), `SUPABASE_SERVICE_ROLE_KEY`, `LLM_PROVIDER=gemini`, `GEMINI_API_KEY`, `CRON_SECRET`.
- `GEMINI_MODEL` và `GEMINI_FALLBACK_MODELS` tùy chọn; không đặt sẽ lọc model từ catalog Gemini.
- Supabase Auth: cập nhật Site URL và Redirect URL `https://<domain>/auth/callback`.
- Cron dọn phiên hết hạn chạy hằng ngày lúc 00:00 UTC (07:00 Việt Nam); xác thực bằng `CRON_SECRET`.
- Upload từ giao diện dùng signed URL tới Storage; không chuyển file lớn qua Vercel Functions.

Test giữ ở local. Không đưa `app.properties`, khóa thật hoặc SQL vào Git.
