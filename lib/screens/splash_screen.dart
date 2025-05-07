import 'package:flutter/material.dart';
import 'package:bri_cek/screens/home_screen.dart';
import 'package:bri_cek/utils/app_size.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Konfigurasi animasi untuk efek glow
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Loop animasi glow
    _animationController.repeat(reverse: true);

    // Navigasi ke halaman berikutnya
    _navigateToHome();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToHome() async {
    try {
      // Lakukan proses inisialisasi asinkron
      // Contoh: await _preloadData();
      // Contoh: await _checkAppVersion();
      // Contoh: await _verifyAuthentication();

      // Minimal delay 1 detik untuk animasi
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      // Handle error jika terjadi
      print("Initialization error: $e");
    } finally {
      // Navigasi ke halaman sesuai state
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Inisialisasi AppSize jika perlu
    final appSize = AppSize();
    appSize.init(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2680C5), Color(0xFF3D91D1)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo dengan efek glow
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(_glowAnimation.value),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/images/Logo_BRI_Unair.png',
                  width: 180,
                  height: 180,
                ),
              ),

              SizedBox(height: AppSize.heightPercent(4)),

              // App name with animated fade-in
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.2, 1.0),
                ),
                child: const Text(
                  'BRI CEK',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
              ),

              SizedBox(height: AppSize.heightPercent(2)),

              // Tagline
              Text(
                'Powered by Bank BRI & Universitas Airlangga',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),

              SizedBox(height: AppSize.heightPercent(6)),

              // Loading indicator
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
