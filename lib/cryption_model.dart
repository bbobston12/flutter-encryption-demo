// this model is used to store the encrypted text, key, and IV
// it's actually essantial for the encryption and decryption process
class CryptionModel {
  final String cryptedText;
  final String base64Key;
  final String base64IV;

  CryptionModel({
    required this.cryptedText,
    required this.base64Key,
    required this.base64IV,
  });
}
