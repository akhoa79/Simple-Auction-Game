# Demo Script - Simple Auction Game
# Tu dong khoi dong server va 3 clients

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "SIMPLE AUCTION GAME - AUTO DEMO LAUNCHER" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Lay duong dan hien tai
$projectPath = $PSScriptRoot

Write-Host "Project path: $projectPath" -ForegroundColor Yellow
Write-Host ""

# Kiem tra Python
Write-Host "Kiem tra Python..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    Write-Host "Python version: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "Python khong duoc cai dat!" -ForegroundColor Red
    Write-Host "Vui long cai Python tu https://www.python.org/downloads/" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Kiem tra files ton tai
Write-Host "Kiem tra files..." -ForegroundColor Yellow
$serverFile = "$projectPath\server\main_server.py"
$clientFile = "$projectPath\client\client_main.py"

if (Test-Path $serverFile) {
    Write-Host "Server file ton tai" -ForegroundColor Green
} else {
    Write-Host "Khong tim thay server file: $serverFile" -ForegroundColor Red
    exit 1
}

if (Test-Path $clientFile) {
    Write-Host "Client file ton tai" -ForegroundColor Green
} else {
    Write-Host "Khong tim thay client file: $clientFile" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Hoi nguoi dung
Write-Host "San sang khoi dong demo!" -ForegroundColor Green
Write-Host ""
Write-Host "Se mo:" -ForegroundColor Yellow
Write-Host "  - 1 cua so Server" -ForegroundColor White
Write-Host "  - 3 cua so Clients" -ForegroundColor White
Write-Host ""
$confirm = Read-Host "Tiep tuc? (Y/N)"

if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "Da huy" -ForegroundColor Red
    exit 0
}

Write-Host ""
Write-Host "Dang khoi dong..." -ForegroundColor Cyan
Write-Host ""

# Khoi dong Server
Write-Host "1. Khoi dong Server..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd '$projectPath\server'; Write-Host 'SERVER' -ForegroundColor Cyan; python main_server.py"
)
Write-Host "Server started" -ForegroundColor Green

# Doi server khoi dong
Write-Host "Doi server khoi dong (3 giay)..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# Khoi dong Client 1
Write-Host "2. Khoi dong Client 1..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd '$projectPath'; Write-Host 'CLIENT 1' -ForegroundColor Green; Write-Host 'Goi y ten: An' -ForegroundColor Gray; python client/client_main.py"
)
Write-Host "Client 1 started" -ForegroundColor Green
Start-Sleep -Milliseconds 800

# Khoi dong Client 2
Write-Host "3. Khoi dong Client 2..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd '$projectPath'; Write-Host 'CLIENT 2' -ForegroundColor Green; Write-Host 'Goi y ten: Binh' -ForegroundColor Gray; python client/client_main.py"
)
Write-Host "Client 2 started" -ForegroundColor Green
Start-Sleep -Milliseconds 800

# Khoi dong Client 3
Write-Host "4. Khoi dong Client 3..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd '$projectPath'; Write-Host 'CLIENT 3' -ForegroundColor Green; Write-Host 'Goi y ten: Cuong' -ForegroundColor Gray; python client/client_main.py"
)
Write-Host "Client 3 started" -ForegroundColor Green

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "DEMO DA KHOI DONG THANH CONG!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Huong dan su dung:" -ForegroundColor Yellow
Write-Host "  1. Nhap ten cho moi client (An, Binh, Cuong)" -ForegroundColor White
Write-Host "  2. Nhan Enter (de dung IP mac dinh 127.0.0.1)" -ForegroundColor White
Write-Host "  3. Nhan Enter (de dung port mac dinh 9999)" -ForegroundColor White
Write-Host "  4. Nhap so tien de dau gia (VD: 1500, 2000, 2500)" -ForegroundColor White
Write-Host ""
Write-Host "Kich ban demo goi y:" -ForegroundColor Yellow
Write-Host "  Client An:    1500" -ForegroundColor White
Write-Host "  Client Binh:  1800" -ForegroundColor White
Write-Host "  Client Cuong: 2000" -ForegroundColor White
Write-Host "  Client An:    2200" -ForegroundColor White
Write-Host "  Client Binh:  2500" -ForegroundColor White
Write-Host ""
Write-Host "Thoi gian dau gia: 120 giay (2 phut)" -ForegroundColor Cyan
Write-Host ""
Write-Host "De dung: Nhan Ctrl+C tren cua so Server" -ForegroundColor Yellow
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan

# Giu cua so nay mo
Write-Host ""
Write-Host "Nhan Enter de dong cua so nay..." -ForegroundColor Gray
Read-Host
