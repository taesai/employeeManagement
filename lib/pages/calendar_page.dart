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
          backgroundColor: Colors.white10,
          elevation: 0.0,
          centerTitle: true,
          title: const Text(
            "ATTENDANCE",
            style: TextStyle(color: Colors.black, fontSize: 22),
          ),
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 20),
                  height: 50,
                  width: 150,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _month,
                    style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                        fontSize: 22),
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
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                          fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
           Container(
              height: 30,
               width: 100,
              margin: const EdgeInsets.all(10),
              
              
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
               child: const Center(
                 child:  Text('Morning',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                    
                  ),                   
               ),                
            ),

            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height:300,
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
                                            color: Colors.orange,
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
                                        SizedBox(width: 20,),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Row(
                                            //   children: [
                                            //     Text(
                                            //       'Status',
                                            //       style: TextStyle(
                                            //           fontSize: 20,
                                            //           fontWeight: FontWeight.w500,
                                            //           color: Colors.grey[400]),
                                            //     ),
                                            //     SizedBox(
                                            //       width: 40,
                                            //     ),
                                            //     snap[index]['wfh'] == true
                                            //         ? Text(
                                            //             'W.F.H',
                                            //             style: const TextStyle(
                                            //                 color: Colors.cyan,
                                            //                 fontSize: 20),
                                            //           )
                                            //         : Text(
                                            //             'W.F.O',
                                            //             style: const TextStyle(
                                            //                 color: Colors.cyan,
                                            //                 fontSize: 20),
                                            //           )
                                            //   ],
                                            // ),
                                            Row(
                                              children: [
                                                const Text(
                                                  "Check In",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.black),
                                                ),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                Text(
                                                  snap[index]['checkIn'],
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18),
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Text("Check Out",
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black)),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  snap[index]['checkOut'],
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18),
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Text('Duration',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black)),
                                                const SizedBox(
                                                  width: 22,
                                                ),
                                                snap[index]['checkOut'] ==
                                                        '00:00:00 AM'
                                                    ? const Text(
                                                        "Didn't Checkout",
                                                        style:  TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 18),
                                                      )
                                                    : Text(
                                                        getHoursWorked(
                                                            snap[index]
                                                                ['checkIn'],
                                                            snap[index]
                                                                ['checkOut']),
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 18),
                                                      )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox();
                                
                          });
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
            ),

             Container(
              height: 30,
               width: 100,
              margin: const EdgeInsets.all(10),
              
              
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
               child: const Center(
                 child:  Text('Evening',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                    
                    ),
                    
               ),
                  
                ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 200,
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
                                          color: Colors.orange,
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
                                      SizedBox(width: 20,),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // Row(
                                          //   children: [
                                          //     Text(
                                          //       'Status',
                                          //       style: TextStyle(
                                          //           fontSize: 20,
                                          //           fontWeight: FontWeight.w500,
                                          //           color: Colors.grey[400]),
                                          //     ),
                                          //     SizedBox(
                                          //       width: 40,
                                          //     ),
                                          //     snap[index]['wfh'] == true
                                          //         ? Text(
                                          //             'W.F.H',
                                          //             style: const TextStyle(
                                          //                 color: Colors.cyan,
                                          //                 fontSize: 20),
                                          //           )
                                          //         : Text(
                                          //             'W.F.O',
                                          //             style: const TextStyle(
                                          //                 color: Colors.cyan,
                                          //                 fontSize: 20),
                                          //           )
                                          //   ],
                                          // ),
                                          Row(
                                            children: [
                                              const Text(
                                                "Check In",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black),
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Text(
                                                snap[index]['checkIn'],
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18),
                                              )
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text("Check Out",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black)),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                snap[index]['checkOut'],
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18),
                                              )
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text('Duration',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black)),
                                              const SizedBox(
                                                width: 22,
                                              ),
                                              snap[index]['checkOut'] ==
                                                      '00:00:00 AM'
                                                  ? const Text(
                                                      "Didn't Checkout",
                                                      style:  TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 18),
                                                    )
                                                  : Text(
                                                      getHoursWorked(
                                                          snap[index]
                                                              ['checkIn'],
                                                          snap[index]
                                                              ['checkOut']),
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 18),
                                                    )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox();
                              
                        });
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