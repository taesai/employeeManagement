// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:new_attendance_manager/data/users.dart';
import 'package:new_attendance_manager/pages/pdf_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List fields = ["Name : ", "Email : ", "Phone No : ", "Role : "];
  List details = ['name', 'email', 'phNumber', 'role'];
  QuerySnapshot? snap;
  String? employeeId;
  File? file;
  UploadTask? task;
  late SharedPreferences sharedPreferences;
  late Future<void> sharedPreferencesFuture;

  Future<void> initializeSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    sharedPreferencesFuture = initializeSharedPreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserDetails().then((_) {
        setState(() {});
        if (employeeId != null) {
          setDefaultProfileData(employeeId);
        }
      });
    });
  }

  Future<void> getUserDetails() async {
    final snap = await FirebaseFirestore.instance
        .collection("Employee")
        .where('name', isEqualTo: Users.empName)
        .get();

    if (snap.docs.isNotEmpty) {
      final documentSnapshot = snap.docs[0];
      final userId = documentSnapshot.id;
      setState(() {
        this.snap = snap;
        employeeId = userId;
      });
    }
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

  Future<void> uploadFile(String link) async {
    if (file == null) return;

    final fileName = file!.path;
    final destination = 'EmpFiles/$fileName';

    task = FirebaseStorage.instance.ref(destination).putFile(file!);

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    await sharedPreferences.setString(link, urlDownload);
  }

  Future<void> updateFile(String? employeeId, String key, String link) async {
    final collectionRef = FirebaseFirestore.instance.collection('Employee');
    final employeeDocRef = collectionRef.doc(employeeId);

    // Retrieve the document reference for the 'docs' subcollection
    final subcollectionRef = employeeDocRef.collection('docs');

    // Get the latest document from the 'docs' subcollection
    final querySnapshot = await subcollectionRef.get();
    final documents = querySnapshot.docs;

    if (documents.isNotEmpty) {
      final latestDoc = documents.last;

      // Update the existing document with the new image URL
      await latestDoc.reference.update({key: link});
    } else {
      // If no document exists, create a new document within the 'docs' subcollection
      await subcollectionRef.doc('Profile Data').set({
        'pdfUrl':
            'https://cdn.icon-icons.com/icons2/564/PNG/512/Add_Image_icon-icons.com_54218.png', // Default value for pdfUrl
        'aadharImageUrl':
            'https://cdn.icon-icons.com/icons2/564/PNG/512/Add_Image_icon-icons.com_54218.png', // Default value for aadharImageUrl
        'panImageUrl':
            'https://cdn.icon-icons.com/icons2/564/PNG/512/Add_Image_icon-icons.com_54218.png', // Default value for panImageUrl
        'profileImageUrl':
            'https://cdn.icon-icons.com/icons2/564/PNG/512/Add_Image_icon-icons.com_54218.png' // Default value for profileImageUrl
      });
    }
  }

  Future<void> setDefaultProfileData(String? employeeId) async {
    final collectionRef = FirebaseFirestore.instance.collection('Employee');
    final employeeDocRef = collectionRef.doc(employeeId);

    // Retrieve the document reference for the 'docs' subcollection
    final subcollectionRef = employeeDocRef.collection('docs');

    // Get the 'Profile Data' document from the 'docs' subcollection
    final profileDataDocRef = subcollectionRef.doc('Profile Data');

    // Check if the 'Profile Data' document already exists
    final profileDataDocSnapshot = await profileDataDocRef.get();

    if (!profileDataDocSnapshot.exists) {
      // Create a new 'Profile Data' document with default image URLs
      await profileDataDocRef.set({
        'pdfUrl':
            'https://cdn.icon-icons.com/icons2/564/PNG/512/Add_Image_icon-icons.com_54218.png',
        'aadharImageUrl':
            'https://cdn.icon-icons.com/icons2/564/PNG/512/Add_Image_icon-icons.com_54218.png',
        'panImageUrl':
            'https://cdn.icon-icons.com/icons2/564/PNG/512/Add_Image_icon-icons.com_54218.png',
        'profileImageUrl':
            'https://cdn.icon-icons.com/icons2/564/PNG/512/Add_Image_icon-icons.com_54218.png',
      });
    }
  }

  Future<bool> doesResourceExist(String? url) async {
    if (url == null) return false;

    final response = await http.head(Uri.parse(url));
    return response.statusCode == 200 &&
            response.headers['content-type']?.contains('image') == true ||
        response.headers['content-type']?.contains('pdf') == true;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[350],
          elevation: 0.0,
          centerTitle: true,
          title: const Text(
            "PROFILE",
            style: TextStyle(color: Colors.black, fontSize: 22),
          ),
        ),
        body: FutureBuilder<void>(
            future: sharedPreferencesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(
                    child: Text('Error initializing SharedPreferences'));
              }

              return Container(color: Colors.grey[350],
                child: Column(
                  
                  children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        selectFile().then((_) {
                          showDialog(
                            context: context,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            barrierDismissible: false,
                          );
              
                          uploadFile('profileLink').then((_) {
                            // File upload completed
                            Navigator.pop(context); // Close the dialog
              
                            updateFile(
                              employeeId,
                              'profileImageUrl',
                              sharedPreferences
                                  .getString('profileLink')
                                  .toString(),
                            );
                          });
                        });
                      },
                      onLongPress: () async {
                        final snapshot = await FirebaseFirestore.instance
                            .collection('Employee')
                            .doc(employeeId)
                            .collection('docs')
                            .doc('Profile Data')
                            .get();
              
                        if (snapshot.exists) {
                          final imageUrl =
                              snapshot.get('profileImageUrl').toString();
              
                          if (imageUrl.isNotEmpty &&
                              imageUrl !=
                                  'https://cdn.icon-icons.com/icons2/564/PNG/512/Add_Image_icon-icons.com_54218.png' &&
                              imageUrl != 'null') {
                            // Check if the image URL is valid
                            doesResourceExist(imageUrl).then((isValid) {
                              if (isValid) {
                                showDialog(
                                  context: context,
                                  builder: (context) => Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 100,
                                    ),
                                    child:
                                        Image.network(imageUrl, fit: BoxFit.fill),
                                  ),
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) => const AlertDialog(
                                    title: Text(
                                      "Alert !!",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    content: Text(
                                      "Kindly upload your profile image first.",
                                      style: TextStyle(color: Colors.cyan),
                                    ),
                                  ),
                                );
                              }
                            });
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) => const AlertDialog(
                                title: Text(
                                  "Alert !!",
                                  style: TextStyle(color: Colors.red),
                                ),
                                content: Text(
                                  "Kindly upload your profile image first.",
                                  style: TextStyle(color: Colors.cyan),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Employee')
                            .doc(employeeId)
                            .collection('docs')
                            .doc('Profile Data')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircleAvatar(
                              radius: 80,
                              backgroundColor: Colors.cyan,
                              child: Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white),
                              ),
                            );
                          } else if (snapshot.hasData && snapshot.data!.exists) {
                            final imageUrl =
                                snapshot.data!.get('profileImageUrl').toString();
              
                            if (imageUrl ==
                                    'https://cdn.icon-icons.com/icons2/564/PNG/512/Add_Image_icon-icons.com_54218.png' ||
                                imageUrl == 'null') {
                              return CircleAvatar(
                                radius: 80,
                                backgroundColor: Colors.black,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.add_a_photo,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "Add Image...",
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return CircleAvatar(
                                radius: 80,
                                backgroundImage: imageUrl.isNotEmpty
                                    ? NetworkImage(imageUrl)
                                    : null,
                                backgroundColor: Colors.black,
                              );
                            }
                          } else {
                            return CircleAvatar(
                              radius: 80,
                              backgroundColor: Colors.black,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.add_a_photo,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: fields.length,
                    itemBuilder: (context, index) {
                      if (snap?.docs.isNotEmpty == true) {
                        final documentSnapshot = snap!.docs[0];
                        final data =
                            documentSnapshot.data() as Map<String, dynamic>?;
              
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 5),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 60,
                            decoration: BoxDecoration(
                              
                              color: Colors.grey[300],
                              border: Border.all(color: Colors.amber,width: 3 ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Text(
                                fields[index] + (data?[details[index]] ?? ''),
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 18),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 5),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Text(
                                fields[index] + "Loading...",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),

                  Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 60, vertical: 20),
                      decoration: BoxDecoration(
                          border: Border.all(
                            
                            color: Colors.amber,
                            width: 3),
                        
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.center,
                      child: const Text("Private Training (Soon...)",
                          style: TextStyle(
                            
                            color: Colors.white,
                            fontSize: 20)
                            ),
                    ),
                  // GestureDetector(
                  //   onTap: () {
                    //   showDialog(
                    //       context: context,
                    //       builder: (context) => Container(
                    //             width: MediaQuery.of(context).size.width,
                    //             margin: const EdgeInsets.symmetric(
                    //                 horizontal: 20, vertical: 200),
                    //             decoration: BoxDecoration(
                    //                 color: Colors.white,
                    //                 borderRadius: BorderRadius.circular(12)),
                    //             child: Column(
                    //               mainAxisAlignment: MainAxisAlignment.start,
                    //               crossAxisAlignment: CrossAxisAlignment.center,
                    //               children: [
                    //                 Container(decoration: BoxDecoration(border: Border.all(color: Colors.white,
                    //                 width: 2) ),
                    //                   child: const Padding(
                    //                     padding: EdgeInsets.symmetric(vertical: 10),
                    //                     child: Text(
                    //                       "Docs",
                    //                       style: TextStyle(
                    //                           color: Colors.black, fontSize: 24),
                    //                     ),
                    //                   ),
                    //                 ),
                    //                 Container(
                    //                   height: 60,
                    //                   width: MediaQuery.of(context).size.width,
                    //                   margin: const EdgeInsets.symmetric(
                    //                       horizontal: 20, vertical: 20),
                    //                   decoration: BoxDecoration(
                    //                       color: Colors.black,
                    //                       borderRadius:
                    //                           BorderRadius.circular(12)),
                    //                   child: Row(
                    //                     mainAxisAlignment:
                    //                         MainAxisAlignment.start,
                    //                     children: [
                    //                       GestureDetector(
                    //                         onTap: () {
                    //                           selectFile().then((_) {
                    //                             showDialog(
                    //                               context: context,
                    //                               builder: (context) =>
                    //                                   const Center(
                    //                                 child:
                    //                                     CircularProgressIndicator(),
                    //                               ),
                    //                               barrierDismissible: false,
                    //                             );
              
                    //                             uploadFile('aadharLink')
                    //                                 .then((_) {
                    //                               // File upload completed
                    //                               Navigator.pop(
                    //                                   context); // Close the dialog
              
                    //                               updateFile(
                    //                                 employeeId,
                    //                                 'aadharImageUrl',
                    //                                 sharedPreferences
                    //                                     .getString('aadharLink')
                    //                                     .toString(),
                    //                               );
                    //                             });
                    //                           });
                    //                         },
                    //                         child: Container(
                    //                           height: 55,
                    //                           width: 55,
                    //                           margin: const EdgeInsets.only(
                    //                               left: 2.5),
                    //                           decoration: BoxDecoration(
                    //                               color: Colors.white,
                    //                               borderRadius:
                    //                                   BorderRadius.circular(12)),
                    //                           child:
                    //                               StreamBuilder<DocumentSnapshot>(
                    //                             stream: FirebaseFirestore.instance
                    //                                 .collection('Employee')
                    //                                 .doc(employeeId)
                    //                                 .collection('docs')
                    //                                 .doc('Profile Data')
                    //                                 .snapshots(),
                    //                             builder: (BuildContext context,
                    //                                 AsyncSnapshot<
                    //                                         DocumentSnapshot>
                    //                                     snapshot) {
                    //                               if (snapshot.connectionState ==
                    //                                   ConnectionState.waiting) {
                    //                                 return const CircleAvatar(
                    //                                   radius: 40,
                    //                                   backgroundColor:
                    //                                       Colors.cyan,
                    //                                   child: Center(
                    //                                     child:
                    //                                         CircularProgressIndicator(
                    //                                             color:
                    //                                                 Colors.white),
                    //                                   ),
                    //                                 );
                    //                               } else if (snapshot.hasData &&
                    //                                   snapshot.data!.exists) {
                    //                                 final imageUrl = snapshot
                    //                                     .data!
                    //                                     .get('aadharImageUrl')
                    //                                     .toString();
              
                    //                                 if (imageUrl ==
                    //                                         'https://cdn.icon-icons.com/icons2/564/PNG/512/Add_Image_icon-icons.com_54218.png' ||
                    //                                     imageUrl == 'null') {
                    //                                   return CircleAvatar(
                    //                                     radius: 40,
                    //                                     backgroundColor:
                    //                                         Colors.cyan,
                    //                                     child: Column(
                    //                                       mainAxisAlignment:
                    //                                           MainAxisAlignment
                    //                                               .center,
                    //                                       children: const [
                    //                                         Icon(
                    //                                           Icons.add_a_photo,
                    //                                           color: Colors.white,
                    //                                           size: 24,
                    //                                         ),
                    //                                       ],
                    //                                     ),
                    //                                   );
                    //                                 } else {
                    //                                   return CircleAvatar(
                    //                                     radius: 80,
                    //                                     backgroundImage:
                    //                                         imageUrl.isNotEmpty
                    //                                             ? NetworkImage(
                    //                                                 imageUrl)
                    //                                             : null,
                    //                                     backgroundColor:
                    //                                         Colors.cyan,
                    //                                   );
                    //                                 }
                    //                               } else {
                    //                                 return CircleAvatar(
                    //                                   radius: 40,
                    //                                   backgroundColor:
                    //                                       Colors.cyan,
                    //                                   child: Column(
                    //                                     mainAxisAlignment:
                    //                                         MainAxisAlignment
                    //                                             .center,
                    //                                     children: const [
                    //                                       Icon(
                    //                                         Icons.add_a_photo,
                    //                                         color: Colors.white,
                    //                                         size: 24,
                    //                                       ),
                    //                                     ],
                    //                                   ),
                    //                                 );
                    //                               }
                    //                             },
                    //                           ),
                    //                         ),
                    //                       ),
                    //                       const SizedBox(width: 30),
                    //                       Row(
                    //                         children: [
                    //                           const Text(
                    //                             "Aadhar Card",
                    //                             style: TextStyle(
                    //                                 color: Colors.white,
                    //                                 fontSize: 22),
                    //                           ),
                    //                           const SizedBox(
                    //                             width: 20,
                    //                           ),
                    //                           GestureDetector(
                    //                             onTap: () async {
                    //                               final snapshot =
                    //                                   await FirebaseFirestore
                    //                                       .instance
                    //                                       .collection('Employee')
                    //                                       .doc(employeeId)
                    //                                       .collection('docs')
                    //                                       .doc('Profile Data')
                    //                                       .get();
              
                    //                               if (snapshot.exists) {
                    //                                 final imageUrl = snapshot
                    //                                     .get('aadharImageUrl')
                    //                                     .toString();
              
                    //                                 if (imageUrl.isNotEmpty &&
                    //                                     imageUrl !=
                    //                                         'https://cdn.icon-icons.com/icons2/564/PNG/512/Add_Image_icon-icons.com_54218.png' &&
                    //                                     imageUrl != 'null') {
                    //                                   // Check if the image URL is valid
                    //                                   doesResourceExist(imageUrl)
                    //                                       .then((isValid) {
                    //                                     if (isValid) {
                    //                                       showDialog(
                    //                                         context: context,
                    //                                         builder: (context) =>
                    //                                             Container(
                    //                                           width:
                    //                                               MediaQuery.of(
                    //                                                       context)
                    //                                                   .size
                    //                                                   .width,
                    //                                           margin:
                    //                                               const EdgeInsets
                    //                                                   .symmetric(
                    //                                             horizontal: 20,
                    //                                             vertical: 100,
                    //                                           ),
                    //                                           child:
                    //                                               Image.network(
                    //                                                   imageUrl,
                    //                                                   fit: BoxFit
                    //                                                       .fill),
                    //                                         ),
                    //                                       );
                    //                                     } else {
                    //                                       showDialog(
                    //                                         context: context,
                    //                                         builder: (context) =>
                    //                                             const AlertDialog(
                    //                                           title: Text(
                    //                                             "Alert !!",
                    //                                             style: TextStyle(
                    //                                                 color: Colors
                    //                                                     .red),
                    //                                           ),
                    //                                           content: Text(
                    //                                             "Kindly upload your aadhar image first.",
                    //                                             style: TextStyle(
                    //                                                 color: Colors
                    //                                                     .cyan),
                    //                                           ),
                    //                                         ),
                    //                                       );
                    //                                     }
                    //                                   });
                    //                                 } else {
                    //                                   showDialog(
                    //                                     context: context,
                    //                                     builder: (context) =>
                    //                                         const AlertDialog(
                    //                                       title: Text(
                    //                                         "Alert !!",
                    //                                         style: TextStyle(
                    //                                             color:
                    //                                                 Colors.red),
                    //                                       ),
                    //                                       content: Text(
                    //                                         "Kindly upload your aadhar image first.",
                    //                                         style: TextStyle(
                    //                                             color:
                    //                                                 Colors.cyan),
                    //                                       ),
                    //                                     ),
                    //                                   );
                    //                                 }
                    //                               }
                    //                             },
                    //                             child: Container(
                    //                               height: 45,
                    //                               width: 70,
                    //                               decoration: BoxDecoration(
                    //                                   color: Colors.cyan,
                    //                                   border: Border.all(
                    //                                       width: 2,
                    //                                       color: Colors.white),
                    //                                   borderRadius:
                    //                                       BorderRadius.circular(
                    //                                           12)),
                    //                               alignment: Alignment.center,
                    //                               child: const Text(
                    //                                 "VIEW",
                    //                                 style: TextStyle(
                    //                                     fontSize: 18,
                    //                                     color: Colors.white),
                    //                               ),
                    //                             ),
                    //                           ),
                    //                         ],
                    //                       )
                    //                     ],
                    //                   ),
                    //                 ),
                    //                 Container(
                    //                   height: 60,
                    //                   width: MediaQuery.of(context).size.width,
                    //                   margin: const EdgeInsets.symmetric(
                    //                       horizontal: 20),
                    //                   decoration: BoxDecoration(
                    //                       color: Colors.cyan,
                    //                       borderRadius:
                    //                           BorderRadius.circular(12)),
                    //                   child: Row(
                    //                     mainAxisAlignment:
                    //                         MainAxisAlignment.start,
                    //                     children: [
                    //                       GestureDetector(
                    //                         onTap: () {
                    //                           selectFile().then((_) {
                    //                             showDialog(
                    //                               context: context,
                    //                               builder: (context) =>
                    //                                   const Center(
                    //                                 child:
                    //                                     CircularProgressIndicator(),
                    //                               ),
                    //                               barrierDismissible: false,
                    //                             );
              
                    //                             uploadFile('panLink').then((_) {
                    //                               // File upload completed
                    //                               Navigator.pop(
                    //                                   context); // Close the dialog
              
                    //                               updateFile(
                    //                                 employeeId,
                    //                                 'panImageUrl',
                    //                                 sharedPreferences
                    //                                     .getString('panLink')
                    //                                     .toString(),
                    //                               );
                    //                             });
                    //                           });
                    //                         },
                    //                         child: Container(
                    //                           height: 55,
                    //                           width: 55,
                    //                           margin: const EdgeInsets.only(
                    //                               left: 2.5),
                    //                           decoration: BoxDecoration(
                    //                               color: Colors.white,
                    //                               borderRadius:
                    //                                   BorderRadius.circular(12)),
                    //                           child:
                    //                               StreamBuilder<DocumentSnapshot>(
                    //                             stream: FirebaseFirestore.instance
                    //                                 .collection('Employee')
                    //                                 .doc(employeeId)
                    //                                 .collection('docs')
                    //                                 .doc('Profile Data')
                    //                                 .snapshots(),
                    //                             builder: (BuildContext context,
                    //                                 AsyncSnapshot<
                    //                                         DocumentSnapshot>
                    //                                     snapshot) {
                    //                               if (snapshot.connectionState ==
                    //                                   ConnectionState.waiting) {
                    //                                 return const CircleAvatar(
                    //                                   radius: 40,
                    //                                   backgroundColor:
                    //                                       Colors.cyan,
                    //                                   child: Center(
                    //                                     child:
                    //                                         CircularProgressIndicator(
                    //                                             color:
                    //                                                 Colors.white),
                    //                                   ),
                    //                                 );
                    //                               } else if (snapshot.hasData &&
                    //                                   snapshot.data!.exists) {
                    //                                 final imageUrl = snapshot
                    //                                     .data!
                    //                                     .get('panImageUrl')
                    //                                     .toString();
              
                    //                                 if (imageUrl ==
                    //                                         'https://cdn.icon-icons.com/icons2/564/PNG/512/Add_Image_icon-icons.com_54218.png' ||
                    //                                     imageUrl == 'null') {
                    //                                   return CircleAvatar(
                    //                                     radius: 40,
                    //                                     backgroundColor:
                    //                                         Colors.cyan,
                    //                                     child: Column(
                    //                                       mainAxisAlignment:
                    //                                           MainAxisAlignment
                    //                                               .center,
                    //                                       children: const [
                    //                                         Icon(
                    //                                           Icons.add_a_photo,
                    //                                           color: Colors.white,
                    //                                           size: 24,
                    //                                         ),
                    //                                       ],
                    //                                     ),
                    //                                   );
                    //                                 } else {
                    //                                   return CircleAvatar(
                    //                                     radius: 80,
                    //                                     backgroundImage:
                    //                                         imageUrl.isNotEmpty
                    //                                             ? NetworkImage(
                    //                                                 imageUrl)
                    //                                             : null,
                    //                                     backgroundColor:
                    //                                         Colors.cyan,
                    //                                   );
                    //                                 }
                    //                               } else {
                    //                                 return CircleAvatar(
                    //                                   radius: 40,
                    //                                   backgroundColor:
                    //                                       Colors.cyan,
                    //                                   child: Column(
                    //                                     mainAxisAlignment:
                    //                                         MainAxisAlignment
                    //                                             .center,
                    //                                     children: const [
                    //                                       Icon(
                    //                                         Icons.add_a_photo,
                    //                                         color: Colors.white,
                    //                                         size: 24,
                    //                                       ),
                    //                                     ],
                    //                                   ),
                    //                                 );
                    //                               }
                    //                             },
                    //                           ),
                    //                         ),
                    //                       ),
                    //                       const SizedBox(width: 30),
                    //                       Row(
                    //                         children: [
                    //                           const Text(
                    //                             "Pan Card",
                    //                             style: TextStyle(
                    //                                 color: Colors.white,
                    //                                 fontSize: 22),
                    //                           ),
                    //                           const SizedBox(
                    //                             width: 50,
                    //                           ),
                    //                           GestureDetector(
                    //                             onTap: () async {
                    //                               final snapshot =
                    //                                   await FirebaseFirestore
                    //                                       .instance
                    //                                       .collection('Employee')
                    //                                       .doc(employeeId)
                    //                                       .collection('docs')
                    //                                       .doc('Profile Data')
                    //                                       .get();
              
                    //                               if (snapshot.exists) {
                    //                                 final imageUrl = snapshot
                    //                                     .get('panImageUrl')
                    //                                     .toString();
              
                    //                                 if (imageUrl.isNotEmpty &&
                    //                                     imageUrl !=
                    //                                         'https://cdn.icon-icons.com/icons2/564/PNG/512/Add_Image_icon-icons.com_54218.png' &&
                    //                                     imageUrl != 'null') {
                    //                                   // Check if the image URL is valid
                    //                                   doesResourceExist(imageUrl)
                    //                                       .then((isValid) {
                    //                                     if (isValid) {
                    //                                       showDialog(
                    //                                         context: context,
                    //                                         builder: (context) =>
                    //                                             Container(
                    //                                           width:
                    //                                               MediaQuery.of(
                    //                                                       context)
                    //                                                   .size
                    //                                                   .width,
                    //                                           margin:
                    //                                               const EdgeInsets
                    //                                                   .symmetric(
                    //                                             horizontal: 20,
                    //                                             vertical: 100,
                    //                                           ),
                    //                                           child:
                    //                                               Image.network(
                    //                                                   imageUrl,
                    //                                                   fit: BoxFit
                    //                                                       .fill),
                    //                                         ),
                    //                                       );
                    //                                     } else {
                    //                                       showDialog(
                    //                                         context: context,
                    //                                         builder: (context) =>
                    //                                             const AlertDialog(
                    //                                           title: Text(
                    //                                             "Alert !!",
                    //                                             style: TextStyle(
                    //                                                 color: Colors
                    //                                                     .red),
                    //                                           ),
                    //                                           content: Text(
                    //                                             "Kindly upload your pan image first.",
                    //                                             style: TextStyle(
                    //                                                 color: Colors
                    //                                                     .cyan),
                    //                                           ),
                    //                                         ),
                    //                                       );
                    //                                     }
                    //                                   });
                    //                                 } else {
                    //                                   showDialog(
                    //                                     context: context,
                    //                                     builder: (context) =>
                    //                                         const AlertDialog(
                    //                                       title: Text(
                    //                                         "Alert !!",
                    //                                         style: TextStyle(
                    //                                             color:
                    //                                                 Colors.red),
                    //                                       ),
                    //                                       content: Text(
                    //                                         "Kindly upload your pan image first.",
                    //                                         style: TextStyle(
                    //                                             color:
                    //                                                 Colors.cyan),
                    //                                       ),
                    //                                     ),
                    //                                   );
                    //                                 }
                    //                               }
                    //                             },
                    //                             child: Container(
                    //                               height: 45,
                    //                               width: 70,
                    //                               decoration: BoxDecoration(
                    //                                   color: Colors.cyan,
                    //                                   border: Border.all(
                    //                                       width: 2,
                    //                                       color: Colors.white),
                    //                                   borderRadius:
                    //                                       BorderRadius.circular(
                    //                                           12)),
                    //                               alignment: Alignment.center,
                    //                               child: const Text(
                    //                                 "VIEW",
                    //                                 style: TextStyle(
                    //                                     fontSize: 18,
                    //                                     color: Colors.white),
                    //                               ),
                    //                             ),
                    //                           ),
                    //                         ],
                    //                       )
                    //                     ],
                    //                   ),
                    //                 ),
                    //                 Container(
                    //                   height: 60,
                    //                   width: MediaQuery.of(context).size.width,
                    //                   margin: const EdgeInsets.symmetric(
                    //                       horizontal: 20, vertical: 20),
                    //                   decoration: BoxDecoration(
                    //                     color: Colors.cyan,
                    //                     borderRadius: BorderRadius.circular(12),
                    //                   ),
                    //                   child: Row(
                    //                     mainAxisAlignment:
                    //                         MainAxisAlignment.start,
                    //                     children: [
                    //                       GestureDetector(
                    //                         onTap: () {
                    //                           selectFile().then((_) {
                    //                             showDialog(
                    //                               context: context,
                    //                               builder: (context) =>
                    //                                   const Center(
                    //                                 child:
                    //                                     CircularProgressIndicator(),
                    //                               ),
                    //                               barrierDismissible: false,
                    //                             );
              
                    //                             uploadFile('resumeLink')
                    //                                 .then((_) {
                    //                               // File upload completed
                    //                               Navigator.pop(
                    //                                   context); // Close the dialog
              
                    //                               updateFile(
                    //                                 employeeId,
                    //                                 'pdfUrl',
                    //                                 sharedPreferences
                    //                                     .getString('resumeLink')
                    //                                     .toString(),
                    //                               );
                    //                             });
                    //                           });
                    //                         },
                    //                         child: Container(
                    //                           height: 55,
                    //                           width: 55,
                    //                           margin: const EdgeInsets.only(
                    //                               left: 2.5),
                    //                           decoration: BoxDecoration(
                    //                             color: Colors.white,
                    //                             borderRadius:
                    //                                 BorderRadius.circular(12),
                    //                           ),
                    //                           child:
                    //                               StreamBuilder<DocumentSnapshot>(
                    //                             stream: FirebaseFirestore.instance
                    //                                 .collection('Employee')
                    //                                 .doc(employeeId)
                    //                                 .collection('docs')
                    //                                 .doc('Profile Data')
                    //                                 .snapshots(),
                    //                             builder: (BuildContext context,
                    //                                 AsyncSnapshot<
                    //                                         DocumentSnapshot>
                    //                                     snapshot) {
                    //                               if (snapshot.connectionState ==
                    //                                   ConnectionState.waiting) {
                    //                                 return const CircleAvatar(
                    //                                   radius: 80,
                    //                                   backgroundColor:
                    //                                       Colors.cyan,
                    //                                   child: Center(
                    //                                     child:
                    //                                         CircularProgressIndicator(
                    //                                             color:
                    //                                                 Colors.white),
                    //                                   ),
                    //                                 );
                    //                               } else if (snapshot.hasData &&
                    //                                   snapshot.data!.exists) {
                    //                                 final pdfUrl = snapshot.data!
                    //                                     .get('pdfUrl')
                    //                                     .toString();
                    //                                 if (pdfUrl ==
                    //                                         'https://cdn.icon-icons.com/icons2/564/PNG/512/Add_Image_icon-icons.com_54218.png' ||
                    //                                     pdfUrl == 'null') {
                    //                                   return const CircleAvatar(
                    //                                     radius: 40,
                    //                                     backgroundColor:
                    //                                         Colors.cyan,
                    //                                     child: Center(
                    //                                       child: Icon(
                    //                                         Icons.upload_file,
                    //                                         color: Colors.white,
                    //                                         size: 24,
                    //                                       ),
                    //                                     ),
                    //                                   );
                    //                                 } else {
                    //                                   return const CircleAvatar(
                    //                                     radius: 40,
                    //                                     backgroundColor:
                    //                                         Colors.cyan,
                    //                                     child: Center(
                    //                                       child: Icon(
                    //                                         Icons
                    //                                             .picture_as_pdf_outlined,
                    //                                         color: Colors.white,
                    //                                         size: 24,
                    //                                       ),
                    //                                     ),
                    //                                   );
                    //                                 }
                    //                               } else {
                    //                                 return const CircleAvatar(
                    //                                   radius: 40,
                    //                                   backgroundColor:
                    //                                       Colors.cyan,
                    //                                   child: Center(
                    //                                     child: Icon(
                    //                                       Icons.upload_file,
                    //                                       color: Colors.white,
                    //                                       size: 24,
                    //                                     ),
                    //                                   ),
                    //                                 );
                    //                               }
                    //                             },
                    //                           ),
                    //                         ),
                    //                       ),
                    //                       const SizedBox(width: 30),
                    //                       Row(
                    //                         children: [
                    //                           const Text(
                    //                             "Resume",
                    //                             style: TextStyle(
                    //                                 color: Colors.white,
                    //                                 fontSize: 22),
                    //                           ),
                    //                           const SizedBox(
                    //                             width: 60,
                    //                           ),
                    //                           GestureDetector(
                    //                             onTap: () async {
                    //                               final snapshot =
                    //                                   await FirebaseFirestore
                    //                                       .instance
                    //                                       .collection('Employee')
                    //                                       .doc(employeeId)
                    //                                       .collection('docs')
                    //                                       .doc('Profile Data')
                    //                                       .get();
              
                    //                               if (snapshot.exists) {
                    //                                 final pdfUrl = snapshot
                    //                                     .get('pdfUrl')
                    //                                     .toString();
              
                    //                                 if (pdfUrl.isNotEmpty &&
                    //                                     pdfUrl !=
                    //                                         'https://cdn.icon-icons.com/icons2/564/PNG/512/Add_Image_icon-icons.com_54218.png' &&
                    //                                     pdfUrl != 'null') {
                    //                                   // Check if the PDF URL is valid
                    //                                   doesResourceExist(pdfUrl)
                    //                                       .then((isValid) {
                    //                                     if (isValid) {
                    //                                       Navigator.push(
                    //                                         context,
                    //                                         MaterialPageRoute(
                    //                                           builder: (context) =>
                    //                                               PdfPage(
                    //                                                   pdfUrl:
                    //                                                       pdfUrl),
                    //                                         ),
                    //                                       );
                    //                                     } else {
                    //                                       showDialog(
                    //                                         context: context,
                    //                                         builder: (context) =>
                    //                                             const AlertDialog(
                    //                                           title: Text(
                    //                                             "Alert !!",
                    //                                             style: TextStyle(
                    //                                                 color: Colors
                    //                                                     .red),
                    //                                           ),
                    //                                           content: Text(
                    //                                             "Kindly upload your resume first.",
                    //                                             style: TextStyle(
                    //                                                 color: Colors
                    //                                                     .cyan),
                    //                                           ),
                    //                                         ),
                    //                                       );
                    //                                     }
                    //                                   });
                    //                                 } else {
                    //                                   showDialog(
                    //                                     context: context,
                    //                                     builder: (context) =>
                    //                                         const AlertDialog(
                    //                                       title: Text(
                    //                                         "Alert !!",
                    //                                         style: TextStyle(
                    //                                             color:
                    //                                                 Colors.red),
                    //                                       ),
                    //                                       content: Text(
                    //                                         "Kindly upload your resume first.",
                    //                                         style: TextStyle(
                    //                                             color:
                    //                                                 Colors.cyan),
                    //                                       ),
                    //                                     ),
                    //                                   );
                    //                                 }
                    //                               }
                    //                             },
                    //                             child: Container(
                    //                               height: 45,
                    //                               width: 70,
                    //                               decoration: BoxDecoration(
                    //                                   color: Colors.cyan,
                    //                                   border: Border.all(
                    //                                       width: 2,
                    //                                       color: Colors.white),
                    //                                   borderRadius:
                    //                                       BorderRadius.circular(
                    //                                           12)),
                    //                               alignment: Alignment.center,
                    //                               child: const Text(
                    //                                 "VIEW",
                    //                                 style: TextStyle(
                    //                                     fontSize: 18,
                    //                                     color: Colors.white),
                    //                               ),
                    //                             ),
                    //                           ),
                    //                         ],
                    //                       )
                    //                     ],
                    //                   ),
                    //                 )
                    //               ],
                    //             ),
                    //           ));
                    // },
                    // child:
                    //  Container(
                    //   height: 50,
                    //   width: MediaQuery.of(context).size.width,
                    //   margin: const EdgeInsets.symmetric(
                    //       horizontal: 60, vertical: 20),
                    //   decoration: BoxDecoration(
                    //       border: Border.all(
                            
                    //         color: Colors.amber,
                    //         width: 3),
                        
                    //       color: Colors.black,
                    //       borderRadius: BorderRadius.circular(12)),
                    //   alignment: Alignment.center,
                    //   child: const Text("Private Training (Soon...)",
                    //       style: TextStyle(
                            
                    //         color: Colors.white,
                    //         fontSize: 20)
                    //         ),
                    // ),
                  //),
                ]),
              );
            }),
      ),
    );
  }
}
