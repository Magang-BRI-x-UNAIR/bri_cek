import 'package:bri_cek/firebase_options.dart';
import 'package:bri_cek/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bri_cek/theme/app_theme.dart';
import 'package:bri_cek/utils/app_size.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Set preferensi orientasi (opsional)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const BRICek());
}

class BRICek extends StatelessWidget {
  const BRICek({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BRICek',
      theme: AppTheme.theme,
      home: const SplashScreen(),
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
