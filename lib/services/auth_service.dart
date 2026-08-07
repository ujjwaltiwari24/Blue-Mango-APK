import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final GoogleSignIn _googleSignIn =
  GoogleSignIn();

  static User? get currentUser => _auth.currentUser;

  static bool get isLoggedIn =>
      _auth.currentUser != null;

  static Stream<User?> get authState =>
      _auth.authStateChanges();

  static String generateUsernameSlug() {
    const uuid = Uuid();

    return "mango-${uuid.v4().substring(0, 8)}";
  }

  static Future<void> createUserDocument({
    required User user,
    required String username,
    String? usernameSlug,
  }) async {
    final ref =
    _firestore.collection("users").doc(user.uid);

    final doc = await ref.get();

    if (doc.exists) return;

    await ref.set({
      "uid": user.uid,
      "username": username,
      "usernameSlug":
      usernameSlug ?? generateUsernameSlug(),
      "email": user.email,
      "photoURL": user.photoURL,
      "createdAt": FieldValue.serverTimestamp(),
      "lastActive": FieldValue.serverTimestamp(),
      "lastUsernameChange":
      FieldValue.serverTimestamp(),
    });
  }

  static Future<UserCredential> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final credential =
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    await credential.user!
        .updateDisplayName(username);

    await createUserDocument(
      user: credential.user!,
      username: username,
    );

    return credential;
  }

  static Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  static Future<UserCredential?> signInWithGoogle() async {
    final googleUser =
    await _googleSignIn.signIn();

    if (googleUser == null) {
      return null;
    }

    final googleAuth =
    await googleUser.authentication;

    final credential =
    GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result =
    await _auth.signInWithCredential(
      credential,
    );

    final user = result.user!;

    await createUserDocument(
      user: user,
      username:
      user.displayName ?? "BlueMango User",
    );

    return result;
  }

  static Future<void> forgotPassword(
      String email,
      ) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  static Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  static Future<void> updateLastActive() async {
    final user = currentUser;

    if (user == null) return;

    await _firestore
        .collection("users")
        .doc(user.uid)
        .update({
      "lastActive":
      FieldValue.serverTimestamp(),
    });
  }
}