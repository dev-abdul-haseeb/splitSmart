import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:split_smart/Screens/groupDetailsScreen.dart';
import 'package:split_smart/Widgets/colors.dart';
import 'package:split_smart/Widgets/loadingDots.dart';
import 'package:flutter/material.dart';
import '../DatabaseHandling.dart';
import '../Widgets/TextStyles.dart';

class chatScreen extends StatefulWidget {
  final groupId;

  const chatScreen({super.key, required this.groupId});

  @override
  State<chatScreen> createState() => _chatScreenState();
}

class _chatScreenState extends State<chatScreen> {
  bool isLoading = false;
  var screenHeight;
  var screenWidth;

  void _openChatBottomSheet(BuildContext context) {
    final _descController = TextEditingController();
    final _amountController = TextEditingController(); // for total in equal mode
    final _customAmountController = TextEditingController(); // for custom amounts
    List<Map<String, dynamic>> payers = [];
    String? selectedMember;

    String mode = "custom"; // "custom" or "equal"

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(screenHeight * 0.03),
        ),
      ),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Surface(context),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(screenHeight * 0.03),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: screenWidth * 0.04,
              right: screenWidth * 0.04,
              top: screenHeight * 0.03,
            ),
            child: SingleChildScrollView(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('groups')
                    .doc(widget.groupId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: loadingDots());
                  }
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final members = List<String>.from(data['members'] ?? []);

                  return StatefulBuilder(
                    builder: (context, setModalState) {
                      double totalExpense = payers.fold(
                        0.0,
                            (sum, item) => sum + (item['amount'] as double),
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Mode selection
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ChoiceChip(
                                selected: mode == "custom",
                                selectedColor: Primary(context),
                                backgroundColor: Background(context),
                                label: Text(
                                  "Custom",
                                  style: TextStyle(
                                    color: mode == "custom" ? Colors.white : TextPrimary(context),
                                  ),
                                ),
                                onSelected: (selected) {
                                  setModalState(() {
                                    mode = "custom";
                                    payers.clear();
                                  });
                                },
                              ),
                              SizedBox(width: screenWidth*0.03),
                              ChoiceChip(
                                selected: mode == "equal",
                                selectedColor: Primary(context),
                                backgroundColor: Background(context),
                                label: Text(
                                  "Equal",
                                  style: TextStyle(
                                    color: mode == "equal" ? Colors.white : TextPrimary(context),
                                  ),
                                ),
                                onSelected: (selected) {
                                  setModalState(() {
                                    mode = "equal";
                                    payers.clear();
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          // Description
                          Text(
                            'Enter description:',
                            style: heading2(screenHeight, context)
                          ),
                          TextField(
                            controller: _descController,
                            style: TextStyle(color: TextPrimary(context)),
                            decoration: InputDecoration(
                              labelText: "Description",
                              labelStyle: TextStyle(color: TextSecondary(context)),
                              hintText: "Max 20 characters",
                              hintStyle: TextStyle(
                                color: Accent(context)?.withOpacity(0.6)
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          if (mode == "custom") ...[
                            Text("Add expense:",
                                style: heading2(screenHeight, context)),
                            Row(
                              children: [
                                Flexible(
                                  flex: 4,
                                  child: DropdownButtonFormField<String>(
                                    value: selectedMember,
                                    isExpanded: true, // Important
                                    hint: Text("Select member", style: TextStyle(color: TextSecondary(context))),
                                    items: members.map((member) {
                                      return DropdownMenuItem<String>(
                                        value: member,
                                        child: Text(member),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setModalState(() {
                                        selectedMember = value;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.02), // Reduced spacing
                                Flexible(
                                  flex: 2,
                                  child: TextField(
                                    controller: _customAmountController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: "Amount",
                                      hintStyle: TextStyle(color: TextSecondary(context)),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add, color: TextPrimary(context)),
                                  onPressed: () {
                                    final enteredAmount = double.tryParse(_customAmountController.text.trim());
                                    if (selectedMember == null || enteredAmount == null || enteredAmount <= 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Select member and valid amount")),
                                      );
                                      return;
                                    }

                                    setModalState(() {
                                      payers.add({
                                        'email': selectedMember,
                                        'amount': enteredAmount,
                                        'status': 'unpaid',
                                      });
                                      _customAmountController.clear();
                                      selectedMember = null;
                                    });
                                  },
                                ),
                              ],
                            )
                          ] else ...[
                            // Equal Distribution UI
                            Text("Enter total amount:", style: heading2(screenHeight, context)),
                            TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: TextPrimary(context)),
                              decoration: InputDecoration(
                                  hintText: "Total Amount",
                                  hintStyle:
                                  TextStyle(color: TextSecondary(context))),
                              onChanged: (_) {
                                final enteredTotal = double.tryParse(
                                    _amountController.text.trim());
                                if (enteredTotal != null && enteredTotal > 0) {
                                  final perPerson =
                                  (enteredTotal / members.length);
                                  setModalState(() {
                                    payers = members
                                        .map((email) => {
                                      'email': email,
                                      'amount': double.parse(perPerson.toStringAsFixed(2)),
                                      'status' : 'unpaid'
                                    })
                                        .toList();
                                  });
                                }
                              },
                            ),
                          ],
                          SizedBox(height: screenHeight * 0.02),

                          if (payers.isNotEmpty) ...[
                            Text("Payers List:",
                                style: heading2(screenHeight, context)),
                            ...payers.map((payer) => ListTile(
                              title: Text(payer['email'],
                                  style:
                                  TextStyle(color: TextSecondary(context))),
                              trailing: Text("Rs. ${payer['amount']}",
                                  style:
                                  TextStyle(color: TextSecondary(context))),
                            )),
                            Text(
                              "Total: Rs. $totalExpense",
                              style: heading2(screenHeight, context).copyWith(
                                color: TextPrimary(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          SizedBox(height: screenHeight * 0.02),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade700,
                                ),
                                onPressed: () {
                                  Navigator.pop(context); // Cancel action
                                },
                                child: Text("Cancel",
                                    style: button(screenHeight, context)),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Button(context),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    isLoading = true;
                                  });

                                  if (_descController.text.trim().length > 20 ||
                                      payers.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                          Text("Fill all fields properly")),
                                    );
                                    return;
                                  }

                                  final totalExpense = payers.fold<double>(
                                    0.0,
                                        (sum, item) =>
                                    sum + (item['amount'] as double),
                                  );

                                  final success = await addChatToGroup(
                                    groupId: widget.groupId,
                                    message: _descController.text,
                                    payers: payers,
                                    total: totalExpense,
                                  );

                                  if (!success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("Failed to send chat")),
                                    );
                                  }
                                  setState(() {
                                    isLoading = false;
                                  });
                                  Navigator.pop(context);
                                },
                                child:
                                Text("Send", style: button(screenHeight, context)),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.05),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Background(context),
      appBar: AppBar(
        backgroundColor: Primary(context),
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('groups').doc(widget.groupId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text("Loading...");
            }
            final data = snapshot.data!.data();
            if (data == null || data is! Map<String, dynamic>) {
              return const Text("Invalid group");
            }
            final groupName = data['name'] ?? 'Group';
            final groupColor = Color(data['color'] ?? 0xFF2196F3);
            final List<dynamic> memberEmails = data['members'] ?? [];

            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>groupDetailsScreen(groupId: widget.groupId)));
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: groupColor,
                    radius: screenHeight*0.022,
                    child: Text(
                      groupName.isNotEmpty ? groupName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth*0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          groupName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenHeight * 0.024,
                            color: TextPrimary(context),
                          ),
                        ),    //Group Name
                        StreamBuilder<List<String>>(
                          stream: getMemberNamesStream(memberEmails),
                          builder: (context, memberSnapshot) {
                            if (memberSnapshot.connectionState == ConnectionState.waiting) {
                              return Text("Loading members...",
                                  style: TextStyle(fontSize: screenHeight*0.014, color: Colors.white70));
                            }
                            if (memberSnapshot.hasError || memberSnapshot.data == null) {
                              return Text("Error loading members",
                                  style: TextStyle(fontSize: screenHeight*0.014, color: Colors.redAccent));
                            }
                            final names = memberSnapshot.data!;
                            return Text(
                              _buildDisplayNames(names),
                              style: TextStyle(fontSize: screenHeight*0.014, color: TextPrimary(context)),
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),

      ),

      body: Column(
        children: [
          StreamBuilder<Map<String, double>>(
            stream: streamUserTransactionSummary(widget.groupId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (!snapshot.hasData || snapshot.hasError) {
                return const Text("Unable to load summary");
              }

              final data = snapshot.data!;
              final give = data['give']!;
              final take = data['take']!;

              return Container(
                width: screenWidth*0.94,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("To Take: Rs. ${take.toStringAsFixed(2)}",
                        style: TextStyle(color: Success(context), fontSize: screenHeight * 0.016)),
                    Text("To Give: Rs. ${give.toStringAsFixed(2)}",
                        style: TextStyle(color: ErrorColor(context), fontSize: screenHeight * 0.016)),
                  ],
                ),
              );
            },
          ),

          Container(
            height: screenHeight*0.75,
            child: StreamBuilder<QuerySnapshot>(
              stream: (() {
                FirebaseFirestore.instance
                    .collection('chats')
                    .where('groupId', isEqualTo: widget.groupId)
                    .orderBy('timestamp', descending: true)
                    .get();
                return FirebaseFirestore.instance
                    .collection('chats')
                    .where('groupId', isEqualTo: widget.groupId)
                    .orderBy('timestamp', descending: true)
                    .snapshots();
              })(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: loadingDots());
                }
                if (!snapshot.hasData) {
                  return const Center(child: loadingDots());
                }

                final messages = snapshot.data!.docs.where((doc) => doc['timestamp'] != null).toList();

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      "Start chat!!",
                      style: heading2(screenHeight, context).copyWith(fontStyle: FontStyle.italic),
                    ),
                  );
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final message = data['message'];
                    final sender = data['senderEmail'];
                    final timestamp = data['timestamp'] != null
                        ? (data['timestamp'] as Timestamp).toDate()
                        : null;
                    final payers = List<Map<String, dynamic>>.from(data['payers'] ?? []);
                    final totalAmount = data['totalExpense'] ?? 0.0;
                    final isCurrentUser = sender == FirebaseAuth.instance.currentUser!.email;

                    return Align(
                      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(maxWidth: screenWidth * 0.75),
                        decoration: BoxDecoration(
                          color: Surface(context),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(screenWidth*0.05),
                            topRight: Radius.circular(screenWidth*0.05),
                            bottomLeft: Radius.circular(isCurrentUser ? screenWidth*0.05 : 0),
                            bottomRight: Radius.circular(isCurrentUser ? 0 : screenWidth*0.05),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sender,
                              style: TextStyle(
                                fontSize: screenHeight*0.016,
                                color: isCurrentUser ? Primary(context) : Accent(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: screenHeight*0.008),
                            Text(
                              message,
                              style: TextStyle(
                                fontSize: screenHeight*0.022,
                                color: isCurrentUser ? TextPrimary(context): TextSecondary(context),
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            SizedBox(height: screenHeight*0.008),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(),
                                ...payers.map((payer) => Text(
                                  "${payer['email']}: Rs. ${payer['amount']} ${sender != payer['email'] ? payer['status']: ''}",
                                  style: TextStyle(color: TextSecondary(context), fontSize: screenHeight*0.015),
                                )),
                                SizedBox(height: screenHeight*0.008),
                                Text(
                                  "Total: Rs. $totalAmount",
                                  style: TextStyle(
                                    fontSize: screenHeight*0.016,
                                    fontWeight: FontWeight.bold,
                                    color: isCurrentUser ? TextPrimary(context) : TextSecondary(context),
                                  ),
                                )
                              ],
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                "${timestamp?.day}/${timestamp?.month} ${timestamp?.hour}:${timestamp?.minute.toString().padLeft(2, '0')}",
                                style: TextStyle(fontSize: screenHeight*0.013, color: isCurrentUser ? Primary(context) : Accent(context)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );


                  },
                );
              },
            ),
          ),

          Center(
            child: SizedBox(
              width: screenWidth*0.7,
              child: FloatingActionButton(
                backgroundColor: Button(context),
                onPressed: () => _openChatBottomSheet(context),
                child: Text('Add expense', style: button(screenHeight, context)),
              ),
            ),
          ),

          if(isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: screenWidth * 0.4),
                child: SpinKitWave(
                  color: Primary(context),
                  size: screenWidth * 0.1,
                ),
              ),
            ),

        ],
      ),

    );
  }

  // Show up to 3 names, then +x...
  String _buildDisplayNames(List<String> names) {
    const maxVisible = 3;
    if (names.length <= maxVisible) {
      return names.join(', ');
    } else {
      final visible = names.sublist(0, maxVisible).join(', ');
      final remaining = names.length - maxVisible;
      return '$visible, +$remaining...';
    }
  }
}
