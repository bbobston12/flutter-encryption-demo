import 'package:encryption_test/cryption_model.dart';
import 'package:flutter/material.dart';
import 'package:encryption_test/encrypt.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Text controller for the input field
  // This will be used to get the text input from the user
  final _textController = TextEditingController();
  // List to store encrypted items
  // This will hold the encrypted text, key, and IV
  final List<CryptionModel> _encryptedItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // Appbar
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      // Body
      body: SafeArea(
        //  Padding for the customization
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Input Field
              TextField(
                controller: _textController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Enter text to encrypt...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  labelText: 'Enter text to encrypt...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              // Encrypt Button
              ElevatedButton.icon(
                onPressed: () {
                  final text = _textController.text.trim();
                  if (text.isNotEmpty) {
                    final result = encryptExample(text);

                    if (result is CryptionModel) {
                      setState(() {
                        // when the button is pressed, the text is encrypted
                        // and added to the list of encrypted items
                        _encryptedItems.add(result);
                        _textController.clear();
                      });
                    }
                  }
                },
                icon: const Icon(Icons.lock, color: Colors.white),
                label: const Text("Encrypt"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Result List
              Expanded(
                child:
                    // control the visibility of the list based on the items
                    _encryptedItems.isEmpty
                        ?
                        // If there are no encrypted items, show a message
                        const Center(
                          child: Text(
                            'Doesn\'t have any encrypted text yet.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                        :
                        // If there are encrypted items, show them in a list
                        ListView.builder(
                          itemCount: _encryptedItems.length,
                          itemBuilder: (context, index) {
                            final currentItem = _encryptedItems[index];
                            // Decrypt the text for display, It'll only be used in the card --> not in the dialog
                            final originalText = decryptExample(currentItem);
                            // If user taps on the card, show the decrypted text in a dialog
                            return GestureDetector(
                              onTap:
                                  () => showDialog(
                                    context: context,
                                    builder:
                                        (conext) => AlertDialog(
                                          title: const Text('Decrypted Text'),
                                          // Show the decrypted text in the dialog
                                          content: Text(
                                            // It allows the currentItem cause it is the item that was tapped
                                            decryptExample(currentItem),
                                          ),

                                          // close button
                                          actions: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.red.shade400,
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed:
                                                  () =>
                                                      Navigator.of(
                                                        context,
                                                      ).pop(),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text('Close'),
                                                  SizedBox(width: 8),
                                                  Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                  ),

                              // Display the original text and the encrypted text in a card
                              child: Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Display the index and the original text
                                      Text(
                                        '${index + 1}. Text',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      // Display the original text and the encrypted text
                                      Text(
                                        '🔓 Original Text: $originalText',
                                        style: const TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '🔐 Encrypted: ${currentItem.cryptedText}',
                                        style: const TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
