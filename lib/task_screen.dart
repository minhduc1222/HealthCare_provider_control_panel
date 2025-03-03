import 'package:flutter/material.dart';

class TaskCreationModal extends StatefulWidget {
  final Function(Map<String, dynamic>) onTaskAdded;

  TaskCreationModal({required this.onTaskAdded});

  @override
  _TaskCreationModalState createState() => _TaskCreationModalState();
}

class _TaskCreationModalState extends State<TaskCreationModal> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  int startHour = 9;
  int endHour = 10;

  void _saveTask() {
    if (titleController.text.isNotEmpty) {
      widget.onTaskAdded({
        'title': titleController.text,
        'description': descriptionController.text,
        'startHour': startHour,
        'endHour': endHour,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: EdgeInsets.all(16),
        height: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Create New Task", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(controller: titleController, decoration: InputDecoration(labelText: "Title")),
            TextField(controller: descriptionController, decoration: InputDecoration(labelText: "Description")),
            Row(
              children: [
                Text("Start:"),
                DropdownButton<int>(
                  value: startHour,
                  items: List.generate(24, (index) => DropdownMenuItem(value: index, child: Text("$index:00"))),
                  onChanged: (value) => setState(() => startHour = value!),
                ),
                Text("End:"),
                DropdownButton<int>(
                  value: endHour,
                  items: List.generate(24, (index) => DropdownMenuItem(value: index, child: Text("$index:00"))),
                  onChanged: (value) => setState(() => endHour = value!),
                ),
              ],
            ),
            Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: _saveTask, child: Text("Save"))),
          ],
        ),
      ),
    );
  }
}
