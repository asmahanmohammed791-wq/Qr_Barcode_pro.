import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gal/gal.dart';

class GenerateBarcodeScreen extends StatefulWidget {
  const GenerateBarcodeScreen({super.key});

  @override
  State<GenerateBarcodeScreen> createState() => _GenerateBarcodeScreenState();
}

class _GenerateBarcodeScreenState extends State<GenerateBarcodeScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();
  String _barcodeData = '';
  BarcodeType _barcodeType = BarcodeType.Code128;

  final List<Map<String, dynamic>> _barcodeTypes = [
    {'name': 'Code 128', 'type': BarcodeType.Code128},
    {'name': 'Code 39', 'type': BarcodeType.Code39},
    {'name': 'EAN-13', 'type': BarcodeType.EAN13},
    {'name': 'EAN-8', 'type': BarcodeType.EAN8},
    {'name': 'UPC-A', 'type': BarcodeType.UPCA},
  ];

  Barcode _getBarcodeObject(BarcodeType type) {
    switch (type) {
      case BarcodeType.Code128:
        return Barcode.code128();
      case BarcodeType.Code39:
        return Barcode.code39();
      case BarcodeType.EAN13:
        return Barcode.ean13();
      case BarcodeType.EAN8:
        return Barcode.ean8();
      case BarcodeType.UPCA:
        return Barcode.upcA();
      default:
        return Barcode.code128();
    }
  }

  void _generateBarcode() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        _barcodeData = _controller.text.trim();
      });
    }
  }

  Future<void> _saveToGallery() async {
    if (_barcodeData.isEmpty) return;
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

  Future<void> _shareBarcode() async {
    if (_barcodeData.isEmpty) return;
    try {
      final image = await _screenshotController.capture();
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/barcode.png';
        final file = File(imagePath);
        await file.writeAsBytes(image);
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: 'Generated Barcode',
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
              labelText: 'Enter barcode data',
              hintText: '123456789012',
              prefixIcon: const Icon(Icons.numbers),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<BarcodeType>(
            value: _barcodeType,
            decoration: InputDecoration(
              labelText: 'Barcode Type',
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
            onPressed: _generateBarcode,
            icon: const Icon(Icons.barcode_reader),
            label: const Text('Generate Barcode'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_barcodeData.isNotEmpty) ...[
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
                    data: _barcodeData,
                    width: 300,
                    height: 120,
                    drawText: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _barcodeData,
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
                    onPressed: _shareBarcode,
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
