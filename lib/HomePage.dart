import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Homepage extends StatefulWidget {
  // ignore: non_constant_identifier_names
  String UserName;
  Homepage(this.UserName);
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: [
              Text(
                "Welcome to home page",
                style: TextStyle(fontSize: 30),
              ),
              Text(
                widget.UserName,
                style: TextStyle(fontSize: 30, color: Colors.brown[300]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
