import 'package:flutter/material.dart' hide Divider;
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_smart/DatabaseHandling.dart';
import 'package:split_smart/Widgets/TextStyles.dart';
import 'package:split_smart/Widgets/colors.dart';

class groupCreateAndJoin extends StatefulWidget {
  const groupCreateAndJoin({super.key});

  @override
  State<groupCreateAndJoin> createState() => _groupCreateAndJoinState();
}

class _groupCreateAndJoinState extends State<groupCreateAndJoin> {
  final groupNameController = TextEditingController();
  final groupCodeController = TextEditingController();
  bool isLoading = false;

  Color selectedColor = Colors.blue;
  final List<Color> availableColors = [
    Colors.red,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.brown,
  ];


  Widget groupCreate(var screenHeight, var screenWidth,) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Enter Group name:',
              style: heading2(
                screenHeight,
                context,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ),      //Enter group name
          SizedBox(height: screenHeight * 0.02),
          TextField(
            controller: groupNameController,
            style: TextStyle(color: Accent(context)),
            decoration: InputDecoration(
              labelText: "Group Name",
              labelStyle: TextStyle(color: Accent(context)),
              border: OutlineInputBorder(),
            ),
          ),        //Group name field
          SizedBox(height: screenHeight * 0.04),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Select Profile Color:',
              style: heading2(
                screenHeight,
                context,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Wrap(
            spacing: screenWidth*0.06,
            runSpacing: screenHeight*0.02,
            children: availableColors.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedColor = color;
                  });
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(screenHeight*0.006),
                    border: Border.all(
                      color: selectedColor == color ? Button(context)! : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: screenHeight * 0.07),
          ElevatedButton(
            onPressed: () async {
              final groupName = groupNameController.text.trim();
              if (groupName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please enter a group name"),
                  ),
                );
                return;
              }
              if (groupName.length>=25) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("The groupName should be less than 20 characters"),
                  ),
                );
                return;
              }
              setState(() {
                isLoading=true;
              });
              String? groupCode = await addGroupToDb(groupName, selectedColor);
              setState(() {
                isLoading=false;
              });
              groupNameController.clear();
              if (groupCode != null) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: DividerColor(context),
                    title: Text(
                      "Group Created",
                      style: TextStyle(
                        color: Success(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Group '$groupName' created successfully!",
                          style: TextStyle(color: TextPrimary(context)),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight*0.02),
                        Row(
                          children: [
                            Text(
                              "Code: $groupCode",
                              style: TextStyle(fontSize: screenHeight*0.02,color: TextPrimary(context)),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(width: screenWidth*0.05,),
                            ElevatedButton.icon(
                              onPressed: () async {
                                await Clipboard.setData(ClipboardData(text: groupCode));
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Group code copied!")),
                                );
                              },
                              icon: Icon(Icons.copy, color: TextSecondary(context)),
                              label: Text(
                                "Copy",
                                style: TextStyle(
                                    color: TextSecondary(context),
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenHeight*0.02
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Success(context),
                              ),
                            ),
                          ],
                        ), //Copy button
                      ],
                    ),
                    actions: [
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Success(context),
                          ),
                          child: Text(
                            "OK",
                            style: TextStyle(
                              color: TextSecondary(context),
                              fontWeight: FontWeight.bold,
                              fontSize: screenHeight * 0.02,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: DividerColor(context),
                    title: Text("Error", style: TextStyle(color: ErrorColor(context),fontWeight: FontWeight.bold),),
                    content: Text("Group could not be created. Please try again.", style: TextStyle(color: TextPrimary(context)),),
                    actions: [
                      Center(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text("OK",style: TextStyle(color: TextSecondary(context),fontWeight: FontWeight.bold,fontSize: screenHeight*0.02),),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: ErrorColor(context)
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Button(context),
            ),
            child: Text(
              "Create Group",
              style: GoogleFonts.poppins(
                color: TextPrimary(context),
                fontWeight: FontWeight.bold,
                fontSize: screenHeight * 0.02,
              ),
            ),
          ),        //Create Button
        ],
      ),
    );
  }

  Widget groupJoin(var screenHeight, var screenWidth) {
    return
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Enter Group code:',
                style: heading2(
                  screenHeight,
                  context,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            TextField(
              controller: groupCodeController,
              style: TextStyle(color: Accent(context)),
              decoration: InputDecoration(
                labelText: "Group Code",
                labelStyle: TextStyle(color: Accent(context)),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: screenHeight*0.05),
            ElevatedButton(
              onPressed: () async {
                final groupCode = groupCodeController.text.trim();
                if (groupCode.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a group name"),
                    ),
                  );
                  return;
                }
                if (groupCode.length>=25) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("The groupName should be less than 20 characters"),
                    ),
                  );
                  return;
                }
                setState(() {
                  isLoading=true;
                });
                bool groupJoined = await joinGroup(groupCode);
                setState(() {
                  isLoading=false;
                });
                groupCodeController.clear();
                if (groupJoined) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: DividerColor(context),
                      title: Text("Group joined", style: TextStyle(color: Success(context),fontWeight: FontWeight.bold),),
                      content: Text("Group with code:'$groupCode' joined successfully!", style: TextStyle(color: TextPrimary(context)),),
                      actions: [
                        Center(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text("OK",style: TextStyle(color: TextSecondary(context),fontWeight: FontWeight.bold,fontSize: screenHeight*0.02),),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Success(context)
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: DividerColor(context),
                      title: Text("Error", style: TextStyle(color: ErrorColor(context),fontWeight: FontWeight.bold),),
                      content: Text("Unable to join group!", style: TextStyle(color: TextPrimary(context)),),
                      actions: [
                        Center(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: ErrorColor(context)
                            ),
                            child: Text("OK",style: TextStyle(color: TextSecondary(context),fontWeight: FontWeight.bold,fontSize: screenHeight*0.02),),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Button(context),
              ),
              child: Text(
                "Join Group",
                style: GoogleFonts.poppins(
                  color: TextPrimary(context),
                  fontWeight: FontWeight.bold,
                  fontSize: screenHeight * 0.02,
                ),
              ),
            ),
          ],
        ),
      );
  }
  
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 2, // Create & Join
      child: Scaffold(
        backgroundColor: Background(context),
        appBar: AppBar(
          backgroundColor: Background(context),
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Accent(context)),
          title: Text(
            'Groups',
            style: TextStyle(
              color: Button(context),
              fontSize: screenHeight * 0.025,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            labelColor: Button(context),
            unselectedLabelColor: Accent(context),
            indicatorColor: Button(context),
            tabs: const [
              Tab(text: "Create Group"),
              Tab(text: "Join Group"),
            ],
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: TabBarView(
                children: [
                  groupCreate(screenHeight, screenWidth),
                  groupJoin(screenHeight, screenWidth)
                ],
              ),
            ),
            if(isLoading)
              Positioned.fill(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: screenWidth * 0.13),
                    child: SpinKitWave(
                      color: Primary(context),
                      size: screenWidth * 0.1,
                    ),
                  ),
                ),
              ),      //Loading Animation

          ],
        ),
      ),
    );
  }
}

