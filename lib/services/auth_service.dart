// import 'package:firebase_auth/firebase_auth.dart';

// class AuthService {
//   // ===========================================================================
//   // FIREBASE AUTH INSTANCE
//   // ===========================================================================

//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // ===========================================================================
//   // CURRENT USER
//   // ===========================================================================

//   User? get currentUser => _auth.currentUser;

//   // ===========================================================================
//   // AUTH STATE
//   // ===========================================================================

//   Stream<User?> get authStateChanges => _auth.authStateChanges();

//   // ===========================================================================
//   // EMAIL + PASSWORD SIGN UP
//   // ===========================================================================

//   Future<UserCredential> signUpWithEmail({
//     required String name,
//     required String email,
//     required String password,
//     String? phoneNumber,
//   }) async {
//     try {
//       final UserCredential credential = await _auth
//           .createUserWithEmailAndPassword(
//             email: email.trim(),
//             password: password,
//           );

//       final User? user = credential.user;

//       if (user != null) {
//         // Store user's name in Firebase Authentication profile.
//         await user.updateDisplayName(name.trim());

//         // Reload user so the updated profile is available.
//         await user.reload();
//       }

//       return credential;
//     } on FirebaseAuthException catch (e) {
//       throw AuthException(_getAuthErrorMessage(e), code: e.code);
//     } catch (e) {
//       throw AuthException('Something went wrong while creating your account.');
//     }
//   }

//   // ===========================================================================
//   // EMAIL + PASSWORD LOGIN
//   // ===========================================================================

//   Future<UserCredential> loginWithEmail({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       return await _auth.signInWithEmailAndPassword(
//         email: email.trim(),
//         password: password,
//       );
//     } on FirebaseAuthException catch (e) {
//       throw AuthException(_getAuthErrorMessage(e), code: e.code);
//     } catch (e) {
//       throw AuthException('Something went wrong while logging in.');
//     }
//   }

//   // ===========================================================================
//   // SEND PASSWORD RESET EMAIL
//   // ===========================================================================

//   Future<void> sendPasswordResetEmail({required String email}) async {
//     try {
//       await _auth.sendPasswordResetEmail(email: email.trim());
//     } on FirebaseAuthException catch (e) {
//       throw AuthException(_getAuthErrorMessage(e), code: e.code);
//     } catch (e) {
//       throw AuthException('Unable to send the password reset email.');
//     }
//   }

//   // ===========================================================================
//   // SEND EMAIL VERIFICATION
//   // ===========================================================================

//   Future<void> sendEmailVerification() async {
//     try {
//       final User? user = _auth.currentUser;

//       if (user == null) {
//         throw AuthException('No user is currently signed in.');
//       }

//       if (!user.emailVerified) {
//         await user.sendEmailVerification();
//       }
//     } on FirebaseAuthException catch (e) {
//       throw AuthException(_getAuthErrorMessage(e), code: e.code);
//     }
//   }

//   // ===========================================================================
//   // PHONE AUTH - SEND OTP
//   // ===========================================================================

//   Future<void> sendPhoneOtp({
//     required String phoneNumber,
//     required Function(String verificationId) onCodeSent,
//     required Function(FirebaseAuthException error) onVerificationFailed,
//     Function(PhoneAuthCredential credential)? onVerificationCompleted,
//     Function(String verificationId)? onCodeAutoRetrievalTimeout,
//   }) async {
//     try {
//       await _auth.verifyPhoneNumber(
//         phoneNumber: phoneNumber.trim(),

//         // ---------------------------------------------------------------
//         // AUTOMATIC VERIFICATION
//         // ---------------------------------------------------------------
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           if (onVerificationCompleted != null) {
//             onVerificationCompleted(credential);
//           }
//         },

//         // ---------------------------------------------------------------
//         // VERIFICATION FAILED
//         // ---------------------------------------------------------------
//         verificationFailed: (FirebaseAuthException e) {
//           onVerificationFailed(e);
//         },

//         // ---------------------------------------------------------------
//         // CODE SENT
//         // ---------------------------------------------------------------
//         codeSent: (String verificationId, int? resendToken) {
//           onCodeSent(verificationId);
//         },

//         // ---------------------------------------------------------------
//         // TIMEOUT
//         // ---------------------------------------------------------------
//         codeAutoRetrievalTimeout: (String verificationId) {
//           if (onCodeAutoRetrievalTimeout != null) {
//             onCodeAutoRetrievalTimeout(verificationId);
//           }
//         },
//       );
//     } on FirebaseAuthException catch (e) {
//       onVerificationFailed(e);
//     } catch (e) {
//       onVerificationFailed(
//         FirebaseAuthException(
//           code: 'unknown',
//           message: 'Unable to send verification code.',
//         ),
//       );
//     }
//   }

//   // ===========================================================================
//   // PHONE AUTH - VERIFY OTP
//   // ===========================================================================

//   Future<UserCredential> verifyPhoneOtp({
//     required String verificationId,
//     required String otp,
//   }) async {
//     try {
//       final PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: verificationId,
//         smsCode: otp.trim(),
//       );

//       return await _auth.signInWithCredential(credential);
//     } on FirebaseAuthException catch (e) {
//       throw AuthException(_getAuthErrorMessage(e), code: e.code);
//     } catch (e) {
//       throw AuthException('Unable to verify the OTP.');
//     }
//   }

//   // ===========================================================================
//   // PHONE AUTH - SIGN IN WITH EXISTING CREDENTIAL
//   // ===========================================================================

//   Future<UserCredential> signInWithPhoneCredential(
//     PhoneAuthCredential credential,
//   ) async {
//     try {
//       return await _auth.signInWithCredential(credential);
//     } on FirebaseAuthException catch (e) {
//       throw AuthException(_getAuthErrorMessage(e), code: e.code);
//     }
//   }

//   // ===========================================================================
//   // UPDATE USER NAME
//   // ===========================================================================

//   Future<void> updateUserName(String name) async {
//     try {
//       final User? user = _auth.currentUser;

//       if (user == null) {
//         throw AuthException('No user is currently signed in.');
//       }

//       await user.updateDisplayName(name.trim());

//       await user.reload();
//     } on FirebaseAuthException catch (e) {
//       throw AuthException(_getAuthErrorMessage(e), code: e.code);
//     }
//   }

//   // ===========================================================================
//   // UPDATE EMAIL
//   // ===========================================================================

//   Future<void> updateEmail(String email) async {
//     try {
//       final User? user = _auth.currentUser;

//       if (user == null) {
//         throw AuthException('No user is currently signed in.');
//       }

//       await user.verifyBeforeUpdateEmail(email.trim());
//     } on FirebaseAuthException catch (e) {
//       throw AuthException(_getAuthErrorMessage(e), code: e.code);
//     }
//   }

//   // ===========================================================================
//   // UPDATE PASSWORD
//   // ===========================================================================

//   Future<void> updatePassword(String newPassword) async {
//     try {
//       final User? user = _auth.currentUser;

//       if (user == null) {
//         throw AuthException('No user is currently signed in.');
//       }

//       await user.updatePassword(newPassword);
//     } on FirebaseAuthException catch (e) {
//       throw AuthException(_getAuthErrorMessage(e), code: e.code);
//     }
//   }

//   // ===========================================================================
//   // DELETE ACCOUNT
//   // ===========================================================================

//   Future<void> deleteAccount() async {
//     try {
//       final User? user = _auth.currentUser;

//       if (user == null) {
//         throw AuthException('No user is currently signed in.');
//       }

//       await user.delete();
//     } on FirebaseAuthException catch (e) {
//       throw AuthException(_getAuthErrorMessage(e), code: e.code);
//     }
//   }

//   // ===========================================================================
//   // SIGN OUT
//   // ===========================================================================

//   Future<void> signOut() async {
//     try {
//       await _auth.signOut();
//     } on FirebaseAuthException catch (e) {
//       throw AuthException(_getAuthErrorMessage(e), code: e.code);
//     } catch (e) {
//       throw AuthException('Unable to sign out.');
//     }
//   }

//   // ===========================================================================
//   // CHECK LOGIN STATUS
//   // ===========================================================================

//   bool get isLoggedIn {
//     return _auth.currentUser != null;
//   }

//   // ===========================================================================
//   // CHECK EMAIL VERIFIED
//   // ===========================================================================

//   bool get isEmailVerified {
//     return _auth.currentUser?.emailVerified ?? false;
//   }

//   // ===========================================================================
//   // FIREBASE ERROR TRANSLATOR
//   // ===========================================================================

//   String _getAuthErrorMessage(FirebaseAuthException e) {
//     switch (e.code) {
//       // ---------------------------------------------------------------
//       // EMAIL
//       // ---------------------------------------------------------------

//       case 'invalid-email':
//         return 'Please enter a valid email address.';

//       case 'user-not-found':
//         return 'No account was found with this email address.';

//       case 'wrong-password':
//       case 'invalid-credential':
//         return 'Incorrect email or password.';

//       case 'email-already-in-use':
//         return 'An account already exists with this email address.';

//       case 'weak-password':
//         return 'Password is too weak. Use at least 8 characters.';

//       case 'user-disabled':
//         return 'This account has been disabled.';

//       // ---------------------------------------------------------------
//       // PHONE
//       // ---------------------------------------------------------------

//       case 'invalid-phone-number':
//         return 'Please enter a valid mobile number.';

//       case 'invalid-verification-code':
//         return 'The OTP you entered is incorrect.';

//       case 'invalid-verification-id':
//         return 'The verification session has expired. Please request a new OTP.';

//       case 'session-expired':
//         return 'The OTP has expired. Please request a new one.';

//       case 'quota-exceeded':
//         return 'Too many verification attempts. Please try again later.';

//       case 'too-many-requests':
//         return 'Too many attempts. Please wait and try again later.';

//       // ---------------------------------------------------------------
//       // NETWORK
//       // ---------------------------------------------------------------

//       case 'network-request-failed':
//         return 'Network error. Please check your internet connection.';

//       // ---------------------------------------------------------------
//       // RECENT LOGIN
//       // ---------------------------------------------------------------

//       case 'requires-recent-login':
//         return 'Please log in again before performing this action.';

//       // ---------------------------------------------------------------
//       // OPERATION
//       // ---------------------------------------------------------------

//       case 'operation-not-allowed':
//         return 'This authentication method is not enabled in Firebase.';

//       // ---------------------------------------------------------------
//       // DEFAULT
//       // ---------------------------------------------------------------

//       default:
//         return e.message ?? 'Authentication failed. Please try again.';
//     }
//   }
// }

// // =============================================================================
// // CUSTOM AUTH EXCEPTION
// // =============================================================================

// class AuthException implements Exception {
//   final String message;
//   final String? code;

//   AuthException(this.message, {this.code});

//   @override
//   String toString() {
//     return message;
//   }
// }
