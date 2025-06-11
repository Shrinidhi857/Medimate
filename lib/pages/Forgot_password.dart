import 'package:medimate/auth/google_auth.dart';
import 'package:medimate/components/my_buttons.dart';
import 'package:medimate/components/my_textfield.dart';
import 'package:medimate/helper/showmessage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ForgotPage extends StatefulWidget {

  ForgotPage({super.key});

  @override
  State<ForgotPage> createState() => _ForgotPageState();
}

class _ForgotPageState extends State<ForgotPage> {
  final TextEditingController emailController = TextEditingController();
  final AuthService _authService = AuthService(); // Initialize AuthService

  void resetPassword() async {
    if (emailController.text.isEmpty) {
      displayMessageToUser("Please enter your email", context);
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
      displayMessageToUser("A password reset link has been sent to your email.", context);

    } catch (e) {
      displayMessageToUser("Failed to send reset email. Please try again.", context);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Icon(
                  Icons.person,
                  size: 80,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                const SizedBox(height: 25),

                // App Name
                Text(
                  "",
                  style: TextStyle(fontSize: 20),
                ),

                const SizedBox(height: 25),

                // Email Field
                MyTextField(
                  hintText: "Email",
                  obscureText: false,
                  controller: emailController,
                ),

                const SizedBox(height: 10),

                MyButtons(
                  text: "Send Reset Link",
                  onTap: resetPassword,
                ),

              ]
            ),
          ),
        ),
      ),
    );
  }
}
