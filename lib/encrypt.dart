import 'package:encrypt/encrypt.dart' as cipher;
import 'package:encryption_test/cryption_model.dart';

// Encrypts the given text and returns a CryptionModel containing the encrypted text, key, and IV
Object encryptExample(String text) {
  final key = cipher.Key.fromSecureRandom(32);

  final iv = cipher.IV.fromSecureRandom(16);

  final encrypter = cipher.Encrypter(cipher.AES(key, mode: cipher.AESMode.cbc));

  try {
    final encrypted = encrypter.encrypt(text, iv: iv);

    print('Oluşturulan Anahtar (Base64): ${key.base64}');
    print('Oluşturulan IV (Base64):      ${iv.base64}');

    return CryptionModel(
      cryptedText: encrypted.base64,
      base64Key: key.base64,
      base64IV: iv.base64,
    );
  } catch (e) {
    print('Error: $e');
    return 'Error: ${e.toString()}';
  }
}

// Decrypts the encrypted text using the provided CryptionModel
String decryptExample(CryptionModel cryptedText) {
  final key = cipher.Key.fromBase64(cryptedText.base64Key);
  final iv = cipher.IV.fromBase64(cryptedText.base64IV);
  final encrypter = cipher.Encrypter(cipher.AES(key, mode: cipher.AESMode.cbc));

  final decrypted = encrypter.decrypt64(cryptedText.cryptedText, iv: iv);

  return decrypted;
}
