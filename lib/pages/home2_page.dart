// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:new_attendance_manager/chatapp/chat_login_status.dart';
import 'package:new_attendance_manager/data/users.dart';
import 'package:new_attendance_manager/pages/login_page.dart';
import 'package:new_attendance_manager/widgets/custom_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:sprintf/sprintf.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String checkInAm = '00:00:00 AM';
  String checkOutAm = '00:00:00 AM';
  String checkInPm = '00:00:00 PM';
  String checkOutPm = '00:00:00 PM';
  String agenda = "No Agenda for today";
  String assignedTask = "No task assigned";
  late SharedPreferences sharedPreferences;
  TextEditingController agendaController = TextEditingController();

  @override
  void initState() {

     _getRecord();
    
    Future.delayed(Duration.zero, () {
       _determinePosition().then((_) {
                      setState(() {
                        myLocationPm = currentAddress;
                        myLocationAm = currentAddress;
                      });     
                    });    
                  });
  }

  

  void _getRecord() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("Employee")
          .where('name', isEqualTo: Users.empName)
          .get();
      DocumentSnapshot snap2 = await FirebaseFirestore.instance
          .collection("Employee")
          .doc(snap.docs[0].id)
          .collection("RecordAm")
          .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
          .get();
      DocumentSnapshot snap3 = await FirebaseFirestore.instance
          .collection("Employee")
          .doc(snap.docs[0].id)
          .collection("RecordPm")
          .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
          .get();
      setState(() {
        checkInAm = snap2['checkIn'];
        checkOutAm = snap2['checkOut'];
        checkInPm = snap3['checkIn'];
        checkOutPm = snap3['checkOut'];
        agenda = snap2['agenda'];
        assignedTask = snap2['assignedtask'];
      });
    } catch (e) {
      setState(() {
        checkInAm = '00:00:00 AM';
        checkOutAm = '00:00:00 AM';

        checkInPm = '00:00:00 PM';
        checkOutPm = '00:00:00 PM';

        agenda = "No Agenda for today";
        assignedTask = "No task assigned";
      });
    }
  }

  Future<void> signOut() async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear().then((_) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    });
  }

  String getHoursWorked(String checkInTime, String checkOutTime) {
    DateTime checkInAm = DateFormat('hh:mm:ss a').parse(checkInTime);
    DateTime checkOutAm = DateFormat('hh:mm:ss a').parse(checkOutTime);
    DateTime checkInPm = DateFormat('hh:mm:ss a').parse(checkInTime);
    DateTime checkOutPm = DateFormat('hh:mm:ss a').parse(checkOutTime);
    Duration duration =
        checkOutAm.difference(checkInAm) + checkOutPm.difference(checkInPm);

    int hours = duration.inMinutes ~/ 60;
    int minutes = (duration.inMinutes % 60).toInt();
    String formattedDuration = sprintf("%d Hrs:%02d Min", [hours, minutes]);
    return formattedDuration;
  }

  Duration checkDuration(String checkInTime, String checkOutTime) {
    String durationString = getHoursWorked(checkInTime, checkOutTime);
    Duration duration = Duration(
        hours: int.parse(durationString.split(' ')[0]),
        minutes: int.parse(durationString.split(':')[1].split(' ')[0]));
    return duration;
  }

  String currentAddress = 'My Address';
  late Position currentposition;
  late String myLocationPm;
  late String myLocationAm;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Please enable Your Location Service');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg:
              'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];

      // Get the address of the current location using the Geocoding API
      List<Placemark> addresses = await placemarkFromCoordinates(
          position.latitude, position.longitude,
          localeIdentifier: Platform.localeName);
      String address = addresses[0].name ?? '';

      setState(() {
        currentposition = position;
        currentAddress =
            "$address, ${place.postalCode}, ${place.locality}, ${place.country}";
      });
    } catch (e) {}

    return position;
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            backgroundColor: Colors.grey[350],
            elevation: 0.0,
            leadingWidth: 300,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        "  Welcome!",
                        style: TextStyle(
                            color: Colors.black,
                            fontStyle: FontStyle.italic,
                            fontSize: 20),
                      ),
                      SizedBox(width: 50),
                      Text(
                        Users.empName,
                        style: TextStyle(
                            color: Colors.orangeAccent,
                            fontSize: 26,
                            fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                  onPressed: () => _openDrawer(),
                  icon: Icon(
                    Icons.menu,
                    color: Colors.black,
                    size: 32,
                  ))
            ],
          ),
          endDrawer: Drawer(
            elevation: 0.0,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      Users.empName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.chat,
                    color: Colors.grey,
                  ),
                  title: Text(
                    'CHAT',
                    style: TextStyle(
                        color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                  // onTap: () {
                  //   Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (context) => ChatLoginStatus()));
                  // },
                ),
                ListTile(
                  leading: Icon(
                    Icons.location_history,
                    color: Colors.orange,
                  ),
                  title: Text(
                    'LOCATION',
                    style: TextStyle(
                        color: Colors.orange, fontStyle: FontStyle.italic),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          Center(child: CircularProgressIndicator()),
                      barrierDismissible: false,
                    );
                    _determinePosition().then((_) {
                      setState(() {
                        myLocationPm = currentAddress;
                        myLocationAm = currentAddress;
                      });
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Your Currect Location"),
                              titleTextStyle:
                                  TextStyle(color: Colors.orange, fontSize: 18),
                              content: Text(currentAddress),
                              contentTextStyle: TextStyle(color: Colors.red),
                            );
                          });
                    });
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.note_add,
                    color: Colors.grey,
                  ),
                  title: Text(
                    'AGENDA',
                    style: TextStyle(
                        color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                  // onTap: ()
                  //  {
                  //   showDialog(
                  //     barrierDismissible: false,
                  //     context: context,
                  //     builder: (context) => AlertDialog(
                  //       titleTextStyle: TextStyle(
                  //           color: Colors.orange,
                  //           fontSize: 22,
                  //           fontStyle: FontStyle.italic),
                  //       title: Text("TODAY's AGENDA"),
                  //       content: SizedBox(
                  //         width: 300,
                  //         child: CustomField(
                  //             controller: agendaController,
                  //             labelText: null,
                  //             obscureText: false,
                  //             suffixIcon: null),
                  //       ),
                  //       actions: [
                  //         GestureDetector(
                  //             onTap: () => Navigator.pop(context),
                  //             child: Padding(
                  //               padding: const EdgeInsets.symmetric(
                  //                   vertical: 5.0, horizontal: 10),
                  //               child: Text(
                  //                 "OK",
                  //                 style: TextStyle(
                  //                     color: Colors.orange, fontSize: 24),
                  //               ),
                  //             ))
                  //       ],
                  //     ),
                  //   );
                  // },
                ),
                ListTile(
                  leading: Icon(
                    Icons.today_outlined,
                    color: Colors.grey,
                  ),
                  title: Text(
                    'ASSIGNED TASK',
                    style: TextStyle(
                        color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                //   onTap: () async {
                //     QuerySnapshot snap = await FirebaseFirestore.instance
                //         .collection("Employee")
                //         .where('name', isEqualTo: Users.empName)
                //         .get();
                //     showDialog(
                //       context: context,
                //       builder: (context) => StreamBuilder<DocumentSnapshot>(
                //         stream: FirebaseFirestore.instance
                //             .collection('Employee')
                //             .doc(snap.docs[0].id)
                //             .collection('docs')
                //             .doc(DateFormat('dd MMMM yyyy')
                //                 .format(DateTime.now()))
                //             .snapshots(),
                //         builder: (context, snapshot) {
                //           if (!snapshot.hasData) {
                //             return Center(child: CircularProgressIndicator());
                //           }
                //           final recordData =
                //               snapshot.data?.data() as Map<String, dynamic>?;
                //           if (recordData == null) {
                //             return AlertDialog(
                //               title: Text("No Task Assigned Yet"),
                //               actions: [
                //                 TextButton(
                //                   onPressed: () => Navigator.pop(context),
                //                   child: Text(
                //                     "OK",
                //                     style: TextStyle(
                //                       color: Colors.orange,
                //                       fontSize: 24,
                //                     ),
                //                   ),
                //                 ),
                //               ],
                //             );
                //           }
                //           final assignedTask =
                //               recordData['assignedtask'] as String?;

                //           if (assignedTask == null) {
                //             return AlertDialog(
                //               title: Text("No Task Assigned Yet"),
                //               actions: [
                //                 TextButton(
                //                   onPressed: () => Navigator.pop(context),
                //                   child: Text(
                //                     "OK",
                //                     style: TextStyle(
                //                       color: Colors.orange,
                //                       fontSize: 24,
                //                     ),
                //                   ),
                //                 ),
                //               ],
                //             );
                //           }

                //           return AlertDialog(
                //             titleTextStyle: TextStyle(
                //                 color: Colors.orange,
                //                 fontSize: 22,
                //                 fontStyle: FontStyle.italic),
                //             title: Text("YOUR TASK"),
                //             content: Text(assignedTask),
                //             actions: [
                //               GestureDetector(
                //                 onTap: () => Navigator.pop(context),
                //                 child: Padding(
                //                   padding: const EdgeInsets.symmetric(
                //                       vertical: 5.0, horizontal: 10),
                //                   child: Text(
                //                     "OK",
                //                     style: TextStyle(
                //                         color: Colors.orange, fontSize: 24),
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           );
                //         },
                //       ),
                //     );
                //   },
                ),
                ListTile(
                  leading: Icon(
                    Icons.exit_to_app,
                    color: Colors.orange,
                  ),
                  title: Text(
                    'LOGOUT',
                    style: TextStyle(
                        color: Colors.orangeAccent,
                        fontStyle: FontStyle.italic),
                  ),
                  onTap: () {
                    signOut();
                  },
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  child: Text(
                    "Today's Status",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      height: 0100,
                      width: 160,
                      decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black,
                                blurRadius: 5,
                                offset: Offset(1, 3))
                          ]),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Date",
                              style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            DateFormat('dd MMM yyyy')
                                .format(DateTime.now())
                                .toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      //mainAxisAlignment: MainAxisAlignment.center,
                    ),

                    // SizedBox(
                    //   width: 2,
                    // ),

                    Container(
                      padding: EdgeInsets.all(5),
                      alignment: Alignment.center,
                      margin:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      height: 100,
                      width: 160,
                      decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black,
                                blurRadius: 5,
                                offset: Offset(1, 3))
                          ]),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Time",
                              style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          StreamBuilder(
                              stream:
                                  Stream.periodic(const Duration(seconds: 1)),
                              builder: (context, snapshot) {
                                return Text(
                                  DateFormat('hh:mm:ss a')
                                      .format(DateTime.now()),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                );
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
                //SizedBox(height: 10,),

                Center(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    height: 30,
                    width: 120,
                     decoration: 
              
                const BoxDecoration(color:Colors.black54,
                  borderRadius: BorderRadius.all(
                    Radius.circular(5)
                    ),
                    boxShadow:  [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 5,
                          spreadRadius: 1,
                          offset: Offset(2, 3)
                        ),
                      ],
      
                
                  ),
                    child: Text(
                      "Morning:",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black,
                            blurRadius: 5,
                            offset: Offset(1, 3))
                      ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Check In",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.orangeAccent),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            checkInAm,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Check Out",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.orangeAccent)),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            checkOutAm,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                checkOutAm == '00:00:00 AM'
                    ? Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Builder(builder: (context) {
                          final GlobalKey<SlideActionState> key = GlobalKey();

                          return SlideAction(
                            text: checkInAm == '00:00:00 AM'
                                ? "Slide to Check In"
                                : "Slide to Check Out",
                            sliderButtonIcon: Icon(Icons.sports_mma_sharp),
                            sliderButtonIconPadding: 20,
                            sliderButtonIconSize: 28,
                            submittedIcon: Icon(Icons.thumb_up_rounded),
                            borderRadius: 10,
                            textStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 20,
                                fontWeight: FontWeight.w500),
                            outerColor: Colors.white,
                            innerColor: Colors.orangeAccent,
                            key: key,
                            onSubmit: () async {
                              // await Future.delayed(Duration(seconds: 1))
                              //     .then((value) => key.currentState!.reset());

                              showDialog(
                                context: context,
                                builder: (context) =>
                                    Center(child: CircularProgressIndicator()),
                                barrierDismissible: false,
                              );
                              _determinePosition().then((_) {
                                setState(() {
                                  myLocationPm = currentAddress;
                                  myLocationAm = currentAddress;
                                });
                                Navigator.pop(context);
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Your Currect Location"),
                                        titleTextStyle: TextStyle(
                                            color: Colors.orange, fontSize: 18),
                                        content: Text(currentAddress),
                                        contentTextStyle:
                                            TextStyle(color: Colors.red),
                                      );
                                    });
                              });

                              QuerySnapshot snap = await FirebaseFirestore
                                  .instance
                                  .collection("Employee")
                                  .where('name', isEqualTo: Users.empName)
                                  .get(); // written so as to fetch the document id of the current user and save it in snap variable.

                              DocumentSnapshot snap2 = await FirebaseFirestore
                                  .instance
                                  .collection("Employee")
                                  .doc(snap.docs[0].id)
                                  .collection("RecordAm")
                                  .doc(DateFormat('dd MMMM yyyy')
                                      .format(DateTime.now()))
                                  .get();

                              try {
                                Duration workedDuration = checkDuration(
                                    snap2['checkIn'],
                                    DateFormat('hh:mm:ss a')
                                        .format(DateTime.now()));

                                if (workedDuration.inHours < 8) {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Duration Warning!!',
                                            style:
                                                TextStyle(color: Colors.black)),
                                        content: Text(
                                          'You have only worked for ${getHoursWorked(snap2['checkIn'], DateFormat('hh:mm:ss a').format(DateTime.now()))}, which is less than 8 hours. So, you\'ll be paid accordingly. Are you sure you want to CheckOut ?',
                                          style: TextStyle(
                                              color: Colors.grey[400]),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text(
                                              'YES',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                            onPressed: () async {
                                              await FirebaseFirestore.instance
                                                  .collection("Employee")
                                                  .doc(snap.docs[0].id)
                                                  .collection('RecordAm')
                                                  .doc(DateFormat(
                                                          'dd MMMM yyyy')
                                                      .format(DateTime.now()))
                                                  .update({
                                                'date': Timestamp.now(),
                                                'checkOut':
                                                    DateFormat('hh:mm:ss a')
                                                        .format(DateTime.now()),
                                                'myLocationOut': myLocationAm,
                                              });

                                              setState(() {
                                                checkOutAm =
                                                    DateFormat('hh:mm:ss a')
                                                        .format(DateTime.now());
                                              });
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                'NO',
                                                style: TextStyle(
                                                    color: Colors.cyan),
                                              ))
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  await FirebaseFirestore.instance
                                      .collection("Employee")
                                      .doc(snap.docs[0].id)
                                      .collection('RecordAm')
                                      .doc(DateFormat('dd MMMM yyyy')
                                          .format(DateTime.now()))
                                      .update({
                                    'date': Timestamp.now(),
                                    'checkOut': DateFormat('hh:mm:ss a')
                                        .format(DateTime.now()),
                                    'myLocationIn': myLocationAm,
                                    //'myLocationAm2': myLocationAm,
                                  });

                                  setState(() {
                                    checkOutAm = DateFormat('hh:mm:ss a')
                                        .format(DateTime.now());
                                  });
                                }
                              } catch (e) {
                                await FirebaseFirestore.instance
                                    .collection("Employee")
                                    .doc(snap.docs[0].id)
                                    .collection("RecordAm")
                                    .doc(DateFormat('dd MMMM yyyy')
                                        .format(DateTime.now()))
                                    .set({
                                  'date': Timestamp.now(),
                                  'checkIn': DateFormat('hh:mm:ss a')
                                      .format(DateTime.now()),
                                  'myLocationIn': myLocationAm,
                                  'checkOut': '00:00:00 AM',
                                  // 'wfo': phuket,
                                  // 'wfh': krabi,
                                  'agenda': agendaController.text.trim(),
                                  'assignedtask': assignedTask,
                                  //'myLocationAm2': myLocation
                                });

                                setState(() {
                                  checkInAm = DateFormat('hh:mm:ss a')
                                      .format(DateTime.now());
                                });
                              }
                            },
                          );
                        }),
                      )
                    : Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        child: Text(
                          "Already checked out for the morning !",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ),
                Center(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    height: 30,
                    width: 120,
                     decoration: 
              
                    const BoxDecoration(color:Colors.black54,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5)
                        ),
                        boxShadow:  [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 5,
                              spreadRadius: 1,
                              offset: Offset(2, 3)
                            ),
                          ],
      
                
                  ),
                    child: Text(
                      "Afternoon:",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black,
                            blurRadius: 5,
                            offset: Offset(1, 3))
                      ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Check In",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.orangeAccent),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            checkInPm,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Check Out",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.orangeAccent)),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            checkOutPm,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                // (krabi == false && phuket == false)
                //     ? Column(
                //         children: [
                //           Text(
                //             "Today, you are on...",
                //             style: TextStyle(
                //                 color: Colors.grey[400], fontSize: 18),
                //           ),
                //           Container(
                //             height: 120,
                //             margin: EdgeInsets.symmetric(
                //                 vertical: 20, horizontal: 80),
                //             padding: EdgeInsets.symmetric(horizontal: 10),
                //             decoration: BoxDecoration(
                //               gradient: LinearGradient(colors: [
                //                         Colors.black,
                //                         Colors.orange,
                //                       ]),
                //               borderRadius: BorderRadius.circular(12),
                //             ),
                //             alignment: Alignment.center,
                //             child: Column(
                //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //               children: [
                //                 GestureDetector(
                //                   onTap: () {
                //                     setState(() {
                //                       phuket = true;
                //                     });
                //                   },
                //                   child: Container(
                //                     height: 50,
                //                     width: 200,
                //                     decoration: BoxDecoration(
                //                       gradient: LinearGradient(colors: [
                //                         Colors.black,
                //                         Colors.orange,
                //                       ]),
                //                         //color: Colors.white30,
                //                         border: Border.all(
                //                             color: Colors.white, width: 2),
                //                         borderRadius:
                //                             BorderRadius.circular(12)),
                //                     alignment: Alignment.center,
                //                     child: Text(
                //                       "Phuket",
                //                       style: TextStyle(
                //                           color: Colors.white, fontSize: 22),
                //                     ),
                //                   ),
                //                 ),
                //                 GestureDetector(
                //                   onTap: () {
                //                     setState(() {
                //                       krabi = true;
                //                     });
                //                   },
                //                   child: Container(
                //                     height: 50,
                //                     width: 200,

                //                     decoration: BoxDecoration(
                //                       gradient: LinearGradient(
                //                         colors: [
                //                         Colors.black,
                //                         Colors.orange,
                //                       ]),

                //                         border: Border.all(
                //                             color: Colors.white, width: 2),
                //                         borderRadius:
                //                             BorderRadius.circular(12)),
                //                     alignment: Alignment.center,
                //                     child: Text(
                //                       "Krabi",
                //                       style: TextStyle(
                //                           color: Colors.white, fontSize: 22),
                //                     ),
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ],
                //       )
                //     : Column(
                //         children: [
                //           Text(
                //             "Today, you are on...",
                //             style: TextStyle(
                //                 color: Colors.grey[400], fontSize: 18),
                //           ),
                //           Container(
                //             height: 60,
                //             width: MediaQuery.of(context).size.width,
                //             margin: EdgeInsets.symmetric(
                //                 vertical: 20, horizontal: 80),
                //             padding: EdgeInsets.symmetric(horizontal: 10),
                //             decoration: BoxDecoration(
                //                 color: Colors.black,
                //                 borderRadius: BorderRadius.circular(12)),
                //             alignment: Alignment.center,
                //             child: krabi == true
                //                 ? Container(
                //                     height: 50,
                //                     width: 200,
                //                     decoration: BoxDecoration(
                //                         color: Colors.white30,
                //                         border: Border.all(
                //                             color: Colors.white, width: 2),
                //                         borderRadius:
                //                             BorderRadius.circular(12)),
                //                     alignment: Alignment.center,
                //                     child: Text(
                //                       "Krabi",
                //                       style: TextStyle(
                //                           color: Colors.white, fontSize: 22),
                //                     ),
                //                   )
                //                 : Container(
                //                     height: 50,
                //                     width: 200,
                //                     decoration: BoxDecoration(
                //                         color: Colors.white30,
                //                         border: Border.all(
                //                             color: Colors.white, width: 2),
                //                         borderRadius:
                //                             BorderRadius.circular(12)),
                //                     alignment: Alignment.center,
                //                     child: Text(
                //                       "Phuket",
                //                       style: TextStyle(
                //                           color: Colors.white, fontSize: 22),
                //                     ),
                //                   ),
                //           ),
                //         ],
                //       ),

                checkOutPm == '00:00:00 PM'
                    ? Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Builder(builder: (context) {
                          final GlobalKey<SlideActionState> key = GlobalKey();

                          return SlideAction(
                            text: checkInPm == '00:00:00 PM'
                                ? "Slide to Check In"
                                : "Slide to Check Out",
                            sliderButtonIcon: Icon(Icons.sports_mma_sharp),
                            sliderButtonIconPadding: 20,
                            sliderButtonIconSize: 28,
                            submittedIcon: Icon(Icons.thumb_up_rounded),
                            borderRadius: 10,
                            textStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 20,
                                fontWeight: FontWeight.w500),
                            outerColor: Colors.white,
                            innerColor: Colors.orangeAccent,
                            key: key,
                            onSubmit: () async {
                              // await Future.delayed(Duration(seconds: 1))
                              //     .then((value) => key.currentState!.reset());

                              showDialog(
                                context: context,
                                builder: (context) =>
                                    Center(child: CircularProgressIndicator()),
                                barrierDismissible: false,
                              );
                              _determinePosition().then((_) {
                                setState(() {
                                  myLocationPm = currentAddress;
                                  myLocationAm = currentAddress;
                                });
                                Navigator.pop(context);
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Your Currect Location"),
                                        titleTextStyle: TextStyle(
                                            color: Colors.orange, fontSize: 18),
                                        content: Text(currentAddress),
                                        contentTextStyle:
                                            TextStyle(color: Colors.red),
                                      );
                                    });
                              });

                              QuerySnapshot snap = await FirebaseFirestore
                                  .instance
                                  .collection("Employee")
                                  .where('name', isEqualTo: Users.empName)
                                  .get(); // written so as to fetch the document id of the current user and save it in snap variable.

                              DocumentSnapshot snap3 = await FirebaseFirestore
                                  .instance
                                  .collection("Employee")
                                  .doc(snap.docs[0].id)
                                  .collection("RecordPm")
                                  .doc(DateFormat('dd MMMM yyyy')
                                      .format(DateTime.now()))
                                  .get();

                              try {
                                Duration workedDuration = checkDuration(
                                    snap3['checkIn'],
                                    DateFormat('hh:mm:ss a')
                                        .format(DateTime.now()));

                                if (workedDuration.inHours < 8) {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Duration Warning!!',
                                            style:
                                                TextStyle(color: Colors.black)),
                                        content: Text(
                                          'You have only worked for ${getHoursWorked(snap3['checkIn'], DateFormat('hh:mm:ss a').format(DateTime.now()))}, which is less than 8 hours. So, you\'ll be paid accordingly. Are you sure you want to CheckOut ?',
                                          style: TextStyle(
                                              color: Colors.grey[400]),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text(
                                              'YES',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                            onPressed: () async {
                                              await FirebaseFirestore.instance
                                                  .collection("Employee")
                                                  .doc(snap.docs[0].id)
                                                  .collection('RecordPm')
                                                  .doc(DateFormat(
                                                          'dd MMMM yyyy')
                                                      .format(DateTime.now()))
                                                  .update({
                                                'date': Timestamp.now(),
                                                'checkOut':
                                                    DateFormat('hh:mm:ss a')
                                                        .format(DateTime.now()),
                                                'myLocationOut': myLocationPm,
                                              });

                                              setState(() {
                                                checkOutPm =
                                                    DateFormat('hh:mm:ss a')
                                                        .format(DateTime.now());
                                              });
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                'NO',
                                                style: TextStyle(
                                                    color: Colors.cyan),
                                              ))
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  await FirebaseFirestore.instance
                                      .collection("Employee")
                                      .doc(snap.docs[0].id)
                                      .collection('RecordPm')
                                      .doc(DateFormat('dd MMMM yyyy')
                                          .format(DateTime.now()))
                                      .update({
                                    'date': Timestamp.now(),
                                    'checkOut': DateFormat('hh:mm:ss a')
                                        .format(DateTime.now()),
                                    'myLocationOut': myLocationPm,
                                    //'myLocationAm2': myLocationAm,
                                  });

                                  setState(() {
                                    checkOutPm = DateFormat('hh:mm:ss a')
                                        .format(DateTime.now());
                                  });
                                }
                              } catch (e) {
                                await FirebaseFirestore.instance
                                    .collection("Employee")
                                    .doc(snap.docs[0].id)
                                    .collection("RecordPm")
                                    .doc(DateFormat('dd MMMM yyyy')
                                        .format(DateTime.now()))
                                    .set({
                                  'date': Timestamp.now(),
                                  'checkIn': DateFormat('hh:mm:ss a')
                                      .format(DateTime.now()),
                                  'myLocationIn': myLocationPm,
                                  'checkOut': '00:00:00 PM',
                                  // 'wfo': phuket,
                                  // 'wfh': krabi,
                                  'agenda': agendaController.text.trim(),
                                  'assignedtask': assignedTask,
                                });

                                setState(() {
                                  checkInPm = DateFormat('hh:mm:ss a')
                                      .format(DateTime.now());
                                });
                              }
                            },
                          );
                        }),
                      )
                    : Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        child: Text(
                          "Already checked out for the evening !",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ),

                // checkOutPm == '00:00:00 PM'
                //     ? Container(
                //         margin:
                //             EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                //         child: Builder(builder: (context) {
                //           final GlobalKey<SlideActionState> key = GlobalKey();

                //           return SlideAction(
                //             text: checkInPm == '00:00:00 PM'
                //                 ? "Slide to Check In"
                //                 : "Slide to Check Out",
                //             sliderButtonIcon: Icon(Icons.sports_mma_sharp),
                //             sliderButtonIconPadding: 20,
                //             sliderButtonIconSize: 28,
                //             submittedIcon: Icon(Icons.thumb_up_rounded),
                //             borderRadius: 10,
                //             textStyle: TextStyle(
                //                 color: Colors.grey,
                //                 fontSize: 20,
                //                 fontWeight: FontWeight.w500),
                //             outerColor: Colors.white,
                //             innerColor: Colors.orangeAccent,
                //             key: key,
                //             onSubmit: () async {
                //               await Future.delayed(Duration(seconds: 1))
                //                   .then((value) => key.currentState!.reset());

                //               QuerySnapshot snap = await FirebaseFirestore
                //                   .instance
                //                   .collection("Employee")
                //                   .where('name', isEqualTo: Users.empName)
                //                   .get(); // written so as to fetch the document id of the current user and save it in snap variable.

                //               DocumentSnapshot snap3 = await FirebaseFirestore
                //                   .instance
                //                   .collection("Employee")
                //                   .doc(snap.docs[0].id)
                //                   .collection("RecordPm")
                //                   .doc(DateFormat('dd MMMM yyyy')
                //                       .format(DateTime.now()))
                //                   .get();

                //               try {
                //                 Duration workedDuration = checkDuration(
                //                     snap3['checkIn'],
                //                     DateFormat('hh:mm:ss a')
                //                         .format(DateTime.now()));

                //                 if (workedDuration.inHours < 8) {
                //                   showDialog(
                //                     barrierDismissible: false,
                //                     context: context,
                //                     builder: (BuildContext context) {
                //                       return AlertDialog(
                //                         title: Text('Duration Warning!!',
                //                             style:
                //                                 TextStyle(color: Colors.black)),
                //                         content: Text(
                //                           'You have only worked for ${getHoursWorked(snap3['checkIn'], DateFormat('hh:mm:ss a').format(DateTime.now()))}, which is less than 8 hours. So, you\'ll be paid accordingly. Are you sure you want to CheckOut ?',
                //                           style: TextStyle(
                //                               color: Colors.grey[400]),
                //                         ),
                //                         actions: <Widget>[
                //                           TextButton(
                //                             child: Text(
                //                               'YES',
                //                               style: TextStyle(
                //                                   color: Colors.black),
                //                             ),
                //                             onPressed: () async {
                //                               await FirebaseFirestore.instance
                //                                   .collection("Employee")
                //                                   .doc(snap.docs[0].id)
                //                                   .collection('RecordPm')
                //                                   .doc(DateFormat(
                //                                           'dd MMMM yyyy')
                //                                       .format(DateTime.now()))
                //                                   .update({
                //                                 'date': Timestamp.now(),
                //                                 'checkOut':
                //                                     DateFormat('hh:mm:ss a')
                //                                         .format(DateTime.now()),
                //                               });

                //                               setState(() {
                //                                 checkOutPm =
                //                                     DateFormat('hh:mm:ss a')
                //                                         .format(DateTime.now());
                //                               });
                //                               Navigator.of(context).pop();
                //                             },
                //                           ),
                //                           TextButton(
                //                               onPressed: () {
                //                                 Navigator.pop(context);
                //                               },
                //                               child: Text(
                //                                 'NO',
                //                                 style: TextStyle(
                //                                     color: Colors.cyan),
                //                               ))
                //                         ],
                //                       );
                //                     },
                //                   );
                //                 } else {
                //                   await FirebaseFirestore.instance
                //                       .collection("Employee")
                //                       .doc(snap.docs[0].id)
                //                       .collection('RecordPm')
                //                       .doc(DateFormat('dd MMMM yyyy')
                //                           .format(DateTime.now()))
                //                       .update({
                //                     'date': Timestamp.now(),
                //                     'checkOut': DateFormat('hh:mm:ss a')
                //                         .format(DateTime.now()),
                //                     'myLocationPm': myLocation
                //                   });

                //                   setState(() {
                //                     checkOutAm = DateFormat('hh:mm:ss a')
                //                         .format(DateTime.now());
                //                   });
                //                 }
                //               } catch (e) {
                //                 await FirebaseFirestore.instance
                //                     .collection("Employee")
                //                     .doc(snap.docs[0].id)
                //                     .collection("RecordPm")
                //                     .doc(DateFormat('dd MMMM yyyy')
                //                         .format(DateTime.now()))
                //                     .set({
                //                   'date': Timestamp.now(),
                //                   'checkIn': DateFormat('hh:mm:ss a')
                //                       .format(DateTime.now()),
                //                   'myLocationPm1': myLocationAm,
                //                   'checkOut': '00:00:00 AM',
                //                   // 'wfo': phuket,
                //                   // 'wfh': krabi,
                //                   'agenda': agendaController.text.trim(),
                //                   'assignedtask': assignedTask,
                //                   'myLocationPm2': myLocation
                //                 });

                //                 setState(() {
                //                   checkInPm = DateFormat('hh:mm:ss a')
                //                       .format(DateTime.now());
                //                 });
                //               }
                //             },
                //           );
                //         }),
                //       )
                //     : Container(
                //         margin: EdgeInsets.symmetric(horizontal: 20),
                //         alignment: Alignment.center,
                //         child: Text(
                //           "Already checked out for the evening !",
                //           style: TextStyle(
                //               fontSize: 20,
                //               fontWeight: FontWeight.w500,
                //               color: Colors.white),
                //         ),
                //       ),
              ],
            ),
          )),
    );
  }
}
