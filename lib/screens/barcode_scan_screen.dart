import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> {
  Map<String, dynamic> barcodeDb = {};
  bool isDbLoaded = false;
  bool isScanning = true; // To prevent multiple scans at once

  @override
  void initState() {
    super.initState();
    loadDatabase();
  }

  Future<void> loadDatabase() async {
    try {
      final String response = await rootBundle.loadString('assets/barcode_status_db.json');
      final data = await json.decode(response);
      setState(() {
        barcodeDb = data;
        isDbLoaded = true;
      });
    } catch (e) {
      print("❌ Error loading Barcode DB: $e");
    }
  }

  void checkBarcode(String code) {
    setState(() => isScanning = false); // Pause scanning

    String status = barcodeDb[code] ?? "UNKNOWN (Not in database)";
    
    // Show Result Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text("Barcode Detected"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            Text(status, style: TextStyle(
              fontSize: 16, 
              color: status.contains("HARAM") ? Colors.red : Colors.green
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => isScanning = true); // Resume scanning
            },
            child: const Text("Scan Next"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Barcode Scanner")),
      body: isDbLoaded
          ? MobileScanner(
              onDetect: (capture) {
                if (!isScanning) return;
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    checkBarcode(barcode.rawValue!);
                    break; // Only check the first code found
                  }
                }
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}