import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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
  late IOWebSocketChannel channel;
  final TextEditingController _hostController = TextEditingController();
  List<int> imageData = [];
  List<int> servoValues = [110, 100, 140, 90, 135, 1]; // Initial servo values
  List<String> servoLabels = [
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
              onPressed: channel != null ? _disconnect : _connect,
              child: Text(channel != null ? 'Disconnect' : 'Connect'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Center(
                child: imageData.isEmpty
                    ? CircularProgressIndicator()
                    : Image.memory(Uint8List.fromList(imageData)),
              ),
            ),
            SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              itemCount: servoValues.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(servoLabels[index]),
                  trailing: servoLabels[index] == "Suction"
                      ? ElevatedButton(
                          onPressed: _toggleSuction,
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (states) {
                                return servoValues[index] == 0
                                    ? Colors.red
                                    : Colors.green;
                              },
                            ),
                            minimumSize:
                                MaterialStateProperty.all<Size>(Size(150, 48)),
                          ),
                          child: Text(
                            servoValues[index] == 0 ? 'Off' : 'On',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${servoValues[index]}°',
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
          ],
        ),
      ),
    );
  }

  void _connect() {
    String host = _hostController.text;
    if (host.isEmpty) {
      _updateResponse('Please enter host IP address.');
      return;
    }

    channel = IOWebSocketChannel.connect('ws://$host:8765');
    channel.stream.listen((data) {
      setState(() {
        imageData = base64.decode(data);
      });
    });

    _updateResponse('Connected to $host');
  }

  void _disconnect() {
    if (channel != null) {
      channel.sink.close();
      setState(() {
        channel = null;
      });
      _updateResponse('Disconnected');
    }
  }

  void _updateResponse(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _adjustServo(int index, int value) {
    setState(() {
      servoValues[index] += value;
    });
    _sendServoValues();
  }

  void _sendServoValues() {
    if (channel != null && channel.sink != null && channel.sink!.add != null) {
      String message = "*" + servoValues.join(",") + "#";
      channel.sink.add(message);
    } else {
      _updateResponse('Socket is not connected.');
    }
  }

  void _toggleSuction() {
    setState(() {
      servoValues[5] = servoValues[5] == 0 ? 1 : 0;
    });
    _sendServoValues();
  }

  @override
  void dispose() {
    _disconnect();
    super.dispose();
  }
}
