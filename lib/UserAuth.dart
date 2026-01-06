import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'DatabaseHandling.dart';

Future<bool> createUserWithEmailAndPassword(
  String Email,
  String Password,
) async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: Email,
      password: Password,
    );
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> signInUserWithEmailAndPassword(String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return true;
  } catch (e) {
    return false;
  }
}

Future<String?> getUserEmail()async{
  String? username = FirebaseAuth.instance.currentUser!.email;
  if(username==null) {
    return null;
  }
  else{
    return username;
  }
}

Future<void> logOutUser () async {
  await FirebaseAuth.instance.signOut();
}

Future<bool> deleteUserWithReAuth(String password) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    final uid = user?.uid;

    if (user == null || email == null || uid == null) return false;

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    // Re-authenticate
    await user.reauthenticateWithCredential(credential);

    // --- 1. Exit all groups the user is part of ---
    final groupsSnapshot = await FirebaseFirestore.instance
        .collection('groups')
        .where('members', arrayContains: email)
        .get();

    for (var groupDoc in groupsSnapshot.docs) {
      final groupId = groupDoc.id;
      await exitGroup(groupId, email); // Use your existing exitGroup logic
    }

    // --- 2. Delete user from Firestore "names" collection ---
    await FirebaseFirestore.instance.collection("names").doc(uid).delete();

    // --- 3. Delete user from Firebase Auth ---
    await user.delete();

    return true;
  } catch (e) {
    return false;
  }
}
