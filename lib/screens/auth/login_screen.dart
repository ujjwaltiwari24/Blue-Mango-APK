import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
      final result = await AuthService.signInWithGoogle();

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
          backgroundColor: const Color(0xff18181B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xffEF4444), width: 1),
          ),
          content: Text(
            "Couldn't sign in with Google. Please try again.",
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xffF4F4F5),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
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
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xff09090B),
      body: Stack(
        children: [
          /// Top Ambient Glow
          Positioned(
            top: -100,
            left: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xff046CC8).withOpacity(0.22),
                    const Color(0xff046CC8).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          /// Bottom Ambient Glow
          Positioned(
            bottom: -120,
            right: -80,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xff023E7D).withOpacity(0.28),
                    const Color(0xff023E7D).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - topPadding,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(height: 20),

                      /// Brand & Identity Section
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Hero(
                            tag: "logo",
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xff046CC8)
                                        .withOpacity(0.25),
                                    blurRadius: 32,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: Image.asset(
                                  "assets/images/logo.jpeg",
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 96,
                                      height: 96,
                                      decoration: BoxDecoration(
                                        color: const Color(0xff046CC8),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "🥭",
                                          style: TextStyle(fontSize: 44),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            "BlueMango",
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xffF4F4F5),
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "You control your identity.\nConnect, share, and express freely.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xffA1A1AA),
                              fontSize: 15,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),

                      /// Authentication Card
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 32),
                        decoration: BoxDecoration(
                          color: const Color(0xff111114),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Text(
                                    "Get Started",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xffF4F4F5),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Secure 1-tap Google Sign-In.\nNo passwords required.",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xff7D8597),
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _loading
                                          ? null
                                          : () {
                                        HapticFeedback.lightImpact();
                                        _googleLogin();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        const Color(0xffF4F4F5),
                                        foregroundColor:
                                        const Color(0xff09090B),
                                        disabledBackgroundColor:
                                        const Color(0xffF4F4F5)
                                            .withOpacity(0.6),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: _loading
                                          ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          valueColor:
                                          AlwaysStoppedAnimation<
                                              Color>(
                                            Color(0xff09090B),
                                          ),
                                        ),
                                      )
                                          : Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          const _GoogleIcon(),
                                          const SizedBox(width: 12),
                                          Text(
                                            "Continue with Google",
                                            style: GoogleFonts
                                                .plusJakartaSans(
                                              fontSize: 15,
                                              fontWeight:
                                              FontWeight.w700,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      /// Footer Terms & Privacy
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Text(
                          "By continuing, you agree to BlueMango's\nTerms of Service & Privacy Policy",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xff5C677D),
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom vector Google logo to eliminate network image dependencies
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Center(
        child: Text(
          "G",
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xff4285F4),
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}