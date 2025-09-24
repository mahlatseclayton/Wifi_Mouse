import socket
import threading
import pyautogui

TCP_PORT = 5000
UDP_PORT = 5001
BUFFER_SIZE = 1024

def handle_client(conn, addr):
    print(f"[SERVER] Connected by {addr}")
    try:
        while True:
            data = conn.recv(BUFFER_SIZE).decode().strip()
            if not data:
                break

            print(f"[SERVER] Received: {data}")
            parts = data.split()
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

            elif cmd == "EXIT":
                break
    except Exception as e:
        print("[ERROR]", e)
    finally:
        conn.close()


def tcp_server():
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind(("0.0.0.0", TCP_PORT))
    server_socket.listen(1)
    print(f"[TCP] Listening on port {TCP_PORT}...")

    while True:
        conn, addr = server_socket.accept()
        threading.Thread(target=handle_client, args=(conn, addr)).start()


def udp_discovery():
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    udp_socket.bind(("0.0.0.0", UDP_PORT))
    print(f"[UDP] Discovery server running on port {UDP_PORT}...")

    while True:
        data, client_addr = udp_socket.recvfrom(BUFFER_SIZE)
        message = data.decode()
        if message == "DISCOVER_MOUSE_SERVER":
            udp_socket.sendto(f"SERVER_IP:{socket.gethostbyname(socket.gethostname())}:{TCP_PORT}".encode(), client_addr)


if __name__ == "__main__":
    threading.Thread(target=udp_discovery, daemon=True).start()
    tcp_server()
