import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class SellerUserManagement extends StatefulWidget {
  const SellerUserManagement({Key? key}) : super(key: key);

  @override
  _SellerUserManagementState createState() => _SellerUserManagementState();
}

class _SellerUserManagementState extends State<SellerUserManagement> {
  var logger = Logger();
  var users = FirebaseFirestore.instance.collection('users');
  String? searchKeyword = '';
  TextEditingController _searchKeyWordEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: searchKeyword!.isNotEmpty
          ? users.where('Type', isEqualTo: 'seller').where('PhoneNumber', isEqualTo: searchKeyword).get()
          : users.where('Type', isEqualTo: 'seller').get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          logger.i(snapshot.error);
          return Text("Something went wrong");
        }

        if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
          //문서가 존재하지 않음.
          return Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          // Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '광고주 회원 관리',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text('총 광고주 회원 수 : ${snapshot.data!.docs.length}'),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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
                          searchKeyword = '';
                          setState(() {});
                        },
                        child: Text('초기화'))
                  ],
                ),
                ListTile(
                  title: Row(
                    children: [
                      // 1631267780723
                      // Type,PhoneNumber,CreatedTime,limit
                      Expanded(child: Text('번호')),
                      Expanded(child: Text('회원 구분')),
                      Expanded(child: Text('핸드폰 번호')),
                      Expanded(child: Text('가입 일')),
                      // Expanded(child: Text('상태')),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: snapshot.data!.docs.asMap().entries.map((e) {
                      return ListTile(
                        title: Row(
                          children: [
                            // Type,PhoneNumber,CreatedTime,limit
                            Expanded(child: Text((e.key + 1).toString())),
                            Expanded(child: Text(e.value['Type'])),
                            Expanded(child: Text(e.value['PhoneNumber'])),
                            Expanded(
                              child: Text(DateFormat.yMd('ko_KR').add_jms().format(DateTime.fromMillisecondsSinceEpoch(e.value['CreatedTime']))),
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
    );
  }
}
