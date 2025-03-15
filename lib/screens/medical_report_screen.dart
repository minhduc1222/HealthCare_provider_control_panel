import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class MedicalReportScreen extends StatefulWidget {
  @override
  _MedicalReportScreenState createState() => _MedicalReportScreenState();
}

class _MedicalReportScreenState extends State<MedicalReportScreen> {
  final TextEditingController _patientIdController = TextEditingController();
  final TextEditingController _providerIdController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();
  final TextEditingController _progressController = TextEditingController();
  
  bool _isLoading = false;
  List<dynamic> _reports = [];
  List<dynamic> _patients = [];
  List<dynamic> _users = [];
  int? _selectedPatient;
  int? _selectedProvider;
  
  @override
  void initState() {
    super.initState();
    _fetchPatients();
    _fetchProviders();
    _fetchReports();
  }
  
  Future<void> _fetchPatients() async {
    try {
      final url = Uri.parse('http://10.0.2.2/api/patients.php');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          setState(() {
            _patients = result['data'];
          });
        }
      }
    } catch (e) {
      print('Error fetching patients: $e');
    }
  }
  
  Future<void> _fetchProviders() async {
    try {
      final url = Uri.parse('http://10.0.2.2/api/users.php?role=healthcare_provider');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          setState(() {
            _users = result['data'];
          });
        }
      }
    } catch (e) {
      print('Error fetching providers: $e');
    }
  }
  
  Future<void> _fetchReports() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final url = Uri.parse('http://10.0.2.2/api/medical_reports.php');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          setState(() {
            _reports = result['data'];
          });
        }
      }
    } catch (e) {
      print('Error fetching reports: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> submitReport() async {
    if (_selectedPatient == null || _selectedProvider == null ||
        _diagnosisController.text.isEmpty || _treatmentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final url = Uri.parse('http://10.0.2.2/api/medical_reports.php');
      
      // Make sure all values are properly formatted
      final requestBody = {
        "patient_id": _selectedPatient,
        "provider_id": _selectedProvider,
        "diagnosis": _diagnosisController.text,
        "treatment": _treatmentController.text,
        "progress": _progressController.text.isEmpty ? "" : _progressController.text,
      };
      
      print('Sending request: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      // Check if response is valid JSON
      if (response.statusCode == 200) {
        // Check if response starts with HTML tags (error page)
        if (response.body.trim().startsWith('<')) {
          print('Error: Server returned HTML instead of JSON');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Server error: Returned HTML instead of JSON')),
          );
        } else {
          try {
            final result = jsonDecode(response.body);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message'] ?? 'Report submitted')),
            );
            
            if (result['status'] == 'success') {
              _clearForm();
              _fetchReports();
            }
          } catch (e) {
            print('Error decoding response: ${response.body}');
            print('Exception details: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error processing server response: $e')),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error submitting report: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _clearForm() {
    setState(() {
      _selectedPatient = null;
      _selectedProvider = null;
      _diagnosisController.clear();
      _treatmentController.clear();
      _progressController.clear();
    });
  }
  
  Future<void> _shareReport(dynamic report) async {
    // Create a temporary file with report details
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/medical_report_${report['report_id']}.txt');
    
    String reportContent = """
MEDICAL REPORT
--------------
Patient: ${report['patient_first_name']} ${report['patient_last_name']}
Provider: ${report['provider_first_name']} ${report['provider_last_name']}
Date: ${report['created_at']}

DIAGNOSIS:
${report['diagnosis']}

TREATMENT PLAN:
${report['treatment']}

PROGRESS NOTES:
${report['progress']}
    """;
    
    await file.writeAsString(reportContent);
    
    // Share the file
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Medical Report for ${report['patient_first_name']} ${report['patient_last_name']}',
    );
    
    // Also record the share in the database
    final url = Uri.parse('http://10.0.2.2/api/medical_reports.php?action=share');
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "report_id": report['report_id'],
        "shared_with": 1, // This would normally be the ID of the user you're sharing with
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Medical Reports"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Create Report"),
              Tab(text: "View Reports"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Create Report Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<int>(
                    value: _selectedPatient,
                    decoration: InputDecoration(
                      labelText: "Patient *",
                      border: OutlineInputBorder(),
                    ),
                    items: _patients.map((patient) {
                      return DropdownMenuItem<int>(
                        value: int.parse(patient['patient_id'].toString()),
                        child: Text("${patient['first_name']} ${patient['last_name']}"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPatient = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedProvider,
                    decoration: InputDecoration(
                      labelText: "Healthcare Provider *",
                      border: OutlineInputBorder(),
                    ),
                    items: _users.map((user) {
                        return DropdownMenuItem<int>(
                          value: int.parse(user['user_id'].toString()),
                          child: Text("${user['first_name']} ${user['last_name']}"),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProvider = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _diagnosisController,
                      decoration: InputDecoration(
                        labelText: "Diagnosis *",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _treatmentController,
                      decoration: InputDecoration(
                        labelText: "Treatment Plan *",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _progressController,
                      decoration: InputDecoration(
                        labelText: "Progress Notes",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : submitReport,
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Submit Report"),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
              
              // View Reports Tab
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _reports.isEmpty
                      ? Center(child: Text("No medical reports found"))
                      : ListView.builder(
                          itemCount: _reports.length,
                          itemBuilder: (context, index) {
                            final report = _reports[index];
                            return Card(
                              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ExpansionTile(
                                title: Text(
                                  "Patient: ${report['patient_first_name']} ${report['patient_last_name']}",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "Provider: ${report['provider_first_name']} ${report['provider_last_name']} | ${report['created_at']}",
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _reportSection("Diagnosis", report['diagnosis']),
                                        SizedBox(height: 12),
                                        _reportSection("Treatment Plan", report['treatment']),
                                        SizedBox(height: 12),
                                        _reportSection("Progress Notes", report['progress']),
                                        SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            OutlinedButton.icon(
                                              icon: Icon(Icons.share),
                                              label: Text("Share"),
                                              onPressed: () => _shareReport(report),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      );
    }
    
    Widget _reportSection(String title, String content) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 4),
          Text(
            content.isEmpty ? "Not provided" : content,
            style: TextStyle(fontSize: 15),
          ),
        ],
      );
    }
  }
