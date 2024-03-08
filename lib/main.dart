import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:new_attendance_manager/firebase_options.dart';
import 'package:new_attendance_manager/pages/emp_pages.dart';
import 'package:new_attendance_manager/pages/login_page.dart';
import 'package:new_attendance_manager/data/users.dart';
import 'package:new_attendance_manager/services/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        canvasColor: Colors.grey[350],
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthCheck(),
      localizationsDelegates: const [MonthYearPickerLocalizations.delegate],
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool userAvailable = false;
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();

    _getCurrentUser();
     LocationService();
  }

  void _getCurrentUser() async {
    sharedPreferences = await SharedPreferences.getInstance();

    try {
      if (sharedPreferences.getString("empEmail") != null) {
        setState(() {
          Users.empName = sharedPreferences.getString(
              'empName')!; // saving empName to Users.empName once again at the initialization of our app
          userAvailable = true;
        });
      }
    } catch (e) {
      setState(() {
        userAvailable = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return userAvailable ? const EmpPages() : const LoginPage();
  }
}
