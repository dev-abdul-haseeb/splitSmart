import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

String generateGroupCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rand = Random.secure();
  return List.generate(6, (index) => chars[rand.nextInt(chars.length)]).join();
}

Future<bool> AddUserToDb(String email, String name) async {
  try {
    await FirebaseFirestore.instance.collection("names").doc(FirebaseAuth.instance.currentUser?.uid.toString()).set({
      "email": email,
      "name": name,
    });
    return true;
  } catch (e) {
    return false;
  }
}

Future<String?>addGroupToDb(String groupName, Color selectedColor) async {
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    String groupCode = generateGroupCode();

    await firestore.collection("groups").add({
      'name': groupName,
      'createdAt': FieldValue.serverTimestamp(),
      'code': groupCode,
      'createdBy': FirebaseAuth.instance.currentUser?.email ?? "unknown",
      'members': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.email]),
      'color': selectedColor.value,
    });
    return groupCode;
  } catch (e) {
    return null;
  }
}

Future<bool> joinGroup(String groupCode) async {
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final userEmail = user.email ?? "unknown";

    // Search for group by group code
    final querySnapshot = await firestore
        .collection("groups")
        .where("code", isEqualTo: groupCode)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return false; // Group not found
    }
    final groupDoc = querySnapshot.docs.first;
    final groupRef = groupDoc.reference;

    // Get existing members list
    final members = List<String>.from(groupDoc.get("members") ?? []);

    // Check if user already exists
    if (members.contains(userEmail)) {
      return false; // Already a member, don't add again
    }

    // Add current user to 'members' array
    await groupRef.update({
      "members": FieldValue.arrayUnion([userEmail]),
    });

    return true;
  } catch (e) {
    return false;
  }
}

Stream<List<Map<String, dynamic>>> getUserGroupsStream(String? userEmail) {
  return FirebaseFirestore.instance
      .collection('groups')
      .where('members', arrayContains: userEmail)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
    final data = doc.data();
    data['id'] = doc.id;
    return data;
  }).toList());
}

Stream<List<String>> getMemberNamesStream(List<dynamic> emails) {
  if (emails.isEmpty) {
    return Stream.value([]);
  }
  final firestore = FirebaseFirestore.instance;
  return firestore.collection("names").snapshots().map((snapshot) {
    return snapshot.docs
        .where((doc) {
      final email = doc.data()['email'];
      return email != null && emails.contains(email);
    })
        .map((doc) {
      final name = doc.data()['name'];
      return name is String ? name : 'Unknown';
    }).toList();
  });
}

Future<String> getUserName() async {
  try {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return "Unknown";

    final docSnapshot = await FirebaseFirestore.instance.collection("names").doc(uid).get();
    if (docSnapshot.exists && docSnapshot.data()?['name'] != null) {
      return docSnapshot.data()!['name'];
    } else {
      return "Unknown";
    }
  } catch (e) {
    return "Unknown";
  }
}

Stream<List<Map<String, dynamic>>> getGroupChatsStream(String groupId) {
  return FirebaseFirestore.instance
      .collection('chats')
      .where('groupId', isEqualTo: groupId)
      .orderBy('timestamp', descending: false) // oldest to newest
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
    final data = doc.data();
    data['id'] = doc.id; // optional: add doc ID
    return data;
  }).toList());
}

Future<bool> addChatToGroup({
  required String groupId,
  required String message,
  required List<Map<String, dynamic>> payers,
  required double total,
}) async {
  try {
    await FirebaseFirestore.instance.collection('chats').add({
      'message': message,
      'senderEmail': FirebaseAuth.instance.currentUser?.email ?? 'Unknown',
      'timestamp': FieldValue.serverTimestamp(),
      'groupId': groupId,
      'payers': payers,
      'totalExpense': total, // ✅ new field added here
    });
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> exitGroup(String groupId, String userEmail) async {
  try {
    final groupDocRef = FirebaseFirestore.instance.collection('groups').doc(groupId);
    final groupSnapshot = await groupDocRef.get();

    if (!groupSnapshot.exists) return false;

    final groupData = groupSnapshot.data()!;
    final members = List<String>.from(groupData['members']);

    if (members.length <= 1) {
      // Delete group and its chats
      final batch = FirebaseFirestore.instance.batch();

      // Delete all chats of the group
      final chatsSnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('groupId', isEqualTo: groupId)
          .get();

      for (var doc in chatsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      batch.delete(groupDocRef);
      await batch.commit();
    } else {
      // Remove the user from the members list
      members.remove(userEmail);
      await groupDocRef.update({'members': members});
    }

    return true;
  } catch (e) {
    return false;
  }
}

Stream<Map<String, double>> streamUserTransactionSummary(String groupId) {
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  if (currentUserEmail == null) {
    return Stream.error("User not logged in");
  }

  return FirebaseFirestore.instance
      .collection('chats')
      .where('groupId', isEqualTo: groupId)
      .snapshots()
      .map((snapshot) {
    double totalGive = 0.0;       // What user owes
    double totalTake = 0.0;       // What others owe user
    double totalGiven = 0.0;      // What user has paid
    double totalReceived = 0.0;   // What user has received

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final sender = data['senderEmail'];
      final payers = List<Map<String, dynamic>>.from(data['payers'] ?? []);

      for (var payer in payers) {
        final payerEmail = payer['email'];
        final payerAmount = (payer['amount'] as num).toDouble();
        final status = payer['status']?.toLowerCase() ?? 'unpaid';

        final isCurrentUserSender = sender == currentUserEmail;
        final isCurrentUserPayer = payerEmail == currentUserEmail;

        // You owe (unpaid, someone else is sender)
        if (!isCurrentUserSender && isCurrentUserPayer && status == 'unpaid') {
          totalGive += payerAmount;
        }

        // Others owe you (unpaid, you are sender)
        if (isCurrentUserSender && !isCurrentUserPayer && status == 'unpaid') {
          totalTake += payerAmount;
        }

        // You paid (paid, someone else is sender)
        if (!isCurrentUserSender && isCurrentUserPayer && status == 'paid') {
          totalGiven += payerAmount;
        }

        // You received (paid, you are sender)
        if (isCurrentUserSender && !isCurrentUserPayer && status == 'paid') {
          totalReceived += payerAmount;
        }
      }
    }

    return {
      'give': totalGive,
      'take': totalTake,
      'given': totalGiven,
      'received': totalReceived,
    };
  });
}

Stream<Map<String, double>> transactionOfAllGroups() {
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  if (currentUserEmail == null) {
    return Stream.error("User not logged in");
  }

  return FirebaseFirestore.instance
      .collection('chats')
      .snapshots()
      .map((snapshot) {
    double totalGive = 0.0;
    double totalTake = 0.0;
    double totalGiven = 0.0;
    double totalReceived = 0.0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final sender = data['senderEmail'];
      final payers = List<Map<String, dynamic>>.from(data['payers'] ?? []);

      for (var payer in payers) {
        final payerEmail = payer['email'];
        final payerAmount = (payer['amount'] as num).toDouble();
        final status = payer['status']?.toLowerCase() ?? 'unpaid';

        final isCurrentUserSender = sender == currentUserEmail;
        final isCurrentUserPayer = payerEmail == currentUserEmail;

        // You owe (unpaid, someone else is sender)
        if (!isCurrentUserSender && isCurrentUserPayer && status == 'unpaid') {
          totalGive += payerAmount;
        }

        // Others owe you (unpaid, you are sender)
        if (isCurrentUserSender && !isCurrentUserPayer && status == 'unpaid') {
          totalTake += payerAmount;
        }

        // You paid (paid, someone else is sender)
        if (!isCurrentUserSender && isCurrentUserPayer && status == 'paid') {
          totalGiven += payerAmount;
        }

        // You received (paid, you are sender)
        if (isCurrentUserSender && !isCurrentUserPayer && status == 'paid') {
          totalReceived += payerAmount;
        }
      }
    }

    return {
      'give': totalGive,
      'take': totalTake,
      'given': totalGiven,
      'received': totalReceived,
    };
  });
}

Stream<List<Map<String, dynamic>>> userRelationsStream() {
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  if (currentUserEmail == null) {
    return const Stream.empty();
  }

  return FirebaseFirestore.instance
      .collection('chats')
      .snapshots()
      .map((snapshot) {
    Map<String, double> toGiveMap = {};
    Map<String, double> toTakeMap = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final senderEmail = data['senderEmail'];
      final payers = List<Map<String, dynamic>>.from(data['payers'] ?? []);

      for (var payer in payers) {
        final payerEmail = payer['email'];
        final amount = (payer['amount'] as num).toDouble();
        final status = payer['status']?.toLowerCase() ?? 'unpaid';

        // Current user owes someone (unpaid)
        if (payerEmail == currentUserEmail &&
            senderEmail != currentUserEmail &&
            status == 'unpaid') {
          toGiveMap[senderEmail] = (toGiveMap[senderEmail] ?? 0.0) + amount;
        }

        // Others owe current user (unpaid)
        if (senderEmail == currentUserEmail &&
            payerEmail != currentUserEmail &&
            status == 'unpaid') {
          toTakeMap[payerEmail] = (toTakeMap[payerEmail] ?? 0.0) + amount;
        }
      }
    }

    final allUsers = {...toGiveMap.keys, ...toTakeMap.keys};

    return allUsers.map((email) {
      return {
        'email': email,
        'toGive': toGiveMap[email] ?? 0.0,
        'toTake': toTakeMap[email] ?? 0.0,
      };
    }).toList();
  });
}

Future<void> settleUpWithUser(String otherUserEmail) async {
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  if (currentUserEmail == null) return;

  final chatsSnapshot = await FirebaseFirestore.instance
      .collection('chats')
      .orderBy('timestamp') // Required for FIFO logic
      .get();

  // Store chats where user owes and where user is owed
  List<Map<String, dynamic>> youOwe = [];
  List<Map<String, dynamic>> theyOwe = [];

  for (var doc in chatsSnapshot.docs) {
    final data = doc.data();
    final docId = doc.id;
    final sender = data['senderEmail'];
    final payers = List<Map<String, dynamic>>.from(data['payers'] ?? []);

    for (int i = 0; i < payers.length; i++) {
      final payer = payers[i];
      final payerEmail = payer['email'];
      final amount = (payer['amount'] as num).toDouble();
      final status = (payer['status'] ?? 'unpaid').toLowerCase();

      if (status == 'paid') continue;

      if (payerEmail == currentUserEmail && sender == otherUserEmail) {
        youOwe.add({
          'docId': docId,
          'payerIndex': i,
          'amount': amount,
        });
      } else if (sender == currentUserEmail && payerEmail == otherUserEmail) {
        theyOwe.add({
          'docId': docId,
          'payerIndex': i,
          'amount': amount,
        });
      }
    }
  }

  // Start offsetting entries
  int i = 0, j = 0;
  while (i < youOwe.length && j < theyOwe.length) {
    final owe = youOwe[i];
    final take = theyOwe[j];

    final oweAmt = owe['amount'];
    final takeAmt = take['amount'];

    final minAmt = oweAmt < takeAmt ? oweAmt : takeAmt;

    // Update owe record
    await _markPayerAsPaid(
      owe['docId'],
      owe['payerIndex'],
      minAmt == oweAmt,
      oweAmt - minAmt,
    );

    // Update take record
    await _markPayerAsPaid(
      take['docId'],
      take['payerIndex'],
      minAmt == takeAmt,
      takeAmt - minAmt,
    );

    // Move pointers accordingly
    if (minAmt == oweAmt) i++;
    else youOwe[i]['amount'] -= minAmt;

    if (minAmt == takeAmt) j++;
    else theyOwe[j]['amount'] -= minAmt;
  }
}

Future<void> _markPayerAsPaid(String docId, int payerIndex, bool fullPay, double remaining) async {
  final docRef = FirebaseFirestore.instance.collection('chats').doc(docId);
  final snapshot = await docRef.get();

  if (!snapshot.exists) return;
  final data = snapshot.data()!;
  final payers = List<Map<String, dynamic>>.from(data['payers'] ?? []);

  if (fullPay) {
    payers[payerIndex]['status'] = 'paid';
  } else {
    payers[payerIndex]['amount'] = remaining;
  }

  await docRef.update({'payers': payers});
}

Future<void> markAsPaid(String receiverEmail, double amountToPay) async {
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  if (currentUserEmail == null) return;

  final chatsRef = FirebaseFirestore.instance.collection('chats');

  final chats = await chatsRef
      .where('senderEmail', isEqualTo: receiverEmail)
      .get();

  double remaining = amountToPay;

  for (var doc in chats.docs) {
    final data = doc.data();
    final payers = List<Map<String, dynamic>>.from(data['payers'] ?? []);

    bool updated = false;

    for (int i = 0; i < payers.length; i++) {
      if (payers[i]['email'] == currentUserEmail &&
          payers[i]['status'] != 'paid') {
        double amount = (payers[i]['amount'] as num).toDouble();

        if (amount <= remaining) {
          payers[i]['status'] = 'paid';
          remaining -= amount;
          updated = true;
        } else {
          payers[i]['amount'] = amount - remaining;
          payers.insert(i + 1, {
            'email': currentUserEmail,
            'amount': remaining,
            'status': 'paid'
          });
          remaining = 0;
          updated = true;
        }

        if (remaining <= 0) break;
      }
    }

    if (updated) {
      await chatsRef.doc(doc.id).update({'payers': payers});
    }

    if (remaining <= 0) break;
  }
}
