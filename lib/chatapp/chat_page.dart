// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_attendance_manager/chatapp/group_info.dart';
import 'package:new_attendance_manager/chatapp/helper_functions.dart';
import 'package:new_attendance_manager/services/chat_database_service.dart';
import 'package:new_attendance_manager/widgets/file_message_tile.dart';
import 'package:new_attendance_manager/widgets/image_message_tile.dart';
import 'package:new_attendance_manager/widgets/message_tile.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  const ChatPage(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.userName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();

  String admin = "";
  File? file;
  String? imageUrl;
  String? fileUrl;

  @override
  void initState() {
    getChatandAdmin();

    super.initState();
  }

  getChatandAdmin() {
    ChatDatabaseService().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
    ChatDatabaseService().getGroupAdmin(widget.groupId).then((value) {
      setState(() {
        admin = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0.0,
          centerTitle: true,
          title: Text(widget.groupName),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: IconButton(
                  onPressed: () {
                    HelperFunctions().nextScreen(
                        context,
                        GroupInfo(
                            groupId: widget.groupId,
                            groupName: widget.groupName,
                            adminName: admin));
                  },
                  icon: Icon(Icons.info)),
            )
          ],
        ),
        body: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                "assets/chat_background_image.jpg",
                fit: BoxFit.fitHeight,
              ),
            ),
            chatMessage(),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                width: MediaQuery.of(context).size.width,
                color: Colors.grey[700],
                child: Row(
                  children: [
                    PopupMenuButton<int>(
                      icon: Icon(
                        CupertinoIcons.paperclip,
                        color: Colors.white,
                      ),
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          value: 1,
                          child: ListTile(
                            leading: Icon(
                              CupertinoIcons.photo,
                              color: Colors.cyan,
                            ),
                            title: Text(
                              'IMAGE',
                              selectionColor: Colors.cyan,
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: ListTile(
                            leading: Icon(
                              CupertinoIcons.doc,
                              color: Colors.cyan,
                            ),
                            title: Text('DOCUMENT'),
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        // Handle the selected value
                        switch (value) {
                          case 1:
                            // Perform function for Option 1
                            selectFile().whenComplete(() => uploadImage()
                                .whenComplete(() => sendMessage()));
                            break;
                          case 2:
                            // Perform function for Option 2
                            selectFile().whenComplete(() =>
                                uploadFile().whenComplete(() => sendMessage()));
                            break;
                        }
                      },
                    ),
                    Expanded(
                        child: TextFormField(
                      controller: messageController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          hintText: "Send a message...",
                          hintStyle:
                              TextStyle(color: Colors.white, fontSize: 16),
                          border: InputBorder.none),
                    )),
                    SizedBox(
                      width: 12,
                    ),
                    GestureDetector(
                        onTap: () {
                          sendMessage();
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(25)),
                          child: Center(
                              child: Icon(
                            Icons.send,
                            color: Colors.white,
                          )),
                        ))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null || result.count == 0) {
      // No file selected, set file to null
      setState(() {
        file = null;
      });
      return;
    }

    final path = result.files.single.path!;

    setState(() {
      file = File(path);
    });
  }

  Future<void> uploadImage() async {
    if (file == null) {
      // No file selected, so do not update Firestore
      return;
    }

    final fileName = file!.path;
    final destination = 'ChatFiles/$fileName';

    try {
      final ref = FirebaseStorage.instance.ref(destination);
      final task = await ref.putFile(file!);
      final urlDownload = await task.ref.getDownloadURL();

      setState(() {
        imageUrl = urlDownload;
      });
    } catch (e) {}
  }

  Future<void> uploadFile() async {
    if (file == null) {
      // No file selected, so do not update Firestore
      return;
    }

    final fileName = file!.path;
    final destination = 'ChatFiles/$fileName';

    try {
      final ref = FirebaseStorage.instance.ref(destination);
      final task = await ref.putFile(file!);
      final urlDownload = await task.ref.getDownloadURL();

      setState(() {
        fileUrl = urlDownload;
      });
    } catch (e) {}
  }

  // chatMessage() {
  //   final scrollController = ScrollController();

  //   return StreamBuilder(
  //       stream: chats,
  //       builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
  //         if (snapshot.hasError) {
  //           return Center(
  //             child: Text("Error: ${snapshot.error}"),
  //           );
  //         }
  //         if (!snapshot.hasData) {
  //           return Center(
  //             child: CircularProgressIndicator(),
  //           );
  //         }

  //         final messages = snapshot.data!.docs.map((doc) => MessageTile(
  //               message: doc["message"],
  //               sender: doc["sender"],
  //               sentByMe: widget.userName == doc["sender"],
  //             ));

  //         WidgetsBinding.instance.addPostFrameCallback((_) {
  //           scrollController.animateTo(
  //             scrollController.position.maxScrollExtent,
  //             duration: Duration(milliseconds: 500),
  //             curve: Curves.easeInOut,
  //           );
  //         });

  //         return ListView(
  //           controller: scrollController,
  //           padding: EdgeInsets.only(bottom: 100),
  //           children: messages.toList(),
  //         );
  //       });
  // }

  chatMessage() {
    final scrollController = ScrollController();

    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}"),
          );
        }
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final messages = snapshot.data!.docs.map((doc) {
          final messageType = doc["messageType"];

          if (messageType == "text") {
            return MessageTile(
              message: doc["message"],
              sender: doc["sender"],
              sentByMe: widget.userName == doc["sender"],
            );
          } else if (messageType == "image") {
            final imageUrl = doc["image"];
            return ImageMessageTile(
              imageUrl: imageUrl,
              sender: doc["sender"],
              sentByMe: widget.userName == doc["sender"],
            );
          } else if (messageType == "pdf") {
            final fileUrl = doc["fileUrl"];
            return FileMessageTile(
              fileUrl: fileUrl,
              sender: doc["sender"],
              sentByMe: widget.userName == doc["sender"],
            );
          } else if (messageType == "docx") {
            final fileUrl = doc["fileUrl"];
            return FileMessageTile(
              fileUrl: fileUrl,
              sender: doc["sender"],
              sentByMe: widget.userName == doc["sender"],
            );
          }

          // Handle other message types here if needed

          return SizedBox(); // Return an empty container if the messageType is not recognized
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });

        return ListView(
          controller: scrollController,
          padding: EdgeInsets.only(bottom: 100),
          children: messages.toList(),
        );
      },
    );
  }

  // sendMessage() {
  //   if (messageController.text.isNotEmpty) {
  //     Map<String, dynamic> chatMessageMap = {
  //       "message": messageController.text,
  //       "sender": widget.userName,
  //       "time": DateTime.now().millisecondsSinceEpoch,
  //     };

  //     ChatDatabaseService().sendMessage(widget.groupId, chatMessageMap);
  //     setState(() {
  //       messageController.clear();
  //     });
  //   }
  // }

  sendMessage() async {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "messageType": "text",
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      await ChatDatabaseService().sendMessage(
        widget.groupId,
        chatMessageMap,
        messageType: 'text',
      );
      setState(() {
        messageController.clear();
      });
    } else if (file != null) {
      if (file!.path.endsWith('.pdf')) {
        // Handle PDF file
        await uploadFile();

        if (fileUrl != null) {
          Map<String, dynamic> chatMessageMap = {
            "fileUrl": fileUrl,
            "messageType": "pdf",
            "sender": widget.userName,
            "time": DateTime.now().millisecondsSinceEpoch,
          };

          await ChatDatabaseService().sendMessage(
            widget.groupId,
            chatMessageMap,
            messageType: 'pdf',
          );
          setState(() {
            file = null;
            fileUrl = null;
          });
        }
      } else if (file!.path.endsWith('.docx')) {
        // Handle DOCX file
        await uploadFile();

        if (fileUrl != null) {
          Map<String, dynamic> chatMessageMap = {
            "fileUrl": fileUrl,
            "messageType": "docx",
            "sender": widget.userName,
            "time": DateTime.now().millisecondsSinceEpoch,
          };

          await ChatDatabaseService().sendMessage(
            widget.groupId,
            chatMessageMap,
            messageType: 'docx',
          );
          setState(() {
            file = null;
            fileUrl = null;
          });
        }
      } else {
        // Handle image file
        await uploadFile();

        if (imageUrl != null) {
          Map<String, dynamic> chatMessageMap = {
            "image": imageUrl,
            "messageType": "image",
            "sender": widget.userName,
            "time": DateTime.now().millisecondsSinceEpoch,
          };

          await ChatDatabaseService().sendMessage(
            widget.groupId,
            chatMessageMap,
            messageType: 'image',
          );
          setState(() {
            file = null;
            imageUrl = null;
          });
        }
      }
    }
  }
}
