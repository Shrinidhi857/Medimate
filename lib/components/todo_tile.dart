import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'marquee.dart';

class  ToDoTile extends StatefulWidget{
  final String taskName;
  final bool subjectAttended;
  final bool subjectBunked;
  Function(bool?)? onChangedg;
  Function(bool?)? onChangedr;

      ToDoTile({super.key,
      required this.taskName,
      required this.subjectAttended,
      required this.subjectBunked,
      required this.onChangedg,
        required this.onChangedr,

      });

  @override
  State<ToDoTile> createState() => _ToDoTileState();
}

class _ToDoTileState extends State<ToDoTile> {
  @override
  Widget build(BuildContext context){
    return Padding(
      padding:  EdgeInsets.only(left:12,right:12,top:12),
        child:
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color:Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //check box
                  MarqueeComp(
                    text: widget.taskName,
                    width: 150,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Column(
                        children: [
                          Text("Attended",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          Checkbox(
                            value: widget.subjectAttended,
                            onChanged:widget.onChangedg ,
                            checkColor: Colors.white,
                            activeColor: Colors.lightGreen,
                            side: BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
                          )
                        ],
                      ),
                      SizedBox(width: 10,),
                      Column(
                        children: [
                          Text("Skipped",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          Checkbox(
                            value: widget.subjectBunked,
                            onChanged:widget.onChangedr,
                            checkColor: Colors.white,
                            activeColor: Colors.red,
                            side: BorderSide(color: Theme.of(context).colorScheme.inversePrimary),),

                        ],
                      )

                    ],
                  ),

                ]

            ),

          ),
      );

  }
}