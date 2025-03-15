// tạo thêm bảng vào trong db:
// CREATE TABLE medical_reports (
// report_id INT AUTO_INCREMENT PRIMARY KEY,
// patient_id INT NOT NULL,
// provider_id INT NOT NULL,
// diagnosis TEXT NOT NULL,
// treatment TEXT NOT NULL,
// progress TEXT,
// created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
// updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
// FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
// FOREIGN KEY (provider_id) REFERENCES users(user_id) ON DELETE CASCADE
// );
//
// CREATE TABLE report_shares (
// share_id INT AUTO_INCREMENT PRIMARY KEY,
// report_id INT NOT NULL,
// shared_with INT NOT NULL,
// shared_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
// FOREIGN KEY (report_id) REFERENCES medical_reports(report_id) ON DELETE CASCADE,
// FOREIGN KEY (shared_with) REFERENCES users(user_id) ON DELETE CASCADE
// );
import 'package:flutter/material.dart';
import 'screens/medical_report_screen.dart';
// Import other screens as needed

void main() {
  runApp(HealthcareProviderApp());
}

class HealthcareProviderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthcare Provider Control Panel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  
  static List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    PatientsScreen(),
    CaregiversScreen(),
    MedicalReportScreen(),
    SettingsScreen(),
  ];
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Healthcare Provider Control Panel'),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              selected: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Patients'),
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.medical_services),
              title: Text('Caregivers'),
              selected: _selectedIndex == 2,
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.description),
              title: Text('Medical Reports'),
              selected: _selectedIndex == 3,
              onTap: () {
                _onItemTapped(3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              selected: _selectedIndex == 4,
              onTap: () {
                _onItemTapped(4);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Caregivers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Placeholder screens - replace these with your actual screen implementations
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Dashboard Screen'));
  }
}

class PatientsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Patients Screen'));
  }
}

class CaregiversScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Caregivers Screen'));
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Settings Screen'));
  }
}
