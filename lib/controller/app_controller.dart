import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

enum RoutName { UserManagement, contentManagement, requestList, adManagement, crimeReport, pushSend  }

class AppController extends GetxService {
  static AppController get to => Get.find();
  var logger = Logger();
  Color baseColor = Color(0xff7E481A);
  RxInt currentIndex = 0.obs;

  void changePageIndex(int index) {
    currentIndex(index);
    // logger.i(currentIndex);
  }

  @override
  void onInit() {
    currentIndex = 0.obs;
    super.onInit();
  }
}
