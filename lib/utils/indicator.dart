import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';

import 'default_button.dart';

class Indicator {
  Indicator._();

  static void showLoading() {
    Widget alert = WillPopScope(
      onWillPop: () => Future.value(false),
      child: AlertDialog(
        alignment: Alignment.center,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        content: WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(),
              ),
              SizedBox(height: 15),
              Center(
                child: Text(
                  "Loading...",
                  style: TextStyle(
                    color: Color(0xFF5B6978),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );

    showDialog(
      context: globalContext,
      barrierDismissible: false,
      builder: (_) {
        //  return alert;
        return Lottie.asset('assets/loading.json');
        //   const SpinKitFoldingCube(
        //   color: Color(0xff3C37FF),
        //   size: 50.0,
        // );
      },
    );
  }

  static void closeIndicator() async {
    Navigator.pop(globalContext, true);
  }
}
