import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unified_storefronts/core/services/storage_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImagePickerWidget extends StatelessWidget {
  final File? selectedImageFile;
  final String? imageUrl;
  final Function(File) onImageSelected;
  final double height;
  final double width;
  final double borderRadius;
  final String placeholderText;
  final IconData icon;
  final bool isLoading;

  const ImagePickerWidget({
    super.key,
    this.selectedImageFile,
    this.imageUrl,
    required this.onImageSelected,
    this.height = 200,
    this.width = double.infinity,
    this.borderRadius = 8.0,
    this.placeholderText = 'Tap to add image',
    this.icon = Icons.add_a_photo,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storageService = StorageService();

    // Show the selected image if available
    if (selectedImageFile != null) {
      return _buildImageContainer(
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Image.file(
                selectedImageFile!,
                height: height,
                width: width,
                fit: BoxFit.cover,
              ),
            ),
            _buildOverlayButtons(context, storageService),
          ],
        ),
      );
    }

    // Show the remote image if URL is available
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return _buildImageContainer(
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: CachedNetworkImage(
                imageUrl: imageUrl!,
                height: height,
                width: width,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 32,
                ),
              ),
            ),
            _buildOverlayButtons(context, storageService),
          ],
        ),
      );
    }

    // Show placeholder if no image is selected
    return _buildImageContainer(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : InkWell(
              onTap: () => _showImageSourceDialog(context, storageService),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    placeholderText,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildImageContainer({required Widget child}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.0,
        ),
      ),
      child: child,
    );
  }

  Widget _buildOverlayButtons(
    BuildContext context,
    StorageService storageService,
  ) {
    return Positioned(
      bottom: 8,
      right: 8,
      child: Row(
        children: [
          // Change image button
          _buildCircleButton(
            context,
            Icons.edit,
            () => _showImageSourceDialog(context, storageService),
          ),
          const SizedBox(width: 8),
          // Remove image button
          _buildCircleButton(
            context,
            Icons.delete,
            () {
              // Clear the selected image
              onImageSelected(File(''));
            },
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(
    BuildContext context,
    IconData icon,
    VoidCallback onTap, [
    Color? color,
  ]) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _showImageSourceDialog(
    BuildContext context,
    StorageService storageService,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await storageService.pickImageFromCamera();
                if (image != null) {
                  onImageSelected(File(image.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await storageService.pickImageFromGallery();
                if (image != null) {
                  onImageSelected(File(image.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}