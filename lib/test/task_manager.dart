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
  DateTime selectedDate = DateTime.now(); // Initialize with today's date
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
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _selectDayFromCalendar(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  void _showTaskCreationModal() {
    setState(() {
      selectedStartTime = null;
      selectedEndTime = null;
    });

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
            // Update the selected date to match the task date
            if (newTask['date'] != null) {
              selectedDate = newTask['date'];
            }
            print('New task added: ${newTask.toString()}');
          });

          // Show feedback that task was added
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Task '${newTask['title']}' added successfully"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  // Helper method to check if two dates are on the same day
  bool _isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  // Filter tasks for the selected date
  List<Map<String, dynamic>> _getTasksForSelectedDate() {
    return tasks.where((task) => _isSameDay(task['date'], selectedDate)).toList();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String currentMonth = DateFormat('MMMM, yyyy').format(selectedDate);
    int daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _isSameDay(selectedDate, now) ? "Today" : DateFormat('MMM d, yyyy').format(selectedDate),
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
          // Display current month
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

          // Horizontal day scroller
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: daysInMonth,
              itemBuilder: (context, index) {
                int day = index + 1;
                DateTime dateForDay = DateTime(selectedDate.year, selectedDate.month, day);
                bool isSelectedDay = _isSameDay(dateForDay, selectedDate);
                bool isToday = _isSameDay(dateForDay, now);

                return GestureDetector(
                  onTap: () => _selectDayFromCalendar(dateForDay),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelectedDay ? Colors.red : (isToday ? Colors.orange : Colors.grey[300]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(dateForDay), // Day of week (Mon, Tue)
                          style: TextStyle(
                            color: isSelectedDay || isToday ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          day.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelectedDay || isToday ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
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
                  // Time grid
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

                  // Display tasks on timeline for the selected date
                  ..._getTasksForSelectedDate().map((task) {
                    // Calculate position and height
                    int startHour = task['startHour'];
                    int startMinute = task['startMinute'];
                    int endHour = task['endHour'];
                    int endMinute = task['endMinute'];

                    int startTotalMinutes = startHour * 60 + startMinute;
                    int endTotalMinutes = endHour * 60 + endMinute;

                    // Position: 60 pixels per hour, so 1 pixel per minute
                    double topPosition = startTotalMinutes * (60 / 60);
                    double height = (endTotalMinutes - startTotalMinutes) * (60 / 60);

                    // Format time for display
                    String startTimeStr = "${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}";
                    String endTimeStr = "${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}";

                    return Positioned(
                      left: 70,
                      right: 16,
                      top: topPosition,
                      child: Container(
                        height: height > 0 ? height : 60, // Ensure minimum height
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    task['title'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  "$startTimeStr - $endTimeStr",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            if (height > 30) // Only show description if there's enough space
                              Text(
                                task['description'] ?? '',
                                style: TextStyle(color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            if (task['category'] != null && height > 50)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    task['category'],
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
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
      int startMinute = int.parse(widget.selectedStartTime!.split(':')[1]);
      int endHour = int.parse(widget.selectedEndTime!.split(':')[0]);
      int endMinute = int.parse(widget.selectedEndTime!.split(':')[1]);

      // Validate end time is after start time
      if (endHour < startHour || (endHour == startHour && endMinute <= startMinute)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("End time must be after start time")),
        );
        return;
      }

      final newTask = {
        'title': titleController.text,
        'description': descriptionController.text,
        'startHour': startHour,
        'startMinute': startMinute,
        'endHour': endHour,
        'endMinute': endMinute,
        'category': selectedCategory,
        'date': widget.selectedDate,
      };

      widget.onTaskAdded(newTask);
      Navigator.pop(context);
    } else {
      // Show validation error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields")),
      );
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
              onPressed: _saveTask,
              child: Text("Create Task"),
            ),
          ),
        ],
      ),
    );
  }
}