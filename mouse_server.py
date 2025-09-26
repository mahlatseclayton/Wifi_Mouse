import socket
import threading
import pyautogui
import random
import string

TCP_PORT = 5000
UDP_PORT = 5001
BUFFER_SIZE = 1024

# === Generate random secret key once per run ===
SECRET_KEY = ''.join(random.choices(string.ascii_uppercase + string.digits, k=8))
print(f"[SECURITY] Server secret key: {SECRET_KEY}")
print(f"[SECURITY] Share this key with authorized clients: {SECRET_KEY}")

def handle_client(conn, addr):
    print(f"[SERVER] Connection attempt from {addr}")

    try:
        # === First message must be secret key ===
        client_key = conn.recv(BUFFER_SIZE).decode().strip()
        if client_key != SECRET_KEY:
            print(f"[SECURITY] Invalid key from {addr}. Closing connection.")
            conn.send("AUTH_FAILED".encode())
            conn.close()
            return

        conn.send("AUTH_OK".encode())
        print(f"[SECURITY] {addr} authenticated successfully")

        while True:
            data = conn.recv(BUFFER_SIZE).decode().strip()
            if not data:
                break

            print(f"[SERVER] Received: {data}")
            parts = data.split()
            if not parts:
                continue

            cmd = parts[0].upper()

            if cmd == "MOVE" and len(parts) == 3:
                dx, dy = int(parts[1]), int(parts[2])
                pyautogui.moveRel(dx, dy)

            elif cmd == "LEFT_CLICK":
                pyautogui.click()

            elif cmd == "RIGHT_CLICK":
                pyautogui.click(button="right")

            elif cmd == "SCROLL" and len(parts) == 2:
                pyautogui.scroll(int(parts[1]))

            elif cmd == "KEYBOARD" and len(parts) > 1:
                text = " ".join(parts[1:])
                pyautogui.typewrite(text)
                print(f"[KEYBOARD] Typed: {text}")

            elif cmd == "PRESS" and len(parts) == 2:
                key = parts[1].lower()
                pyautogui.press(key)
                print(f"[KEYBOARD] Pressed: {key}")

            elif cmd == "EXIT":
                break

            elif cmd == "AUTH_OK" or cmd == "AUTH_FAILED":
                # Ignore authentication responses
                pass

            else:
                print(f"[SERVER] Unknown command: {cmd}")

    except Exception as e:
        print(f"[ERROR] {e}")
    finally:
        print(f"[SERVER] Connection closed with {addr}")
        conn.close()

def tcp_server():
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_socket.bind(("0.0.0.0", TCP_PORT))
    server_socket.listen(5)
    print(f"[TCP] Listening on port {TCP_PORT}...")
    print(f"[TCP] Waiting for connections with access code: {SECRET_KEY}")

    while True:
        try:
            conn, addr = server_socket.accept()
            threading.Thread(target=handle_client, args=(conn, addr), daemon=True).start()
        except Exception as e:
            print(f"[TCP ERROR] {e}")

def udp_discovery():
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    udp_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    udp_socket.bind(("0.0.0.0", UDP_PORT))
    print(f"[UDP] Discovery server running on port {UDP_PORT}...")

    while True:
        try:
            data, client_addr = udp_socket.recvfrom(BUFFER_SIZE)
            message = data.decode().strip()
            if message == "DISCOVER_MOUSE_SERVER":
                response = f"SERVER_IP:{socket.gethostbyname(socket.gethostname())}:{TCP_PORT}:{SECRET_KEY}"
                udp_socket.sendto(response.encode(), client_addr)
                print(f"[UDP] Discovery request from {client_addr}")
        except Exception as e:
            print(f"[UDP ERROR] {e}")

if __name__ == "__main__":
    print("=== Smart Mouse & Keyboard Control Server ===")
    print("Starting servers...")
    
    # Start UDP discovery server
    udp_thread = threading.Thread(target=udp_discovery, daemon=True)
    udp_thread.start()
    
    # Start TCP server
    tcp_server()