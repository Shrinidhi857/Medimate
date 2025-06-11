import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'notification_details_screen.dart';

class NotificationScreen extends StatefulWidget{
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  void firbaseMessaging() async{
    FirebaseMessaging messaging =FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    print("FCM token:$token");


    //fore ground
    FirebaseMessaging.onMessage.listen((RemoteMessage message){
      final title =message.notification?.title??"N/A";
      final body =message.notification?.body??"N/A";

      showDialog(
          context: context,
          builder: (context)=>AlertDialog(title: Text(""),
            content: Text(
              body,
              maxLines: 1,
                style: TextStyle(overflow: TextOverflow.ellipsis),
            ),
            actions: [
              TextButton(onPressed: (){
                Navigator.push(context, 
                    MaterialPageRoute(builder: (context)=>NotificationDetailScreen (
                        title: title,
                        body: body,
                    )));
              },child: Text("Next"),),
              TextButton(onPressed: (){},child: Text("Cancel"),)

            ],
        ));
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message){
      final title =message.notification?.title??"N/A";
      final body =message.notification?.body??"N/A";
      
      Navigator.push(context, MaterialPageRoute(builder: (context)=>NotificationDetailScreen(title: title, body: body)));

    });

    FirebaseMessaging.instance.getInitialMessage().then((message){
      if(message!=null) {
        final title = message.notification?.title ?? "N/A";
        final body = message.notification?.body ?? "N/A";

        Navigator.push(context, MaterialPageRoute(builder: (context) =>
            NotificationDetailScreen(title: title, body: body)));
      }
    });
  }
  @override
  void initState(){
    super.initState();
    firbaseMessaging();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text("push_notification"),
      ),
    );
  }
}