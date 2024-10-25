import 'dart:convert';
import 'package:blogs_app/constants/constants.dart';
import 'package:blogs_app/screens/password_reset/forgot_password2.dart';
import 'package:blogs_app/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ForgotPassword1 extends StatefulWidget {
  const ForgotPassword1({super.key});

  @override
  State<ForgotPassword1> createState() => _ForgotPassword1State();
}

class _ForgotPassword1State extends State<ForgotPassword1> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  String? _validateEmail(String? value) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    } else if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<void> postData(String email, BuildContext context) async {
    final url = Uri.parse('${Constants.uri}generateOTPToChangePassword');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = json.encode({"email": email});

    print('Sending request with body: $body'); // Add this line for debugging

    try {
      final response = await http.post(url, headers: headers, body: body);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => ForgotPassword2(
                  email: email,
                )));
      } else if (response.statusCode == 400) {
        showSnackBar(context, 'User does not exist!');
      } else {
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Exception: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
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
            const Text(
              'Enter your Email Address',
              style: TextStyle(color: Colors.black, fontSize: 25),
            ),
            SizedBox(
              height: screenHeight * 0.05,
            ),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'info@example.com',
                  hintStyle: TextStyle(color: Constants.bg),
                  labelStyle: TextStyle(color: Constants.bg),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    borderSide: BorderSide(color: Constants.bg),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    borderSide: BorderSide(color: Constants.bg),
                  ),
                ),
                validator: _validateEmail,
              ),
            ),
            SizedBox(
              height: screenHeight * 0.06,
            ),
            SizedBox(
              width: screenWidth * 0.8,
              height: screenHeight * 0.075,
              child: TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    postData(_emailController.text, context);
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
                  'Send OTP',
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
