import 'package:flutter/material.dart';
import 'package:bri_cek/utils/app_size.dart';
import 'package:bri_cek/screens/login_screen.dart'; // Import Login Screen
import 'package:bri_cek/screens/manage_questions_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _addUser() {
    if (_usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'User ${_usernameController.text} berhasil ditambahkan!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      _usernameController.clear();
      _passwordController.clear();
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              height: AppSize.heightPercent(15),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0xFF2680C5),
                    Color(0xFF3D91D1),
                    Color(0xFFF37021),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  // Cloud decorations
                  _buildCloudDecoration(
                    top: AppSize.heightPercent(10),
                    left: AppSize.widthPercent(20),
                    size: AppSize.widthPercent(13),
                    opacity: 0.3,
                  ),
                  _buildCloudDecoration(
                    top: AppSize.heightPercent(3),
                    left: AppSize.widthPercent(42),
                    size: AppSize.widthPercent(12),
                    opacity: 0.2,
                  ),
                  _buildCloudDecoration(
                    top: AppSize.heightPercent(8),
                    left: AppSize.widthPercent(90),
                    size: AppSize.widthPercent(15),
                    opacity: 0.2,
                  ),

                  // Header content
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppSize.widthPercent(6),
                      top: AppSize.heightPercent(2),
                      right: AppSize.widthPercent(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          "Admin Dashboard",
                          style: AppSize.getTextStyle(
                            fontSize: AppSize.titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: AppSize.heightPercent(1)),
                        Text(
                          "Kelola pertanyaan dan pengguna",
                          style: AppSize.getTextStyle(
                            fontSize: AppSize.bodyFontSize,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section: Manage Questions
                      Text(
                        'Manage Questions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const ManageQuestionsScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: EdgeInsets.symmetric(
                            vertical: AppSize.heightPercent(2),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.arrow_forward, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Manage Questions',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),

                      // Section: Add Users
                      Text(
                        'Add Users',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _addUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                        ),
                        child: const Text('Add User'),
                      ),
                      SizedBox(height: 32),

                      // Logout Button
                      ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          padding: EdgeInsets.symmetric(
                            vertical: AppSize.heightPercent(2),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.logout, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloudDecoration({
    required double top,
    required double left,
    required double size,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: Icon(
        Icons.cloud,
        color: Colors.white.withOpacity(opacity),
        size: size,
      ),
    );
  }
}
