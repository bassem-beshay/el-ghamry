import 'package:flutter/material.dart';

const Color kBlue = Color(0xFF1565C0);
const Color kWhite = Colors.white;
const Color kBlack = Colors.black;

void main() {
  runApp(const ElGhamryPharmacyApp());
}

class ElGhamryPharmacyApp extends StatelessWidget {
  const ElGhamryPharmacyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'صيدلية الغمري',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: kBlue,
          onPrimary: kWhite,
          secondary: kBlue,
          onSecondary: kWhite,
          surface: kWhite,
          onSurface: kBlack,
          error: Color(0xFFB00020),
          onError: kWhite,
        ),
        scaffoldBackgroundColor: kWhite,
        appBarTheme: const AppBarTheme(
          backgroundColor: kBlue,
          foregroundColor: kWhite,
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kBlue,
            foregroundColor: kWhite,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kBlue,
          foregroundColor: kWhite,
        ),
        iconTheme: const IconThemeData(color: kBlue),
        cardTheme: CardThemeData(
          color: kWhite,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: kBlue.withAlpha(30)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kBlue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kBlue, width: 2),
          ),
          labelStyle: const TextStyle(color: kBlack),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: kBlue,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              'صيدلية الغمري',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: kBlue,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('صيدلية الغمري'),
        ),
        body: const Center(
          child: Text(
            'مرحبا بك في صيدلية الغمري',
            style: TextStyle(
              fontSize: 22,
              color: kBlack,
            ),
          ),
        ),
      ),
    );
  }
}
