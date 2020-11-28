import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'dart:async';

import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordAudio extends StatefulWidget {
  @override
  _RecordAudioState createState() => _RecordAudioState();
}

class _RecordAudioState extends State<RecordAudio> {
  FlutterAudioRecorder _recorder;
  Recording _recording;
  Timer _t;
  // Widget _buttonIcon = Icon(Icons.do_not_disturb_on);
  String _alert;

  var micColor = Colors.black;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _prepare();
    });
  }

  void _opt() async {
    // print(_recording);
    // print(_recording.status);
    switch (_recording.status) {
      case RecordingStatus.Initialized:
        {
          await _startRecording();
          break;
        }
      case RecordingStatus.Recording:
        {
          await _stopRecording();
          break;
        }
      case RecordingStatus.Stopped:
        {
          await _prepare();
          break;
        }

      default:
        break;
    }
  }

  Future _init() async {
    // String customPath = '/id_';
    // create custom path
    io.Directory appDocDirectory;
    if (io.Platform.isIOS) {
      appDocDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDocDirectory = await getExternalStorageDirectory();
    }

    // can add extension like ".mp4" ".wav" ".m4a" ".aac"
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id') ?? 0;
    final userName = prefs.getString('username') ?? 0;
    String customPath = appDocDirectory.path +
        '/' +
        userId.toString() +
        '_' +
        userName.toString();
    // print("this is custom path");
    // print(userId);
    // print(customPath);

    _recorder = FlutterAudioRecorder(customPath,
        audioFormat: AudioFormat.WAV, sampleRate: 22050);
    await _recorder.initialized;
  }

  Future _prepare() async {
    var hasPermission = await FlutterAudioRecorder.hasPermissions;
    if (hasPermission) {
      await _init();
      var result = await _recorder.current();
      // print("this is result" + result.toString());
      setState(() {
        _recording = result;
        // _buttonIcon = _playerIcon(_recording.status);
        _alert = "";
      });
    } else {
      setState(() {
        _alert = "Permission Required.";
      });
    }
  }

// start record and update current state
  Future _startRecording() async {
    await _recorder.start();
    var current = await _recorder.current();
    setState(() {
      _recording = current;
    });

    _t = Timer.periodic(Duration(milliseconds: 10), (Timer t) async {
      var current = await _recorder.current();
      setState(() {
        _recording = current;
        _t = t;
      });
    });
  }

// stop the recording and update current state
  Future _stopRecording() async {
    var result = await _recorder.stop();
    _t.cancel();

    setState(() {
      _recording = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Container(
            width: 200,
            height: 200,
            child: IconButton(
              color: Colors.greenAccent,
              icon: Icon(
                Icons.mic,
                size: 200,
                color: micColor,
              ),
              onPressed: () {
                // show message for permission
                if (_alert != "") {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(_alert),
                  ));
                }

                // change colour of mike.
                setState(() {
                  if (_recording.status == RecordingStatus.Initialized) {
                    micColor = Colors.blue;
                  } else {
                    micColor = Colors.black;
                  }
                });
                _opt();
                print('this is recording path');
                print(_recording.path);
              },
            ),
          ),

          Text('Tap mic. to record'),

          // show duration of recorded audio
          Text(
            '${_recording?.duration ?? "0:00:00:000000"}',
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
