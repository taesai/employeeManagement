import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_attendance_manager/chatapp/helper_functions.dart';
import 'package:new_attendance_manager/services/chat_database_service.dart';

class ChatAuthService {
  final FirebaseAuth firebaseAuth =
      FirebaseAuth.instance; // create an instance of firebase authentication

  // login method
  Future loginWithUsernameAndPassword(String email, String password) async {
    try {
      User user = (await firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user!;

      if (user != null) {
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // register method
  Future registerUserWithEmailAndPassword(
      String fullName, String email, String password) async {
    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;

      if (user != null) {
        //call our database service to update the user database
        await ChatDatabaseService(uid: user.uid)
            .updateUserData(fullName, email);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // signout method
  Future signOut() async {
    try {
      await HelperFunctions.saveUserLoggedInStatus(false);
      await HelperFunctions.saveUserEmailSF("");
      await HelperFunctions.saveUserNameSF("");
      await firebaseAuth.signOut();
    } catch (e) {
      return null;
    }
  }
}
