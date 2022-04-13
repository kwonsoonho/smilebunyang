import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:smilebunyang/controller/app_controller.dart';
import 'package:smilebunyang/pages/1depth/ad_management.dart.dart';
import 'package:smilebunyang/pages/1depth/admin_magement.dart';
import 'package:smilebunyang/pages/1depth/content_management.dart';
import 'package:smilebunyang/pages/1depth/crime_management.dart';
import 'package:smilebunyang/pages/1depth/sellreq_management.dart';
import 'package:smilebunyang/pages/1depth/tax_management.dart';
import 'package:smilebunyang/pages/1depth/user_management.dart';

class HomePage extends GetView<AppController> {
  bool SuperAdmin;

  HomePage({Key? key,required this.SuperAdmin}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    if(SuperAdmin == false){
      AppController.to.currentIndex(6);
    }
    return Scaffold(
      appBar: AppBar(
          title: const Text('분양톡톡 관리자 페이지 1.1.5'),
          ),
      body: Row(
        children: [
          LeftDrawer(SuperAdmin: SuperAdmin,),
          Expanded(
            child: Obx(() {
              // controller 에다가 enum을 통해 페이지를 선언해 주고 배열로 인덱스를 주면 연동 된다.
              //enum RoutName { UserManagement, contentManagement, requestList, adManagement, crimeReport, adminManagement, taxReqList }

              switch (RoutName.values[controller.currentIndex.value]) {
                case RoutName.UserManagement:
                  return const UserManagement();
                case RoutName.contentManagement:
                  return const ContentManagement();
                case RoutName.requestList:
                  return const SellReqManagement();
                case RoutName.adManagement:
                  return const adManagement();
                case RoutName.crimeReport:
                  return const CrimeManagement();
                case RoutName.adminManagement:
                  return const AdminManagement();
                case RoutName.taxReqList:
                  return const TaxReqManagement();

              }
            }),
          ),
        ],
      ),
    );
  }
}

class LeftDrawer extends StatelessWidget {
  bool SuperAdmin;

  LeftDrawer({
    Key? key,required this.SuperAdmin
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration:  BoxDecoration(
                color: AppController.to.baseColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text(
                    '관리자님 안녕하세요.',
                    style: TextStyle(fontSize: 20,color: Colors.white),
                  ),
                  TextButton.icon(
                    onPressed: () async => await FirebaseAuth.instance.signOut().then((value) => Get.offAllNamed('/')),
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                    label: const Text(
                      '로그아웃',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
            SuperAdmin ? ListTile(title: const Text('회원 관리'), onTap: () => AppController.to.currentIndex(0)) : Container(),
            SuperAdmin ? ListTile(title: const Text('게시글 관리'), onTap: () => AppController.to.currentIndex(1)): Container(),
            SuperAdmin ? ListTile(title: const Text('매물 요청 리스트'), onTap: () => AppController.to.currentIndex(2)): Container(),
            SuperAdmin ? ListTile(title: const Text('광고 관리'), onTap: () => AppController.to.currentIndex(3)): Container(),
            SuperAdmin ? ListTile(title: const Text('신고 리스트'), onTap: () => AppController.to.currentIndex(4)): Container(),
            // ListTile(title: const Text('관리자 리스트'), onTap: () => AppController.to.currentIndex(5)),
            ListTile(title: const Text('세무 상담 리스트'), onTap: () => AppController.to.currentIndex(6)),
          ],
        ),
      ),
    );
  }
}
