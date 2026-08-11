import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_barcode_pro/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const QRBarcodeApp());
    expect(find.text('QR & Barcode Pro'), findsOneWidget);
  });
}
