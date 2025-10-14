# Test Plan

## Mục tiêu
- Xác minh concurrent bidding và broadcast hoạt động đúng
- Đảm bảo Lock bảo vệ giá cao nhất, không race condition
- Kiểm thử kết thúc phiên bằng timer

## Phạm vi
- Server multi-client
- Client console/GUI
- Giao thức JSON

## Kịch bản chính
- Bid hợp lệ: NEW_PRICE broadcast tới tất cả
- Bid thấp hơn: trả về ERROR cho client
- Nhiều clients bid gần như đồng thời: chỉ một bid cao nhất được chấp nhận theo thứ tự xử lý có lock
- Hết giờ: phát WINNER và không nhận thêm bid

## Hiệu năng (tùy chọn)
- Mô phỏng nhiều clients đồng thời (script tại infra/)

## Tiêu chí pass/fail
- Không lỗi runtime khi nhiều client kết nối/ngắt kết nối
- Tất cả thông điệp theo JSON schema
- Không rò rỉ tài nguyên (socket/threads)
