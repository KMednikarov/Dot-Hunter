import 'package:firebase_core/firebase_core.dart';

/// Holds the Firebase configuration for the current platform.
///
/// The values in this file are placeholders and should be replaced with the
/// configuration for your Firebase project. Obtain these by running
/// `flutterfire configure` and replace the strings below.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'YOUR_API_KEY',
      appId: 'YOUR_APP_ID',
      messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
      projectId: 'YOUR_PROJECT_ID',
    );
  }
}
