Simple Auction Game (Multi Client-Server)
=========================================

Mục tiêu
--------
Triển khai mô hình Multi Client-Server dùng Socket (Python) để chứng minh concurrency và truyền tin realtime (Broadcast). Server quản lý giá cao nhất và người đặt giá; Client tương tác qua giao thức JSON.

Công nghệ
---------
- Python 3.x (Windows/macOS/Linux)
- Server: socket, threading, json (thuộc Python stdlib)
- Client: socket, json, sys (Console) hoặc tkinter (GUI)
- Git để quản lý mã nguồn

Cấu trúc thư mục
----------------
```
AUCTION_PROJECT_MIDTERM/
├── .vscode/
│   ├── launch.json
│   └── tasks.json
├── .gitignore
├── requirements.txt
├── README.md
├── server/
│   ├── main_server.py         # Listener & accept loop (Người 1)
│   ├── auction_hub.py         # Client list & broadcast (Người 1,2)
│   ├── client_thread.py       # Client handler thread (Người 1)
│   ├── auction_logic.py       # Highest price + Lock (Người 2)
│   └── timer_thread.py        # Auction countdown (Người 4)
├── client/
│   ├── client_main.py         # Client connection & I/O (Người 3)
│   └── client_ui.py           # Console/Tkinter UI (Người 4)
├── docs/
│   ├── architecture.md
│   ├── sequence_diagram.png
│   └── test_plan.md
└── infra/
    └── load_test_script.py
```

Vai trò phân công
-----------------
- Người 1: Backend Core (Listener)
- Người 2: Logic & Sync (Hub)
- Người 3: Client Logic & I/O
- Người 4: Frontend (UI) & Timer
- Người 5: Test, Docs & Git

Giao thức JSON (schema tham khảo)
---------------------------------
- BID (Client -> Server):
  - Ví dụ: {"type": "BID", "user": "An", "value": 1500}
- NEW_PRICE (Server -> All Clients, broadcast):
  - Ví dụ: {"type": "NEW_PRICE", "user": "Binh", "value": 1600}
- ERROR (Server -> Client):
  - Ví dụ: {"type": "ERROR", "message": "Giá phải lớn hơn 1600"}
- WINNER (Server -> All Clients):
  - Ví dụ: {"type": "WINNER", "user": "Binh", "value": 2000}

Yêu cầu kỹ thuật cốt lõi
------------------------
- Multi-threading: mỗi client một thread riêng trong `client_thread.py`.
- Lock/Mutex: bảo vệ biến Giá Cao Nhất + Tên người bid trong `auction_logic.py`.
- Broadcast: `auction_hub.py` giữ danh sách socket hoạt động và phát `NEW_PRICE`.
- Timer: `timer_thread.py` đếm ngược, phát `WINNER` khi hết giờ.

Thiết lập môi trường
--------------------
1) Cài Python 3.x.
2) Tạo môi trường ảo (tuỳ chọn) và cài dependencies nếu thêm vào `requirements.txt`.
3) Các file mã nguồn hiện đang trống để nhóm tự triển khai.

Chạy (sau khi nhóm bổ sung code)
--------------------------------
- VS Code Debug:
  - Server: Run config "Python: Run Server (main_server.py)".
  - Client: Run config "Python: Run Client (client_main.py)" (mở nhiều terminal để chạy nhiều client).
- VS Code Tasks: Terminal > Run Task > Run Server / Run Client.

Gợi ý dependencies (tuỳ chọn ghi vào requirements.txt)
------------------------------------------------------
- pytest (unit test), black/flake8 (format/lint)
- tkinter (nếu cần GUI; trên Windows/macOS thường có sẵn)

Ghi chú Git
-----------
- Không tạo nested repo. Dự án nằm trong repo hiện tại. Commit thay đổi từ root repo (`Simple-Auction-Game`).
