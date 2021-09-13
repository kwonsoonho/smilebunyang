import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:smilebunyang/pages/sellDetailpreview.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class adManagement extends StatefulWidget {
  const adManagement({Key? key}) : super(key: key);

  @override
  _adManagementState createState() => _adManagementState();
}

class _adManagementState extends State<adManagement> {
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
            child: Text(
              '광고 관리',
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
                selectedColor: const Color(0xff7E481A),
                // buttonWidth: 50,
                mainGroupAlignment: MainGroupAlignment.start,
                selectedButton: selectedSellType,
                onSelected: (index, isSelected) {
                  setState(() {
                    selectedSellType = index;
                    // logger.i('$selectedSellType, $index', 'Selected');
                    // setState(() {});
                    switch (selectedSellType) {
                      case 0:
                        futureWhere = users.where('ADPosition', arrayContains: 0);
                        setState(() {});
                        break;
                      case 1:
                        futureWhere = users.where('ADPosition', arrayContains: 1);
                        setState(() {});
                        break;
                      case 2:
                        futureWhere = users.where('ADPosition', arrayContains: 2);
                        setState(() {});
                        break;
                      case 3:
                        futureWhere = users.where('ADPosition', arrayContains: 3);
                        setState(() {});
                        break;
                      case 4:
                        futureWhere = users.where('ADPosition', arrayContains: 4);
                        setState(() {});
                        break;
                      case 5:
                        futureWhere = users.where('ADPosition', arrayContains: 5);
                        setState(() {});
                        break;
                      case 6:
                        futureWhere = users.where('ADPosition', arrayContains: 6);
                        setState(() {});
                        break;
                      case 7:
                        futureWhere = users.where('ADPosition', arrayContains: 7);
                        setState(() {});
                        break;
                      case 8:
                        futureWhere = users.where('ADPosition', arrayContains: 8);
                        setState(() {});
                        break;
                      case 9:
                        futureWhere = users.where('ADPosition', arrayContains: 9);
                        setState(() {});
                        break;
                      case 10:
                        futureWhere = users.where('ADPosition', arrayContains: 10);
                        setState(() {});
                        break;
                    }
                  });
                },
                buttons: ["메인 슬라이드", "메인 추천1", "메인 추천2", "메인 베너 슬라이드", "검색 추천", "검색 베너 슬라이드", "아파트", "상가", "오피스텔", "지산", "기타"],
              ),
              ElevatedButton(
                  onPressed: () {
                    // 글을 찾는다.
                    // 해글 글에 해당 애드번호가 있는지 확인한다. 있으면 있다고 알리고 닫음.
                    // 없으면 해당 글의 애드포지션에 해당 애드 번호를 부여 한다.
                    // 부여가 완료되면 추가가 되었다고 알린다.
                  },
                  child: Text('광고 추가'))
            ],
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
