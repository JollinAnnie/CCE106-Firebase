
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class PickedImage {
  final Uint8List bytes;
  final String url;

  PickedImage({required this.bytes, required this.url});
}

class CrudService {
  final CollectionReference items = FirebaseFirestore.instance.collection(
    'items',
  );

  // CLOUDINARY CONFIGURATION
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'p0mqk7u7',
    'flutter_notes_preset',
    cache: false,
  );

  final ImagePicker _picker = ImagePicker();

  // PICK AND UPLOAD IMAGE
  Future<PickedImage?> pickImageForAddItem() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) return null;

    final bytes = await pickedFile.readAsBytes();

    final response = await _cloudinary.uploadFile(
      CloudinaryFile.fromBytesData(
        bytes,
        identifier: pickedFile.name,
        resourceType: CloudinaryResourceType.Image,
      ),
    );

    return PickedImage(
      bytes: bytes,
      url: response.secureUrl,
    );
  }

  // CREATE
  Future<void> addItem(String name, int quantity) {
    return addItemWithImage(name, quantity, null);
  }

  Future<void> addItemWithImage(
    String name,
    int quantity,
    String? imageUrl,
  ) async {
    await items.add({
      'name': name,
      'quantity': quantity,
      'image_url': imageUrl,
      'createdAt': Timestamp.now(),
    });
  }

  // READ
  Stream<QuerySnapshot> getItems() {
    return items.orderBy('createdAt', descending: true).snapshots();
  }

  // UPDATE
  Future<void> updateItem(String id, String name, int quantity) {
    return items.doc(id).update({
      'name': name,
      'quantity': quantity,
    });
  }

  // DELETE
  Future<void> deleteItem(String id) {
    return items.doc(id).delete();
  }
}
