import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:convert' show Encoding, json;
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

var logger = Logger();

class PostCall {
  final postUrl = 'https://fcm.googleapis.com/fcm/send';

  void sendPush(String title, String page, String image, String type) {
    var sendCount = 0;
    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAAlraZXLE:APA91bGJxr9lmOnVHHNfLnbfQ6GZ82mGvzQLFMmXCy510TslcdxILRxObEDcxMdUSbs6XJpy8s5SRbpV4xydZJkvKsTKthqKwywzz_CZTRseOGP8Jeypge1p09qLcap1sbUlud90JFu1'
    };

    FirebaseFirestore.instance
        .collection('users')
        .where('PhoneNumber',
            isEqualTo:
                "01041043676")
        .get()
        .then((QuerySnapshot querySnapshot) async {
    // FirebaseFirestore.instance.collection('users').where('Type', isEqualTo: "normal").get().then((QuerySnapshot querySnapshot) async {
      for (var doc in querySnapshot.docs) {
        final data = {
          "notification": {"body": "[$type] $title", "image": image},
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "detail": page,
            // "update" : ""
          },
          "to": doc["Token"],
          "priority":"high",
        };

        final response = await http.post(Uri.parse(postUrl), body: json.encode(data), encoding: Encoding.getByName('utf-8'), headers: headers);

        if (response.statusCode == 200) {
          // on success do sth
          logger.i("${response.statusCode} page $page", "statusCode");
          sendCount += 1;
          // return true;
        } else {
          logger.i(response.statusCode, "statusCode");
          // on failure do sth
          // return false;
        }
        logger.i("${doc["Token"]} ${doc["Type"]}");
      }
      logger.i("발송 종료");

      Get.defaultDialog(
          title: "발송 성공 안내", middleText: "$sendCount 명에게 발송하였습니다.", confirm: OutlinedButton(onPressed: () => Get.close(0), child: const Text("확인")));
    });
  }
}
