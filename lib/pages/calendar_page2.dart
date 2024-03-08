// ignore_for_file: prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, prefer_const_constructors

import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:new_attendance_manager/data/users.dart';
import 'package:sprintf/sprintf.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  String _month = DateFormat('MMMM').format(DateTime.now());

//declaration de 2 streams pour query dans builder ligne 111
  Stream stream1 = FirebaseFirestore.instance
      .collection("Employee")
      .doc(Users.docID)
      .collection("RecordAm")
      .snapshots();

  Stream stream2 = FirebaseFirestore.instance
      .collection("Employee")
      .doc(Users.docID)
      .collection("RecordPm")
      .snapshots();

  String getHoursWorked(String checkInTime, String checkOutTime) {
    DateTime checkIn = DateFormat('hh:mm:ss a').parse(checkInTime);
    DateTime checkOut = DateFormat('hh:mm:ss a').parse(checkOutTime);

    Duration duration = checkOut.difference(checkIn);

    int hours = duration.inMinutes ~/ 60;
    int minutes = (duration.inMinutes % 60).toInt();
    String formattedDuration = sprintf("%d Hrs:%02d Min", [hours, minutes]);
    return formattedDuration;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[350],
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            "ATTENDANCE",
            style: TextStyle(color: Colors.black, fontSize: 22),
          ),
        ),
        body: Column(
          children: [
            
            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 20),
                  height: 50,
                  width: 150,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _month,
                    style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.w500,
                        fontSize: 24),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final month = await showMonthYearPicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2022),
                        lastDate: DateTime(2099));

                    if (month != null) {
                      setState(() {
                        _month = DateFormat('MMMM').format(month);
                      });
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 20),
                    height: 50,
                    width: 150,
                    alignment: Alignment.center,
                    child: const Text(
                      'Pick a Month',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
            
            
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("Employee")
                    .doc(Users.docID)
                    .collection("RecordAm")
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    final snap = snapshot.data!.docs;
                    return ListView.builder(
                        itemCount: snap.length,
                        itemBuilder: (context, index) {
                          return DateFormat('MMMM')
                                      .format(snap[index]['date'].toDate()) ==
                                  _month
                              ? Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  height: 90,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          width: 2, color: Colors.black)),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 90,
                                        margin: const EdgeInsets.only(
                                            left: 2,
                                            top: 2,
                                            bottom: 2,
                                            right: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.orangeAccent,
                                          borderRadius:
                                              BorderRadius.circular(17),
                                        ),
                                        child: Center(
                                          child: Text(
                                            DateFormat('EE\ndd').format(
                                                snap[index]['date'].toDate()),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 22),
                                          ),
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            
                                            children: [
                                              SizedBox(width: 15,),
                                              Text(
                                                "Check In",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Text(
                                                snap[index]['checkIn'],
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20),
                                              )
                                            ],
                                          ),
                                          Row(
                                            children: [
                                               SizedBox(width: 15,),
                                              Text("Check Out",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black)),
                                              SizedBox(
                                                width: 15,
                                              ),
                                              Text(
                                                snap[index]['checkOut'],
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20),
                                              )
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(width: 15,),
                                              Text('Duration',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black)),
                                              SizedBox(
                                                width: 22,
                                              ),
                                              snap[index]['checkOut'] ==
                                                      '00:00:00 AM'
                                                  ? Text(
                                                      "Didn't Checkout",
                                                      style: const TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )
                                                  : Text(
                                                      getHoursWorked(
                                                          snap[index]
                                                              ['checkIn'],
                                                          snap[index]
                                                              ['checkOut']),
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 20),
                                                    )
                                            ],
                                          ),
                                        ],
                                        
                                      ),
                                    ],
                                  ),
                                  
                                  
                                )
                              : const SizedBox();
                              
                              
                              
                        },);
                  } else {
                    return const SizedBox();
                  }
                  
                },
                
              ),
            ),
             Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 100,
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("Employee")
                    .doc(Users.docID)
                    .collection("RecordPm")
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    final snap = snapshot.data!.docs;
                    return ListView.builder(
                        itemCount: snap.length,
                        itemBuilder: (context, index) {
                          return DateFormat('MMMM')
                                      .format(snap[index]['date'].toDate()) ==
                                  _month
                              ? Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  height: 90,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          width: 2, color: Colors.black)),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 90,
                                        margin: const EdgeInsets.only(
                                            left: 2,
                                            top: 2,
                                            bottom: 2,
                                            right: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.orangeAccent,
                                          borderRadius:
                                              BorderRadius.circular(17),
                                        ),
                                        child: Center(
                                          child: Text(
                                            DateFormat('EE\ndd').format(
                                                snap[index]['date'].toDate()),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 22),
                                          ),
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            
                                            children: [
                                              SizedBox(width: 15,),
                                              Text(
                                                "Check In",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Text(
                                                snap[index]['checkIn'],
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20),
                                              )
                                            ],
                                          ),
                                          Row(
                                            children: [
                                               SizedBox(width: 15,),
                                              Text("Check Out",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black)),
                                              SizedBox(
                                                width: 15,
                                              ),
                                              Text(
                                                snap[index]['checkOut'],
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20),
                                              )
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(width: 15,),
                                              Text('Duration',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black)),
                                              SizedBox(
                                                width: 22,
                                              ),
                                              snap[index]['checkOut'] ==
                                                      '00:00:00 PM'
                                                  ? Text(
                                                      "Didn't Checkout",
                                                      style: const TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )
                                                  : Text(
                                                      getHoursWorked(
                                                          snap[index]
                                                              ['checkIn'],
                                                          snap[index]
                                                              ['checkOut']),
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 20),
                                                    )
                                            ],
                                          ),
                                        ],
                                        
                                      ),
                                    ],
                                  ),
                                  
                                  
                                )
                              : const SizedBox();
                              
                              
                              
                        },);
                  } else {
                    return const SizedBox();
                  }
                  
                },
                
              ),
            )
            
            
            
          ],
        ),
      ),
    );
  }
}
