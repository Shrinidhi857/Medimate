import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:medimate/components/mybuttons.dart';

class NumberPage extends StatefulWidget {
  final TextEditingController hourController;
  final TextEditingController minuteController;
  final TextEditingController timeFormatController;

  const NumberPage({
    super.key,
    required this.hourController,
    required this.minuteController,
    required this.timeFormatController,
  });

  @override
  State<NumberPage> createState() => _NumberPageState();
}

class _NumberPageState extends State<NumberPage> {
  var hour = 0;
  var minute = 0;
  var timeFormat = "AM";

  @override
  void initState() {
    super.initState();
    // Initialize controllers with default values
    widget.hourController.text = hour.toString().padLeft(2, '0');
    widget.minuteController.text = minute.toString().padLeft(2, '0');
    widget.timeFormatController.text = timeFormat;
  }

  void updateTextControllers() {
    widget.hourController.text = hour.toString().padLeft(2, '0');
    widget.minuteController.text = minute.toString().padLeft(2, '0');
    widget.timeFormatController.text = timeFormat;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /*Text(
              "Pick Your Time! ${widget.hourController.text}:${widget.minuteController.text} ${widget.timeFormatController.text}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),*/
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      NumberPicker(
                        minValue: 0,
                        maxValue: 12,
                        value: hour,
                        zeroPad: true,
                        infiniteLoop: true,
                        itemWidth: 80,
                        itemHeight: 60,
                        onChanged: (value) {
                          setState(() {
                            hour = value;
                            updateTextControllers();
                          });
                        },
                        textStyle: TextStyle(color: Theme.of(context).colorScheme.inversePrimary, fontSize: 20),
                        selectedTextStyle:  TextStyle(color: Theme.of(context).colorScheme.inversePrimary, fontSize: 30),
                        decoration:  BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
                            bottom: BorderSide(color:Theme.of(context).colorScheme.inversePrimary),
                          ),
                        ),
                      ),
                      NumberPicker(
                        minValue: 0,
                        maxValue: 59,
                        value: minute,
                        zeroPad: true,
                        infiniteLoop: true,
                        itemWidth: 80,
                        itemHeight: 60,
                        onChanged: (value) {
                          setState(() {
                            minute = value;
                            updateTextControllers();
                          });
                        },
                        textStyle:  TextStyle(color:Theme.of(context).colorScheme.inversePrimary, fontSize: 20),
                        selectedTextStyle:  TextStyle(color:Theme.of(context).colorScheme.inversePrimary, fontSize: 30),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
                            bottom: BorderSide(color:Theme.of(context).colorScheme.inversePrimary),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                timeFormat = "AM";
                                updateTextControllers();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: timeFormat == "AM" ?Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: timeFormat == "AM" ? Colors.grey : Colors.grey.shade700,
                                ),
                              ),
                              child:  Text(
                                "AM",
                                style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary, fontSize: 25),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                timeFormat = "PM";
                                updateTextControllers();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: timeFormat == "PM" ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: timeFormat == "PM" ? Colors.grey : Colors.grey.shade700,
                                ),
                              ),
                              child: Text(
                                "PM",
                                style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary, fontSize: 25),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MyButton(
                        text: "SAVE",
                        onPressed: () {
                          print("Saved Time: ${widget.hourController.text}:${widget.minuteController.text}:${widget.timeFormatController.text}");
                          Navigator.of(context).pop();
                        },
                      ),
                      MyButton(
                        text: "CANCEL",
                        onPressed: () {
                          setState(() {
                            hour = 0;
                            minute = 0;
                            timeFormat = "AM";
                            updateTextControllers();
                            Navigator.of(context).pop();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
