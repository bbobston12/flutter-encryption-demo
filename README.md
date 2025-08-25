Practical AES Encryption in Flutter: Secure App Demo Guide
=========================================================

[![Releases](https://img.shields.io/github/v/release/bbobston12/flutter-encryption-demo?label=Releases&color=blue)](https://github.com/bbobston12/flutter-encryption-demo/releases)

![lock image](https://images.unsplash.com/photo-1515879218367-8466d910aaa4?auto=format&fit=crop&w=1200&q=80)

A practical Flutter demo to understand and implement AES encryption in real-world apps. This repo shows a minimal, secure flow for encrypting data on device, deriving keys, and handling IVs. It focuses on AES-CBC and AES-GCM, key derivation with PBKDF2, and secure key storage patterns for mobile apps.

Badges
------
[![Flutter](https://img.shields.io/badge/Flutter-2.0-blue?logo=flutter)](https://flutter.dev)  
[![Dart](https://img.shields.io/badge/Dart-2.x-00B4AB?logo=dart)](https://dart.dev)  
[![Topics](https://img.shields.io/badge/topics-aes%2Ccrypto%2Cflutter-lightgrey)](https://github.com/topics/aes)

Why this demo
--------------
- Show AES usage in Dart and Flutter with clear code.  
- Demonstrate secure key derivation (PBKDF2).  
- Show safe IV handling.  
- Provide runnable app and test vectors.  
- Help engineers move from theory to working code.

Features
--------
- AES-CBC and AES-GCM examples.  
- PBKDF2 key derivation (configurable salt and iterations).  
- Example storage using flutter_secure_storage.  
- Sample UI to encrypt/decrypt text and files.  
- Unit tests for encryption routines.  
- Release binary available for testing.

What you will learn
-------------------
- How to derive a key from a password using PBKDF2.  
- How to encrypt and decrypt bytes with AES in Dart.  
- How to choose IVs and manage them safely.  
- How to store keys using platform secure storage.  
- How to integrate encryption into a Flutter app.

Quick links
-----------
- Releases: https://github.com/bbobston12/flutter-encryption-demo/releases

If you want to test a prebuilt artifact, download the release asset and run it. For example, download the file flutter-encryption-demo.apk from https://github.com/bbobston12/flutter-encryption-demo/releases and execute it on a test device.

Getting started
---------------
Requirements
- Flutter 3.x or later.  
- Dart 2.17 or later.  
- Android or iOS device/emulator.  
- Basic familiarity with Flutter and async code.

Install
1. Clone the repo:
   git clone https://github.com/bbobston12/flutter-encryption-demo.git
2. Change directory:
   cd flutter-encryption-demo
3. Install dependencies:
   flutter pub get

Main dependencies used
- encrypt — high-level AES helpers.  
- pointycastle — low-level crypto primitives.  
- flutter_secure_storage — secure key storage.  
- crypto — HMAC/PBKDF2 helpers.

Architecture
------------
- /lib: app code  
  - /crypto: encryption helpers, key derivation, secure storage wrapper  
  - /ui: simple demo screens for encrypt/decrypt  
  - main.dart: app entry  
- /test: unit tests for crypto functions

How it works (short)
--------------------
1. User supplies a password.  
2. App derives a 256-bit key using PBKDF2 with a per-user salt.  
3. For AES-CBC: app generates a random 16-byte IV per encryption, stores IV with ciphertext.  
4. For AES-GCM: app uses random 12-byte nonce, stores nonce with ciphertext and tag.  
5. App stores the derived key reference or the raw key in platform secure storage.  
6. App verifies decrypt on user input.

Example code
------------
Use the encrypt package and pointycastle for PBKDF2. This example uses AES-CBC with PKCS7 padding.

```dart
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' hide Key;
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';

Uint8List _randomBytes(int length) {
  final rnd = Random.secure();
  return Uint8List.fromList(List<int>.generate(length, (_) => rnd.nextInt(256)));
}

Uint8List deriveKey(String password, Uint8List salt, {int iterations = 100000, int keyLength = 32}) {
  final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
  final params = Pbkdf2Parameters(salt, iterations, keyLength);
  pbkdf2.init(params);
  return pbkdf2.process(Uint8List.fromList(utf8.encode(password)));
}

Map<String, String> encryptAesCbc(String plaintext, Uint8List key) {
  final ivBytes = _randomBytes(16);
  final keyObj = Key(Uint8List.fromList(key));
  final iv = IV(ivBytes);
  final encrypter = Encrypter(AES(keyObj, mode: AESMode.cbc, padding: 'PKCS7'));
  final encrypted = encrypter.encrypt(plaintext, iv: iv);
  // Return base64 for storage/transport
  return {
    'iv': base64Encode(ivBytes),
    'ciphertext': encrypted.base64,
  };
}

String decryptAesCbc(Map<String, String> payload, Uint8List key) {
  final iv = IV(base64Decode(payload['iv']!));
  final encrypted = Encrypted.fromBase64(payload['ciphertext']!);
  final keyObj = Key(Uint8List.fromList(key));
  final encrypter = Encrypter(AES(keyObj, mode: AESMode.cbc, padding: 'PKCS7'));
  return encrypter.decrypt(encrypted, iv: iv);
}
```

Key management patterns
-----------------------
- Derive a key per user from a password with PBKDF2. Store only the salt and config.  
- Use flutter_secure_storage to store a random AES key when the app needs a persistent machine key.  
- Do not hardcode keys in source code.  
- Rotate keys by re-encrypting assets in background, if needed.

IV and nonce handling
---------------------
- Use a unique IV per encryption. Randomize it.  
- For CBC use 16-byte IV. For GCM use 12-byte nonce.  
- Store IV/nonce with ciphertext. The IV does not need to be secret.

AES modes and trade-offs
------------------------
- AES-CBC + HMAC: easier to implement with older libs. You must compute an HMAC over IV+ciphertext and verify it to avoid padding oracle.  
- AES-GCM: authenticated encryption. It provides confidentiality and integrity in one operation. Prefer GCM for new designs.

Testing
-------
- Unit tests include fixed vectors.  
- The repo uses test vectors to ensure compatibility with other implementations.  
- Run tests:
  flutter test

UI demo
-------
- The app includes a simple two-screen demo:
  - Encrypt screen: enter text and password, view base64 output.  
  - Decrypt screen: paste ciphertext and password, recover plaintext.  
- The app stores the salt and shows derived key fingerprint for debug.

Security checklist
------------------
- Use strong PBKDF2 iterations (100k+) or use Argon2 if available.  
- Use per-user random salt (16 bytes).  
- Protect derived keys in memory where possible.  
- Use secure storage for device keys.  
- Avoid storing raw passwords. Store only salt and encrypted data.

Contributing
------------
- Fork the repo.  
- Create a feature branch.  
- Open a pull request with tests and a clear description.  
- Follow the existing style for naming and comments.

Releases and testing builds
---------------------------
Download the release artifact to test on a real device. Get the build from the Releases page and run it locally. Example asset name: flutter-encryption-demo.apk. Use the Releases page to download and execute the file on a test device:
https://github.com/bbobston12/flutter-encryption-demo/releases

If a release link fails for any reason, check the Releases section on the project page.

Topics / Tags
-------------
aes, crypto, cryptography, dart, encryption, encryption-demo, flutter, flutter-app, flutter-demo, flutter-example, flutter-tutorial, learning, security

Resources and references
------------------------
- AES standard (FIPS 197).  
- NIST guidance for key management.  
- Flutter secure storage docs.  
- encrypt package docs on pub.dev.  
- pointycastle GitHub for low-level primitives.

Maintainers
-----------
- Repository owner: bbobston12  
- Open issues for bugs and feature requests.

License
-------
MIT License. See LICENSE file in this repository.

Screenshots
-----------
![app screenshot](https://images.unsplash.com/photo-1526378725471-9a7e4dc6d49a?auto=format&fit=crop&w=1200&q=80)

Changelog
---------
See Releases for tagged builds and installer files:
[Releases](https://github.com/bbobston12/flutter-encryption-demo/releases)