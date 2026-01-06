import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide Divider;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:split_smart/DatabaseHandling.dart';
import 'package:split_smart/UserAuth.dart';
import 'package:split_smart/Widgets/TextStyles.dart';
import 'package:split_smart/Widgets/colors.dart';

import '../Providers/colourProviders.dart';

class userSettingsScreen extends StatefulWidget {
  const userSettingsScreen({super.key});

  @override
  State<userSettingsScreen> createState() => _userSettingsScreenState();
}

class _userSettingsScreenState extends State<userSettingsScreen> {
  var screenWidth;
  var screenHeight;
  bool isLoading = false;

  Widget account() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.015,
        horizontal: screenWidth * 0.02,
      ),
      child: Container(
        width: screenWidth * 0.94,
        height: screenHeight * 0.2,
        decoration: BoxDecoration(
          color: Surface(context),
          borderRadius: BorderRadius.circular(screenHeight * 0.02),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.03),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_circle_rounded, color: TextPrimary(context),size: screenHeight*0.04,),
                      SizedBox(width: screenWidth*0.02,),
                      Text(
                        'Account',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.inter(
                          fontSize: screenHeight * 0.03,
                          color: TextPrimary(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      final uid = user?.uid;

                      String currentName = "";
                      setState(() {
                        isLoading = true;
                      });
                      final doc = await FirebaseFirestore.instance.collection('names').doc(uid).get();
                      currentName = doc.data()!['name'];
                      setState(() {
                        isLoading = false;
                      });

                      showDialog(
                        context: context,
                        builder: (context) {
                          final nameController = TextEditingController(text: currentName);
                          final passwordController = TextEditingController(); // Keep password empty

                          return AlertDialog(
                            backgroundColor: Surface(context),
                            title: Text("Edit Account Info", style: heading1(screenHeight, context)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: nameController,
                                  style: TextStyle(color: Accent(context)),
                                  decoration: InputDecoration(
                                    labelText: "Name",
                                    labelStyle: TextStyle(color: Accent(context)),
                                  ),
                                ),    //Name
                                SizedBox(height: screenHeight * 0.02),
                                TextField(
                                  controller: passwordController,
                                  style: TextStyle(color: Accent(context)),

                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    labelStyle: TextStyle(color: Accent(context)),
                                  ),
                                ),    //Password
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Cancel", style: TextStyle(color: ErrorColor(context))),
                              ),    //Cancel Button
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Button(context),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  Navigator.pop(context);
                                  if (uid != null && nameController.text.isNotEmpty) {
                                    await FirebaseFirestore.instance.collection('names').doc(uid).update({'name': nameController.text});
                                  }
                                  if (passwordController.text.isNotEmpty) {
                                    try {
                                      await user?.updatePassword(passwordController.text);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Password update failed. Re-authenticate and try again."),
                                          backgroundColor: ErrorColor(context),
                                        ),
                                      );
                                    }
                                  }
                                  else if(passwordController.text.length<6 && passwordController.text.length>0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Password must be of 6+ characters."),
                                        backgroundColor: ErrorColor(context),
                                      ),
                                    );
                                  }
                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                                child: Text("Save", style: TextStyle(fontWeight: FontWeight.bold,color: TextPrimary(context))),
                              ),    //Save button
                            ],
                          );
                        },
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: screenWidth * 0.07),
                      child: Icon(Icons.edit, color: Button(context)),
                    ),
                  ),
                ],
              ), //Account and Edit
              SizedBox(height: screenHeight * 0.025),
              Row(
                children: [
                  Container(
                    width: screenWidth * 0.35,
                    child: Text(
                      'Name:',
                      style: heading2(screenHeight, context),
                    ),
                  ),
                  Container(
                    child: FutureBuilder<String>(
                      future: getUserName(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text(
                            "Loading...",
                            style: GoogleFonts.manrope(
                              color: TextPrimary(context),
                              fontSize: screenHeight * 0.02,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                            "Error",
                            style: GoogleFonts.manrope(
                              color: ErrorColor(context),
                              fontSize: screenHeight * 0.02,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else {
                          return Text(
                            snapshot.data ?? "Unknown",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: GoogleFonts.manrope(
                              color: TextPrimary(context),
                              fontSize: screenHeight * 0.02,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ), //Name
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  Container(
                    width: screenWidth * 0.35,
                    child: Text(
                      'Email Address:',
                      style: heading2(screenHeight, context),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<String?>(
                      future: getUserEmail(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text(
                            "Loading...",
                            style: GoogleFonts.manrope(
                              color: TextPrimary(context),
                              fontSize: screenHeight * 0.02,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                            "Error",
                            style: GoogleFonts.manrope(
                              color: ErrorColor(context),
                              fontSize: screenHeight * 0.02,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else {
                          return Text(
                            snapshot.data ?? "Unknown",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                            style: GoogleFonts.manrope(
                              color: TextPrimary(context),
                              fontSize: screenHeight * 0.02,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ), //Email
            ],
          ),
        ),
      ),
    );
  }

  Widget appearance() {
    final isWhiteMode = Provider.of<colorProvider>(context).whiteTheme;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.015,
        horizontal: screenWidth * 0.02,
      ),
      child: Container(
        width: screenWidth * 0.94,
        height: screenHeight * 0.13,
        decoration: BoxDecoration(
          color: Surface(context),
          borderRadius: BorderRadius.circular(screenHeight * 0.02),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.03),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb, color: TextPrimary(context),size: screenHeight*0.03,),
                  SizedBox(width: screenWidth*0.02,),
                  Text(
                    'Theme',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.inter(
                      fontSize: screenHeight * 0.03,
                      color: TextPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ), //Theme
              SizedBox(height: screenHeight * 0.005),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Dark Mode", style: heading2(screenHeight, context)),
                  Transform.scale(
                    scale: screenHeight * 0.0008,
                    child: Switch(
                      value: isWhiteMode,
                      activeColor: Button(context),
                      onChanged: (value) {
                        Provider.of<colorProvider>(
                          context,
                          listen: false,
                        ).changeColor();
                      },
                    ),
                  ),
                  Text("Light Mode", style: heading2(screenHeight, context)),
                ],
              ), //The theme and button
            ],
          ),
        ),
      ),
    );
  }

  Widget dataAndPrivacy() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.015,
        horizontal: screenWidth * 0.02,
      ),
      child: Container(
        width: screenWidth * 0.94,
        height: screenHeight * 0.22,
        decoration: BoxDecoration(
          color: Surface(context),
          borderRadius: BorderRadius.circular(screenHeight * 0.02),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.03),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.privacy_tip_outlined, color: TextPrimary(context),size: screenHeight*0.03,),
                  SizedBox(width: screenWidth*0.02,),
                  Text(
                    'Data & Privacy',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.inter(
                      fontSize: screenHeight * 0.03,
                      color: TextPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ), //Theme
              SizedBox(height: screenHeight * 0.02),
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: DividerColor(context),
                      title: Text(
                        'Delete Account',
                        style: TextStyle(
                          color: ErrorColor(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        'Are you sure you want to delete your account?',
                        style: TextStyle(color: TextPrimary(context)),
                      ), //Confirming
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: TextSecondary(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ), //Cancel button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ErrorColor(context),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            String password = '';
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: DividerColor(context),
                                  title: Text(
                                    'Confirm Deletion',
                                    style: TextStyle(
                                      color: ErrorColor(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Please enter your password to confirm deletion:',
                                        style: TextStyle(
                                          color: TextPrimary(context),
                                        ),
                                      ),    //Ask to re-enter
                                      SizedBox(height: screenHeight*0.02),
                                      TextField(
                                        obscureText: true,
                                        onChanged: (value) => password = value,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Password',
                                          labelStyle: TextStyle(
                                            color: Accent(context),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: TextSecondary(context),
                                        ),
                                      ),
                                    ),    //Cancel button
                                    ElevatedButton(
                                      onPressed: () async {
                                        setState(() {
                                          isLoading=true;
                                        });
                                        Navigator.of(context,).pop(); // Close the password dialog
                                        bool result = await deleteUserWithReAuth(password);
                                        if (result) {
                                          showDialog(   //Delete confirm
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              backgroundColor: DividerColor(context),
                                              title: Text(
                                                'Account Deleted',
                                                style: TextStyle(
                                                  color: Success(context),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              content: Text(
                                                'Your account has been deleted.',
                                                style: TextStyle(
                                                  color: TextPrimary(context),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text(
                                                    'OK',
                                                    style: TextStyle(
                                                      color: TextSecondary(context),
                                                    ),
                                                  ),
                                                ),    //OK Button
                                              ],
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context,).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to delete account. Incorrect password or error occurred.',
                                                style: TextStyle(
                                                  color: TextSecondary(context),
                                                ),
                                              ),
                                              backgroundColor: ErrorColor(context),
                                            ),    //Failed to delete
                                          );
                                        }
                                        setState(() {
                                          isLoading=false;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: ErrorColor(context),
                                      ),
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: TextSecondary(context),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),    //Delete Button
                                  ],
                                );
                              },
                            );
                          },

                          child: Text(
                            'Confirm',
                            style: TextStyle(
                              color: TextSecondary(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ), //Confirm button
                      ],
                    ),
                  );
                },
                child: Container(
                  width: screenWidth * 0.88,
                  height: screenHeight * 0.054,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screenHeight * 0.02),
                    color: DividerColor(context),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Delete Account',
                        style: heading2(screenHeight, context),
                      ),
                      SizedBox(width: screenWidth * 0.3),
                      Icon(Icons.delete, color: Button(context)),
                    ],
                  ),
                ),
              ),    //Delete User
              SizedBox(height: screenHeight * 0.01),
              InkWell(
                onTap: () async {
                  setState(() {
                    isLoading = true;
                  });
                  await logOutUser();
                  setState(() {
                    isLoading = false;
                  });
                },
                child: Container(
                  width: screenWidth * 0.88,
                  height: screenHeight * 0.054,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screenHeight * 0.02),
                    color: DividerColor(context),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Logout', style: heading2(screenHeight, context)),
                      SizedBox(width: screenWidth * 0.52),
                      Icon(Icons.logout, color: Button(context)),
                    ],
                  ),
                ),
              ),    //LogOut
            ],
          ),
        ),
      ),
    );
  }

  Widget aboutApp() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.01,
        horizontal: screenWidth * 0.02,
      ),
      child: Container(
        width: screenWidth * 0.94,
        height: screenHeight * 0.05,
        decoration: BoxDecoration(
          color: DividerColor(context),
          borderRadius: BorderRadius.circular(screenHeight * 0.01),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.03),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("App Version: 1.0", style: heading2(screenHeight, context)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Background(context),
      appBar: AppBar(
        backgroundColor: Background(context),
        title: Padding(
          padding: EdgeInsets.only(top: screenHeight * 0.01),
          child: Text('Settings', style: heading1(screenHeight, context)),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              account(),
              appearance(),
              dataAndPrivacy(),
              aboutApp(),
            ],
          ),
          if (isLoading)
            Center(
              child: SpinKitWave(
                color: Primary(context),
                size: screenWidth * 0.1,
              ),
            ),
        ],
      ),
    );
  }
}
