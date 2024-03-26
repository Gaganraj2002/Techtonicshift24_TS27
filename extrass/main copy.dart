import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arm Controller Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SocketClientPage(),
    );
  }
}

class SocketClientPage extends StatefulWidget {
  @override
  _SocketClientPageState createState() => _SocketClientPageState();
}

class _SocketClientPageState extends State<SocketClientPage> {
  late Socket _socket;
  final TextEditingController _hostController = TextEditingController();
  String _response = '';
  bool _isConnected = false;
  List<int> _servoValues = [110, 100, 140, 90, 135, 1];
  List<String> _servoLabels = [
    "Servo1",
    "Servo2",
    "Servo3",
    "Servo4",
    "Servo5",
    "Suction",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arm Controller Client'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 10),
            TextField(
              controller: _hostController,
              decoration: InputDecoration(
                hintText: 'Enter host IP address',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isConnected ? _disconnect : _connect,
              child: Text(_isConnected ? 'Disconnect' : 'Connect'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Center(
                child: ListView.builder(
                  itemCount: _servoValues.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_servoLabels[index]),
                      trailing: _servoLabels[index] == "Suction"
                          ? ElevatedButton(
                              onPressed: _toggleSuction,
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                        (states) {
                                  return _servoValues[index] == 0
                                      ? Colors.red
                                      : Colors.green;
                                }),
                                minimumSize: MaterialStateProperty.all<Size>(
                                    Size(150, 48)),
                              ),
                              child: Text(
                                _servoValues[index] == 0 ? 'Off' : 'On',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${_servoValues[index]}°',
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () => _adjustServo(index, 1),
                                  child: Icon(Icons.arrow_drop_up),
                                ),
                                ElevatedButton(
                                  onPressed: () => _adjustServo(index, -1),
                                  child: Icon(Icons.arrow_drop_down),
                                ),
                              ],
                            ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _connect() async {
    String host = _hostController.text;
    if (host.isEmpty) {
      _updateResponse('Please enter host IP address.');
      return;
    }

    try {
      _socket = await Socket.connect(host, 8765); // Adjust port as needed
      setState(() {
        _isConnected = true;
      });
      _receiveMessages();
    } catch (e) {
      _updateResponse('Error connecting to server: $e');
    }
  }

  void _disconnect() {
    if (_socket != null) {
      _socket.destroy();
      setState(() {
        _isConnected = false;
      });
    }
  }

  void _receiveMessages() {
    _socket.listen(
      (List<int> event) {
        String message = String.fromCharCodes(event);
        _updateResponse(message);
      },
      onError: (error) {
        _updateResponse('Error receiving message: $error');
      },
      onDone: () {
        _updateResponse('Connection closed.');
        _socket.destroy();
        setState(() {
          _isConnected = false;
        });
      },
    );
  }

  void _updateResponse(String message) {
    setState(() {
      _response = message;
    });
  }

  void _adjustServo(int index, int value) {
    setState(() {
      _servoValues[index] += value;
    });
    _sendServoValues();
  }

  void _sendServoValues() {
    if (_socket != null && _socket.remoteAddress != null) {
      String message = "*" + _servoValues.join(",") + "#";
      _socket.write(message);
    } else {
      _updateResponse('Socket is not connected.');
    }
  }

  void _toggleSuction() {
    setState(() {
      _servoValues[5] = _servoValues[5] == 0 ? 1 : 0;
    });
    _sendServoValues();
  }
}
