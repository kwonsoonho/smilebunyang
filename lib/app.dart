import 'package:flutter/material.dart';

// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:smilebunyang/home.dart';

class App extends StatefulWidget {

  bool SuperAdmin;
  App({Key? key,required this.SuperAdmin}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Center(child: Text('error'),);
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          // Get.offAllNamed('/');
          return HomePage(SuperAdmin: widget.SuperAdmin);
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
