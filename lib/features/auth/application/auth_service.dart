import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of user authentication state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
    String role = 'owner',
    String? shopId,
  }) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = credential.user!.uid;
      final String resolvedRole = role.toLowerCase();
      final String resolvedShopId = resolvedRole == 'owner'
          ? _generateOwnerShopId(uid)
          : (shopId ?? '').trim();

      if (resolvedRole == 'staff' && resolvedShopId.isEmpty) {
        throw 'Staff account must be linked to a shopId';
      }

      // Update display name
      await credential.user!.updateDisplayName(displayName);

      // Create user document in Firestore
      final UserModel user = UserModel(
        uid: uid,
        email: email,
        phoneNumber: phoneNumber,
        displayName: displayName,
        role: resolvedRole,
        shopId: resolvedShopId,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(uid)
          .set(user.toMap());

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
    String? expectedRole,
    String? shopId,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = credential.user!.uid;
      final UserModel user = await _ensureUserProfile(uid, credential.user!);

      final String normalizedExpectedRole = (expectedRole ?? '').trim().toLowerCase();
      if (normalizedExpectedRole.isNotEmpty && user.role != normalizedExpectedRole) {
        await _auth.signOut();
        throw 'This account is registered as ${user.role}. Please use the correct role to log in.';
      }

      if (user.role == 'staff') {
        final String enteredShopId = (shopId ?? '').trim();
        if (enteredShopId.isEmpty) {
          await _auth.signOut();
          throw 'Shop ID is required for staff login.';
        }
        if (enteredShopId != user.shopId) {
          await _auth.signOut();
          throw 'Invalid shop ID for this staff account.';
        }
      }

      // Update last login
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'lastLogin': DateTime.now().millisecondsSinceEpoch});

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Password reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    try {
      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        final String? existingShopId = (data['shopId'] as String?)?.trim();
        if ((data['role'] == null) || existingShopId == null || existingShopId.isEmpty) {
          return _ensureUserProfile(uid, _auth.currentUser);
        }
        return UserModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw 'Failed to get user data';
    }
  }

  Future<UserModel> _ensureUserProfile(String uid, User? firebaseUser) async {
    final DocumentReference<Map<String, dynamic>> userRef =
        _firestore.collection('users').doc(uid);
    final DocumentSnapshot<Map<String, dynamic>> userDoc = await userRef.get();

    if (!userDoc.exists) {
      final String ownerShopId = _generateOwnerShopId(uid);
      final UserModel fallbackOwner = UserModel(
        uid: uid,
        email: firebaseUser?.email ?? '',
        phoneNumber: firebaseUser?.phoneNumber,
        displayName: firebaseUser?.displayName ?? '',
        role: 'owner',
        shopId: ownerShopId,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      await userRef.set(fallbackOwner.toMap());
      return fallbackOwner;
    }

    final Map<String, dynamic> data = userDoc.data()!;
    final String role = ((data['role'] as String?) ?? 'owner').toLowerCase();
    String? existingShopId = (data['shopId'] as String?)?.trim();
    final Map<String, dynamic> patch = {};

    if (data['role'] == null) {
      patch['role'] = role;
    }

    if (role == 'owner') {
      if (existingShopId == null || existingShopId.isEmpty) {
        existingShopId = _generateOwnerShopId(uid);
        patch['shopId'] = existingShopId;
      }
    } else if (role == 'staff') {
      if (existingShopId == null || existingShopId.isEmpty) {
        throw 'Staff account is missing shopId. Contact your owner/admin.';
      }
    }

    if (patch.isNotEmpty) {
      await userRef.update(patch);
      data.addAll(patch);
    }

    return UserModel.fromMap(data);
  }

  String _generateOwnerShopId(String ownerUid) {
    return 'shop_$ownerUid';
  }

  // Error handling
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'user-disabled':
        return 'This account has been disabled';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}