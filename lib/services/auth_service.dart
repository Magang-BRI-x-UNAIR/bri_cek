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

  // Get all users (Admin function)
  Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('users')
              .orderBy('fullName') // Sort by full name
              .get();

      List<UserModel> users = [];

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Skip admin users from the list if needed
          if (data['role'] != 'admin') {
            UserModel user = UserModel.fromMap(data, doc.id);
            users.add(user);
          }
        } catch (e) {
          print('Error parsing user ${doc.id}: $e');
          // Continue with other users even if one fails
        }
      }

      return users;
    } catch (e) {
      print('Error getting all users: $e');
      throw Exception('Failed to load users: $e');
    }
  }

  // Delete user (Admin function)
  Future<void> deleteUser(String uid) async {
    try {
      // Get current user (admin) credentials for re-authentication if needed
      User? currentAdmin = _auth.currentUser;

      // Delete user document from Firestore first
      await _firestore.collection('users').doc(uid).delete();

      // Note: Deleting from Firebase Auth requires admin SDK or the user to be currently signed in
      // For now, we'll just delete from Firestore
      // In production, you might want to use Firebase Admin SDK or Cloud Functions

      print('User $uid deleted successfully from Firestore');
    } catch (e) {
      print('Error deleting user: $e');
      throw Exception('Failed to delete user: $e');
    }
  }

  // Update user data (Admin function)
  Future<void> updateUser(String uid, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      print('Error updating user: $e');
      throw Exception('Failed to update user: $e');
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return UserModel.fromMap(data, uid);
      }

      return null;
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
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

      // Store current user (admin) to restore later
      User? currentAdmin = _auth.currentUser;

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
        'email': dummyEmail,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      // Sign out the newly created user and restore admin session
      await _auth.signOut();
      if (currentAdmin != null) {
        // You might need to re-authenticate the admin here
        // This is a limitation of Firebase Auth
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('Create user error: $e');
      // Map the error code to your custom error code
      if (e.code == 'email-already-in-use') {
        throw FirebaseAuthException(
          code: 'username-exists',
          message: 'Username sudah digunakan oleh akun lain',
        );
      }
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      QuerySnapshot result = await findUserByUsername(username);
      return result.docs.isEmpty;
    } catch (e) {
      print('Error checking username availability: $e');
      return false;
    }
  }

  // Get users count
  Future<int> getUsersCount() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: 'user')
              .get();
      return querySnapshot.docs.length;
    } catch (e) {
      print('Error getting users count: $e');
      return 0;
    }
  }
}
