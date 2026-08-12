import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gal/gal.dart';

class GenerateQrScreen extends StatefulWidget {
  const GenerateQrScreen({super.key});

  @override
  State<GenerateQrScreen> createState() => _GenerateQrScreenState();
}

class _GenerateQrScreenState extends State<GenerateQrScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();
  String _qrData = '';
  BarcodeType _barcodeType = BarcodeType.QrCode;

  final List<Map<String, dynamic>> _barcodeTypes = [
    {'name': 'QR Code', 'type': BarcodeType.QrCode},
    {'name': 'Code 128', 'type': BarcodeType.Code128},
    {'name': 'Code 39', 'type': BarcodeType.Code39},
    {'name': 'EAN-13', 'type': BarcodeType.Ean13},
    {'name': 'EAN-8', 'type': BarcodeType.Ean8},
    {'name': 'UPC-A', 'type': BarcodeType.UpcA},
  ];

  Barcode _getBarcodeObject(BarcodeType type) {
    switch (type) {
      case BarcodeType.QrCode:
        return Barcode.qrCode();
      case BarcodeType.Code128:
        return Barcode.code128();
      case BarcodeType.Code39:
        return Barcode.code39();
      case BarcodeType.Ean13:
        return Barcode.ean13();
      case BarcodeType.Ean8:
        return Barcode.ean8();
      case BarcodeType.UpcA:
        return Barcode.upcA();
      default:
        return Barcode.qrCode();
    }
  }

  void _generateQr() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        _qrData = _controller.text.trim();
      });
    }
  }

  Future<void> _saveToGallery() async {
    if (_qrData.isEmpty) return;
    try {
      final status = await Permission.storage.request();
      if (status.isGranted || await Permission.photos.request().isGranted) {
        final Uint8List? image = await _screenshotController.capture();
        if (image != null) {
          await Gal.putImageBytes(image);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Saved to gallery!')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _shareQr() async {
    if (_qrData.isEmpty) return;
    try {
      final image = await _screenshotController.capture();
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/qr_code.png';
        final file = File(imagePath);
        await file.writeAsBytes(image);
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: 'Generated Code',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Enter text or URL',
              hintText: 'https://example.com',
              prefixIcon: const Icon(Icons.link),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<BarcodeType>(
            value: _barcodeType,
            decoration: InputDecoration(
              labelText: 'Code Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
            items: _barcodeTypes.map((type) {
              return DropdownMenuItem<BarcodeType>(
                value: type['type'] as BarcodeType,
                child: Text(type['name'] as String),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _barcodeType = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _generateQr,
            icon: const Icon(Icons.qr_code),
            label: const Text('Generate Code'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_qrData.isNotEmpty) ...[
            Center(
              child: Screenshot(
                controller: _screenshotController,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: BarcodeWidget(
                    barcode: _getBarcodeObject(_barcodeType),
                    data: _qrData,
                    width: 200,
                    height: 200,
                    drawText: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _qrData,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveToGallery,
                    icon: const Icon(Icons.download),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareQr,
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
