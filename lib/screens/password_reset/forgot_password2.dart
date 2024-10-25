import 'dart:async';
import 'dart:convert';
import 'package:blogs_app/constants/constants.dart';
import 'package:blogs_app/screens/password_reset/reset_password.dart';
import 'package:blogs_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ForgotPassword2 extends StatefulWidget {
  final String email;

  const ForgotPassword2({super.key, required this.email});

  @override
  State<ForgotPassword2> createState() => _ForgotPassword2State();
}

class _ForgotPassword2State extends State<ForgotPassword2> {
  // Store the OTP
  final List<TextEditingController> _otpControllers =
      List.generate(4, (index) => TextEditingController());

  // Timer and countdown variables
  late Timer _timer;
  int _remainingSeconds = 120;
  bool _canResendOtp = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _remainingSeconds = 120; // Reset to 2 minutes
    _canResendOtp = false; // Disable the resend button
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _canResendOtp = true;
        });
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    // Dispose controllers and timer to avoid memory leaks
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    _timer.cancel();
    super.dispose();
  }

  // Function to verify OTP
  Future<void> verifyOtpToChangePassword(
      String email, String otp, BuildContext context) async {
    final url = Uri.parse('${Constants.uri}verifyOTPToChangePassword');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'email': email, 'otp': otp});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result == true) {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => ResetPassword(email: email)));
          // Navigate to next screen or handle success
        } else {
          showSnackBar(context, 'Invalid or expired OTP!');
        }
      } else {
        // Handle error responses
        showSnackBar(context, 'OTP verification failed!');
      }
    } catch (error) {
      // Handle exceptions
      showSnackBar(context, 'Error: $error');
    }
  }

  Future<void> postData(String email, BuildContext context) async {
    final url = Uri.parse('${Constants.uri}generateOTPToChangePassword');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = json.encode({"email": email});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        showSnackBar(context, 'OTP sent successfully!');
      } else if (response.statusCode == 400) {
        showSnackBar(context, 'User does not exist!');
      } else {
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Exception: $error');
    }
  }

  // Function to build each OTP field
  Widget _buildOtpField(int index, BuildContext context) {
    return Container(
      height: 68,
      width: 64,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
        border: Border.all(color: Constants.bg),
      ),
      child: Center(
        child: TextFormField(
          controller: _otpControllers[index],
          onChanged: (value) {
            if (value.length == 1 && index < 3) {
              FocusScope.of(context).nextFocus(); // Move to next field
            } else if (value.isEmpty && index > 0) {
              FocusScope.of(context).previousFocus(); // Move to previous field
            }
          },
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
          cursorColor: Constants.bg,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: const InputDecoration(border: InputBorder.none),
        ),
      ),
    );
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
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('We sent you a code', style: TextStyle(fontSize: 24)),
              SizedBox(height: screenHeight * 0.05),
              Text('Enter it to verify ${widget.email}',
                  style: const TextStyle(fontSize: 18)),
              SizedBox(height: screenHeight * 0.02),
              Form(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                      4, (index) => _buildOtpField(index, context)),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.bg,
                      foregroundColor: Constants.yellow,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02))),
                  onPressed: () {
                    // Handle OTP submission
                    String otp = _otpControllers
                        .map((controller) => controller.text)
                        .join();
                    verifyOtpToChangePassword(widget.email, otp, context);
                  },
                  child: const Text('Verify OTP'),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Center(
                child: Column(
                  children: [
                    if (_canResendOtp)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Constants.bg,
                            foregroundColor: Constants.yellow,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.02))),
                        onPressed: _canResendOtp
                            ? () {
                                // Handle Resend OTP logic
                                startTimer(); // Restart the timer
                                postData(widget.email, context);
                              }
                            : null, // Disable button if can't resend yet
                        child: const Text('Resend OTP'),
                      ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      _canResendOtp
                          ? 'You can resend the OTP now.'
                          : 'Resend OTP in $_remainingSeconds seconds',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
