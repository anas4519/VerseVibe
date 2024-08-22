import 'package:blogs_app/constants/constants.dart';
import 'package:blogs_app/sheets/login_sheet.dart';
import 'package:blogs_app/sheets/register_sheet.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Constants.bg,
      body: Padding(
        padding: EdgeInsets.only(
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            top: screenHeight * 0.03),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/Illustration Picture.png'),
              SizedBox(
                height: screenHeight * 0.03,
              ),
              const Text(
                'Welcome',
                style: const TextStyle(color: Color(0xFFEF5858), fontSize: 36),
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              const Text(
                'To get started with VerseVibe,\nyou must have an accout.\nClick Login if you already have an account.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: screenHeight * 0.04,
              ),
              SizedBox(
                width: screenWidth * 0.8,
                height: screenHeight * 0.075,
                child: TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        backgroundColor: const Color(0xFFFFECAA),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(48),
                                topRight: Radius.circular(48))),
                        builder: (ctx) => const RegisterSheet(),
                        isScrollControlled: true);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF050522), // Text color
                    backgroundColor: const Color(0xFFFFDE69),

                    // Padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              SizedBox(
                width: screenWidth * 0.8,
                height: screenHeight * 0.075,
                child: TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        backgroundColor: const Color(0xFFFFECAA),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(48),
                                topRight: Radius.circular(48))),
                        builder: (ctx) => const LoginSheet(),
                        isScrollControlled: true);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFFDE69), // Text color
                    backgroundColor: const Color(0xFF050522),

                    // Padding
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: const BorderSide(
                            color: const Color(0xFFFFDE69), width: 2) //
                        ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
