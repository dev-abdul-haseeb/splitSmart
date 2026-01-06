import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'colors.dart';

class loadingDots extends StatelessWidget {
  const loadingDots({super.key});
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
      color: Background(context),
      child: SpinKitWave(
        color: Color(0xFF6366F1),
        size: screenWidth*0.2,
      ),
    );
  }
}
