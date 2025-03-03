// import 'package:flutter/material.dart';

// void main() {
//   runApp(MaterialApp(home: TaskScreen()));
// }

// class TaskScreen extends StatefulWidget {
//   @override
//   _TaskScreenState createState() => _TaskScreenState();
// }

// class _TaskScreenState extends State<TaskScreen> {
//   DateTime? selectedDate;
//   String? selectedStartTime;
//   String? selectedEndTime;
// 	final List<String> timeSlots = List.generate(24 * 4, (index) {
//     final hours = (index ~/ 4).toString().padLeft(2, '0');
//     final minutes = ((index % 4) * 15).toString().padLeft(2, '0');
//     return '$hours:$minutes';
//   });

//   void _pickDate(BuildContext context) async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );

//     if (picked != null) {
//       setState(() {
//         selectedDate = picked;
//       });
//     }
//   }

//   void _showTaskModal() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true, // Full screen modal
//       builder: (context) => TaskModal(
//         selectedDate: selectedDate,
//         onDatePicked: _pickDate,
//         selectedStartTime: selectedStartTime,
//         selectedEndTime: selectedEndTime,
//         timeSlots: timeSlots,
//         onStartTimeChanged: (String? value) {
//           setState(() => selectedStartTime = value);
//         },
//         onEndTimeChanged: (String? value) {
//           setState(() => selectedEndTime = value);
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Task Manager")),
//       body: Center(
//       child: Text("Welcome to Task Manager"),
//     ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showTaskModal,
//         child: Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }
// }



