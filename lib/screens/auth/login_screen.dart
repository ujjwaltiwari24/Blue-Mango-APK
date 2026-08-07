import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool _loading = false;

  Future<void> _googleLogin() async {
    if (_loading) return;

    setState(() {
      _loading = true;
    });

    try {

      final result =
      await AuthService.signInWithGoogle();

      if (!mounted) return;

      if (result != null) {
        Navigator.pushReplacementNamed(
          context,
          "/feed",
        );
      }

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          _loading = false;
        });
      }

    }
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return Scaffold(

        backgroundColor: const Color(0xff09090B),

    body: Stack(

    children: [

    /// Background Glow

    Positioned(
    top: -120,
    left: -80,
    child: Container(
    width: 260,
    height: 260,
    decoration: BoxDecoration(
    color: const Color(0xff44B0FF)
        .withOpacity(.12),
    shape: BoxShape.circle,
    ),
    ),
    ),

    Positioned(
    bottom: -180,
    right: -100,
    child: Container(
    width: 300,
    height: 300,
    decoration: BoxDecoration(
    color: const Color(0xff192BC2)
        .withOpacity(.15),
    shape: BoxShape.circle,
    ),
    ),
    ),

    SafeArea(

    child: SingleChildScrollView(

    padding: const EdgeInsets.symmetric(
    horizontal: 28,
    ),

    child: ConstrainedBox(

    constraints: BoxConstraints(
    minHeight:
    size.height -
    MediaQuery.of(context)
        .padding
        .top,
    ),

    child: Column(

    mainAxisAlignment:
    MainAxisAlignment.center,

    children: [

    Hero(

    tag: "logo",

    child: Image.asset(
    "assets/images/logo.jpeg",
    width: 140,
    ),

    ),

    const SizedBox(height: 35),

    const Text(

    "Welcome to",

    style: TextStyle(
    color: Colors.white70,
    fontSize: 20,
    ),

    ),

    const SizedBox(height: 10),

    const Text(

    "BlueMango",

    style: TextStyle(
    color: Colors.white,
    fontSize: 38,
    fontWeight: FontWeight.w800,
    letterSpacing: -.5,
    ),

    ),

    const SizedBox(height: 14),

    const Text(

    "Speak Freely.\nStay Unknown.",

    textAlign: TextAlign.center,

    style: TextStyle(
    color: Colors.grey,
    fontSize: 16,
    height: 1.5,
    ),

    ),

    const SizedBox(height: 70),
    Container(

    width: double.infinity,

    padding: const EdgeInsets.all(24),

    decoration: BoxDecoration(

    color: Colors.white.withOpacity(.05),

    borderRadius: BorderRadius.circular(30),

    border: Border.all(
    color: Colors.white10,
    ),

    ),

    child: Column(

    children: [

    const Text(

    "Continue with your Google account",

    textAlign: TextAlign.center,

    style: TextStyle(

    color: Colors.white,

    fontSize: 18,

    fontWeight: FontWeight.w700,

    ),

    ),

    const SizedBox(height: 10),

    const Text(

    "BlueMango only supports secure Google Sign-In.\nNo passwords. No fake registrations.",

    textAlign: TextAlign.center,

    style: TextStyle(

    color: Colors.white60,

    fontSize: 14,

    height: 1.5,

    ),

    ),

    const SizedBox(height: 30),

    SizedBox(

    width: double.infinity,

    height: 58,

    child: ElevatedButton(

    onPressed: _loading
    ? null
        : () {

    HapticFeedback.lightImpact();

    _googleLogin();

    },

    style: ElevatedButton.styleFrom(

    backgroundColor: Colors.white,

    foregroundColor: Colors.black,

    elevation: 0,

    shape: RoundedRectangleBorder(

    borderRadius:
    BorderRadius.circular(18),

    ),

    ),

    child: _loading

    ? const SizedBox(

    width: 26,

    height: 26,

    child:
    CircularProgressIndicator(

    strokeWidth: 2.5,

    ),

    )

        : Row(

    mainAxisAlignment:
    MainAxisAlignment.center,

    children: [

    Image.network(

    "https://developers.google.com/identity/images/g-logo.png",

    width: 24,

    height: 24,

    ),

    const SizedBox(width: 14),

    const Text(

    "Continue with Google",

    style: TextStyle(

    fontSize: 17,

    fontWeight:
    FontWeight.w700,

    ),

    ),

    ],

    ),

    ),

    ),

    const SizedBox(height: 28),

    Text(

    "By continuing you agree to our Terms of Service\nand Privacy Policy.",

    textAlign: TextAlign.center,

    style: TextStyle(

    color: Colors.grey.shade500,

    fontSize: 12,

    height: 1.6,

    ),

    ),

    ],

    ),

    ),

    const SizedBox(height: 40),
      const SizedBox(height: 30),

    ],
    ),
    ),
    ),
    ),
    ],
    ),
    );
  }
}