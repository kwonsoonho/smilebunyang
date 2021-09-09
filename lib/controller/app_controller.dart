import 'package:get/get.dart';
import 'package:logger/logger.dart';

enum RoutName { userManagement, contentManagement, crimeReport, requestList, addManagement }

class AppController extends GetxService {
  static AppController get to => Get.find();
  var logger = Logger();

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
