import 'package:flutter/material.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({Key? key}) : super(key: key);

  @override
  _UserManagementState createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('UserManagement'),),
    );
  }
}
