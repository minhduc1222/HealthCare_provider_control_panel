import 'package:flutter/material.dart';
import 'test/task_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TaskManagerApp(),
    );
  }
}
