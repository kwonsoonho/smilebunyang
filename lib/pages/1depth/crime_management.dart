import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:smilebunyang/controller/app_controller.dart';
import 'package:smilebunyang/pages/sellDetailpreview.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class CrimeManagement extends StatefulWidget {
  const CrimeManagement({Key? key}) : super(key: key);

  @override
  _CrimeManagementState createState() => _CrimeManagementState();
}

class _CrimeManagementState extends State<CrimeManagement> {
  var appController = Get.put(AppController());

  var logger = Logger();
  var users = FirebaseFirestore.instance.collection('CrimeReport');
  var contentCount = 0;
  var futureWhere;

  @override
  void initState() {
    futureWhere = users.where('crimeStatus', isEqualTo: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              '신고 관리',
              style: TextStyle(fontSize: 20),
            ),
          ),
          GroupButton(
            direction: Axis.horizontal,
            isRadio: true,
            spacing: 5,
            selectedColor: appController.baseColor,
            buttonWidth: 100,
            mainGroupAlignment: MainGroupAlignment.start,
            selectedButton: 0,
            onSelected: (index, isSelected) {
              setState(() {
                if (index == 0) {
                  futureWhere = users.where('crimeStatus', isEqualTo: false);
                } else {
                  futureWhere = users.where('crimeStatus', isEqualTo: true);
                }
                setState(() {});
              });
            },
            buttons: ["미 처리", "처리"],
          ),
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: futureWhere.orderBy('reportTime', descending: true).get(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  logger.i(snapshot.error);
                  return Text("Something went wrong");
                }

                if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                  //문서가 존재하지 않음.
                  return Center(child: Text("검색 결과가 없습니다."));
                }

                if (snapshot.connectionState == ConnectionState.done) {
                  // Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

                  contentCount = snapshot.data!.docs.length;
                  // logger.i(contentCount);
                  return Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('총 문의 수 : $contentCount'),
                        ListTile(
                          title: Row(
                            children: [
                              // 번호
                              // 내용
                              // 시간
                              // 신고자 // 생략
                              // 상태
                              // 글 상세보기
                              Container(width: 50, child: Center(child: Text('번호'))),
                              Expanded(child: Center(child: Text('신고 내용'))),
                              Expanded(child: Center(child: Text('신고일'))),
                              Container(width: 100, child: Center(child: Text('처리상태'))),
                              Container(width: 100, child: Center(child: Text('신고 글'))),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            children: snapshot.data!.docs.asMap().entries.map((e) {
                              return ListTile(
                                title: Row(
                                  children: [
                                    Container(width: 50, child: Center(child: Text((e.key + 1).toString()))),
                                    Expanded(child: Center(child: Text((e.value['reason'])))),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                            DateFormat.yMd('ko_KR').add_jms().format(DateTime.fromMillisecondsSinceEpoch(e.value['reportTime']))),
                                      ),
                                    ),
                                    // 문의 내용
                                    Container(
                                      width: 100,
                                      child: Center(
                                        child: TextButton(
                                          onPressed: () {
                                            var _status = e.value['crimeStatus'];
                                            users.doc(e.value.id).update({'crimeStatus': !_status}).then((value) {
                                              print("User Updated");
                                              setState(() {});
                                            }).catchError((error) => print("Failed to update user: $error"));
                                          },
                                          child: Text(e.value['crimeStatus'] ? '처리' : '미 처리'),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 100,
                                      child: Center(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Get.to(SellDetailPreView(sellID: e.value['docID']));
                                          },
                                          child: Text('상세보기'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
