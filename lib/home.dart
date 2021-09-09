import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:smilebunyang/controller/app_controller.dart';
import 'package:smilebunyang/pages/content_management.dart';
import 'package:smilebunyang/pages/user_management.dart';

class HomePage extends GetView<AppController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('미소분양 관리자 페이지'),
      ),
      body: Row(
        children: [
          LeftDrawer(),
          Expanded(
            child: Obx(() {
              // controller 에다가 enum을 통해 페이지를 선언해 주고 배열로 인덱스를 주면 연동 된다.
              // enum RoutName { userManagement, contentManagement, crimeReport, requestList, addManagement }

              switch (RoutName.values[controller.currentIndex.value]) {
                case RoutName.userManagement:
                  return UserManagement();
                case RoutName.contentManagement:
                  return ContentManagement();
                case RoutName.crimeReport:
                  return UserManagement();
                case RoutName.requestList:
                  return UserManagement();
                case RoutName.addManagement:
                  return UserManagement();
              }
              return Container();
            }),
          ),
        ],
      ),
    );
  }
}

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  '미소 분양 관리자님 안녕하세요.',
                  style: TextStyle(fontSize: 20),
                ),
                TextButton.icon(
                  onPressed: () {},
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
          ListTile(title: const Text('회원 관리'), onTap: () => AppController.to.currentIndex(0)),
          ListTile(title: const Text('게시글 관리'), onTap: () => AppController.to.currentIndex(1)),
          ListTile(title: const Text('신고 리스트'), onTap: () => AppController.to.currentIndex(2)),
          ListTile(title: const Text('매물 요청 리스트'), onTap: ()  => AppController.to.currentIndex(3)),
          ListTile(title: const Text('광고 관리'), onTap: ()  => AppController.to.currentIndex(4)),
        ],
      ),
    );
  }
}
