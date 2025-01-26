import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CustomQrCode extends StatelessWidget {
  final String data;

  const CustomQrCode({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Decorative gradient background with rounded corners
          Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(170, 209, 209, 209),
                  Color.fromARGB(200, 245, 188, 255),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color:
                      const Color.fromARGB(46, 155, 39, 176).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),
          // QR Code widget
          QrImageView(
            data: data,
            version: QrVersions.auto,
            size: 280,
            gapless: false,
            // Styling for the QR code
            backgroundColor: const Color.fromARGB(
                53, 0, 0, 0), // Matches the gradient background
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Colors.black, // Color of the "eye" patterns
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.circle,
              color: Colors.black, // Color of the QR code dots
            ),
            // Embedded logo in the center of the QR code
            embeddedImage:
                const AssetImage('assets/plogo.png'), // Update your path
            embeddedImageStyle: const QrEmbeddedImageStyle(
              size: Size(80, 80), // Size of the embedded logo
            ),
            // Error handling for invalid QR data
            errorStateBuilder: (context, error) {
              return const Center(
                child: Text(
                  'Error generating QR code!',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
