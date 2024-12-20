import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemDetailScreen extends StatefulWidget {
  final String itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late Future<DocumentSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchItemDetails();
  }

  Future<DocumentSnapshot> _fetchItemDetails() {
    return FirebaseFirestore.instance
        .collection('Items')
        .doc(widget.itemId)
        .get();
  }

  void _refreshScreen() {
    setState(() {
      _future = _fetchItemDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Item Details'),
      ),
      child: FutureBuilder<DocumentSnapshot>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;

          Widget buildDataItem(String title, String? value) {
            if (value == null || value.isEmpty) {
              return const SizedBox.shrink();
            }

            final combinedText = '$title: $value';

            return GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: combinedText));
                showTemporaryPopup(context, combinedText);
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    '$title: ',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: SelectableText(
                      value,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: const Icon(CupertinoIcons.doc_on_doc),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: combinedText));
                      showTemporaryPopup(context, combinedText);
                    },
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              buildDataItem('상호명', data['ItemName']),
              const SizedBox(height: 10),
              buildDataItem('주소', data['Location']),
              const SizedBox(height: 10),
              buildDataItem('전화번호', data['PhoneNumber']),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: CupertinoButton(
                  color: CupertinoColors.tertiaryLabel,
                  onPressed: () {
                    showEditDialog(context, widget.itemId, data);
                  },
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: CupertinoButton(
                  color: const Color.fromARGB(255, 255, 105, 97),
                  onPressed: () {
                    showDeleteConfirmation(context, widget.itemId);
                  },
                  child: const Text('Delete'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void showEditDialog(
      BuildContext context, String itemId, Map<String, dynamic> data) {
    final TextEditingController nameController =
        TextEditingController(text: data['ItemName']);
    final TextEditingController locationController =
        TextEditingController(text: data['Location']);
    final TextEditingController phoneController =
        TextEditingController(text: data['PhoneNumber']);

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Edit Item'),
          content: Column(
            children: [
              CupertinoTextField(
                controller: nameController,
                placeholder: 'Name',
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                controller: locationController,
                placeholder: 'Location',
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                controller: phoneController,
                placeholder: 'Phone Number',
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('Items')
                    .doc(itemId)
                    .update({
                  'ItemName': nameController.text,
                  'Location': locationController.text,
                  'PhoneNumber': phoneController.text,
                });
                Navigator.pop(context);
                _refreshScreen();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void showDeleteConfirmation(BuildContext context, String itemId) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Delete Item'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('Items')
                    .doc(itemId)
                    .delete();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              isDestructiveAction: true,
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void showTemporaryPopup(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) {
        return FadeOutPopup(message: message);
      },
    );

    overlay?.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 1), () {
      overlayEntry.remove();
    });
  }
}

class FadeOutPopup extends StatefulWidget {
  final String message;

  const FadeOutPopup({super.key, required this.message});

  @override
  State<FadeOutPopup> createState() => _FadeOutPopupState();
}

class _FadeOutPopupState extends State<FadeOutPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: CupertinoPopupSurface(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.message,
                style: const TextStyle(
                    fontSize: 16, color: Color.fromARGB(255, 94, 93, 93)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
