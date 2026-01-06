import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:split_smart/DatabaseHandling.dart';
import 'package:split_smart/Screens/signInScreen.dart';
import 'package:split_smart/UserAuth.dart';

import '../Widgets/TextStyles.dart';
import '../Widgets/colors.dart';
import '../main.dart';

class signUpScreen extends StatefulWidget {
  const signUpScreen({super.key});

  @override
  State<signUpScreen> createState() => _signUpScreenState();
}

class _signUpScreenState extends State<signUpScreen> {
  var formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
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
        title: Text('Sign Up', style: appBarText(screenHeight, context)),
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
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: screenWidth * 0.16, bottom: screenHeight * 0.007),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Enter Name:',
                            style: heading2(screenHeight, context),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.15),
                        child: TextFormField(
                          controller: nameController,
                          style: TextStyle(color: Accent(context)),
                          validator: (val) =>
                          val == null || val.isEmpty ? 'Enter name' : null,
                          decoration: InputDecoration(
                            hintText: 'Name',
                            hintStyle: TextStyle(color: Accent(context)),
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
                      ),
                    ],
                  ),    //Email field
                  SizedBox(height: screenHeight * 0.03),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: screenWidth * 0.16, bottom: screenHeight * 0.007),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Enter Email:',
                            style: heading2(screenHeight, context),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.15),
                        child: TextFormField(
                          controller: emailController,
                          style: TextStyle(color: Accent(context)),
                          validator: (val) =>
                          val == null || val.isEmpty ? 'Enter email' : null,
                          decoration: InputDecoration(
                             hintText: 'Email',
                             hintStyle: TextStyle(color: Accent(context)),
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
                      ),
                    ],
                  ),    //Email field
                  SizedBox(height: screenHeight * 0.03),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: screenWidth * 0.16, bottom: screenHeight * 0.007),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Enter Password:',
                            style: heading2(screenHeight, context),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.15),
                        child: TextFormField(
                          controller: passwordController,
                          style: TextStyle(color: Accent(context)),
                          obscureText: true,
                          validator: (val) =>
                          val == null || val.isEmpty ? 'Enter password' : val.length<6 ? 'Password must be of at least 6 characters' : null,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(color: Accent(context)),
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
                      ),
                    ],
                  ),    //Password field
                  SizedBox(height: screenHeight * 0.03),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: screenWidth * 0.16, bottom: screenHeight * 0.007),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Re-enter password:',
                            style: heading2(screenHeight, context),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.15),
                        child: TextFormField(
                          controller: confirmPasswordController,
                          style: TextStyle(color: Accent(context)),
                          obscureText: true,
                          validator: (val) =>
                          val == null || val.isEmpty ? 'Re-enter password' : val!=passwordController.text.trim() ? "Passwords don't match" : null,
                          decoration: InputDecoration(
                            hintText: 'Confirm Password',
                            hintStyle: TextStyle(color: Accent(context)),
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
                      ),
                    ],
                  ),    //ConfirmPassword field
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
                          bool signUpSuccessful = await createUserWithEmailAndPassword(emailController.text.trim(), passwordController.text.trim());
                          if(signUpSuccessful) {
                            bool dataInDB = await AddUserToDb(
                                emailController.text.
                                trim(), nameController.text.trim());
                            if (!dataInDB) {
                              error = "Unable to create account!";
                              _errorOpacity = 1.0;
                            }
                            else{
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Account created successfully!"),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              Future.delayed(Duration(milliseconds: 1050), () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const MyApp()),
                                      (route) => false,
                                );
                              });
                            }
                          }
                          else {
                            error = "Unable to create account!";
                            _errorOpacity = 1.0;
                          }
                          setState(() {
                            isloading = false;
                          });
                        }
                      },
                      child: Text(
                        'Sign up',
                        style: button(screenHeight, context),
                      ),
                    ),
                  ),    //Sign up button
                  SizedBox(height: screenHeight * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: subTitle(screenHeight, context),
                      ),
                      InkWell(
                        child: Text(
                          'Sign in',
                          style: link(
                            screenHeight,
                            context,
                          ).copyWith(decoration: TextDecoration.underline),
                        ),
                        onTap: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>signInScreen()));
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
            bottom: screenHeight * 0.06,
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
