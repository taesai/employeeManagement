// ignore_for_file: prefer_const_constructors,prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_attendance_manager/pages/emp_pages.dart';
import 'package:new_attendance_manager/data/users.dart';
import 'package:new_attendance_manager/widgets/custom_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late SharedPreferences sharedPreferences;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: 
         Column(
          
          
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //SizedBox(height: 50,),
            Text(
              "EMERALD",
              style: TextStyle(
                  color: Colors.orange,
                  fontSize: 32,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "FOR Trainers",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic),
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              "Login now ...",
              style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[400]),
            ),
            
            Container(height: 200, width: 200, decoration:
              BoxDecoration(
                image:
                  DecorationImage(
                    image:AssetImage("assets/register.png")))),
            CustomField(
              controller: emailController,
              obscureText: false,
              suffixIcon: Icon(Icons.email),
              labelText: "Email",
            ),
            SizedBox(
              height: 5,
            ),
            CustomField(
                controller: passwordController,
                labelText: "Password",
                suffixIcon: Icon(Icons.lock),
                obscureText: true),
            SizedBox(
              height: 15,
            ),
            GestureDetector(
              onTap: () async {
                FocusScope.of(context).unfocus();
                String email = emailController.text.trim();
                String password = passwordController.text.trim();

                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter your email.")));
                } else if (password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter your password.")));
                } else {
                  QuerySnapshot snap = await FirebaseFirestore.instance
                      .collection("Employee")
                      .where("email", isEqualTo: email)
                      .get();

                  Users.empName = snap.docs[0][
                      'name']; // saves the name of current user to Users.empName

                  try {
                    if (password == snap.docs[0]['password']) {
                      sharedPreferences = await SharedPreferences.getInstance();

                      sharedPreferences.setString(
                          "empName",
                          Users
                              .empName); // storing the Users.empName to sharedpreferences in empName.
                      sharedPreferences.setString("empEmail", email).then((_) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EmpPages()));
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Password is incorrect.")));
                    }
                  } catch (e) {
                    String error = " ";

                    if (e.toString() ==
                        "RangeError (index): Invalid value: Valid value range is empty: 0") {
                      setState(() {
                        error = "Employee id does not exist";
                      });
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(error)));
                    } else {
                      setState(() {
                        error = "An error has occured";
                      });
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(error)));
                    }
                  }
                }
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 60),
                height: 40,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Colors.orange, width: 2)),
                alignment: Alignment.center,
                child: Text(
                  "LOGIN",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w500),
                ),
              ),
            )
          ],
        ),
      
    );
  }
}
