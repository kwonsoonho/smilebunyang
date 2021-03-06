import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:smilebunyang/app.dart';
import 'package:smilebunyang/binding/initbinding.dart';
import 'package:smilebunyang/home.dart';
import 'package:smilebunyang/loginpage.dart';
import 'package:smilebunyang/pages/policypage.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var baseColor = Colors.black;

    return GetMaterialApp(
      title: '분양톡톡 관리자',
      theme: ThemeData(
          inputDecorationTheme:
              InputDecorationTheme(focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: baseColor)), focusColor: baseColor),
          appBarTheme: AppBarTheme(color: baseColor),
          primaryColor: baseColor,
          elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(primary: baseColor)),
          tabBarTheme: TabBarTheme(
              unselectedLabelColor: Colors.grey, indicator: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white, width: 5)))),
          floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: baseColor),
          textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(primary: baseColor)),
          outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(primary: baseColor)),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(selectedIconTheme: IconThemeData(color: baseColor)),
          scaffoldBackgroundColor: Colors.grey),
      initialBinding: InitBinding(),
      // home: const HomePage(),
      initialRoute: '/',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      getPages: [
        // GetPage(name: '/App', page: (() => App())),
        GetPage(name: '/', page: (() => const LoginPage())),
        GetPage(name: '/policy',page: (() => const PolicyPage())),
        // GetPage(name: '/', page: (() => HomePage()))
      ],
    );
  }
}
