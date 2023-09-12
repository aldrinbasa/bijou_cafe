// ignore_for_file: use_build_context_synchronously

import 'package:bijou_cafe/home/home_admin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:bijou_cafe/constants/texts.dart';
import 'package:bijou_cafe/models/user_model.dart';
import 'package:bijou_cafe/utils/firestore_database.dart';
import 'package:bijou_cafe/utils/page_transition.dart';
import 'package:bijou_cafe/utils/toast.dart';
import 'package:bijou_cafe/init/login/login_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bijou_cafe/home/home_user_screen.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserSingleton userSingleton = UserSingleton();

  void setUser(UserModel user, BuildContext context) {
    userSingleton.setUser(user);
    saveUserDetailsToSharedPreferences(user);

    if (userSingleton.user?.userType == "user") {
      PageTransition.pushRightNavigation(context, const HomeUserScreen());
      Toast.show(
          context, "Login success! Welcome ${userSingleton.user?.firstName}.");
    } else if (userSingleton.user?.userType == "admin") {
      PageTransition.pushRightNavigation(context, const HomeAdminScreen());
      Toast.show(context,
          "Admin login success! Welcome ${userSingleton.user?.firstName}.");
    } else {
      Toast.show(
          context, "User error. User has incomplete details. Please sign-up.");
    }
  }

  Future<void> signInWithEmail(
      BuildContext context, String email, String password) async {
    FirestoreDatabase firestoreDatabase = FirestoreDatabase();

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        final userInfo = await firestoreDatabase.getUserInfoByUUID(user.uid);

        UserModel loggedInUser = UserModel(
          uid: user.uid,
          email: user.email!,
          firstName: userInfo!['firstName'],
          lastName: userInfo['lastName'],
          userType: userInfo['userType'],
        );

        setUser(loggedInUser, context);
      }
    } catch (error) {
      if (error is FirebaseAuthException) {
        Toast.show(context, error.message);
      }
    }
  }

  Future<void> signUp(BuildContext context, String email, String firstName,
      String lastName, String password) async {
    FirestoreDatabase firestoreDatabase = FirestoreDatabase();

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        UserModel newUser = UserModel(
            uid: user.uid,
            email: email,
            firstName: firstName,
            lastName: lastName,
            userType: 'user');

        firestoreDatabase.createNewUser(newUser);
      }
    } catch (error) {
      if (error is FirebaseAuthException) {
        Toast.show(context, error.message);
      }
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        User? user = userCredential.user;

        if (user != null) {
          final userInfo =
              await FirestoreDatabase().getUserInfoByUUID(user.uid);

          UserModel loggedInUser = UserModel(
            uid: user.uid,
            email: user.email!,
            firstName: userInfo!['firstName'],
            lastName: userInfo['lastName'],
            userType: userInfo['userType'],
          );

          setUser(loggedInUser, context);
        }
      }
    } catch (error) {
      Toast.show(context, gmailNotRegistered);
    }
  }

  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    userSingleton.clearUser();
    clearUserDetailsFromSharedPreferences();

    PageTransition.pushRightNavigation(context, const LoginScreen());
  }

  void clearUserDetailsFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user_email');
    prefs.remove('user_first_name');
    prefs.remove('user_last_name');
    prefs.remove('user_type');
  }

  void saveUserDetailsToSharedPreferences(UserModel user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_email', user.email);
    prefs.setString('user_first_name', user.firstName);
    prefs.setString('user_last_name', user.lastName);
    prefs.setString('user_type', user.userType);
    prefs.setString('user_uid', user.uid);
  }
}
