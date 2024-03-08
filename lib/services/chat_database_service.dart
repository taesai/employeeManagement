import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatDatabaseService {
  final String? uid;
  ChatDatabaseService({this.uid});

  // reference for our collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  // updating the userdata
  Future updateUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid,
    });
  }

  //getting user data
  Future gettingUserdata(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  //get user groups
  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  //creating a group
  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });

    // update the members
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  // getting the chats
  getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  // getting the group admin
  Future getGroupAdmin(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  // getting group members
  getGroupMembers(String groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  // search
  searchByName(String groupName) {
    return groupCollection.where("groupName", isEqualTo: groupName).get();
  }

  // function -> bool
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  //toggling the group join/exit
  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    // doc reference
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];

    // if user has our groups -> then remove them or also in other part re-join.
    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

  Future<String?> uploadImageToStorage(File imageFile) async {
    try {
      // Generate a unique filename for the image
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Create a reference to the storage location
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('ChatFiles/$fileName');

      // Upload the image file to the storage location
      final UploadTask uploadTask = storageReference.putFile(imageFile);
      final TaskSnapshot uploadSnapshot = await uploadTask.whenComplete(() {});

      // Retrieve the image URL after successful upload
      final imageUrl = await uploadSnapshot.ref.getDownloadURL();

      // Return the image URL
      return imageUrl;
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadFileToStorage(File file) async {
    try {
      // Generate a unique filename for the file
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Create a reference to the storage location
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('ChatFiles/$fileName');

      // Upload the file to the storage location
      final UploadTask uploadTask = storageReference.putFile(file);
      final TaskSnapshot uploadSnapshot = await uploadTask.whenComplete(() {});

      // Retrieve the file URL after successful upload
      final fileUrl = await uploadSnapshot.ref.getDownloadURL();

      // Return the file URL
      return fileUrl;
    } catch (e) {
      return null;
    }
  }

  //send message
  // sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
  //   groupCollection.doc(groupId).collection("messages").add(chatMessageData);
  //   groupCollection.doc(groupId).update({
  //     "recentMessage": chatMessageData['message'],
  //     "recentMessageSender": chatMessageData['sender'],
  //     "recentMessageTime": chatMessageData['time'].toString(),
  //   });
  // }

  sendMessage(String groupId, Map<String, dynamic> chatMessageData,
      {String messageType = 'text'}) async {
    if (messageType == 'text') {
      groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    } else if (messageType == 'image') {
      if (chatMessageData.containsKey('image')) {
        groupCollection
            .doc(groupId)
            .collection("messages")
            .add(chatMessageData);
      } else {
        // Handle image message, e.g., upload image to storage and store the image URL
        String? imageUrl = await uploadImageToStorage(chatMessageData['image']);
        chatMessageData['image'] = imageUrl;
        groupCollection
            .doc(groupId)
            .collection("messages")
            .add(chatMessageData);
      }
    } else if (messageType == 'pdf') {
      if (chatMessageData.containsKey('fileUrl')) {
        groupCollection
            .doc(groupId)
            .collection("messages")
            .add(chatMessageData);
      } else {
        // Handle PDF file message, e.g., upload PDF to storage and store the file URL
        String? fileUrl = await uploadFileToStorage(chatMessageData['fileUrl']);
        chatMessageData['fileUrl'] = fileUrl;
        groupCollection
            .doc(groupId)
            .collection("messages")
            .add(chatMessageData);
      }
    } else if (messageType == 'docx') {
      if (chatMessageData.containsKey('fileUrl')) {
        groupCollection
            .doc(groupId)
            .collection("messages")
            .add(chatMessageData);
      } else {
        // Handle DOCX file message, e.g., upload DOCX to storage and store the file URL
        String? fileUrl = await uploadFileToStorage(chatMessageData['fileUrl']);
        chatMessageData['fileUrl'] = fileUrl;
        groupCollection
            .doc(groupId)
            .collection("messages")
            .add(chatMessageData);
      }
    }

    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
      "messageType": messageType,
    });
  }
}
