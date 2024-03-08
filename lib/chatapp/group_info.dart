// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_attendance_manager/chatapp/chat_home_page.dart';
import 'package:new_attendance_manager/chatapp/chat_login_status.dart';
import 'package:new_attendance_manager/chatapp/helper_functions.dart';
import 'package:new_attendance_manager/data/users.dart';
import 'package:new_attendance_manager/services/chat_database_service.dart';

class GroupInfo extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String adminName;

  const GroupInfo(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.adminName});

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;

  @override
  void initState() {
    getMembers();
    super.initState();
  }

  getMembers() {
    ChatDatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupId)
        .then((value) {
      setState(() {
        members = value;
      });
    });
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  Future<void> removeMemberFromGroup(String groupId, String memberId) async {
    final groupRef =
        FirebaseFirestore.instance.collection('groups').doc(groupId);

    try {
      final groupSnapshot = await groupRef.get();
      if (groupSnapshot.exists) {
        final members = List.from(groupSnapshot.data()?['members']);
        members.remove(memberId);
        await groupRef.update({'members': members});
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          centerTitle: true,
          title: Text("Group Info"),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: IconButton(
                  onPressed: () {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              "EXIT",
                              style: TextStyle(color: Colors.red),
                            ),
                            content: Text(
                              "Are you sure you want to exit the group?",
                              style: TextStyle(
                                  color: Colors.cyan,
                                  fontStyle: FontStyle.italic),
                            ),
                            actions: [
                              IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  )),
                              IconButton(
                                  onPressed: () async {
                                    String? memberID;
                                    setState(() {
                                      memberID =
                                          "${FirebaseAuth.instance.currentUser!.uid}_${Users.empName}";
                                    });
                                    removeMemberFromGroup(
                                            widget.groupId, memberID!)
                                        .then((_) => ChatDatabaseService(
                                                    uid: FirebaseAuth.instance
                                                        .currentUser!.uid)
                                                .toggleGroupJoin(
                                                    widget.groupId,
                                                    widget.adminName,
                                                    widget.groupName)
                                                .whenComplete(() {
                                              HelperFunctions()
                                                  .nextScreenReplace(
                                                      context, ChatHomePage());
                                            }));
                                  },
                                  icon: Icon(
                                    Icons.done,
                                    color: Colors.green,
                                  ))
                            ],
                          );
                        });
                  },
                  icon: Icon(Icons.exit_to_app)),
            )
          ],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        widget.groupName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 28),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Group: ${widget.groupName}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text("Admin: ${getName(widget.adminName)}")
                      ],
                    )
                  ],
                ),
              ),
              memberList(),
            ],
          ),
        ),
      ),
    );
  }

  memberList() {
    return StreamBuilder(
        stream: members,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data['members'] != null) {
              if (snapshot.data['members'].length != 0) {
                return ListView.builder(
                    itemCount: snapshot.data['members'].length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              getName(snapshot.data['members'][index])
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 28),
                            ),
                          ),
                          title: Text(getName(snapshot.data['members'][index])),
                          subtitle:
                              Text(getId(snapshot.data['members'][index])),
                        ),
                      );
                    });
              } else {
                return Text("No Members");
              }
            } else {
              return Text("No Members");
            }
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }
        });
  }
}
