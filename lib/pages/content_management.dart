import 'package:flutter/material.dart';

class ContentManagement extends StatefulWidget {
  const ContentManagement({Key? key}) : super(key: key);

  @override
  _ContentManagementState createState() => _ContentManagementState();
}

class _ContentManagementState extends State<ContentManagement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('ContentManagement'),),
    );
  }
}
