import 'package:flutter/material.dart';

class TaskModal extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(BuildContext) onDatePicked;
  final String? selectedStartTime;
  final String? selectedEndTime;
  final List<String> timeSlots;
  final Function(String?) onStartTimeChanged;
  final Function(String?) onEndTimeChanged;

  TaskModal({
    required this.selectedDate,
    required this.onDatePicked,
    required this.selectedStartTime,
    required this.selectedEndTime,
    required this.timeSlots,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  @override
  _TaskModalState createState() => _TaskModalState();
}

class _TaskModalState extends State<TaskModal> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final List<String> categories = [
    "SPORT APP",
    "MEDICAL APP",
    "RENT APP",
    "NOTES",
    "GAMING PLATFORM APP"
  ];
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Text("Create new task",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: "Title"),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => widget.onDatePicked(context),
            child: Text(widget.selectedDate == null
                ? "Pick a date"
                : "Selected Date: ${widget.selectedDate!.toLocal()}".split(' ')[0]),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: widget.selectedStartTime,
                  items: widget.timeSlots
                      .map((time) =>
                          DropdownMenuItem(value: time, child: Text(time)))
                      .toList(),
                  onChanged: widget.onStartTimeChanged,
                  decoration: InputDecoration(labelText: "Start Time"),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: widget.selectedEndTime,
                  items: widget.timeSlots
                      .map((time) =>
                          DropdownMenuItem(value: time, child: Text(time)))
                      .toList(),
                  onChanged: widget.onEndTimeChanged,
                  decoration: InputDecoration(labelText: "End Time"),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: "Description"),
            maxLines: 3,
          ),
          SizedBox(height: 10),
          Text("Category", style: TextStyle(fontSize: 16)),
          Wrap(
            spacing: 8,
            children: categories
                .map((cat) => ChoiceChip(
                      label: Text(cat),
                      selected: selectedCategory == cat,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = selected ? cat : null;
                        });
                      },
                    ))
                .toList(),
          ),
          Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Create Task"),
            ),
          ),
        ],
      ),
    );
  }
}
