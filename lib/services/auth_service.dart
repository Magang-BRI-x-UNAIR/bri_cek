import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bri_cek/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is admin
  Future<bool> isAdmin() async {
    if (currentUser == null) return false;

    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(currentUser!.uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['role'] == 'admin';
      }
    } catch (e) {
      print('Error checking admin status: $e');
    }
    return false;
  }

  // Get user data
  Future<UserModel?> getUserData() async {
    if (currentUser == null) return null;

    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(currentUser!.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(
          doc.data() as Map<String, dynamic>,
          currentUser!.uid,
        );
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
    return null;
  }

  // Find user by username
  Future<QuerySnapshot> findUserByUsername(String username) async {
    return await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
  }

  // Sign in with username and password
  Future<UserCredential> signInWithUsernameAndPassword(
    String username,
    String password,
  ) async {
    try {
      // Find the user with the given username in Firestore
      QuerySnapshot userQuery = await findUserByUsername(username);

      if (userQuery.docs.isEmpty) {
        // No user with this username
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found with this username',
        );
      }

      // Get the email stored for this user
      String email =
          (userQuery.docs.first.data() as Map<String, dynamic>)['email'] ??
          '$username@example.com';

      // Use Firebase Auth to sign in with the email
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  // Create user with username and password (Admin function)
  Future<UserModel?> createUser({
    required String username,
    required String password,
    required String fullName,
    required String nickname,
    required String employeeId,
  }) async {
    try {
      // Check if username already exists
      QuerySnapshot existingUsers = await findUserByUsername(username);
      if (existingUsers.docs.isNotEmpty) {
        throw FirebaseAuthException(
          code: 'username-exists',
          message: 'Username already exists',
        );
      }

      // Generate a dummy email for Firebase Auth (which requires emails)
      String dummyEmail = '$username@example.com';

      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: dummyEmail,
        password: password,
      );

      // Create user object
      UserModel user = UserModel(
        uid: result.user!.uid,
        username: username,
        fullName: fullName,
        nickname: nickname,
        employeeId: employeeId,
        role: 'user',
      );

      // Save user data to Firestore
      await _firestore.collection('users').doc(user.uid).set({
        ...user.toMap(),
        'email': dummyEmail, // Store the dummy email for auth purposes
      });

      return user;
    } on FirebaseAuthException catch (e) {
      print('Create user error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
