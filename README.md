# 🖱️ WiFi Mouse & Keyboard Control App  

This project turns your **phone into a wireless mouse and keyboard** for your computer using WiFi.  
It’s built with a **Flutter mobile app** (for the interface and controls) and a **Python server** (that runs on your PC to move the mouse, click, scroll, and type).  

The idea is simple:  
- The **app** sends commands (like "move mouse left" or "press key")  
- The **server** receives the commands and uses `pyautogui` to control your computer  

This makes it possible to **control your computer remotely**, just like using a physical mouse and keyboard.  

---


---

## 🛠️ Technologies Used

### 📱 Mobile App (Client Side)
- **Flutter** → cross-platform framework for Android/iOS  
- **Dart** → programming language used by Flutter  
- **Material Design** → gives the app its UI look  
- **Socket programming (Dart `Socket`)** → sends commands from phone to server  
- **Widgets used**:
  - `Column`, `Row` → for layout  
  - `IconButton`, `ElevatedButton` → for mouse controls  
  - `TextField` → for typing text (keyboard input)  
  - `PageView` / `Carousel` → for onboarding/help screens  

### 💻 PC Server (Backend Side)
- **Python 3** → programming language for the server  
- **socket** → handles connections between app and PC  
- **threading** → allows multiple clients (if needed)  
- **pyautogui** → controls mouse movement, clicks, scrolling, and typing  
- **random** → generates a random access code for secure connection  

### 🔒 Security
- Uses a **random Access Code** so only you can connect to your PC.  
- Code is shown on the PC server when it starts.  
- Without the code, no one on the network can connect.  

---

## 🚀 Features
- Move the mouse (arrows → up, down, left, right)  
- Mouse clicks (left, right, double-click)  
- Scroll (up, down)  
- On-screen keyboard for typing  
- Connection protected by **Access Code**  
- Works over **local WiFi** (LAN)  

---

## ⚡ How It Works
1. **Start the Python server** on your computer.  
   - It listens on a port (default `5000`).  
   - It generates and displays an **Access Code**.  

2. **Run the Flutter app** on your phone.  
   - Connect to the server using your computer’s IP, port, and Access Code.  
   - After successful authentication, the app can send commands.  

3. **Commands are transmitted over sockets** (TCP).  
   - Example:  
     - App sends `"MOVE UP"` → server receives it → `pyautogui.moveRel(0, -10)` moves mouse up.  
     - App sends `"CLICK LEFT"` → server runs `pyautogui.click(button='left')`.  
     - App sends `"TYPE hello"` → server types `"hello"` on the computer.  

---

## 🛠️ Installation

### 1. On Your Computer (Server)
- Install Python 3  
- Install dependencies:
  ```bash
  pip install pyautogui

