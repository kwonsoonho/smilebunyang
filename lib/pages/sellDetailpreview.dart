import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:smilebunyang/controller/app_controller.dart';
import 'package:smilebunyang/pages/DetailSlider.dart';

class SellDetailPreView extends StatefulWidget {
  final String sellID;

  const SellDetailPreView({Key? key, required this.sellID}) : super(key: key);

  @override
  _SellDetailPreViewState createState() => _SellDetailPreViewState();
}

class _SellDetailPreViewState extends State<SellDetailPreView> {
  // final TextEditingController _crimeReportEditingController = TextEditingController();
  CollectionReference ADList = FirebaseFirestore.instance.collection('sellList');
  var logger = Logger();
  var withSize = Get.width;
  var searchQuery;
  var isFavorite = false;
  var adPosition;
  var sellerNumber;
  var docTitle;
  var docWriteUID;
  var askCount;

  @override
  void initState() {
    askCountCheck();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('분양 상세 정보'),
      ),
      body: Center(
        child: Container(
          color: Colors.white,
          width: 412,
          height: Get.height,
          child: FutureBuilder<DocumentSnapshot>(
            future: ADList.doc(widget.sellID).get(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                logger.w(snapshot.error);
                return Center(child: Text("오류 : 앱을 다시 실행해주세요."));
              }

              if (snapshot.hasData && !snapshot.data!.exists) {
                logger.i("hasData : ${snapshot.data!.data()}");
                return Center(child: Text("문서가 존재하지 않음."));
              }

              if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                var data = snapshot.data!.data() as Map<String, dynamic>;
                docTitle = data['mainTitle'];
                docWriteUID = data['UID'];
                sellerNumber = data['phoneNumber'];
                var LikeCount = data['FavoriteList'].length;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            '사용자에게 보여지는 화면(광고, 신청등 제외) 입니다.',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Container(
                        height: 1,
                        color: Colors.black38,
                      ),
                      DetailSlider(sellID: widget.sellID),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                '[${data['localName']}] ${data['mainTitle']}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                  border: Border.fromBorderSide(BorderSide(color: AppController.to.baseColor))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['Body']),
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          DateFormat.yMd('ko_KR')
                                              .format(DateTime.fromMillisecondsSinceEpoch(data['WriteTime'])),
                                          style: TextStyle(color: Colors.black54)),
                                      Row(
                                        children: [
                                          Text('조회수 ${data['ViewCount']}', style: TextStyle(color: Colors.black54)),
                                          SizedBox(width: 10),
                                          Text('문의수 $askCount', style: TextStyle(color: Colors.black54)),
                                          SizedBox(width: 10),
                                          Text('관심수 $LikeCount', style: TextStyle(color: Colors.black54)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                                    height: 1,
                                    color: AppController.to.baseColor,
                                  ),
                                  Text(
                                    "분양 주소 : ${data['address']}",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.black54),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.done) {
                var data = snapshot.data! as Map<String, dynamic>;
                logger.i(data, 'ssss');
                // var sellDetail = data['sellDetail'];
                return Text('data');
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
    );
  }

  void askCountCheck() {
    var reqListCollection =
        FirebaseFirestore.instance.collection('CallReqList').where('docID', isEqualTo: widget.sellID);
    reqListCollection.get().then((value) {
      askCount = value.docs.length;
    });
  }

  GestureDetector bottomButtonBulider(
    String title,
    Icon getIcon,
    Function() buttonFun,
  ) {
    return GestureDetector(
      onTap: buttonFun,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Colors.black38),
          borderRadius: BorderRadius.circular(15),
        ),
        // color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [getIcon, Text(title)],
        ),
      ),
    );
  }

  String getSellTypeChange(int SellType) {
    switch (SellType) {
      case 0:
        adPosition = 6;
        return '아파트';
      case 1:
        adPosition = 7;
        return '상가';
      case 2:
        adPosition = 8;
        return '오피스텔';
      case 3:
        adPosition = 9;
        return '지식산업센터';
      case 4:
        adPosition = 10;
        return '기타';
    }
    return '';
  }
}
