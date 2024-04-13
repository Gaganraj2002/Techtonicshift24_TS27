// ignore_for_file: library_private_types_in_public_api, avoid_print
import 'dart:convert';
import 'dart:typed_data';
import 'package:arm_controller/speech_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:web_socket_channel/io.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Arm Controller Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SocketClientPage(),
    );
  }
}

class SocketClientPage extends StatefulWidget {
  const SocketClientPage({super.key});

  @override
  _SocketClientPageState createState() => _SocketClientPageState();
}

class _SocketClientPageState extends State<SocketClientPage> {
  IOWebSocketChannel? channel;
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
    SpeechController speechController = Get.put(SpeechController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arm Controller Client'),
      ),
      body: Stack(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 95),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 10),
                TextField(
                  controller: _hostController,
                  decoration: const InputDecoration(
                    hintText: 'Enter host IP address',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: channel != null ? _disconnect : _connect,
                  child: Text(channel != null ? 'Disconnect' : 'Connect'),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: imageData.isEmpty
                        ? const CircularProgressIndicator()
                        : Image.memory(Uint8List.fromList(imageData)),
                  ),
                ),
                const SizedBox(height: 20),
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
                                        ? Colors.green
                                        : Colors.red;
                                  },
                                ),
                                minimumSize: MaterialStateProperty.all<Size>(
                                    const Size(150, 48)),
                              ),
                              child: Text(
                                servoValues[index] == 0 ? 'On' : 'Off',
                                style: const TextStyle(fontSize: 16),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${servoValues[index]}°',
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () => _adjustServo(index, 1),
                                  child: const Icon(Icons.arrow_drop_up),
                                ),
                                ElevatedButton(
                                  onPressed: () => _adjustServo(index, -1),
                                  child: const Icon(Icons.arrow_drop_down),
                                ),
                              ],
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Obx(
          //   () => Text("Recognaised text are${speechController.text.value}"),
          // ),
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 90,
            bottom: 30,
            child: Container(
              decoration: BoxDecoration(
                color:
                    const Color.fromARGB(255, 129, 128, 128).withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.black, width: 2),
              ),
              height: 60,
              width: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      speechController.isMicClicked.value = true;
                      Get.to(const VoiceControllerWidget());
                    },
                    child: const Icon(Icons.mic),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.to(const VoiceControllerWidget());
                      speechController.isMicClicked.value = false;
                    },
                    child: const Icon(Icons.keyboard),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _connect() {
    String host = _hostController.text;
    if (host.isEmpty) {
      _updateResponse('Please enter host IP address.');
      return;
    }

    try {
      channel = IOWebSocketChannel.connect('ws://$host:8765');
      channel!.stream.listen((data) {
        setState(() {
          imageData = base64.decode(data);
        });
      });

      _updateResponse('Connected to $host');
    } catch (e) {
      _updateResponse('Failed to connect to $host');
    }
  }

  void _disconnect() {
    if (channel != null) {
      channel!.sink.close();
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
    if (channel != null) {
      String message = "*${servoValues.join(",")}#";
      channel!.sink.add(message);
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

class VoiceControllerWidget extends StatefulWidget {
  const VoiceControllerWidget({super.key});

  @override
  State<VoiceControllerWidget> createState() => _VoiceControllerWidgetState();
}

class _VoiceControllerWidgetState extends State<VoiceControllerWidget> {
  // SpeechController speechController = Get.put(SpeechController());

  SpeechToText speech = SpeechToText();

  bool isMicClicked = true;

  var isListening = false;
  var recognizedText = 'Press the mic to start recordnig.';

  void checkMic() async {
    bool micAvailable = await speech.initialize();

    if (micAvailable) {
      print("microphone permission is available");
    } else {
      print("User denined permissions");
    }
  }

  @override
  void initState() {
    super.initState();
    checkMic();
  }

  @override
  Widget build(BuildContext context) {
    SpeechController speechController = Get.put(SpeechController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: 300,
            width: 300,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Stack(
              children: [
                speechController.isMicClicked.value
                    ? Text(
                        recognizedText,
                        style: const TextStyle(fontSize: 20),
                      )
                    : TextField(
                        maxLines: 5,
                        controller: speechController.userCommandText,
                        decoration: const InputDecoration(
                          hintText: 'Enter command....',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(4.0)),
                            borderSide:
                                BorderSide(color: Colors.black, width: 3.0),
                          ),
                        ),
                      ),
                speechController.isMicClicked.value
                    ? Positioned(
                        right: 0,
                        bottom: 10,
                        child: GestureDetector(
                          onTap: () async {
                            if (!isListening) {
                              bool micAvailable = await speech.initialize();

                              if (micAvailable) {
                                setState(() {
                                  isListening = true;
                                });

                                speech.listen(
                                  listenFor: const Duration(seconds: 20),
                                  onResult: (result) {
                                    setState(() {
                                      recognizedText = result.recognizedWords;
                                      isListening = false;
                                    });
                                  },
                                );

                                print(recognizedText);
                              }
                            } else {
                              setState(() {
                                isListening = false;
                              });
                              speech.stop();
                            }
                          },
                          child: isListening
                              ? const Icon(Icons.record_voice_over)
                              : const Icon(Icons.mic_off),
                        ),
                      )
                    : Positioned(
                        right: 0,
                        bottom: 13,
                        child: GestureDetector(
                          onTap: () {
                            //add logic to send the text to server
                            print(
                                "User command 👀👀👀is: ${speechController.userCommandText.text}");
                            speechController.userCommandText.clear();
                            Get.back();
                          },
                          child: const Text(
                            "Send",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: TextButton(
                    onPressed: () {
                      speech.stop();
                      Get.back();
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
