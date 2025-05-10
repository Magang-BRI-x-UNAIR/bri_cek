import 'package:bri_cek/data/admin_data.dart'; // Import Admin Data
import 'package:bri_cek/screens/admin_dashboard_screen.dart'; // Import Admin Dashboard
import 'package:bri_cek/screens/home_screen.dart'; // Import Home Screen
import 'package:bri_cek/utils/app_size.dart';
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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      final email = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      // Validasi data admin
      if (email == AdminData.email && password == AdminData.password) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
        );
      } else {
        // Jika bukan admin, arahkan ke HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
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
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSize.paddingHorizontal,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo
                  Image.asset(
                    'assets/images/Logo_BRI_Unair.png', // Replace with your logo path
                    width: AppSize.widthPercent(40),
                  ),
                  SizedBox(height: AppSize.heightPercent(4)),

                  // Login Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Username Field
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
                            hintText: 'Enter your username',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSize.cardBorderRadius,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username is required';
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
                            hintText: 'Enter your password',
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
                              return 'Password is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppSize.heightPercent(4)),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _login,
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
                            child: Text(
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
