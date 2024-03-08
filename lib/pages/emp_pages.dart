// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_attendance_manager/data/users.dart';
import 'package:new_attendance_manager/pages/calendar_page.dart';
import 'package:new_attendance_manager/pages/home2_page.dart';
import 'package:new_attendance_manager/pages/profile_page.dart';
import 'package:new_attendance_manager/services/location_service.dart';


class EmpPages extends StatefulWidget {
  const EmpPages({super.key});

  @override
  State<EmpPages> createState() => _EmpPagesState();
}

class _EmpPagesState extends State<EmpPages> {
  int currentIndex = 0;

  List<IconData> navigationIcons = [
    Icons.home,
    Icons.calendar_today,
    Icons.person
  ];

  List navigationTitles = ["Home", "Presence", "Profile"];

  void getDocId() async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("Employee")
        .where('name', isEqualTo: Users.empName)
        .get();

    setState(() {
      Users.docID = snap.docs[0].id;
    });
  }

  // void _startLocationService() async {
  //   LocationService().initialize();

  //   LocationService().getLongitude().then((value) {
  //     setState(() {
  //       Users.longitude = value!;
  //     });

  //     LocationService().getLatitude().then((value) {
  //       setState(() {
  //         Users.latitude = value!;
  //       });
  //     });
  //   });
  // }


  @override
  void initState() {
    super.initState();
    //_startLocationService();
    currentIndex = 0;
    getDocId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          HomePage(),
          CalendarPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(bottom: 15, right: 5, left: 5),
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (int i = 0; i < navigationIcons.length; i++) ...<Expanded>{
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  setState(() {
                    currentIndex = i;
                  });
                },
                child: Container(
                  height: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  width: 50,
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        navigationIcons[i],
                        color: i == currentIndex
                            ? Colors.orangeAccent
                            : Colors.grey[400],
                        size: i == currentIndex ? 30 : 24,
                      ),
                      Text(
                        navigationTitles[i],
                        style: TextStyle(
                          color: i == currentIndex
                              ? Colors.grey[300]
                              : Colors.grey[300],
                          fontSize: i == currentIndex ? 17 : 14,
                        ),
                      )
                    ],
                  ),
                ),
              ))
            }
          ],
        ),
      ),
    );
  }
}
