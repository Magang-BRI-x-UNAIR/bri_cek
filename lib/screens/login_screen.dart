import 'package:bri_cek/data/admin_data.dart';
import 'package:bri_cek/screens/admin_dashboard_screen.dart';
import 'package:bri_cek/screens/home_screen.dart';
import 'package:bri_cek/services/auth_service.dart';
import 'package:bri_cek/utils/app_size.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      try {
        // Check if admin login
        if (username == AdminData.username && password == AdminData.password) {
          // Admin login logic
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminDashboardScreen(),
            ),
          );
          return;
        }

        // Regular user login with Firebase
        await _authService.signInWithUsernameAndPassword(username, password);

        // Navigate to Home Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = _getAuthErrorMessage(e.code);
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Login gagal. Periksa username dan password Anda.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Username tidak ditemukan.';
      case 'username-exists': // Add this case
        return 'Username sudah digunakan.';
      case 'wrong-password':
        return 'Password salah.';
      case 'user-disabled':
        return 'Akun telah dinonaktifkan.';
      default:
        return 'Error: $code';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Top Wave Decoration
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: AppSize.heightPercent(30),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF2680C5), // BRI Blue
                      Color(0xFF3D91D1),
                      Color(0xFFF37021), // BRI Orange
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CustomPaint(painter: WavePainter()),
              ),
            ),

            // Login Content
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSize.paddingHorizontal,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: AppSize.heightPercent(10)),

                    // App Logo
                    Image.asset(
                      'assets/images/Logo_BRI_Unair.png',
                      width: AppSize.widthPercent(40),
                    ),
                    SizedBox(height: AppSize.heightPercent(4)),

                    // Login Form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Username Field (changed from Email)
                          Text(
                            'Username',
                            style: AppSize.getTextStyle(
                              fontSize: AppSize.bodyFontSize,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: AppSize.heightPercent(1)),
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              hintText: 'Masukkan username Anda',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSize.cardBorderRadius,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Username harus diisi';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppSize.heightPercent(2)),

                          // Password Field
                          Text(
                            'Password',
                            style: AppSize.getTextStyle(
                              fontSize: AppSize.bodyFontSize,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: AppSize.heightPercent(1)),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              hintText: 'Masukkan password Anda',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSize.cardBorderRadius,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password harus diisi';
                              }
                              return null;
                            },
                          ),

                          if (_errorMessage != null)
                            Padding(
                              padding: EdgeInsets.only(
                                top: AppSize.heightPercent(1),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: AppSize.getTextStyle(
                                  fontSize: AppSize.bodyFontSize,
                                  color: Colors.red,
                                ),
                              ),
                            ),

                          SizedBox(height: AppSize.heightPercent(4)),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppSize.heightPercent(2),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSize.cardBorderRadius,
                                  ),
                                ),
                              ),
                              child:
                                  _isLoading
                                      ? SizedBox(
                                        height: AppSize.heightPercent(2.5),
                                        width: AppSize.heightPercent(2.5),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : Text(
                                        'Login',
                                        style: AppSize.getTextStyle(
                                          fontSize: AppSize.bodyFontSize,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                            ),
                          ),
                        ],
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
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height * 0.9,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.8,
      size.width,
      size.height * 0.9,
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
