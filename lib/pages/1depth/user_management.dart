import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({Key? key}) : super(key: key);

  @override
  _UserManagementState createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  var logger = Logger();
  var users = FirebaseFirestore.instance.collection('users');
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
              '회원 관리',
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
                        futureWhere = users.where('Type', isEqualTo: 'normal');
                        setState(() {});
                        break;
                      case 2:
                        //상가
                        futureWhere = users.where('Type', isEqualTo: 'seller');
                        setState(() {});
                        break;
                    }
                  });
                },
                buttons: ["전체", "일반 사용자", "광고주"],
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
                  ? futureWhere.where('PhoneNumber', isEqualTo: searchKeyword).orderBy('CreatedTime', descending: true).get()
                  : futureWhere.orderBy('CreatedTime', descending: true).get(),
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
                              Container(width: 50, child: Center(child: Text('번호'))),
                              Expanded(child: Center(child: Text('타입'))),
                              Expanded(child: Center(child: Text('핸드폰번호'))),
                              Expanded(child: Center(child: Text('가입일'))),
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
                                    Expanded(child: Center(child: Text(getSellTypeChange(e.value['Type'])))),
                                    //핸드폰번호
                                    Expanded(child: Center(child: Text(e.value['PhoneNumber']))),
                                    //가입일
                                    Expanded(
                                        child: Center(
                                      child:
                                          Text(DateFormat.yMd('ko_KR').add_jms().format(DateTime.fromMillisecondsSinceEpoch(e.value['CreatedTime']))),
                                    )),
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

  String getSellTypeChange(String Type) {
    switch (Type) {
      case 'normal':
        return '일반';
      case 'seller':
        return '광고주';
    }
    return '';
  }
}
