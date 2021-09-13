import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:smilebunyang/app.dart';
import 'package:smilebunyang/pages/admincheck.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var logger = Logger();

  FirebaseAuth auth = FirebaseAuth.instance;
  late ConfirmationResult confirmationResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          height: 500,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SvgPicture.asset('assets/svg/roundlogo.svg', width: 300),
                Text(
                  '미소분양 관리자로 승인된 계정만 로그인 가능합니다.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await signInWithGoogle();
                      Get.offAll(AdminCheck(
                        UID: auth.currentUser!.uid,
                        Email: auth.currentUser!.email!,
                      ));
                    } on Exception catch (e) {
                      logger.w(e);
                    }
                  },
                  child: Text('관리자 구글 로그인'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

    // Once signed in, return the UserCredential
    UserCredential userCredential = await auth.signInWithPopup(googleProvider);
    logger.i(userCredential.user!.uid);
    return userCredential;

    // Or use signInWithRedirect
    // return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
  }
}
