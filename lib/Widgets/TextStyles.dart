import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

TextStyle appBarText(var screenHeight, BuildContext context) {
  return GoogleFonts.poppins(
    fontSize: screenHeight * 0.035,
    color: TextPrimary(context),
    fontWeight: FontWeight.bold,
  );
}

TextStyle heading1(var screenHeight, BuildContext context) {
  return GoogleFonts.poppins(
    fontSize: screenHeight * 0.04,
    color: TextPrimary(context),
    fontWeight: FontWeight.bold,
  );
}

TextStyle heading2(var screenHeight, BuildContext context) {
  return GoogleFonts.poppins(
    fontSize: screenHeight * 0.02,
    color: TextPrimary(context),
  );
}

TextStyle button(var screenHeight, BuildContext context) {
  return GoogleFonts.poppins(
    fontSize: screenHeight * 0.025,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );
}

TextStyle subTitle(var screenHeight, BuildContext context) {
  return GoogleFonts.inter(
    fontSize: screenHeight * 0.02,
    color: TextSecondary(context),
  );
}

TextStyle link(var screenHeight, BuildContext context) {
  return GoogleFonts.poppins(
    fontSize: screenHeight * 0.02,
    fontWeight: FontWeight.bold,
    color: TextSecondary(context),
  );
}

TextStyle errorText(var screenHeight, BuildContext context) {
  return GoogleFonts.manrope(
    fontSize: screenHeight * 0.02,
    fontWeight: FontWeight.bold,
    color: ErrorColor(context),
  );
}



