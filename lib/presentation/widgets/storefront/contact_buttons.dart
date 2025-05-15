import 'package:flutter/material.dart';

class ContactButtons extends StatelessWidget {
  final String? whatsappNumber;
  final String? instagramHandle;
  final String? phoneNumber;
  final VoidCallback? onWhatsAppTap;
  final VoidCallback? onInstagramTap;
  final VoidCallback? onPhoneTap;

  const ContactButtons({
    super.key,
    this.whatsappNumber,
    this.instagramHandle,
    this.phoneNumber,
    this.onWhatsAppTap,
    this.onInstagramTap,
    this.onPhoneTap,
  });

  @override
  Widget build(BuildContext context) {
    // Check if any contact methods are available
    final hasWhatsApp = whatsappNumber != null && whatsappNumber!.isNotEmpty;
    final hasInstagram = instagramHandle != null && instagramHandle!.isNotEmpty;
    final hasPhone = phoneNumber != null && phoneNumber!.isNotEmpty;
    
    // If no contact methods available, don't show the buttons
    if (!hasWhatsApp && !hasInstagram && !hasPhone) {
      return const SizedBox();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Us',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // WhatsApp Button
              if (hasWhatsApp)
                _buildContactButton(
                  context,
                  'WhatsApp',
                  Icons.whatsapp,
                  Colors.green,
                  onWhatsAppTap,
                ),
              
              // Instagram Button
              if (hasInstagram)
                _buildContactButton(
                  context,
                  'Instagram',
                  Icons.camera_alt,
                  Colors.purple,
                  onInstagramTap,
                ),
              
              // Phone Button
              if (hasPhone)
                _buildContactButton(
                  context,
                  'Call',
                  Icons.phone,
                  Colors.blue,
                  onPhoneTap,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
          label: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }
}