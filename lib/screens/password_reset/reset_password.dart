import 'dart:convert';
import 'package:blogs_app/constants/constants.dart';
import 'package:blogs_app/landing/landingPage.dart';
import 'package:blogs_app/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  final String email;
  const ResetPassword({super.key, required this.email});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureText = true;
  bool _obscureText2 = true;

  void _togglePasswordView() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _toggleConfirmPasswordView() {
    setState(() {
      _obscureText2 = !_obscureText2;
    });
  }

  String? _validatePassword(String? value) {
    final passwordRegex =
        RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$');
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (!passwordRegex.hasMatch(value)) {
      return 'Invalid Password';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _changePassword(String email, String password) async {
    final url = Uri.parse(
        '${Constants.uri}resetPassword'); // Replace with your actual API URL

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // Password changed successfully
        showSnackBar(context, 'Password changed successfully!');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (ctx) => const LandingPage()),
          (route) => false,
        );
      } else {
        final responseBody = jsonDecode(response.body);
        showSnackBar(
            context, responseBody['status'] ?? 'Failed to change password');
      }
    } catch (error) {
      showSnackBar(context, 'Error: $error');
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFFFECAA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFECAA),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Reset Password', style: TextStyle(fontSize: 24)),
            SizedBox(height: screenHeight * 0.05),
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: 'Create Password',
                        hintStyle: TextStyle(color: Constants.bg),
                        labelStyle: TextStyle(color: Constants.bg),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02),
                          borderSide: BorderSide(color: Constants.bg),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02),
                          borderSide: BorderSide(color: Constants.bg),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: _togglePasswordView,
                        ),
                      ),
                      validator: _validatePassword,
                    ),
                    SizedBox(height: screenHeight * 0.01),

                    // Password Requirement Note
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Password must be at least 8 characters long and include a combination of letters, numbers, and symbols.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Confirm Password Field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureText2,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintStyle: TextStyle(color: Constants.bg),
                        labelStyle: TextStyle(color: Constants.bg),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02),
                          borderSide: BorderSide(color: Constants.bg),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02),
                          borderSide: BorderSide(color: Constants.bg),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: _toggleConfirmPasswordView,
                        ),
                      ),
                      validator: _validateConfirmPassword,
                    ),
                  ],
                )),
            SizedBox(
              height: screenHeight * 0.05,
            ),
            SizedBox(
              width: screenWidth * 0.8,
              height: screenHeight * 0.075,
              child: TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _changePassword(widget.email, _passwordController.text);
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: Constants.bg,
                  foregroundColor: Constants.yellow,
                  // Padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                child: const Text(
                  'Change Password',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
