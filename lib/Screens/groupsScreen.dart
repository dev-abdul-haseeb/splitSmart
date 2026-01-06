import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide Divider;
import 'package:google_fonts/google_fonts.dart';
import 'package:split_smart/Screens/groupCreateAndJoinScreen.dart';
import 'package:split_smart/Widgets/TextStyles.dart';
import 'package:split_smart/Widgets/colors.dart';
import 'package:split_smart/Widgets/loadingDots.dart';

import '../DatabaseHandling.dart';
import 'chatScreen.dart';

class groupsScreen extends StatefulWidget {
  const groupsScreen({super.key});

  @override
  State<groupsScreen> createState() => _groupsScreenState();
}

class _groupsScreenState extends State<groupsScreen> {
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    final String? userEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      backgroundColor: Background(context),
      appBar: AppBar(
        backgroundColor: Background(context),
        title: Padding(
          padding: EdgeInsets.only(top: screenHeight*0.02),
          child: Text('Chats', style: heading1(screenHeight, context),),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getUserGroupsStream(userEmail),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingDots();
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error loading groups", style: TextStyle(color: ErrorColor(context))));
          }
          final groups = snapshot.data;
          if (groups == null || groups.isEmpty) {
            return Center(child: Text("You haven't joined any groups yet.", style: TextStyle(color: TextPrimary(context))));
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: screenHeight*0.015, horizontal: screenWidth*0.006),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return Card(
                color: Surface(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenHeight*0.01)),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: screenWidth*0.04, vertical: screenHeight*0.004),
                  leading: CircleAvatar(
                    backgroundColor: Color(group['color'] ?? 0xFF2196F3), // Default to blue if null
                    radius: screenWidth*0.06,
                    child: Text(
                      (group['name'] != null && group['name'].isNotEmpty)
                          ? group['name'][0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: screenHeight*0.02
                      ),
                    ),
                  ),
                  title: Text(
                    group['name'] ?? 'Unnamed Group',
                    style: GoogleFonts.poppins(fontSize: screenHeight*0.025,color: TextPrimary(context), fontWeight: FontWeight.bold),
                  ),    //Group Name
                  subtitle: StreamBuilder<List<String>>(
                    stream: getMemberNamesStream(group['members']),
                    builder: (context, memberSnapshot) {
                      if (memberSnapshot.connectionState == ConnectionState.waiting) {
                        return Text(
                          "Loading members...",
                          style: GoogleFonts.inter(
                            fontSize: screenHeight * 0.015,
                            color: Accent(context),
                          ),
                        );
                      }
                      if (memberSnapshot.hasError) {
                        return Text(
                          "Error loading members",
                          style: GoogleFonts.inter(
                            fontSize: screenHeight * 0.015,
                            color: ErrorColor(context),
                          ),
                        );
                      }

                      final names = memberSnapshot.data ?? [];

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return SizedBox(
                            width: constraints.maxWidth,
                            child: Text(
                              names.join(', '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: screenHeight * 0.015,
                                color: TextSecondary(context),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => chatScreen(groupId: group['id']),),);
                  },
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>groupCreateAndJoin()));
        },
        backgroundColor: Button(context),
        shape: const CircleBorder(),
        child: Icon(
          Icons.chat,
          color: Background(context),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );

  }
}