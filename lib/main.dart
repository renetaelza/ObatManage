import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:obat/pages/manage_transaksi.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/cart.dart';
import 'pages/manage_obat.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
        theme: ThemeData(
          primaryColor: Color(0xFF17153B),
        ),
        routes: {
          'login_page': (context) => LoginPage(),
          'home_page': (context) => HomePage(),
          'profile_page': (context) => ProfilePage(),
          'manage_obat': (context) => ManageObat(),
          'manage_transaksi': (context) => ManageTransaksi(),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(Duration(seconds: 4));
    Navigator.pushReplacementNamed(context, 'login_page');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'logo/pharmacy.png',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            Text(
              'Selamat Datang di Apotek Harapan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
