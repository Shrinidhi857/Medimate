import 'package:medimate/pages/Login_page.dart';
import 'package:medimate/pages/register_page.dart';
import 'package:flutter/material.dart';


class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({
    super.key,
  });

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}




  class _LoginOrRegisterState extends State<LoginOrRegister>{

    //Initially show login page
    bool showLoginPage =true;


    //toggle between login and Register page
    void togglePages(){
      setState(() {
        showLoginPage=!showLoginPage;
      });
    }


    @override
    Widget build(BuildContext context){
      if(showLoginPage){
        return LoginPage(onTap: togglePages,);
      }else{
        return RegisterPage(onTap: togglePages,);
      }

  }

}