# DocuMind

## Chạy local

- Node.js 22 trở lên; chạy `npm ci`.
- Copy `app.properties.example` thành `app.properties`, điền Supabase URL, public key và service role key.
- Chạy `npm run dev`.
- Kiểm tra: `npm run lint`, `npm run typecheck`, `npm run build`.

## Đã tích hợp

Đăng ký, hồ sơ, danh mục IT, phiên phân tích, lưu bản gốc trong Storage private, URL bản gốc có hạn 600 giây, quota, nhật ký và thống kê API.

Các module đọc tài liệu, phân tích AI, quiz, chat và xuất báo cáo sẽ được tích hợp theo phân công. Test giữ ở local; không đưa khóa thật lên Git.
