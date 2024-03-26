import asyncio
import websockets
import cv2
import base64
import serial
import serial.tools.list_ports

# Define servo and suction states
servo_values = [110, 100, 140, 90, 135]  # Initial servo angles
suction_state = 0  # Initial suction state (0: Off, 1: On)


def send_serial_data(serial_device):
    main_list = servo_values + [suction_state]
    message = "*" + ",".join([str(val) for val in main_list]) + "#"
    print("Sending:", message)
    serial_device.write(message.encode("utf-8"))


async def send_camera_feed(websocket):
    cap = cv2.VideoCapture(0)  # Change the index if using a different camera
    while cap.isOpened():
        try:
            ret, frame = cap.read()
            if not ret:
                print("Error reading frame")
                break
            _, buffer = cv2.imencode(".jpg", frame)
            base64_bytes = base64.b64encode(buffer)
            data = base64_bytes.decode("utf-8")
            await websocket.send(data)
            await asyncio.sleep(0.1)  # Add a small delay to control the frame rate
        except websockets.exceptions.ConnectionClosedError:
            print("Client disconnected.")
            break
        except Exception as e:
            print("Exception:", e)
    cap.release()
    print("Camera released.")
    print("Waiting for new client...")


async def handle_message(websocket, message):
    global servo_values, suction_state
    if message.startswith("*") and message.endswith("#"):
        servo_values_str = message[1:-1].split(",")
        if (
            len(servo_values_str) == len(servo_values) + 1
        ):  # Check if correct number of values received
            servo_values = [int(val) for val in servo_values_str[:-1]]
            suction_state = int(servo_values_str[-1])
            print("Servo values updated:", servo_values)
            print("Suction state updated:", suction_state)


async def handle_client(websocket, path):
    print(f"Client connected from {websocket.remote_address}")
    camera_task = asyncio.create_task(send_camera_feed(websocket))
    try:
        async for message in websocket:
            await handle_message(websocket, message)
    except websockets.exceptions.ConnectionClosedError:
        pass
    finally:
        camera_task.cancel()
        print("Client disconnected.")
        print("Waiting for new client...")


async def main():
    async with websockets.serve(handle_client, "0.0.0.0", 8765):
        print("Server started. Waiting for clients...")
        await asyncio.Future()  # Keep the server running


asyncio.run(main())
