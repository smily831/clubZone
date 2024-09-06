import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sutlej_club/auth/login_page.dart';
import 'package:sutlej_club/auth/register_page.dart';
import 'package:sutlej_club/dashboard/home_page.dart';
import 'dashboard/add_plan.dart';
import 'dashboard/bill_page.dart';
import 'dashboard/category_list.dart';
import 'dashboard/category_page.dart';
import 'dashboard/member_register.dart';
import 'dashboard/product_list.dart';
import 'dashboard/product_page.dart';
import 'dashboard/scanner.dart';
import 'firebase_options.dart';
import 'auth/splash_page.dart';

Future<void> main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Sutlej Club',
        theme: ThemeData(
          fontFamily: GoogleFonts.nunito().fontFamily,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashPage(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const HomePage(),
          '/memberRegister': (context) => const MemberRegistrationPage(),
          '/scanner': (context) => const Scanner(),
          '/addPlan': (context) => const AddPlanPage(),
          '/category': (context) => const CategoryPage(),
          '/categoryList': (context) => const CategoryList(),
          '/product': (context) => const ProductPage(),
          '/productList': (context) => const ProductList(),

        }
    );
  }
}

