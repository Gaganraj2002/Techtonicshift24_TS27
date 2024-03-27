**Arm Controller**

This repository contains code for an arm controller system built with Flutter for the client-side application, Python for the server-side application, and Arduino for controlling the arm hardware.

### Contents
1. [Introduction](#introduction)
2. [Folder Structure](#folder-structure)
3. [Setup](#setup)
4. [Usage](#usage)
5. [Contributing](#contributing)
6. [License](#license)

### Introduction
The Arm Controller project allows users to remotely control the movements and operations of a robotic arm. The system consists of three main components:
- **Client-side Application (Flutter)**: A mobile/web application built with Flutter that provides a user interface for interacting with the arm controller system.
- **Server-side Application (Python)**: A Python server application that acts as a communication bridge between the client-side application and the arm hardware.
- **Arm Hardware Control Code (Arduino)**: Arduino code running on the arm hardware, responsible for executing commands received from the server to control the arm's actuators and peripherals.

### Folder Structure
- **armcontroller**: Contains the Flutter project for the client-side application.
- **Main_server.py**: Python script for the server-side application.
- **arm_main.ino**: Arduino code for controlling the arm hardware.

### Setup
1. **Flutter Setup**:
   - Ensure you have Flutter installed on your system. If not, follow the official Flutter installation guide: [Flutter Installation](https://flutter.dev/docs/get-started/install)
   - Navigate to the `armcontroller` folder and run `flutter pub get` to install dependencies.

2. **Python Setup**:
   - Install Python if not already installed. You can download Python from the official website: [Python Downloads](https://www.python.org/downloads/)
   - Run `pip install websockets opencv-python` to install the required Python package.(you can also create a vitual environment using venv or pipenv)


3. **Arduino Setup**:
   - Open the `arm_main.ino` file in the Arduino IDE.
   - Upload the code to your Arduino board connected to the arm hardware.

### Usage
1. **Start the Server**:
   - Run the `Main_server.py` script to start the Python server. Make sure the server is running and accessible.

2. **Run the Flutter App**:
   - Open the `armcontroller` folder in your preferred IDE.
   - Run the Flutter app on your desired platform (Android or iOS(requires MacOS)) using `flutter run`.

3. **Interact with the App**:
   - Input the host IP address in the app to connect to the server.
   - Use the app interface to control the arm's movements and operations.

### App Interface

![iOS interface](https://github.com/Gaganraj2002/Techtonicshift24_TS27/blob/main/images/iOS.png?raw=true)

![Android interface](https://github.com/Gaganraj2002/Techtonicshift24_TS27/blob/main/images/Android.png?raw=true)

### Arm Pictures

![ARM](https://github.com/Gaganraj2002/Techtonicshift24_TS27/blob/main/images/arm1.png?raw=true)

![ARM](https://github.com/Gaganraj2002/Techtonicshift24_TS27/blob/main/images/arm2.png?raw=true)

![ARM](https://github.com/Gaganraj2002/Techtonicshift24_TS27/blob/main/images/arm3.jpeg?raw=true)

### Contributing
Contributions are welcome! Feel free to open issues or pull requests for any improvements or fixes.

### License
This project is licensed under the [MIT License](LICENSE). Feel free to use and modify the code for your own purposes.
