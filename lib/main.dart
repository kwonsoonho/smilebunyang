import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smilebunyang/app.dart';
import 'package:smilebunyang/binding/initbinding.dart';
import 'package:smilebunyang/home.dart';

void main() async{
  // WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '미소분양 관리자',
      theme: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey
      ),
      initialBinding: InitBinding(),
      // home: const HomePage(),
      initialRoute: '/' ,
      getPages: [
        GetPage(name: '/', page: (() => App()))
        // GetPage(name: '/', page: (() => HomePage()))
      ],
    );
  }
}
