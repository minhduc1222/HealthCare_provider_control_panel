import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: TaskHomePage());
  }
}

class TaskHomePage extends StatefulWidget {
  @override
  _TaskHomePageState createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  List<Map<String, dynamic>> tasks = [];
  DateTime? selectedDate;
  String? selectedStartTime;
  String? selectedEndTime;
  final List<String> timeSlots = List.generate(24 * 4, (index) {
    final hours = (index ~/ 4).toString().padLeft(2, '0');
    final minutes = ((index % 4) * 15).toString().padLeft(2, '0');
    return '$hours:$minutes';
  });

  void _pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _showTaskCreationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => TaskCreationModal(
            selectedDate: selectedDate,
            onDatePicked: _pickDate,
            selectedStartTime: selectedStartTime,
            selectedEndTime: selectedEndTime,
            timeSlots: timeSlots,
            onStartTimeChanged: (String? value) {
              setState(() => selectedStartTime = value);
            },
            onEndTimeChanged: (String? value) {
              setState(() => selectedEndTime = value);
            },
            onTaskAdded: (newTask) {
              setState(() {
                tasks.add(newTask);
                print(tasks); // Debug xem có lưu task không

              });
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String currentMonth = DateFormat('MMMM, yyyy').format(now);
    int currentDay = now.day;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Today",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: _showTaskCreationModal,
              child: Text("Add Task"),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hiển thị tháng hiện tại
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              currentMonth,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Danh sách thứ/ngày của tháng hiện tại (cuộn ngang)
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 30,
              itemBuilder: (context, index) {
                int day = index + 1;
                bool isToday = (day == currentDay);
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isToday ? Colors.red : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E').format(
                          DateTime(now.year, now.month, day),
                        ), // Hiển thị thứ (Mon, Tue)
                        style: TextStyle(
                          color: isToday ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        day.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isToday ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Timeline
          Expanded(
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  // Lưới thời gian
                  Column(
                    children: List.generate(24, (index) {
                      return Container(
                        height: 60,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 50,
                              child: Text(
                                "${index.toString().padLeft(2, '0')}:00",
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey[300])),
                          ],
                        ),
                      );
                    }),
                  ),

                  // Hiển thị task trên timeline
                  ...tasks.map((task) {
                    int startMinutes = int.parse(task['startHour'].split(':')[0]) * 60 +
                    int.parse(task['startHour'].split(':')[1]);
                    int endMinutes = int.parse(task['endHour'].split(':')[0]) * 60 +
                    int.parse(task['endHour'].split(':')[1]);

                    double topPosition = startMinutes * 1.0;
                    double height = (endMinutes - startMinutes) * 1.0;

                    return Positioned(
                      left: 70,
                      right: 16,
                      top: topPosition,
                      child: Container(
                        height: height,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              task['description'],
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskCreationModal extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(BuildContext) onDatePicked;
  final String? selectedStartTime;
  final String? selectedEndTime;
  final List<String> timeSlots;
  final Function(String?) onStartTimeChanged;
  final Function(String?) onEndTimeChanged;
  final Function(Map<String, dynamic>) onTaskAdded;

  TaskCreationModal({
    required this.selectedDate,
    required this.onDatePicked,
    required this.selectedStartTime,
    required this.selectedEndTime,
    required this.timeSlots,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
    required this.onTaskAdded,
  });

  @override
  _TaskCreationModalState createState() => _TaskCreationModalState();
}

class _TaskCreationModalState extends State<TaskCreationModal> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final List<String> categories = [
    "SPORT APP",
    "MEDICAL APP",
    "RENT APP",
    "NOTES",
    "GAMING PLATFORM APP",
  ];
  String? selectedCategory;

  void _saveTask() {
    if (widget.selectedDate != null &&
        widget.selectedStartTime != null &&
        widget.selectedEndTime != null &&
        titleController.text.isNotEmpty) {

    int startHour = int.parse(widget.selectedStartTime!.split(':')[0]);
    int endHour = int.parse(widget.selectedEndTime!.split(':')[0]);
    if (endHour <= startHour) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("End time must be after start time")),
      );
      return;
    }
      final newTask = {
        'title': titleController.text,
        'description': descriptionController.text,
        'startHour': int.parse(widget.selectedStartTime!.split(':')[0]),
        'startMinute': int.parse(widget.selectedStartTime!.split(':')[1]),
        'endHour': int.parse(widget.selectedEndTime!.split(':')[0]),
        'endMinute': int.parse(widget.selectedEndTime!.split(':')[1]),
        'category': selectedCategory,
      };
      widget.onTaskAdded(newTask);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      height: MediaQuery.of(context).size.height * 0.9, // Almost full screen
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
          Text(
            "Create new task",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: "Title"),
          ),
          SizedBox(height: 10),
          TextField(
            readOnly: true,
            onTap: () => widget.onDatePicked(context),
            decoration: InputDecoration(
              labelText: "Date",
              hintText:
                  widget.selectedDate == null
                      ? "Pick a date"
                      : DateFormat('yyyy-MM-dd').format(widget.selectedDate!),
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: widget.selectedStartTime,
                  items:
                      widget.timeSlots
                          .map(
                            (time) => DropdownMenuItem(
                              value: time,
                              child: Text(time),
                            ),
                          )
                          .toList(),
                  onChanged: widget.onStartTimeChanged,
                  decoration: InputDecoration(labelText: "Start Time"),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: widget.selectedEndTime,
                  items:
                      widget.timeSlots
                          .map(
                            (time) => DropdownMenuItem(
                              value: time,
                              child: Text(time),
                            ),
                          )
                          .toList(),
                  onChanged: widget.onEndTimeChanged,
                  decoration: InputDecoration(labelText: "End Time"),
                ),
              ),
            ],
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: "Description"),
            maxLines: 3,
          ),
          SizedBox(height: 10),
          Text("Category", style: TextStyle(fontSize: 16)),
          Wrap(
            spacing: 8,
            children:
                categories
                    .map(
                      (cat) => ChoiceChip(
                        label: Text(cat),
                        selected: selectedCategory == cat,
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = selected ? cat : null;
                          });
                        },
                      ),
                    )
                    .toList(),
          ),
          Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Submit task logic
                _saveTask();
              },
              child: Text("Create Task"),
            ),
          ),
        ],
      ),
    );
  }
}
