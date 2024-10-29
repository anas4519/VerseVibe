import 'dart:async';
import 'dart:convert';
import 'package:blogs_app/constants/constants.dart';
import 'package:blogs_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class VerifyOtp extends StatefulWidget {
  final String email;
  final String name;
  final String password;
  const VerifyOtp(
      {super.key,
      required this.email,
      required this.name,
      required this.password});

  @override
  State<VerifyOtp> createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> {
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

  // Function to build each OTP field
  Widget _buildOtpField(int index, BuildContext context) {
    return Container(
      height: 68,
      width: 64,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
        border: Border.all(color: Constants.yellow),
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
          style: const TextStyle(color: Colors.white, fontSize: 18),
          textAlign: TextAlign.center,
          cursorColor: Constants.yellow,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: const InputDecoration(border: InputBorder.none),
        ),
      ),
    );
  }

  Future<void> checkOTP(BuildContext context, String otp) async {
    showLoadingDialog(context, 'Verifying OTP...');
    final url = Uri.parse('${Constants.uri}verify-otp');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      "fullName": widget.name,
      "email": widget.email,
      "password": widget.password,
      "otp": otp
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      Navigator.of(context).pop();
      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        showSnackBar(context,
            'Account created successfully, login with the same credentials!');
      } else {
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      Navigator.of(context).pop();
      showSnackBar(context, 'Error verifying OTP!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Verification Code',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
              SizedBox(height: screenHeight * 0.02),
              Text('We have sent the verification code to',
                  style: TextStyle(color: Colors.grey[300], fontSize: 12)),
              SizedBox(height: screenHeight * 0.01),
              Text(widget.email,
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: screenHeight * 0.04),
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
                      backgroundColor: Constants.yellow,
                      foregroundColor: Constants.bg,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02))),
                  onPressed: () {
                    // Handle OTP submission
                    String otp = _otpControllers
                        .map((controller) => controller.text)
                        .join();
                    checkOTP(context, otp);
                    // Add logic to verify OTP and proceed with registration
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
                            backgroundColor: Constants.yellow,
                            foregroundColor: Constants.bg,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.02))),
                        onPressed: _canResendOtp
                            ? () {
                                // Handle Resend OTP logic
                                startTimer(); // Restart the timer
                                print('Resend OTP');
                              }
                            : null, // Disable button if can't resend yet
                        child: const Text('Resend OTP'),
                      ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      _canResendOtp
                          ? 'You can resend the OTP now.'
                          : 'Resend OTP in $_remainingSeconds seconds',
                      style: TextStyle(color: Colors.grey[300], fontSize: 12),
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
