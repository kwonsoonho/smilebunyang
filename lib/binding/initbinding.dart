import 'package:get/get.dart';
import 'package:smilebunyang/controller/app_controller.dart';

class InitBinding implements Bindings {
  // 얘를 사용할 곳에서 Controller을 사용하겠다고 선언해 줘야 한다.
  @override
  void dependencies() {
    Get.put(AppController());
  }
}