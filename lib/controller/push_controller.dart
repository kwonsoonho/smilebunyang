import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert' show Encoding, json;
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

var logger = Logger();

class PostCall {
  final postUrl = 'https://fcm.googleapis.com/fcm/send';


  void sendPush(String title, String page, String image, String type) {
    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAAlraZXLE:APA91bGJxr9lmOnVHHNfLnbfQ6GZ82mGvzQLFMmXCy510TslcdxILRxObEDcxMdUSbs6XJpy8s5SRbpV4xydZJkvKsTKthqKwywzz_CZTRseOGP8Jeypge1p09qLcap1sbUlud90JFu1'
    };

    // FirebaseFirestore.instance
    //     .collection('users')
    //     .where('Token',
    //         isEqualTo:
    //             "fmXv_PQGSwKAwoOqRDh2aF:APA91bFrlDcf5F4pr6Kc5BEaJ4bb55zPSnu1koJfdD9hQ3i7vZNwcSgdwb3NIOqdmYK4PHZdW3Qf6XUIdk4vbQszORjGqC59U2ZUDUn-2NoB7XNWVhUB3iyRumSELimvnFQlp4QTr4Qk")
    //     .get()
    //     .then((QuerySnapshot querySnapshot) async {
      FirebaseFirestore.instance.collection('users').where('Type', isEqualTo: "normal").get().then((QuerySnapshot querySnapshot) async {
      for (var doc in querySnapshot.docs) {
        final data = {
          "notification": {"body": "[$type] $title", "image": image},
          "data": {
            "detail": page,
          },
          "to": doc["Token"]
        };

        final response = await http.post(Uri.parse(postUrl), body: json.encode(data), encoding: Encoding.getByName('utf-8'), headers: headers);

        if (response.statusCode == 200) {
          // on success do sth
          logger.i(response.statusCode, "statusCode");
          return true;
        } else {
          logger.i(response.statusCode, "statusCode");
          // on failure do sth
          return false;
        }

        // logger.i("${doc["Token"]} ${doc["Type"]}");
      }
    });
  }

// Future<bool> makeCall(String title, String page, String image, String type) async {
//   final headers = {
//     'content-type': 'application/json',
//     'Authorization':
//         'key=AAAAlraZXLE:APA91bGJxr9lmOnVHHNfLnbfQ6GZ82mGvzQLFMmXCy510TslcdxILRxObEDcxMdUSbs6XJpy8s5SRbpV4xydZJkvKsTKthqKwywzz_CZTRseOGP8Jeypge1p09qLcap1sbUlud90JFu1'
//   };
//
//   // 여기까지 고정
//
//   final data = {
//     // 타이틀에 제목 넣고 , 바디는 없어도 될듯
//     "notification": {"body": "[$type] $title", "image": image},
//     // "priority": "high",
//     "data": {
//       // 여기에 문서 번호 넣고
//       "detail": page,
//     },
//     "to":
//         "fmXv_PQGSwKAwoOqRDh2aF:APA91bFrlDcf5F4pr6Kc5BEaJ4bb55zPSnu1koJfdD9hQ3i7vZNwcSgdwb3NIOqdmYK4PHZdW3Qf6XUIdk4vbQszORjGqC59U2ZUDUn-2NoB7XNWVhUB3iyRumSELimvnFQlp4QTr4Qk"
//   };
//
//   final response = await http.post(Uri.parse(postUrl), body: json.encode(data), encoding: Encoding.getByName('utf-8'), headers: headers);
//
//   if (response.statusCode == 200) {
//     // on success do sth
//     logger.i(response.statusCode, "statusCode");
//     return true;
//   } else {
//     logger.i(response.statusCode, "statusCode");
//     // on failure do sth
//     return false;
//   }
// }

}
