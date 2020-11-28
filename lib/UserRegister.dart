import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'VoiceRegister.dart';

import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class RegisterVoice extends StatelessWidget {
  String username;
  String email;
  // create user using post request to Spring API
  void createUser() async {
    http.Response response = await http.post(
      'http://192.168.100.83:8080/User',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'username': username, 'email': email}),
    );
    // print("this is post response");
    // print(jsonDecode(response.body));
    final responseBody = jsonDecode(response.body);
    // store user unique id and username to the device
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('id', responseBody['id']);
    prefs.setString('username', responseBody['username']);
    // print(prefs.getInt('id'));
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.headline6;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("User Register"),
      ),
      body: Column(
        children: [
          Padding(padding: EdgeInsets.fromLTRB(5.0, 30.0, 5.0, 12.0)),
          Text(
            'Register Your Info:',
            style: TextStyle(fontSize: 30.0),
          ),
          Padding(padding: EdgeInsets.fromLTRB(5.0, 12.0, 5.0, 20.0)),

          // username text field
          TextField(
            style: textStyle,
            onChanged: (value) {
              username = value;
            },
            decoration: InputDecoration(
                labelText: "Enter your Username",
                hintText: 'eg. ElonMusk',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3.5))),
          ),
          Padding(padding: EdgeInsets.fromLTRB(5.0, 12.0, 5.0, 20.0)),

          // email textfield
          TextField(
            style: textStyle,
            onChanged: (value) {
              email = value;
            },
            decoration: InputDecoration(
                labelText: "Enter your Email",
                hintText: 'eg. Elon12@gmail.com',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3.5))),
          ),
          Padding(padding: EdgeInsets.fromLTRB(5.0, 12.0, 5.0, 20.0)),

          SizedBox(
            width: 90,
            height: 50,
            child: RaisedButton(
              child: Text('Next'),
              onPressed: () {
                createUser();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TrainVoice()));
              },
            ),
          )
        ],
      ),
    );
  }
}
