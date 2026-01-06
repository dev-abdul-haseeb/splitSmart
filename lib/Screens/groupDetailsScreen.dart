import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_smart/Widgets/colors.dart';
import 'package:split_smart/Widgets/TextStyles.dart';

import '../DatabaseHandling.dart';

class groupDetailsScreen extends StatefulWidget {
  final String groupId;

  const groupDetailsScreen({super.key, required this.groupId});

  @override
  State<groupDetailsScreen> createState() => _groupDetailsScreenState();
}

class _groupDetailsScreenState extends State<groupDetailsScreen> {
  late String currentUserEmail;

  @override
  void initState() {
    super.initState();
    currentUserEmail = FirebaseAuth.instance.currentUser!.email!;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Background(context),
      appBar: AppBar(
        title: Text("Group Details",style: GoogleFonts.inter(fontSize: screenHeight*0.03,fontWeight: FontWeight.bold,color: TextPrimary(context)),),
        backgroundColor: Primary(context),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('groups').doc(widget.groupId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final groupName = data['name'] ?? 'Group';
          final groupColor = Color(data['color'] ?? 0xFF2196F3);
          final members = List<String>.from(data['members'] ?? []);

          return Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: screenHeight * 0.05,
                          backgroundColor: groupColor,
                          child: Text(
                            groupName[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: screenHeight * 0.04,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Center(
                        child: Text(
                          groupName,
                          style: heading1(screenHeight, context),
                        ),
                      ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Group code: ", style: heading2(screenHeight, context)),
                            Text(
                              data['code'],
                              style: heading2(screenHeight, context).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Divider(color: DividerColor(context)),
                      Text("Members:", style: heading2(screenHeight, context)),
                      Divider(color: DividerColor(context)),
                      SizedBox(height: screenHeight * 0.015),
                      ...members.map((email) => Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Surface(context),
                              borderRadius: BorderRadius.circular(screenHeight * 0.01),
                            ),
                            child: ListTile(
                              leading: Icon(Icons.person, color: TextSecondary(context)),
                              title: Text(email, style: TextStyle(color: TextPrimary(context))),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                        ],
                      )),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.015,
                      ),
                    ),
                    onPressed: () async {
                      await exitGroup(widget.groupId, currentUserEmail);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.exit_to_app, size: screenHeight * 0.025, color: TextPrimary(context)),
                    label: Text("Exit Group", style: button(screenHeight, context)),
                  ),
                ),
              ],
            ),
          );

        },
      ),
    );
  }
}
