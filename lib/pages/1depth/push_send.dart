import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert' show Encoding, json;
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class PushSend extends StatefulWidget {
  const PushSend({Key? key}) : super(key: key);

  @override
  _PushSendState createState() => _PushSendState();
}

class _PushSendState extends State<PushSend> {
  var logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: OutlinedButton(
            onPressed: () {
              // Https 보내기
              makeCall();
            },
            child: Text("푸쉬보내기"),
          ),
        ),
      ),
    );
  }

  final postUrl = 'https://fcm.googleapis.com/fcm/send';
  final data = {
    // 타이틀에 제목 넣고 , 바디는 없어도 될듯
    "notification": {"title": "this is a title"},
    // "priority": "high",
    "data": {
      // 여기에 문서 번호 넣고
      "detail": "7jNTZ2uXxsqn55jgk7g4",
    },
    "to":
        "fXVrtOh4SXSJppkCut9iZC:APA91bFtWGrVJ6TO6RDhJ5sBrPe4nxqZPrnZR_hZj9oReXdPW3NUJ1tKBLq1qljb4uS3UoGzI8MGXh1LN4UtVQ1yljH3xVZz5TPejVyGJEW2FiB6m1HtGmYk1-n60eNgz2wdxiS4UzxH"
  };

  Future<bool> makeCall() async {
    logger.i("send");
    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAAlraZXLE:APA91bGJxr9lmOnVHHNfLnbfQ6GZ82mGvzQLFMmXCy510TslcdxILRxObEDcxMdUSbs6XJpy8s5SRbpV4xydZJkvKsTKthqKwywzz_CZTRseOGP8Jeypge1p09qLcap1sbUlud90JFu1'
    };

    final response = await http.post(Uri.parse(postUrl),
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      // on success do sth
      logger.i(response.statusCode,"statusCode");
      return true;
    } else {
      print("실패");
      // on failure do sth
      return false;
    }
  }
}


