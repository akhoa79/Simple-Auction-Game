# 📐 KIẾN TRÚC HỆ THỐNG - VISUAL GUIDE

## 🏗️ Tổng quan kiến trúc

```
┌─────────────────────────────────────────────────────────────────┐
│                         SERVER PROCESS                           │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              main_server.py (Người 1)                     │  │
│  │  ┌─────────────────────────────────────────────────────┐ │  │
│  │  │  Socket Listener (Port 9999)                        │ │  │
│  │  │  - Bind to 0.0.0.0:9999                            │ │  │
│  │  │  - Listen for connections                           │ │  │
│  │  │  - Accept loop ♾️                                   │ │  │
│  │  └─────────────────────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │         AuctionHub (Người 2)                             │  │
│  │  ┌─────────────────────────────────────────────────────┐│  │
│  │  │  clients = {socket1: "Client-1",                    ││  │
│  │  │             socket2: "Client-2",                    ││  │
│  │  │             socket3: "Client-3"}                    ││  │
│  │  │  + broadcast_new_price()                            ││  │
│  │  │  + broadcast_winner()                               ││  │
│  │  └─────────────────────────────────────────────────────┘│  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │         AuctionState (Người 2)                           │  │
│  │  ┌─────────────────────────────────────────────────────┐│  │
│  │  │  🔒 Lock                                            ││  │
│  │  │  current_price = 2500                               ││  │
│  │  │  current_winner = "Binh"                            ││  │
│  │  │  + place_bid(user, value) ← Thread-safe!           ││  │
│  │  └─────────────────────────────────────────────────────┘│  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │         TimerThread (Người 4)                            │  │
│  │  ┌─────────────────────────────────────────────────────┐│  │
│  │  │  ⏰ Countdown: 120 seconds                          ││  │
│  │  │  - Warning at 10s, 5s                               ││  │
│  │  │  - Broadcast WINNER when done                       ││  │
│  │  └─────────────────────────────────────────────────────┘│  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐                   │
│  │  Thread 1 │  │  Thread 2 │  │  Thread 3 │  ← ClientThreads  │
│  │ Client-1  │  │ Client-2  │  │ Client-3  │     (Người 1)     │
│  │           │  │           │  │           │                    │
│  │ recv() ♾️ │  │ recv() ♾️ │  │ recv() ♾️ │                    │
│  │ handle    │  │ handle    │  │ handle    │                    │
│  └─────┬─────┘  └─────┬─────┘  └─────┬─────┘                   │
│        │              │              │                           │
└────────┼──────────────┼──────────────┼───────────────────────────┘
         │              │              │
         │ TCP/IP       │ TCP/IP       │ TCP/IP
         │ Socket       │ Socket       │ Socket
         │              │              │
    ┌────▼────┐    ┌────▼────┐    ┌────▼────┐
    │ CLIENT 1│    │ CLIENT 2│    │ CLIENT 3│
    │         │    │         │    │         │
    │  "An"   │    │ "Binh"  │    │ "Cuong" │
    │         │    │         │    │         │
    │ BID:    │    │ BID:    │    │ BID:    │
    │  1500 → │    │  1800 → │    │  2000 → │
    │         │    │         │    │         │
    │ ← NEW   │    │ ← NEW   │    │ ← NEW   │
    │   PRICE │    │   PRICE │    │   PRICE │
    └─────────┘    └─────────┘    └─────────┘
```

---

## 🔄 Flow: Client gửi BID

```
CLIENT (An)                                 SERVER
   │                                           │
   │  1. Connect                               │
   │ ───────────────────────────────────────> │
   │                                           │ 2. Accept
   │                                           │    Create ClientThread
   │                                           │    Add to AuctionHub
   │                                           │
   │ <─────────────────────────────────────── │ 3. Send WELCOME
   │  {"type":"WELCOME", "current_price":1000} │
   │                                           │
   │  4. User nhập: 1500                       │
   │  {"type":"BID", "user":"An", "value":1500}│
   │ ───────────────────────────────────────> │
   │                                           │
   │                                     ┌─────▼─────┐
   │                                     │ClientThread│
   │                                     │ handle_msg │
   │                                     └─────┬─────┘
   │                                           │
   │                                     ┌─────▼────────┐
   │                                     │AuctionState  │
   │                                     │🔒 LOCK       │
   │                                     │place_bid()   │
   │                                     │ value > cur? │
   │                                     │ YES → Accept │
   │                                     │ cur = 1500   │
   │                                     │ winner = "An"│
   │                                     └─────┬────────┘
   │                                           │
   │                                     ┌─────▼────────┐
   │                                     │ AuctionHub   │
   │                                     │ broadcast()  │
   │                                     └─────┬────────┘
   │                                           │
   │ <═════════════════════════════════════╗  │
CLIENT An                                   ║  │
   │ {"type":"NEW_PRICE","user":"An",     ║  │
   │  "value":1500}                        ║  │
                                           ║  │
CLIENT Binh                                ║  │
   │ <═════════════════════════════════════╬═ │
   │ {"type":"NEW_PRICE","user":"An",     ║  │
   │  "value":1500}                        ║  │
                                           ║  │
CLIENT Cuong                               ║  │
   │ <═════════════════════════════════════╝  │
   │ {"type":"NEW_PRICE","user":"An",         │
   │  "value":1500}                            │
```

---

## 🔒 Lock Mechanism (Thread-Safe)

```
┌──────────────────────────────────────────────────────────────┐
│                     RACE CONDITION                            │
│  Without Lock - ❌ WRONG!                                     │
│                                                                │
│  Thread 1 (An: 1500)     Thread 2 (Binh: 1800)              │
│       │                         │                             │
│       │ Read: cur = 1000        │                             │
│       │ Check: 1500 > 1000? ✓   │                             │
│       │                         │ Read: cur = 1000            │
│       │                         │ Check: 1800 > 1000? ✓       │
│       │ Write: cur = 1500       │                             │
│       │                         │ Write: cur = 1800           │
│       │                         │                             │
│  Result: cur = 1800 (Binh wins)                               │
│  But An bid first! ← WRONG!                                   │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                     WITH LOCK                                 │
│  ✅ CORRECT!                                                  │
│                                                                │
│  Thread 1 (An: 1500)     Thread 2 (Binh: 1800)              │
│       │                         │                             │
│       │ 🔒 Acquire Lock         │                             │
│       │ Read: cur = 1000        │                             │
│       │ Check: 1500 > 1000? ✓   │                             │
│       │ Write: cur = 1500       │ 🚫 WAIT (Lock held by T1)  │
│       │ 🔓 Release Lock         │                             │
│       │                         │ 🔒 Acquire Lock             │
│       │                         │ Read: cur = 1500            │
│       │                         │ Check: 1800 > 1500? ✓       │
│       │                         │ Write: cur = 1800           │
│       │                         │ 🔓 Release Lock             │
│                                                                │
│  Result: cur = 1800 (Binh wins)                               │
│  Because 1800 > 1500 ← CORRECT!                               │
└──────────────────────────────────────────────────────────────┘

Code implementation:
┌────────────────────────────────────────┐
│  def place_bid(self, user, value):    │
│      with self.lock:  # ← CRITICAL    │
│          if value > self.current_price:│
│              self.current_price = value│
│              self.current_winner = user│
│              return True               │
│          return False                  │
└────────────────────────────────────────┘
```

---

## 📡 Broadcast Mechanism

```
                    SERVER
               ┌─────────────┐
               │ AuctionHub  │
               │             │
               │  clients =  │
               │  {socket1,  │
               │   socket2,  │
               │   socket3}  │
               └──────┬──────┘
                      │
      ┌───────────────┼───────────────┐
      │               │               │
      ▼               ▼               ▼
  socket1         socket2         socket3
  send()          send()          send()
      │               │               │
      │               │               │
      ▼               ▼               ▼
┌─────────┐     ┌─────────┐     ┌─────────┐
│CLIENT 1 │     │CLIENT 2 │     │CLIENT 3 │
│  "An"   │     │ "Binh"  │     │ "Cuong" │
└─────────┘     └─────────┘     └─────────┘

Message: {"type":"NEW_PRICE","user":"Binh","value":1800}

→ ALL clients receive the SAME message at the SAME time
→ Realtime update!
```

---

## ⏱️ Timer Flow

```
Server Start
     │
     ├─> Start TimerThread
     │        │
     │        ├─> Sleep 1 second
     │        ├─> elapsed++
     │        │
     │        ├─> elapsed == 110?
     │        │   YES → Broadcast "10 giây còn lại!"
     │        │
     │        ├─> elapsed == 115?
     │        │   YES → Broadcast "5 giây còn lại!"
     │        │
     │        ├─> elapsed == 120?
     │        │   YES → End Auction
     │        │         └─> Get winner info
     │        │         └─> Broadcast WINNER
     │        │         └─> Set auction.is_active = False
     │        │
     │        └─> Loop back (if not done)
     │
     └─> Auction ends
```

---

## 🧵 Threading Model

```
Main Thread
    │
    ├─> Create Server Socket
    ├─> Create AuctionState
    ├─> Create AuctionHub
    │
    ├─> Start TimerThread ────────────────┐
    │                                      │
    ├─> Accept Loop ♾️                    │
    │   │                                  ▼
    │   ├─> Accept Client 1       ┌──────────────┐
    │   │   └─> Create Thread 1   │ TimerThread  │
    │   │       └─> thread.start() │   (Daemon)   │
    │   │                          │              │
    │   ├─> Accept Client 2        │ Countdown    │
    │   │   └─> Create Thread 2    │   120s       │
    │   │       └─> thread.start() │              │
    │   │                          │ Broadcast    │
    │   └─> Accept Client 3        │  warnings    │
    │       └─> Create Thread 3    │              │
    │           └─> thread.start() │ End auction  │
    │                              └──────────────┘
    │
    ├─> Threads running in parallel:
    │
    ├──> Thread 1 (Client 1)
    │    └─> recv() ♾️
    │        └─> handle BID
    │            └─> place_bid() (with Lock)
    │                └─> broadcast_new_price()
    │
    ├──> Thread 2 (Client 2)
    │    └─> recv() ♾️
    │        └─> handle BID
    │            └─> place_bid() (with Lock)
    │                └─> broadcast_new_price()
    │
    └──> Thread 3 (Client 3)
         └─> recv() ♾️
             └─> handle BID
                 └─> place_bid() (with Lock)
                     └─> broadcast_new_price()

Note: Lock ensures only ONE thread can modify 
      current_price at a time!
```

---

## 📦 Data Flow

```
┌──────────────────────────────────────────────────────────┐
│                     CLIENT SIDE                           │
│                                                            │
│  User Input: "1500"                                       │
│       │                                                    │
│       ├─> Create JSON                                     │
│       │   {"type":"BID","user":"An","value":1500}        │
│       │                                                    │
│       └─> socket.send()                                   │
│           │                                                │
└───────────┼────────────────────────────────────────────────┘
            │ Network (TCP/IP)
            ▼
┌──────────────────────────────────────────────────────────┐
│                     SERVER SIDE                           │
│                                                            │
│  ClientThread.recv()                                      │
│       │                                                    │
│       ├─> Parse JSON                                      │
│       │   message = json.loads(data)                      │
│       │                                                    │
│       ├─> Extract data                                    │
│       │   type = "BID"                                    │
│       │   user = "An"                                     │
│       │   value = 1500                                    │
│       │                                                    │
│       ├─> Call AuctionState.place_bid()                  │
│       │   │                                                │
│       │   ├─> 🔒 Acquire Lock                            │
│       │   ├─> Validate: 1500 > current_price?           │
│       │   │   YES → Accept                               │
│       │   │   current_price = 1500                       │
│       │   │   current_winner = "An"                      │
│       │   └─> 🔓 Release Lock                            │
│       │                                                    │
│       └─> Call AuctionHub.broadcast_new_price()          │
│           │                                                │
│           ├─> Create JSON                                 │
│           │   {"type":"NEW_PRICE","user":"An","value":1500}│
│           │                                                │
│           └─> For each client socket:                     │
│               socket.send()                               │
│                     │                                      │
└─────────────────────┼──────────────────────────────────────┘
                      │ Network (TCP/IP)
                      ▼
┌──────────────────────────────────────────────────────────┐
│                  ALL CLIENTS                              │
│                                                            │
│  recv()                                                   │
│    │                                                       │
│    ├─> Parse JSON                                         │
│    │   {"type":"NEW_PRICE","user":"An","value":1500}    │
│    │                                                       │
│    └─> Display                                            │
│        "💰 GIÁ MỚI: An đặt $1500"                        │
└──────────────────────────────────────────────────────────┘
```

---

## 🎯 Key Concepts Diagram

```
┌────────────────────────────────────────────────────────────┐
│                  MULTI-THREADING                            │
│                                                              │
│  Main Thread ─┬─> Thread 1 (Client 1)                      │
│               ├─> Thread 2 (Client 2)                      │
│               ├─> Thread 3 (Client 3)                      │
│               └─> Timer Thread                             │
│                                                              │
│  Benefits:                                                  │
│  ✓ Handle multiple clients concurrently                    │
│  ✓ Non-blocking I/O                                        │
│  ✓ Parallel processing                                     │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│                  SYNCHRONIZATION (Lock)                     │
│                                                              │
│  Shared Resource: current_price, current_winner            │
│                                                              │
│  Without Lock:    Thread 1 ──┐                             │
│                   Thread 2 ──┼─> 💥 RACE CONDITION         │
│                   Thread 3 ──┘                             │
│                                                              │
│  With Lock:       Thread 1 ─> 🔒 ... 🔓                   │
│                   Thread 2 ───────> 🔒 ... 🔓             │
│                   Thread 3 ─────────────> 🔒 ... 🔓       │
│                   (Sequential access)                       │
│                                                              │
│  Implementation: threading.Lock()                           │
│                  with lock: ...                            │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│                     BROADCAST                               │
│                                                              │
│  One message → Many recipients                             │
│                                                              │
│       Server                                                │
│         │                                                    │
│    ┌────┼────┐                                             │
│    │    │    │                                             │
│    ▼    ▼    ▼                                             │
│   C1   C2   C3                                             │
│                                                              │
│  Use case: NEW_PRICE, WINNER, WARNING                      │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│                  SOCKET PROGRAMMING                         │
│                                                              │
│  TCP/IP (Reliable, Connection-oriented)                    │
│                                                              │
│  Server:                  Client:                           │
│  1. socket()             1. socket()                        │
│  2. bind()               2. connect()                       │
│  3. listen()             3. send()/recv()                   │
│  4. accept() ♾️                                            │
│  5. send()/recv()                                          │
│                                                              │
│  Protocol: JSON over TCP                                   │
└────────────────────────────────────────────────────────────┘
```

---

## 🎓 Phân tích từng thành phần

### 1. main_server.py (Người 1)
```
┌─────────────────────────────────────┐
│         main_server.py              │
├─────────────────────────────────────┤
│  Responsibilities:                  │
│  • Create listener socket           │
│  • Bind to 0.0.0.0:9999            │
│  • Accept loop                      │
│  • Create thread for each client    │
│  • Handle Ctrl+C (graceful shutdown)│
│  • Coordinate all components        │
├─────────────────────────────────────┤
│  Key Functions:                     │
│  • start_server()                   │
│  • signal_handler()                 │
│  • shutdown_server()                │
└─────────────────────────────────────┘
```

### 2. client_thread.py (Người 1)
```
┌─────────────────────────────────────┐
│         client_thread.py            │
├─────────────────────────────────────┤
│  Responsibilities:                  │
│  • Handle ONE client connection     │
│  • Receive messages (recv loop)     │
│  • Parse JSON                       │
│  • Handle BID requests              │
│  • Send responses (WELCOME, ERROR)  │
│  • Cleanup on disconnect            │
├─────────────────────────────────────┤
│  Key Functions:                     │
│  • run() - Main thread loop         │
│  • handle_message()                 │
│  • send_welcome()                   │
│  • cleanup()                        │
└─────────────────────────────────────┘
```

### 3. auction_logic.py (Người 2)
```
┌─────────────────────────────────────┐
│         auction_logic.py            │
├─────────────────────────────────────┤
│  Responsibilities:                  │
│  • Store auction state              │
│    - current_price                  │
│    - current_winner                 │
│    - is_active                      │
│  • Validate bids                    │
│  • 🔒 Lock for thread-safety        │
├─────────────────────────────────────┤
│  Key Functions:                     │
│  • place_bid() ← with lock!         │
│  • get_current_price()              │
│  • get_current_winner()             │
│  • end_auction()                    │
└─────────────────────────────────────┘
```

### 4. auction_hub.py (Người 2)
```
┌─────────────────────────────────────┐
│          auction_hub.py             │
├─────────────────────────────────────┤
│  Responsibilities:                  │
│  • Manage client list               │
│    clients = {socket: id}           │
│  • Add/remove clients               │
│  • Broadcast messages to ALL        │
│  • Handle disconnections            │
├─────────────────────────────────────┤
│  Key Functions:                     │
│  • add_client()                     │
│  • remove_client()                  │
│  • broadcast_message()              │
│  • broadcast_new_price()            │
│  • broadcast_winner()               │
└─────────────────────────────────────┘
```

### 5. timer_thread.py (Người 4)
```
┌─────────────────────────────────────┐
│         timer_thread.py             │
├─────────────────────────────────────┤
│  Responsibilities:                  │
│  • Countdown from 120 seconds       │
│  • Send warnings at 10s, 5s         │
│  • End auction when time's up       │
│  • Broadcast WINNER                 │
│  • Can be stopped early             │
├─────────────────────────────────────┤
│  Key Functions:                     │
│  • run() - Countdown loop           │
│  • broadcast_warning()              │
│  • end_auction()                    │
│  • stop()                           │
└─────────────────────────────────────┘
```

---

**💡 Visual guide này giúp hiểu rõ kiến trúc hệ thống!**
