import 'package:blogs_app/constants/constants.dart';
import 'package:blogs_app/providers/user_provider.dart';
import 'package:blogs_app/screens/home_screen.dart';
import 'package:blogs_app/screens/password_reset/forgot_password1.dart';
import 'package:blogs_app/services/auth_service.dart';
import 'package:blogs_app/sheets/register_sheet.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginSheet extends StatefulWidget {
  const LoginSheet({super.key});

  @override
  State<LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<LoginSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _togglePasswordView() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      postData(_emailController.text, _passwordController.text, context);
    }
  }

  Future<void> postData(
      String email, String password, BuildContext context) async {
    final url = Uri.parse('${Constants.url}user/signin');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = json.encode({"email": email, "password": password});

    try {
      var userProvier = Provider.of<UserProvider>(context, listen: false);
      final navigator = Navigator.of(context);
      final response = await http.post(url, headers: headers, body: body);

      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        userProvier.setUser(response.body);
        AuthService().getUserData(context);
        await prefs.setString(
            'x-auth-token', jsonDecode(response.body)['token']);
        navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (ctx) => const HomeScreen()),
            (route) => false);
      } else if (response.statusCode == 401) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonDecode(response.body)['error'])));
      }
      // else {
      //   print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      // }
    } catch (error) {
      print('Error: $error');
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $error'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.8,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(48),
          topRight: Radius.circular(48),
        ),
        color: Color(0xFFFFECAA),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.06),
        child: Form(
          key: _formKey,
          child: ListView(
            // Set the ListView to use the available height
            shrinkWrap: true,
            children: [
              Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back!!!',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        'Login',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 30.0, // Set the width of the circle
                    height: 30.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red)),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.red,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              const Align(
                alignment: Alignment.topLeft,
                child: Text('username/email'),
              ),
              SizedBox(height: screenHeight * 0.005),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'info@example.com',
                  hintStyle: const TextStyle(color: Colors.black),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.025,
                    horizontal: screenWidth * 0.04,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero, // Rectangular shape
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(
                        screenWidth * 0.04), // Rectangular shape
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(
                        screenWidth * 0.04), // Rectangular shape
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.025,
                    horizontal: screenWidth * 0.04,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Colors.black,
                    ),
                    onPressed: _togglePasswordView,
                  ),
                  hintText: 'password',
                  hintStyle: const TextStyle(color: Colors.black),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero, // Rectangular shape
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(
                        screenWidth * 0.04), // Rectangular shape
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(
                        screenWidth * 0.04), // Rectangular shape
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Row(
                children: [
                  const Spacer(),
                  InkWell(
                    child: const Text('Forgot Password?'),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> const ForgotPassword1()));
                    },
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              SizedBox(
                width: screenWidth * 0.8,
                height: screenHeight * 0.075,
                child: TextButton(
                  onPressed: _login,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFFDE69), // Text color
                    backgroundColor: const Color(0xFF050522),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Row(
                children: [
                  const Text(
                    'Don\'t have an account? ',
                    style: TextStyle(fontSize: 16),
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
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
                      child: const Text('Register',
                          style: TextStyle(fontSize: 16, color: Colors.red)))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
