import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:smilebunyang/controller/app_controller.dart';

class AdminManagement extends StatefulWidget {
  const AdminManagement({Key? key}) : super(key: key);

  @override
  _AdminManagementState createState() => _AdminManagementState();
}

class _AdminManagementState extends State<AdminManagement> {
  var appController = Get.put(AppController());

  var logger = Logger();
  var users = FirebaseFirestore.instance.collection('admin');
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
              '관리자 권한 관리',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // GroupButton(
              //   direction: Axis.horizontal,
              //   isRadio: true,
              //   spacing: 5,
              //   selectedColor: appController.baseColor,
              //   buttonWidth: 100,
              //   mainGroupAlignment: MainGroupAlignment.start,
              //   selectedButton: selectedSellType,
              //   onSelected: (index, isSelected) {
              //     setState(() {
              //       selectedSellType = index;
              //       // logger.i('$selectedSellType, $index', 'Selected');
              //       switch (selectedSellType) {
              //         case 0:
              //         //전체
              //           futureWhere = users;
              //           setState(() {});
              //           break;
              //         case 1:
              //         //아파트
              //           futureWhere = users.where('Type', isEqualTo: 'normal');
              //           setState(() {});
              //           break;
              //         case 2:
              //         //상가
              //           futureWhere = users.where('Type', isEqualTo: 'seller');
              //           setState(() {});
              //           break;
              //       }
              //     });
              //   },
              //   buttons: ["전체", "일반 사용자", "광고주"],
              // ),
              // Row(
              //   children: [
              //     Container(
              //       width: 200,
              //       child: TextField(
              //         controller: _searchKeyWordEditingController,
              //         onChanged: (value) {
              //           searchKeyword = value;
              //         },
              //       ),
              //     ),
              //     SizedBox(width: 10),
              //     ElevatedButton(
              //         onPressed: () {
              //           searchKeyword = _searchKeyWordEditingController.text;
              //           setState(() {});
              //         },
              //         child: Text('검색')),
              //     SizedBox(width: 10),
              //     ElevatedButton(
              //         onPressed: () {
              //           _searchKeyWordEditingController.text = '';
              //           setState(() {});
              //         },
              //         child: Text('초기화'))
              //   ],
              // )
            ],
          ),
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future:
              // searchKeyword!.isNotEmpty
              //     ? futureWhere.where('PhoneNumber', isEqualTo: searchKeyword).orderBy('CreatedTime', descending: true).get()
                  futureWhere.get(),
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
                        Text('총 사용 수 : $contentCount'),
                        ListTile(
                          title: Row(
                            children: [
                              // 1631267780723
                              // Type,PhoneNumber,CreatedTime,limit
                              // Container(width: 50, child: Center(child: Text('번호'))),
                              // Expanded(child: Center(child: Text('타입'))),
                              Expanded(child: Center(child: Text('이메일'))),
                              Expanded(child: Center(child: Text('권한'))),
                              Expanded(child: Center(child: Text('승인여부'))),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            children: snapshot.data!.docs.asMap().entries.map((e) {
                              return ListTile(
                                title: Row(
                                  children: [
                                    //핸드폰번호
                                    Expanded(child: Center(child: Text(e.value['Email']))),
                                    Expanded(child: Center(child: Text(e.value['Power']))),
                                    Expanded(
                                      child: Container(
                                        width: 100,
                                        child: Center(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                var _status = e.value['Type'];
                                                users.doc(e.value.id).update({'Type': !_status}).then((value) {
                                                  setState(() {});
                                                }).catchError((error) => print("Failed to update user: $error"));
                                              },
                                              child: Text(e.value['Type'] ? '승인' : '미승인'),
                                            )),
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
