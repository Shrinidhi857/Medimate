import 'package:flutter/material.dart';

class NotificationDetailScreen extends StatelessWidget{
  final String title;
  final String body;
  const NotificationDetailScreen({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("Notification detiails"),),
      body: Padding(
          padding:EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),
              Text(body),
            ],
        ),
      ),
    );
  }
}