import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:unified_storefronts/config/constants.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  // Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
  }

  // Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    return await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
  }

  // Pick multiple images from gallery
  Future<List<XFile>> pickMultipleImages() async {
    return await _picker.pickMultiImage(
      imageQuality: 80,
    );
  }

  // Upload profile image
  Future<String> uploadProfileImage(File file, String sellerId) async {
    final fileName = '$sellerId-${_uuid.v4()}${path.extension(file.path)}';
    final ref = _storage.ref().child('${AppConstants.profileImagesPath}/$fileName');
    
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() => {});
    
    return await snapshot.ref.getDownloadURL();
  }

  // Upload store logo
  Future<String> uploadStoreLogo(File file, String storeId) async {
    final fileName = '$storeId-logo-${_uuid.v4()}${path.extension(file.path)}';
    final ref = _storage.ref().child('${AppConstants.storeImagesPath}/$fileName');
    
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() => {});
    
    return await snapshot.ref.getDownloadURL();
  }

  // Upload store banner
  Future<String> uploadStoreBanner(File file, String storeId) async {
    final fileName = '$storeId-banner-${_uuid.v4()}${path.extension(file.path)}';
    final ref = _storage.ref().child('${AppConstants.storeImagesPath}/$fileName');
    
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() => {});
    
    return await snapshot.ref.getDownloadURL();
  }

  // Upload product image
  Future<String> uploadProductImage(File file, String productId) async {
    final fileName = '$productId-${_uuid.v4()}${path.extension(file.path)}';
    final ref = _storage.ref().child('${AppConstants.productImagesPath}/$fileName');
    
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() => {});
    
    return await snapshot.ref.getDownloadURL();
  }

  // Upload multiple product images
  Future<List<String>> uploadMultipleProductImages(List<File> files, String productId) async {
    final uploadTasks = <Future<String>>[];
    
    for (final file in files) {
      uploadTasks.add(uploadProductImage(file, productId));
    }
    
    return await Future.wait(uploadTasks);
  }

  // Delete image by URL
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Handle error (e.g., image doesn't exist anymore)
      print('Error deleting image: $e');
    }
  }

  // Delete multiple images by URL
  Future<void> deleteMultipleImages(List<String> imageUrls) async {
    final deleteTasks = <Future<void>>[];
    
    for (final url in imageUrls) {
      deleteTasks.add(deleteImage(url));
    }
    
    await Future.wait(deleteTasks);
  }

  // Compress image (Simple compression using imageQuality in picker)
  // For more advanced compression, consider using additional packages like flutter_image_compress
  Future<XFile?> compressImage(File file) async {
    // Using the image_picker's compression capability when picking the image
    // This is a simplified approach
    return XFile(file.path);
  }
}