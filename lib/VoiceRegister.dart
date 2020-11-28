import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'RecordAudio.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'UserLogin.dart';
import 'package:http/http.dart' as http;
import 'dart:io' as io;

class TrainVoice extends StatefulWidget {
  @override
  _TrainVoiceState createState() => _TrainVoiceState();
}

class _TrainVoiceState extends State<TrainVoice> {
  int userId;
  String userName;
  bool audioState = false;
  io.Directory appDocDirectory;

// fetch the storage directory
  void _init() async {
    if (io.Platform.isIOS) {
      appDocDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDocDirectory = await getExternalStorageDirectory();
    }
  }

// fetch userid and username from the device
  void getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('id') ?? 0;
    userName = prefs.getString('username') ?? 0;
  }

// loading when post request is sent
  void _loading() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

// post request to train the voice
  Future uploadVoice() async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://192.168.100.83:8080/trainVoice'));
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
        if (response.statusCode == 200) {
          var _audio = File(_voicePath);
          _audio.delete();
          Navigator.pop(context);
          // if status code is 200 then assume the voice is regestered
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginUser()));
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

  // play recorded audio
  void playAudio() {
    AudioPlayer player = AudioPlayer();
    getUserInfo();
    player.play(
        appDocDirectory.path +
            "/" +
            userId.toString() +
            "_" +
            userName +
            ".wav",
        isLocal: true);
  }

  @override
  Widget build(BuildContext context) {
    _init();
    getUserInfo();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('User Register'),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 35.0, bottom: 15.0),
              alignment: Alignment.topCenter,
              child: Text(
                'Register Your Voice',
                style: TextStyle(fontSize: 30),
              ),
              // padding: EdgeInsets.all(20),
            ),
            Container(
              child: RecordAudio(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: SizedBox(
                    width: 100,
                    height: 50,
                    child: RaisedButton(
                        child: Text('Clear'),
                        onPressed: () {
                          getUserInfo();
                          var abc = File(appDocDirectory.path +
                              "/" +
                              userId.toString() +
                              "_" +
                              userName +
                              ".wav");
                          abc.delete();
                          RecordAudio();
                        }),
                  ),
                ),
                Padding(padding: EdgeInsets.all(5)),
                Container(
                  child: SizedBox(
                    width: 100,
                    height: 50,
                    child: RaisedButton(
                        child: Text('Play'),
                        onPressed: () {
                          playAudio();
                        }),
                  ),
                ),
                Padding(padding: EdgeInsets.all(5)),
                Container(
                  child: SizedBox(
                    width: 100,
                    height: 50,
                    child: RaisedButton(
                        child: Text('Register'),
                        onPressed: () {
                          uploadVoice();
                        }),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
