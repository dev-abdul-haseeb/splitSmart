import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_smart/Screens/homeScreen.dart';
import 'package:split_smart/Screens/signInScreen.dart';
import 'package:split_smart/Widgets/colors.dart';

import '../auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
bool showSplash = true;

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  bool showSlogan = false;
  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;
  var screenWidth;
  var screenHeight;

  @override
  void initState() {
    super.initState();

    // Wallet rotation controller
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: -0.3).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeOutBack),
    );

    // 1 second: start wallet fall animation
    Future.delayed(const Duration(seconds: 2), () {
      _rotateController.forward();
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        showSlogan = true;
      });
    });

    // 4 seconds: move to next screen
    Future.delayed(const Duration(seconds: 6), () {
      setState(() {
        showSplash = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    if (showSplash) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              AnimatedBuilder(
                animation: _rotateController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotateAnimation.value,
                    alignment: Alignment.topRight,
                    child: Icon(
                      Icons.wallet,
                      size: screenHeight * 0.1,
                      color: Colors.deepPurple,
                    ),
                  );
                },
              ),

              SizedBox(width: screenWidth * 0.07),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SplitSmart",
                    style: GoogleFonts.poppins(
                      fontSize: screenHeight * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(seconds: 2),
                    opacity: showSlogan ? 1.0 : 0.0,
                    child: Text(
                      "Money Made Friendly",
                      style: GoogleFonts.inter(
                        fontSize: screenHeight * 0.02,
                        color: Colors.black,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      );
    }

    // Firebase auth check
    return const AuthWrapper();

  }

  @override
  void dispose() {
    _rotateController.dispose();
    super.dispose();
  }
}
