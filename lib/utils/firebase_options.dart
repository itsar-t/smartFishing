import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCPRF1eeFW7WMBhqaSFzwgG-Dl-Jd-FznU',
    appId: '1:178466110297:web:7142e3a839b86adce22a48',
    messagingSenderId: '178466110297',
    projectId: 'fishing-app-cls055',
    authDomain: 'fishing-app-cls055.firebaseapp.com',
    storageBucket: 'fishing-app-cls055.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDGy5WaYALxF1LvCRohFsFzsZZl9AWy1yY',
    appId: '1:178466110297:android:20f6f83511861e1ce22a48',
    messagingSenderId: '178466110297',
    projectId: 'fishing-app-cls055',
    storageBucket: 'fishing-app-cls055.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDIMTQvG58h6aHsxp37matcbRTIBpJfdFw',
    appId: '1:178466110297:ios:ed40f426074773d4e22a48',
    messagingSenderId: '178466110297',
    projectId: 'fishing-app-cls055',
    storageBucket: 'fishing-app-cls055.firebasestorage.app',
    iosClientId:
        '178466110297-c7khnugvss509ki04pbn5opncgccrijp.apps.googleusercontent.com',
    iosBundleId: 'com.example.smartFishing',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDIMTQvG58h6aHsxp37matcbRTIBpJfdFw',
    appId: '1:178466110297:ios:ed40f426074773d4e22a48',
    messagingSenderId: '178466110297',
    projectId: 'fishing-app-cls055',
    storageBucket: 'fishing-app-cls055.firebasestorage.app',
    iosClientId:
        '178466110297-c7khnugvss509ki04pbn5opncgccrijp.apps.googleusercontent.com',
    iosBundleId: 'com.example.smartFishing',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCPRF1eeFW7WMBhqaSFzwgG-Dl-Jd-FznU',
    appId: '1:178466110297:web:a52a38e92bbc92dfe22a48',
    messagingSenderId: '178466110297',
    projectId: 'fishing-app-cls055',
    authDomain: 'fishing-app-cls055.firebaseapp.com',
    storageBucket: 'fishing-app-cls055.firebasestorage.app',
  );
}
