import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:smilebunyang/controller/app_controller.dart';
import 'package:smilebunyang/pages/sellDetailpreview.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class SellReqManagement extends StatefulWidget {
  const SellReqManagement({Key? key}) : super(key: key);

  @override
  _SellReqManagementState createState() => _SellReqManagementState();
}

class _SellReqManagementState extends State<SellReqManagement> {
  var appController = Get.put(AppController());

  var logger = Logger();
  var users = FirebaseFirestore.instance.collection('sellReqList');
  var contentCount = 0;
  String? searchKeyword = '';
  int selectedSellType = 0;
  TextEditingController _searchKeyWordEditingController = TextEditingController();
  var futureWhere;

  @override
  void initState() {
    futureWhere = users;
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
              '매물 요청 관리',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GroupButton(
                direction: Axis.horizontal,
                isRadio: true,
                spacing: 5,
                selectedColor: appController.baseColor,
                buttonWidth: 100,
                mainGroupAlignment: MainGroupAlignment.start,
                selectedButton: selectedSellType,
                onSelected: (index, isSelected) {
                  setState(() {
                    selectedSellType = index;
                    // logger.i('$selectedSellType, $index', 'Selected');
                    switch (selectedSellType) {
                      case 0:
                        //전체
                        futureWhere = users;
                        setState(() {});
                        break;
                      case 1:
                        //아파트
                        futureWhere = users.where('reqStatus', isEqualTo: true);
                        setState(() {});
                        break;
                      case 2:
                        //상가
                        futureWhere = users.where('reqStatus', isEqualTo: false);
                        setState(() {});
                        break;
                    }
                  });
                },
                buttons: ["전체", "접수", "완료"],
              ),
              Row(
                children: [
                  Container(
                    width: 200,
                    child: TextField(
                      controller: _searchKeyWordEditingController,
                      onChanged: (value) {
                        searchKeyword = value;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: () {
                        searchKeyword = _searchKeyWordEditingController.text;
                        setState(() {});
                      },
                      child: Text('검색')),
                  SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: () {
                        _searchKeyWordEditingController.text = '';
                        setState(() {});
                      },
                      child: Text('초기화'))
                ],
              )
            ],
          ),
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: searchKeyword!.isNotEmpty
                  ? futureWhere.where('UserPhoneNumber', isEqualTo: searchKeyword).orderBy('reqWriteTime', descending: true).get()
                  : futureWhere.orderBy('reqWriteTime', descending: true).get(),
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
                              // 번호 , 요청 제목, 요청 핸드폰번호, 요청일,상세보기, 문의 상태
                              Container(width: 50, child: Center(child: Text('번호'))),
                              Expanded(child: Center(child: Text('요청 제목'))),
                              Expanded(child: Center(child: Text('핸드폰번호'))),
                              Expanded(child: Center(child: Text('요청일'))),
                              Container(width: 100,child: Center(child: Text('문의내용'))),
                              Container(width: 100, child: Center(child: Text('문의상태'))),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            children: snapshot.data!.docs.asMap().entries.map((e) {
                              return ListTile(
                                title: Row(
                                  children: [
                                    //번호
                                    Container(width: 50, child: Center(child: Text((e.key + 1).toString()))),
                                    //타입
                                    Expanded(child: Center(child: Text((e.value['reqTitle'])))),
                                    //핸드폰번호
                                    Expanded(child: Center(child: Text(e.value['UserPhoneNumber']))),
                                    //가입일
                                    Expanded(
                                        child: Center(
                                      child: Text(
                                          DateFormat.yMd('ko_KR').add_jms().format(DateTime.fromMillisecondsSinceEpoch(e.value['reqWriteTime']))),
                                    )),
                                    // 문의 내용
                                    Container(
                                      width: 100,
                                      child: ElevatedButton(
                                        onPressed: () => Get.defaultDialog(title: '문의 내용', middleText: '${e.value['reqBody']}'),
                                        child: Text('문의내용'),
                                      ),
                                    ),
                                    // 문의상태
                                    // Container(width: 100, child: Center(child: Text(e.value['reqStatus'].toString()))),
                                    Container(
                                        width: 100,
                                        child: Center(
                                            child: TextButton(
                                          onPressed: () {
                                            var _status = e.value['reqStatus'];
                                            users.doc(e.value.id).update({'reqStatus': !_status}).then((value) {
                                              print("User Updated");
                                              setState(() {});
                                            }).catchError((error) => print("Failed to update user: $error"));
                                          },
                                          child: Text(e.value['reqStatus'] ? '요청' : '완료'),
                                        ))),
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
