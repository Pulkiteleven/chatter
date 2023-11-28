
import 'package:chatter/Auth/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Backend/backend.dart';
import 'Usefull/Colors.dart';
import 'Usefull/Functions.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    // home:homeScreen(data: {},)
      theme: ThemeData(brightness: Brightness.dark, primarySwatch: Colors.cyan),

      // home:logIn(),
      home: Splash()
    // home: signUp()
    // home: signUp()




  ));
}

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    Future.delayed(Duration(seconds: 3), () {
      check();
    });

  }

  check() async {
    if (_auth.currentUser != null) {
      checker(context);
    } else {
      navScreen(logIn(), context, true);

    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Spacer(),
                    mainText("chatter", mainColor, 40.0, FontWeight.bold, 1),
                    Spacer(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
