import 'package:flutter/material.dart';
import 'package:new_attendance_manager/chatapp/chat_home_page.dart';
import 'package:new_attendance_manager/chatapp/chat_login_page.dart';
import 'package:new_attendance_manager/chatapp/helper_functions.dart';

class ChatLoginStatus extends StatefulWidget {
  const ChatLoginStatus({super.key});

  @override
  State<ChatLoginStatus> createState() => _ChatLoginStatusState();
}

class _ChatLoginStatusState extends State<ChatLoginStatus> {
  bool isSignedIn = false;

  @override
  void initState() {
    super.initState();
    getUserLoggedInStatus();
  }

  getUserLoggedInStatus() async {
    await HelperFunctions.getUserLoggedInStatus().then((value) {
      if (value != null) {
        setState(() {
          isSignedIn = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primaryColor: HelperFunctions().primaryColor,
          scaffoldBackgroundColor: Colors.white),
      debugShowCheckedModeBanner: false,
      home: isSignedIn ? const ChatHomePage() : const ChatLoginPage(),
    );
  }
}
