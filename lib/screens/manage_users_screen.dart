import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bri_cek/utils/app_size.dart';
import 'package:bri_cek/screens/login_screen.dart';
import 'package:bri_cek/screens/manage_questions_screen.dart';
import 'package:bri_cek/services/auth_service.dart';
import 'package:bri_cek/models/user_model.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  // Form controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _isAddingUser = false;
  bool _isLoadingUsers = true;
  String? _errorMessage;
  List<UserModel> _users = [];
  bool _showAddUserForm = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      final users = await _authService.getAllUsers();
      setState(() {
        _users = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading users: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearForm() {
    _usernameController.clear();
    _passwordController.clear();
    _fullNameController.clear();
    _employeeIdController.clear();
    setState(() {
      _errorMessage = null;
    });
  }

  Future<void> _addUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isAddingUser = true;
        _errorMessage = null;
      });

      try {
        final user = await _authService.createUser(
          username: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
          fullName: _fullNameController.text.trim(),
          nickname: _fullNameController.text.trim(),
          employeeId: _employeeIdController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User ${user?.fullName ?? _usernameController.text} berhasil ditambahkan!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _clearForm();
        setState(() {
          _showAddUserForm = false;
        });
        _loadUsers(); // Refresh user list
      } on FirebaseAuthException catch (e) {
        setState(() {
          if (e.code == 'username-exists') {
            _errorMessage = 'Username sudah digunakan oleh akun lain';
          } else {
            _errorMessage = e.message ?? 'Terjadi kesalahan saat membuat akun';
          }
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isAddingUser = false;
        });
      }
    }
  }

  Future<void> _deleteUser(UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
            ),
            title: Row(
              children: [
                Icon(Icons.delete, color: Colors.red.shade600),
                SizedBox(width: 8),
                Text('Hapus User'),
              ],
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus user "${user.fullName}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Hapus', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _authService.deleteUser(user.uid);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User ${user.fullName} berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        _loadUsers(); // Refresh list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error menghapus user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
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
                    top: AppSize.heightPercent(8),
                    left: AppSize.widthPercent(20),
                    size: AppSize.widthPercent(10),
                    opacity: 0.3,
                  ),
                  _buildCloudDecoration(
                    top: AppSize.heightPercent(2),
                    left: AppSize.widthPercent(70),
                    size: AppSize.widthPercent(12),
                    opacity: 0.2,
                  ),

                  // Back button
                  Positioned(
                    top: AppSize.heightPercent(2),
                    left: AppSize.widthPercent(4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                        tooltip: 'Kembali ke Home',
                      ),
                    ),
                  ),

                  // Header content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.people,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Manage Users",
                          style: AppSize.getTextStyle(
                            fontSize: AppSize.titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Kelola pengguna sistem",
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

            // Action Buttons
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showAddUserForm = !_showAddUserForm;
                          if (!_showAddUserForm) _clearForm();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _showAddUserForm
                                ? Colors.grey
                                : Colors.blue.shade600,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(
                        _showAddUserForm ? Icons.close : Icons.person_add,
                        color: Colors.white,
                      ),
                      label: Text(
                        _showAddUserForm ? 'Cancel' : 'Add User',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _loadUsers,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(Icons.refresh, color: Colors.white),
                    label: Text(
                      'Refresh',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Add User Form (if visible)
                    if (_showAddUserForm) ...[
                      _buildAddUserForm(),
                      SizedBox(height: 16),
                    ],

                    // Users List Header
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.people, color: Colors.blue.shade700),
                          SizedBox(width: 8),
                          Text(
                            'Registered Users (${_users.length})',
                            style: AppSize.getTextStyle(
                              fontSize: AppSize.subtitleFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),

                    // Users List
                    Expanded(
                      child:
                          _isLoadingUsers
                              ? Center(
                                child: CircularProgressIndicator(
                                  color: Colors.blue.shade600,
                                ),
                              )
                              : _users.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                itemCount: _users.length,
                                itemBuilder: (context, index) {
                                  return _buildUserCard(_users[index]);
                                },
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddUserForm() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_add, color: Colors.blue.shade700),
                SizedBox(width: 8),
                Text(
                  'Add New User',
                  style: AppSize.getTextStyle(
                    fontSize: AppSize.subtitleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Username Field
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Username harus diisi';
                }
                if (value.toLowerCase() == 'adminbri') {
                  return 'Username tidak tersedia';
                }
                return null;
              },
            ),
            SizedBox(height: 12),

            // Password Field
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password harus diisi';
                }
                if (value.length < 6) {
                  return 'Password minimal 6 karakter';
                }
                return null;
              },
            ),
            SizedBox(height: 12),

            // Full Name Field
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                prefixIcon: Icon(Icons.badge),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama lengkap harus diisi';
                }
                return null;
              },
            ),
            SizedBox(height: 12),

            // Employee ID Field
            TextFormField(
              controller: _employeeIdController,
              decoration: InputDecoration(
                labelText: 'ID Karyawan',
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'ID karyawan harus diisi';
                }
                return null;
              },
            ),

            // Error Message
            if (_errorMessage != null)
              Container(
                margin: EdgeInsets.only(top: 12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 16),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isAddingUser ? null : _addUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    _isAddingUser
                        ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_add, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Add User',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: Colors.blue.shade700, size: 25),
          ),
          SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: AppSize.getTextStyle(
                    fontSize: AppSize.bodyFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Username: ${user.username}',
                  style: AppSize.getTextStyle(
                    fontSize: AppSize.smallFontSize,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  'ID: ${user.employeeId}',
                  style: AppSize.getTextStyle(
                    fontSize: AppSize.smallFontSize,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  'Active',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                onPressed: () => _deleteUser(user),
                icon: Icon(Icons.delete, color: Colors.red.shade400),
                tooltip: 'Delete User',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            'No Users Found',
            style: AppSize.getTextStyle(
              fontSize: AppSize.subtitleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Click "Add User" to create the first user',
            style: AppSize.getTextStyle(
              fontSize: AppSize.bodyFontSize,
              color: Colors.grey.shade500,
            ),
          ),
        ],
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
