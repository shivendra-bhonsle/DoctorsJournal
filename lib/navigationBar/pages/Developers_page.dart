import 'package:flutter/material.dart';

class Developers extends StatelessWidget {
  const Developers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Developers'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
    );
  }
}