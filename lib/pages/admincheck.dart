import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:smilebunyang/app.dart';
import 'package:smilebunyang/loginpage.dart';

class AdminCheck extends StatefulWidget {
  final String UID;
  final String Email;


  const AdminCheck({Key? key, required this.UID, required this.Email}) : super(key: key);

  @override
  _AdminCheckState createState() => _AdminCheckState();
}

class _AdminCheckState extends State<AdminCheck> {

  var logger = Logger();

  @override
  Widget build(BuildContext context) {
    var users = FirebaseFirestore.instance.collection('admin').doc(widget.UID);
    // .where('UID',isEqualTo: widget.uid)

    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: users.get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          logger.i(snapshot.connectionState);
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          if (snapshot.hasData && !snapshot.data!.exists) {
            logger.w(("snapshot.hasData : ${snapshot.hasData} , snapshot.data!.exists : ${snapshot.data!.exists}"));
            // 문서가 없음. 최초 가입으로 판단함.
            // Get.offAll(TypeSelect());
            addAdmin();
            return rejectAdmin();
          }
          if (snapshot.connectionState == ConnectionState.done) {
            // logger.w("snapshot.connectionState == ConnectionState.done : ${snapshot.connectionState}");
            var data = snapshot.data!.data() as Map<String, dynamic>;
            var SuperAdmin = data['SuperAdmin'];

            if (data['Type'] == true) {
              return App(SuperAdmin: SuperAdmin,);
            } else if (data['Type'] == false) {
              return rejectAdmin();
            } else {
              return Text("오류 상태입니다.");
            }
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void addAdmin() async {
    logger.i("계정 생성 들어옴");

    var addAdmin = FirebaseFirestore.instance.collection('admin').doc(widget.UID);

    var User = [];
    var UserInfo = <String, dynamic>{};
    UserInfo.addAll({'Type': false,'Email' : widget.Email});

    User.add(UserInfo);

    try {
      await addAdmin.set(UserInfo);
    } catch (e) {
      logger.w("오류 : $e");
    }
  }

}

class rejectAdmin extends StatelessWidget {
  const rejectAdmin({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(child: Text('등록되지 않은 관리자 입니다.\n사용이 불가능합니다.'),),
        ElevatedButton(onPressed: () => Get.offAllNamed('/'), child: Text('돌아가기'))
      ],
    );
  }
}
