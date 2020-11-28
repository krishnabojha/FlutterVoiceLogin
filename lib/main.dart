import 'package:flutter/material.dart';
import 'UserRegister.dart';
import 'VoiceRegister.dart';

void main() {
  runApp(MaterialApp(
    home: MainController(),
  ));
}

class MainController extends StatefulWidget {
  @override
  _MainControllerState createState() => _MainControllerState();
}

class _MainControllerState extends State<MainController> {
  @override
  Widget build(BuildContext context) {
    // RegisterVoice();
    return Container(
      child: RegisterVoice(),
      // child: TrainVoice(),
    );
  }
}
