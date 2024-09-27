import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (error) {
      print('Google sign-in error: $error');
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      print('Google sign-out error: $error');
    }
  }

  static GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
}
