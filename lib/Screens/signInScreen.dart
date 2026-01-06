import 'package:flutter/material.dart' hide Divider;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:split_smart/Screens/signUpScreen.dart';
import 'package:split_smart/UserAuth.dart';
import 'package:split_smart/Widgets/TextStyles.dart';
import 'package:split_smart/Widgets/colors.dart';

class signInScreen extends StatefulWidget {
  const signInScreen({super.key});

  @override
  State<signInScreen> createState() => _signInScreenState();
}

class _signInScreenState extends State<signInScreen> {
  var formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;
  bool isloading = false;
  String error = "";
  double _errorOpacity = 0.0;


  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Background(context),
      appBar: AppBar(
        backgroundColor: Primary(context),
        title: Text('Sign In', style: appBarText(screenHeight, context)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Form(
            key: formKey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.15),
                    child: TextFormField(
                      controller: emailController,
                      style: TextStyle(color: Accent(context)),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Enter email' : null,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Accent(context)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.04),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300, // normal border
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.04),
                          borderSide: BorderSide(
                            color: Primary(context)!, // border on focus
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.04),
                          borderSide: BorderSide(color: ErrorColor(context)!), // Error
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.04),
                          borderSide: BorderSide(color: ErrorColor(context)!, width: 2),
                        ),
                      ),
                    ),
                  ),    //Email field
                  SizedBox(height: screenHeight * 0.04),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.15),
                    child: TextFormField(
                      controller: passwordController,
                      style: TextStyle(color: Accent(context)),
                      obscureText: _obscureText,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Enter password' : null,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Accent(context)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility : Icons.visibility_off,
                            color: TextSecondary(context),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.04),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300, // normal border
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.04),
                          borderSide: BorderSide(
                            color: Primary(context)!, // border on focus
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.04),
                          borderSide: BorderSide(color: ErrorColor(context)!, width: 2),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.04),
                          borderSide: BorderSide(color: ErrorColor(context)!, width: 2),
                        ),
                      ),
                    ),
                  ),    //Password field
                  SizedBox(height: screenHeight * 0.05),
                  SizedBox(
                    width: screenWidth * 0.5,
                    height: screenHeight * 0.06,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Button(context),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth*0.05),
                        ),
                      ),
                      onPressed: () async {
                        if(formKey.currentState!.validate()) {
                          error="";
                          _errorOpacity=0.0;
                          setState(() {
                            isloading = true;
                          });
                          bool signedIn = await signInUserWithEmailAndPassword(emailController.text.trim(),passwordController.text.trim());
                          if(!signedIn) {
                            error = "Unable to log in!";
                            _errorOpacity = 1.0;
                          }
                          setState(() {
                            isloading = false;
                          });
                        }
                      },
                      child: Text(
                        'Sign in',
                        style: button(
                          screenHeight,
                          context,
                        ),
                      ),
                    ),
                  ),    //Sign in button
                  SizedBox(height: screenHeight * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: subTitle(screenHeight, context),
                      ),
                      InkWell(
                        child: Text(
                          'Sign up',
                          style: link(
                            screenHeight,
                            context,
                          ).copyWith(decoration: TextDecoration.underline),
                        ),
                        onTap: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>signUpScreen()));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isloading)
            Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: screenWidth * 0.4),
                child: SpinKitWave(
                  color: Primary(context),
                  size: screenWidth * 0.1,
                ),
              ),
            ),
          Positioned(
            bottom: screenHeight * 0.22,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _errorOpacity,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
              child: Center(
                child: Text(
                  error,
                  style: errorText(screenHeight, context),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

        ]
      ),
    );
  }
}
