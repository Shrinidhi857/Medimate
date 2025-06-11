import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _myBox = Hive.box('mybox');

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent user from closing dialog
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Trigger authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        if (context.mounted) Navigator.pop(context); // Close dialog if user cancels
        return null;
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        if (context.mounted) Navigator.pop(context);
        return null;
      }

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      if (context.mounted) Navigator.pop(context); // Close dialog after success
      return userCredential;
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // Close dialog on error
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  // 🔥 Sign out method
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      await _myBox.clear();
    } catch (e) {
      print("Sign-out Error: $e");
    }
  }
}
