import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.blue[700],
      child: Center(
        child:SpinKitPumpingHeart(
          color: Colors.red[700],
          size: 50.0,
        ) ,
      ),
    );
  }
}
