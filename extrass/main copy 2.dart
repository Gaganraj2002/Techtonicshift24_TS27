import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Feed Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VideoStreamPage(),
    );
  }
}

class VideoStreamPage extends StatefulWidget {
  @override
  _VideoStreamPageState createState() => _VideoStreamPageState();
}

class _VideoStreamPageState extends State<VideoStreamPage> {
  late IOWebSocketChannel channel;
  late List<int> imageData;

  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect(
        'ws://192.168.233.43:8765'); // Replace with your server IP address
    channel.stream.listen((data) {
      setState(() {
        imageData = base64.decode(data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Feed Client'),
      ),
      body: Center(
        child: imageData == null
            ? CircularProgressIndicator()
            : Image.memory(Uint8List.fromList(imageData)),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
