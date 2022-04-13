import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:smilebunyang/controller/app_controller.dart';
import 'package:smilebunyang/controller/push_controller.dart';
import 'package:smilebunyang/pages/sellDetailpreview.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ContentManagement extends StatefulWidget {
  const ContentManagement({Key? key}) : super(key: key);

  @override
  _ContentManagementState createState() => _ContentManagementState();
}

class _ContentManagementState extends State<ContentManagement> {
  var appController = Get.put(AppController());

  var logger = Logger();
  var users = FirebaseFirestore.instance.collection('sellList');
  var contentCount = 0;
  String? searchKeyword = '';
  int selectedSellType = 0;
  TextEditingController _searchKeyWordEditingController = TextEditingController();
  var futureWhere;
  bool isApproval = false;

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
            child: const Text(
              '게시물 관리',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GroupButton(
                    direction: Axis.horizontal,
                    isRadio: true,
                    spacing: 5,
                    selectedColor: appController.baseColor,
                    buttonWidth: 80,
                    mainGroupAlignment: MainGroupAlignment.start,
                    selectedButton: 0,
                    onSelected: (index, isSelected) {
                      if (index == 0) {
                        isApproval = false;
                      } else {
                        isApproval = true;
                      }
                      setState(() {});
                    },
                    buttons: const ["미승인", "승인"],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  GroupButton(
                    direction: Axis.horizontal,
                    isRadio: true,
                    spacing: 5,
                    selectedColor: appController.baseColor,
                    buttonWidth: 80,
                    mainGroupAlignment: MainGroupAlignment.start,
                    selectedButton: selectedSellType,
                    onSelected: (index, isSelected) {
                      setState(() {
                        selectedSellType = index;
                        // logger.i('$selectedSellType, $index', 'Selected');

                        if (selectedSellType == 0) {
                          futureWhere = users;
                          setState(() {});
                        } else {
                          futureWhere = users.where('sellType', isEqualTo: selectedSellType - 1);
                          setState(() {});
                        }
                      });
                    },
                    buttons: const ["전체", "아파트", "상가", "오피스텔", "지ㆍ산", "기타"],
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _searchKeyWordEditingController,
                      onChanged: (value) {
                        searchKeyword = value;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: () {
                        searchKeyword = _searchKeyWordEditingController.text;
                        setState(() {});
                      },
                      child: const Text('검색')),
                  const SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: () {
                        _searchKeyWordEditingController.text = '';
                        setState(() {});
                      },
                      child: const Text('초기화'))
                ],
              )
            ],
          ),
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: searchKeyword!.isNotEmpty
                  ? futureWhere
                      .where('isApproval', isEqualTo: isApproval)
                      .where('indexMainTitle', arrayContains: searchKeyword)
                      .orderBy('WriteTime', descending: true)
                      .get()
                  : futureWhere.where('isApproval', isEqualTo: isApproval).orderBy('WriteTime', descending: true).get(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  logger.i(snapshot.error);
                  return Text("Something went wrong");
                }

                if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                  //문서가 존재하지 않음.
                  return const Center(child: Text("검색 결과가 없습니다."));
                }

                if (snapshot.connectionState == ConnectionState.done) {
                  // Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

                  contentCount = snapshot.data!.docs.length;
                  // logger.i(contentCount);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('총 게시물 수 : $contentCount'),
                      ListTile(
                        title: Row(
                          children: [
                            // 1631267780723
                            // Type,PhoneNumber,CreatedTime,limit
                            Container(width: 50, child: Center(child: Text('번호'))),
                            Container(width: 150, child: Center(child: Text('타입'))),
                            Expanded(child: Center(child: Text('제목'))),
                            Expanded(child: Center(child: Text('주소'))),
                            Expanded(child: Center(child: Text('작성일'))),
                            Expanded(child: Center(child: Text('작성자 번호'))),
                            Container(width: 100, child: Center(child: Text('광고 알림'))),
                            Container(width: 100, child: Center(child: Text('광고 추가'))),
                            Container(width: 100, child: Center(child: Text('상세보기'))),
                            Container(width: 100, child: Center(child: Text('승연여부'))),
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
                                  //번호
                                  Container(width: 50, child: Center(child: Text((e.key + 1).toString()))),
                                  //타입
                                  Container(width: 150, child: Center(child: Text(getSellTypeChange((e.value['sellType']))))),
                                  //제목
                                  Expanded(child: Center(child: Text(e.value['mainTitle']))),
                                  //주소
                                  Expanded(child: Center(child: Text(e.value['address']))),
                                  //작성일
                                  Expanded(
                                      child: Center(
                                    child:
                                        Text(DateFormat.yMd('ko_KR').add_jms().format(DateTime.fromMillisecondsSinceEpoch(e.value['WriteTime']))),
                                  )),
                                  //작성자 번호
                                  Expanded(child: Center(child: Text(e.value['phoneNumber']))),
                                  Container(
                                    width: 100,
                                    child: Center(
                                        child: ElevatedButton(
                                      onPressed: () {
                                        logger.i("푸쉬 발송");
                                        PostCall().sendPush(e.value['mainTitle'], e.value.id,e.value['images'][0],getSellTypeChange((e.value['sellType'])));
                                        // PostCall().sendPush();
                                      },
                                      child: Text('푸쉬 발송'),
                                    )),
                                  ),
                                  // 광고 추가
                                  Container(
                                    width: 100,
                                    child: Center(
                                        child: ElevatedButton(
                                      onPressed: () {
                                        var _addAdPosition;
                                        Get.defaultDialog(
                                            title: '광고 선택',
                                            content: GroupButton(
                                              direction: Axis.vertical,
                                              isRadio: true,
                                              spacing: 5,
                                              selectedColor: const Color(0xff7E481A),
                                              buttonWidth: 150,
                                              mainGroupAlignment: MainGroupAlignment.start,
                                              selectedButton: _addAdPosition,
                                              onSelected: (index, isSelected) {
                                                _addAdPosition = index;
                                                logger.i('$selectedSellType, $index', 'Selected');
                                              },
                                              buttons: [
                                                "메인 슬라이드",
                                                "홈 상단 광고",
                                                "메인 추천2(사용안함)"
                                                "메인 하단 슬라이드",
                                                "검색 추천",
                                                "검색 베너 슬라이드",
                                                "아파트",
                                                "상가",
                                                "오피스텔",
                                                "지산",
                                                "기타"
                                              ],
                                            ),
                                            confirm: OutlinedButton(
                                                onPressed: () async {
                                                  // 해당 글에 해당 번호가 있는지 확인
                                                  List AddList = e.value['ADPosition'];
                                                  if (AddList.contains(_addAdPosition)) {
                                                    Get.back();
                                                    Get.defaultDialog(title: '안내', middleText: '이미 해당 위치에 등록되어 있습니다.');
                                                  } else {
                                                    Get.back();
                                                    AddList.add(_addAdPosition);
                                                    await users.doc(e.value.id).update({'ADPosition': AddList}).then((value) {
                                                      Get.defaultDialog(title: '안내', middleText: '추가가 완료되었습니다.');
                                                    });
                                                    // 해당 글에 해당 번호가 없을 경우 추가
                                                  }
                                                },
                                                child: Text('광고 추가')),
                                            cancel: ElevatedButton(onPressed: () => Get.back(), child: Text('취소')));
                                      },
                                      child: Text('광고추가'),
                                    )),
                                  ),
                                  Container(
                                    width: 100,
                                    child: Center(
                                        child: ElevatedButton(
                                      onPressed: () {
                                        Get.to(SellDetailPreView(sellID: e.value.id));
                                      },
                                      child: Text('상세보기'),
                                    )),
                                  ),
                                  Container(
                                    width: 100,
                                    child: Center(
                                        child: ElevatedButton(
                                      onPressed: () {
                                        var _status = e.value['isApproval'];
                                        users.doc(e.value.id).update({'isApproval': !_status}).then((value) {
                                          print("User Updated");
                                          setState(() {});
                                        }).catchError((error) => print("Failed to update user: $error"));
                                      },
                                      child: Text(e.value['isApproval'] ? '승인' : '미승인'),
                                    )),
                                  ),
                                  Container(
                                    width: 50,
                                    child: Center(
                                      child: IconButton(
                                        onPressed: () async {
                                          Get.defaultDialog(
                                            title: '게시글 삭제 안내',
                                            middleText: '삭제되 게시글은 복구하지 못합니다. 정말 삭제하시겠습니까?',
                                            confirm: OutlinedButton(
                                                onPressed: () async {
                                                  var deleteList = [];
                                                  // imageSelectedController.defaultDialog('게시글 삭제 중');
                                                  var doc = FirebaseFirestore.instance.collection('sellList').doc(e.value.id);
                                                  await doc.snapshots().forEach(
                                                    (element) async {
                                                      deleteList = element['images'];
                                                      logger.i(deleteList, 'deleteList');
                                                      if (deleteList.isNotEmpty) {
                                                        for (var deleteImage in deleteList) {
                                                          await firebase_storage.FirebaseStorage.instance.refFromURL(deleteImage).delete();
                                                        }
                                                        await doc.delete();
                                                      } else {
                                                        // imageSelectedController.dialogCheck();
                                                        await doc.delete();
                                                      }
                                                      Get.back();
                                                      Get.defaultDialog(title: '안내', middleText: '게시글이 삭제되었습니다.');
                                                      setState(() {});
                                                    },
                                                  );
                                                },
                                                child: Text('삭제')),
                                            cancel: ElevatedButton(
                                              onPressed: () => Get.back(),
                                              child: Text('취소'),
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.delete_forever),
                                      ),
                                    ),
                                  ),
                                  //상태
                                  // Expanded(child: Text(e.value['isApproval'])),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                }

                return const Center(
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
