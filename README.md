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


  ## 📱 Installing the App on Your Phone

You don’t need to build the app yourself — just install the provided `.apk` (Android) or `.ipa` (iOS) file.  

---

### 📲 Android (Install APK)
1. Download the `.apk` file onto your Android phone.  
2. Open **Settings → Security → Install unknown apps**.  
   - Enable installation from your browser or file manager.  
3. Tap the downloaded `.apk` file.  
4. Confirm installation → the app will appear on your home screen.  

---

### 🍏 iOS (Install IPA)

You can install the `.ipa` file in two ways:  

#### Option A – Using **Mac + Xcode**  
1. Connect your iPhone/iPad to your Mac.  
2. Open **Xcode** → go to **Devices and Simulators** (Window → Devices).  
3. Drag and drop the `.ipa` file into your device in Xcode.  
4. Wait for it to finish installing → app will appear on your home screen.  

#### Option B – Using **Windows + Sideloadly**  
1. Download and install **Sideloadly** → [https://sideloadly.io](https://sideloadly.io)  
2. Connect your iPhone/iPad to your Windows PC.  
3. Open **Sideloadly**.  
   - Select your device.  
   - Drag and drop the `.ipa` file into Sideloadly.  
   - Enter your Apple ID (used for signing).  
   - Click **Start**.  
4. On your iPhone:  
   - Go to **Settings → General → VPN & Device Management**.  
   - Trust the developer profile linked to your Apple ID.  
5. The app will appear on your home screen 🎉.  

---

⚠️ **Note (iOS users):** If you’re using a **free Apple ID**, the installed app will expire after **7 days**. With a **paid Apple Developer account**, it lasts up to a year.  



