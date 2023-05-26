import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'MQTTClientManager.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // int _counter = 0;
  MQTTClientManager mqttClientManager = MQTTClientManager();
  final String pubTopic = "message";
  // final String message = "";
  final TextEditingController message = TextEditingController();

  @override
  void initState() {
    setupMqttClient();
    setupUpdatesListener();
    super.initState();
  }

  void _incrementCounter() {
    setState(() {
      // _counter++;
      mqttClientManager.publishMessage(
          pubTopic, message.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:  Center(
        child: Column(
          children: [

            const Text("Enter Your Message"),

            const SizedBox(height: 10,),

            TextField(
              controller: message,
            decoration: const InputDecoration(
              labelText: 'Enter your name',
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.send_and_archive_rounded),
      ),
    );
  }

  Future<void> setupMqttClient() async {
    await mqttClientManager.connect();
    mqttClientManager.subscribe(pubTopic);
  }

  void setupUpdatesListener() {
    mqttClientManager
        .getMessagesStream()!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');
    });
  }

  @override
  void dispose() {
    mqttClientManager.disconnect();
    super.dispose();
  }
}