import 'package:blogs_app/constants/constants.dart';
import 'package:blogs_app/landing/landingPage.dart';
import 'package:blogs_app/providers/user_provider.dart';
import 'package:blogs_app/screens/home_screen.dart';
import 'package:blogs_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  Gemini.init(apiKey: Constants.GEMINI_API_KEY);
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService authService = AuthService();
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      await authService.getUserData(context);
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      FlutterNativeSplash
          .remove(); // Ensure splash screen is removed in case of errors
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle( SystemUiOverlayStyle(
      systemNavigationBarColor: Constants.bg, // Set your desired color here
      // systemNavigationBarIconBrightness: Brightness.dark, // Adjust icon color as needed
    ));
    return MaterialApp(
      
      title: 'Flutter Demo',
      theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Constants.bg,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          appBarTheme: AppBarTheme(
            color: Constants.appBar,
            foregroundColor: Colors.white
          ),
          
          
          textTheme: GoogleFonts.poppinsTextTheme()),
      debugShowCheckedModeBanner: false,
      home: Provider.of<UserProvider>(context).user.token.isEmpty? const LandingPage(): const HomeScreen(),
      // home: const VerifyOtp(email: 'nadeeemanas617@gmail.com',),
    );
  }
}
