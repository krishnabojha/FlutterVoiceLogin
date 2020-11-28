import 'dart:io';

import 'package:Voice_recog_login/HomePage.dart';
import 'package:Voice_recog_login/RecordAudio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io' as io;

class LoginUser extends StatefulWidget {
  @override
  _LoginUserState createState() => _LoginUserState();
}

class _LoginUserState extends State<LoginUser> {
  int userId;
  String userName;
  bool audioState = false;
  io.Directory appDocDirectory;

// fetch storage directory
  void _init() async {
    if (io.Platform.isIOS) {
      appDocDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDocDirectory = await getExternalStorageDirectory();
    }
  }

// fetch id and username from device
  void getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('id') ?? 0;
    userName = prefs.getString('username') ?? 0;
  }

// loading when post request is doing
  void _loading() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

// post request to recognize voice
  Future uploadVoice() async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://192.168.100.83:8080/testVoice'));
      String _voicePath = appDocDirectory.path +
          "/" +
          userId.toString() +
          "_" +
          userName +
          ".wav";

      if (userId != null) {
        request.files
            .add(await http.MultipartFile.fromPath('file', _voicePath));
        _loading();
        http.Response response =
            await http.Response.fromStream(await request.send());
        // print("Result: ${response.statusCode}");
        // print(response.body);
        // print(response.body.runtimeType);
        if (response.statusCode == 200) {
          var responseBody = (response.body).split('_');
          Navigator.pop(context);
          var _audio = File(_voicePath);
          _audio.delete();
          if (((responseBody[0].toString()) == (userId.toString())) &&
              ((responseBody[1].split('.')[0]) == userName)) {
            // print('You will logged in');
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => Homepage(userName)));
          } else {
            Fluttertoast.showToast(
                msg: "Your voice is not Matched",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          }
        } else {
          var _audio = File(_voicePath);
          _audio.delete();
          Navigator.pop(context);
          Fluttertoast.showToast(
              msg: "Please Try Again!!!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
        if (response.statusCode == 500) {
          Fluttertoast.showToast(
              msg: "Server Side problem occured",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      }
    } catch (_) {
      // print('Please record audio first');
      Fluttertoast.showToast(
          msg: "Please record audio first",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    _init();
    getUserInfo();
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Login'),
      ),
      body: Container(
          child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 35.0, bottom: 15.0),
            alignment: Alignment.topCenter,
            child: Text(
              'Login With Your Voice',
              style: TextStyle(fontSize: 30),
            ),
            // padding: EdgeInsets.all(20),
          ),
          Container(
            child: RecordAudio(),
          ),
          Container(
            child: SizedBox(
              width: 200,
              height: 60,
              child: RaisedButton(
                  child: Text('Login'),
                  onPressed: () {
                    uploadVoice();
                  }),
            ),
          )
        ],
      )
          // child: RecordAudio(),
          ),
    );
  }
}
