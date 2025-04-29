import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bri_cek/screens/home_screen.dart';
import 'package:bri_cek/screens/choose_bank.dart';
import 'package:bri_cek/theme/app_theme.dart';
import 'package:bri_cek/utils/app_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferensi orientasi (opsional)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const BRICek());
}

class BRICek extends StatelessWidget {
  const BRICek({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomeScreen(),
      builder: (context, child) {
        AppSize().init(context);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(AppSize.isSmallScreen ? 0.9 : 1.0),
          ),
          child: child!,
        );
      },
    );
  }
}
