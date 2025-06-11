import 'package:medimate/auth/google_auth.dart';
import 'package:medimate/components/my_buttons.dart';
import 'package:medimate/components/my_textfield.dart';
import 'package:medimate/helper/showmessage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // Initialize AuthService

  String getThemedImage(bool isDarkMode) {
    return isDarkMode ? 'assets/dark/logo.png' : 'assets/light/logo.png';
  }


  void login() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessageToUser(e.code, context);
    }
  }

  void _handleGoogleSignIn() async {
    AuthService authService = AuthService();
    UserCredential? userCredential = await authService.signInWithGoogle(context);

    if (userCredential != null) {
      print("User signed in: ${userCredential.user?.displayName}");
    } else {
      print("Google sign-in failed.");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
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
                Image.asset(getThemedImage(isDarkMode),scale:5,),
                const SizedBox(height: 25),

                // App Name
                Text(
                  "MEDIMATE",
                  style: TextStyle(fontSize: 25,fontWeight: FontWeight.w900),
                ),

                const SizedBox(height: 25),

                // Email Field
                MyTextField(
                  hintText: "Email",
                  obscureText: false,
                  controller: emailController,
                ),

                const SizedBox(height: 25),

                // Password Field
                MyTextField(
                  hintText: "Password",
                  obscureText: true,
                  controller: passwordController,
                ),

                const SizedBox(height: 10),

                // Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap:()=> Navigator.pushNamed(context,'/forgotpage'),
                      child: Text(
                        "Forgot password?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // Sign-in Button
                MyButtons(
                  text: "Login",
                  onTap: login,
                ),



                const SizedBox(height: 10),

                // Don't Have an Account? Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?"),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        " Register here",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15,),
                ElevatedButton(
                    onPressed: _handleGoogleSignIn,
                    child:
                        SizedBox(
                          height: 45,
                          width: 200,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 40,width:40,
                                decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,  // Background color
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                image: AssetImage('assets/images/google.png',), // Local image
                                )
                                ),
                              ),
                              SizedBox(width: 10,),
                              Text("Signin with Google",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary
                                ),
                              )
                            ],
                          ),
                        ),
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }
}
