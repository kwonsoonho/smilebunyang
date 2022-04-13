import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group_button/group_button.dart';
import 'package:logger/logger.dart';
import 'package:smilebunyang/controller/app_controller.dart';

class adManagement extends StatefulWidget {
  const adManagement({Key? key}) : super(key: key);

  @override
  _adManagementState createState() => _adManagementState();
}

class _adManagementState extends State<adManagement> {
  var appController = Get.put(AppController());

  var logger = Logger();
  var users = FirebaseFirestore.instance.collection('sellList');
  var contentCount = 0;
  int selectedSellType = 0;
  var futureWhere;

  @override
  void initState() {
    futureWhere = users.where('ADPosition', arrayContains: 0);
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
            child: const Text(
              '광고 관리',
              style: TextStyle(fontSize: 20),
            ),
          ),
          GroupButton(
            direction: Axis.horizontal,
            isRadio: true,
            spacing: 5,
            selectedColor: appController.baseColor,
            // buttonWidth: 50,
            mainGroupAlignment: MainGroupAlignment.start,
            selectedButton: selectedSellType,
            onSelected: (index, isSelected) {
              setState(() {
                selectedSellType = index;
                futureWhere = users.where('ADPosition', arrayContains: selectedSellType);
                setState(() {

                });
              });
            },
            buttons: const ["메인 슬라이드", "홈 광고", "사용 안함", "메인 하단 슬라이드", "검색 추천", "검색 베너 슬라이드", "아파트", "상가", "오피스텔", "지산", "기타"],
          ),
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: futureWhere.orderBy('WriteTime', descending: true).get(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                logger.i(snapshot.connectionState, 'connectionState');
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
                  // return Container(child: Text('data'),);
                  logger.i(contentCount);
                  return Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('광고 수 : $contentCount'),
                        ListTile(
                          title: Row(
                            children: [
                              // 번호, 타입, 제목, 광고주 번호, 삭제
                              Container(width: 50, child: Center(child: Text('번호'))),
                              Container(width: 100, child: Center(child: Text('타입'))),
                              Expanded(child: Center(child: Text('요청 제목'))),
                              Expanded(child: Center(child: Text('광고주 연락처'))),
                              Container(width: 50, child: Center(child: Text('삭제'))),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            children: snapshot.data!.docs.asMap().entries.map((e) {
                              return ListTile(
                                title: Row(
                                  children: [
                                    Container(width: 50, child: Center(child: Text(((e.key + 1).toString())))),
                                    Container(width: 100, child: Center(child: Text(getSellTypeChange(e.value['sellType'])))),
                                    Expanded(child: Center(child: Text(e.value['mainTitle']))),
                                    Expanded(child: Center(child: Text(e.value['phoneNumber']))),
                                    Container(
                                      width: 50,
                                      child: Center(
                                        child: IconButton(
                                          onPressed: () async {
                                            logger.i('${e.value.id}, ${e.value['ADPosition']}');
                                            users.doc(e.value.id).update({
                                              'ADPosition': FieldValue.arrayRemove([selectedSellType])
                                            }).then((value) {
                                              setState(() {});
                                            });
                                          },
                                          icon: Icon(Icons.delete_forever),
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

  String getSellTypeChange(int SellType) {
    switch (SellType) {
      case 0:
        return '아파트';
      case 1:
        return '상가';
      case 2:
        return '오피스텔';
      case 3:
        return '지식산업센터';
      case 4:
        return '기타';
    }
    return '';
  }
}
