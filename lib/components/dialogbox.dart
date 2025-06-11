import 'package:flutter/material.dart';
import 'package:medimate/components/timepage.dart';
import 'mybuttons.dart';
import 'package:input_quantity/input_quantity.dart';

class DialogBox extends StatefulWidget {
  final TextEditingController medinamecontroller;
  final TextEditingController timecontroller;
  final TextEditingController dosecontroller;
  final TextEditingController quantitycontroller;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  DialogBox({
    super.key,
    required this.medinamecontroller,
    required this.timecontroller,
    required this.dosecontroller,
    required this.quantitycontroller,
    required this.onSave,
    required this.onCancel,
  });

  @override
  _DialogBoxState createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  TextEditingController hourController = TextEditingController();
  TextEditingController minuteController = TextEditingController();
  TextEditingController timeFormatController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  bool isTimeSelected = false;
  bool isQtyFocused = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "📑 Medication Details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            /// Medication Name Field
            TextField(
              controller: widget.medinamecontroller,
              decoration: InputDecoration(
                hintText: "Medication name",
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            /// Time Picker and Dosage
            Row(
              children: [
                Flexible(flex: 1, child: _buildTimePicker(widget.timecontroller)),
                SizedBox(width: 16),
                Flexible(
                  flex: 1,
                  child: TextField(
                    controller: widget.dosecontroller,
                    decoration: InputDecoration(
                      hintText: "Dosage",
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            /// Quantity Picker
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(" Quantity",style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Focus(
                  onFocusChange: (focus) {
                    setState(() {
                      isQtyFocused = focus;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isQtyFocused ? Colors.blue : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InputQty(
                      maxVal: 100,
                      initVal: 0,
                      minVal: 0,
                      steps: 1,
                      decoration: QtyDecorationProps(
                        width:5,
                        btnColor: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      onQtyChanged: (val) {
                        quantityController.text = val.toString();
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            /// Save and Cancel Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // Copy the quantity value from the local controller to the external one
                    widget.quantitycontroller.text = quantityController.text;
                    widget.onSave();
                  },
                  child: Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: widget.onCancel,
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildTimePicker(TextEditingController controller) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          isTimeSelected = true;
        });

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NumberPage(
              hourController: hourController,
              minuteController: minuteController,
              timeFormatController: timeFormatController,
            ),
          ),
        );

        if (hourController.text.isNotEmpty &&
            minuteController.text.isNotEmpty &&
            timeFormatController.text.isNotEmpty) {
          setState(() {
            controller.text =
            "${hourController.text.padLeft(2, '0')}:${minuteController.text.padLeft(2, '0')} ${timeFormatController.text}";
          });
        }
      },
      child: Container(
        height: 50,
        alignment: Alignment.center,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
            width: 1,
          ),
        ),
        child: Text(
          controller.text.isNotEmpty ? controller.text : "Time",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
