# 🎯 HƯỚNG DẪN CHẠY SIMPLE AUCTION GAME

## 📋 Mục Lục
1. [Kiểm tra môi trường](#1-kiểm-tra-môi-trường)
2. [Chạy Server](#2-chạy-server)
3. [Chạy Clients](#3-chạy-clients)
4. [Test kịch bản](#4-test-kịch-bản)
5. [Troubleshooting](#5-troubleshooting)

---

## 1. Kiểm tra môi trường

### Yêu cầu
- Python 3.x (3.7 trở lên)
- Windows PowerShell / Command Prompt / Terminal

### Kiểm tra Python
```powershell
python --version
```

Nếu chưa có Python, tải tại: https://www.python.org/downloads/

---

## 2. Chạy Server

### Bước 1: Mở Terminal trong VS Code

### Bước 2: Di chuyển đến thư mục server
```powershell
cd AUCTION_PROJECT_MIDTERM\server
```

### Bước 3: Chạy server
```powershell
python main_server.py
```

### Kết quả mong đợi
```
============================================================
🎯 SIMPLE AUCTION GAME - SERVER
============================================================
[INIT] Khởi tạo Auction State...
[AUCTION] Khởi tạo phiên đấu giá - Giá khởi điểm: $1000
[INIT] Khởi tạo Auction Hub...
[SERVER] Đang lắng nghe tại 0.0.0.0:9999
[SERVER] Thời gian đấu giá: 120 giây
------------------------------------------------------------
[TIMER] Khởi động timer thread...
[TIMER] Timer đã bắt đầu đếm ngược 120 giây
[TIMER] Bắt đầu đếm ngược 120 giây...
------------------------------------------------------------
[SERVER] Sẵn sàng chấp nhận clients...
[SERVER] Nhấn Ctrl+C để dừng server
```

**✅ Server đang chạy và sẵn sàng!**

---

## 3. Chạy Clients

### Mở nhiều Terminals cho nhiều Clients

#### Cách 1: Sử dụng VS Code
1. Nhấn `Ctrl + Shift + P`
2. Gõ "Terminal: Split Terminal" hoặc click icon `+` dropdown > `Split Terminal`
3. Hoặc đơn giản: Click vào icon `+` để tạo terminal mới

#### Cách 2: PowerShell Script (Mở nhiều cửa sổ)
```powershell
# Mở 3 clients cùng lúc
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; python client\client_main.py"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; python client\client_main.py"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; python client\client_main.py"
```

### Chạy từng Client

#### Terminal 1 (Client 1)
```powershell
cd AUCTION_PROJECT_MIDTERM
python client/client_main.py
```

Nhập thông tin:

---

## 5. Troubleshooting

### Lỗi: "Address already in use"

**Nguyên nhân:** Server vẫn đang chạy ở process khác

**Giải pháp PowerShell:**
```powershell
# Tìm process đang sử dụng port 9999
netstat -ano | findstr :9999

# Kill process (thay <PID> bằng số PID tìm được)
taskkill /PID <PID> /F
```

**Hoặc đổi port:**
Sửa trong `main_server.py`:
```python
PORT = 9998  # Đổi sang port khác
```

### Lỗi: "Connection refused"

**Kiểm tra:**
1. Server đã chạy chưa?
2. IP và Port đúng chưa?
3. Firewall có chặn không?

**Giải pháp:**
```powershell
# Tắt Windows Firewall tạm thời (nếu test local)
# Hoặc thêm exception cho Python
```

### Lỗi: "ModuleNotFoundError"

**Kiểm tra:**
```powershell
# Đảm bảo đang ở đúng thư mục
pwd
# Kết quả phải là: ...\AUCTION_PROJECT_MIDTERM\server hoặc ...\AUCTION_PROJECT_MIDTERM
```




## 📝 Lưu ý cho nhóm

1. **Người 1 (Backend Core):** Đã hoàn thành ✅
   - `main_server.py` - Listener và Accept loop
   - `client_thread.py` - Thread handler cho mỗi client

2. **Người 2 (Logic & Sync):** Đã hoàn thành ✅
   - `auction_logic.py` - State management + Lock
   - `auction_hub.py` - Client list + Broadcast

3. **Người 3 (Client Logic):** Đã hoàn thành ✅
   - `client_main.py` - Connection + I/O

4. **Người 4 (Timer):** Đã hoàn thành ✅
   - `timer_thread.py` - Countdown timer
   - (UI nâng cao có thể thêm Tkinter sau)

5. **Người 5 (Test & Docs):** Cần làm
   - Load testing script
   - Documentation
   - Git management

---

## 🚀 Chạy nhanh (Quick Start)

### PowerShell Script
Tạo file `run_demo.ps1`:

```powershell
# Chạy server trong background
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\AUCTION_PROJECT_MIDTERM\server'; python main_server.py"

# Đợi server khởi động
Start-Sleep -Seconds 2

# Chạy 3 clients
1..3 | ForEach-Object {
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\AUCTION_PROJECT_MIDTERM'; python client/client_main.py"
    Start-Sleep -Milliseconds 500
}

Write-Host "✅ Server và 3 clients đã được khởi động!"
```

Chạy:
```powershell
.\run_demo.ps1
```

---

**🎉 Chúc bạn demo thành công!**
