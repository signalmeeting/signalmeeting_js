//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:avisonhouse/models/user.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_database/firebase_database.dart';
//
//class AuthService {
//  final String uid;
//  AuthService({this.uid});
//  final FirebaseAuth _auth = FirebaseAuth.instance;
//  final CollectionReference userCollection =
//      Firestore.instance.collection('users');
//
//  Stream<User> get
//  user {
//    return _auth.onAuthStateChanged
//        //.map((FirebaseUser user) => _userFromFirebaseUser(user));
//        .map(_userFromFirebaseUser);
//  }
//
//  User _userFromFirebaseUser(FirebaseUser user) {
//    return user != null ? User(uid: user.uid) : null;
//  }
//
//  Future signOut() async {
//    try {
//      return await _auth.signOut();
//    } catch (e) {}
//  }
//
//  Stream<UserData> get userData {
//    return userCollection.document(uid).snapshots().map(_userFromSnapshot);
//  }
//
//  UserData _userFromSnapshot(DocumentSnapshot snapshot) {
//    return UserData(
//      uid: uid,
//      userName: snapshot.data['name'],
//      userRoom: snapshot.data['room'],
//      userEmail: snapshot.data['email'],
//    );
//  }
//}
