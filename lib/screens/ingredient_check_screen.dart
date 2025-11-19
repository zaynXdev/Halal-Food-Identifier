import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

class IngredientCheckScreen extends StatefulWidget {
  const IngredientCheckScreen({super.key});

  @override
  State<IngredientCheckScreen> createState() => _IngredientCheckScreenState();
}

class _IngredientCheckScreenState extends State<IngredientCheckScreen> {
  late CameraController controller;
  bool isCameraInitialized = false;
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  
  // Database to hold our JSON data
  Map<String, dynamic> ingredientDb = {};
  bool isDbLoaded = false;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    loadDatabase();
    initCamera();
  }

  // 1. Load the JSON Database
  Future<void> loadDatabase() async {
    try {
      final String response = await rootBundle.loadString('assets/halal_ingredients_db.json');
      final data = await json.decode(response);
      setState(() {
        ingredientDb = data;
        isDbLoaded = true;
      });
      print("✅ Ingredient DB Loaded: ${ingredientDb.length} entries");
    } catch (e) {
      print("❌ Error loading DB: $e");
    }
  }

  // 2. Initialize Camera
  Future<void> initCamera() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        // Use the back camera, high resolution for better OCR
        controller = CameraController(cameras[0], ResolutionPreset.veryHigh, enableAudio: false);
        await controller.initialize();
        setState(() {
          isCameraInitialized = true;
        });
      }
    }
  }

  // 3. Capture and Process
  Future<void> captureAndAnalyze() async {
    if (isProcessing) return;
    setState(() => isProcessing = true);

    try {
      // A. Take the picture
      final image = await controller.takePicture();
      
      // B. Run OCR (Read Text)
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await textRecognizer.processImage(inputImage);
      
      // C. Analyze Ingredients
      analyzeText(recognizedText.text);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isProcessing = false);
    }
  }

  // 4. The Logic: Compare OCR text with Database
  void analyzeText(String text) {
    String scannedText = text.toLowerCase(); // Convert to lowercase for matching
    List<Map<String, String>> detectedIngredients = [];
    
    // Check every ingredient in our database against the scanned text
    ingredientDb.forEach((key, value) {
      if (scannedText.contains(key.toLowerCase())) {
        detectedIngredients.add({
          "name": key,
          "status": value.toString()
        });
      }
    });

    showResultDialog(detectedIngredients);
  }

  // 5. Show Results
  void showResultDialog(List<Map<String, String>> results) {
    String title = "Safe to Eat? 🤔";
    Color color = Colors.grey;
    IconData icon = Icons.help_outline;

    // Determine overall status
    bool hasHaram = results.any((i) => i['status']!.contains("HARAM"));
    bool hasMushbooh = results.any((i) => i['status']!.contains("MUSHBOOH"));

    if (hasHaram) {
      title = "🚫 HARAM DETECTED";
      color = Colors.red;
      icon = Icons.block;
    } else if (hasMushbooh) {
      title = "⚠️ MUSHBOOH (Doubtful)";
      color = Colors.orange;
      icon = Icons.warning_amber;
    } else if (results.isEmpty) {
      title = "No Ingredients Found";
      color = Colors.blue;
      icon = Icons.search_off;
    } else {
      title = "✅ Likely Halal";
      color = Colors.green;
      icon = Icons.check_circle;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 500,
        child: Column(
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const Divider(),
            Expanded(
              child: results.isEmpty 
                ? const Center(child: Text("No risky ingredients detected in the list."))
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      bool isBad = item['status']!.contains("HARAM");
                      return ListTile(
                        leading: Icon(Icons.circle, size: 15, color: isBad ? Colors.red : Colors.orange),
                        title: Text(item['name']!.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(item['status']!),
                      );
                    },
                  ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Scan Again"),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isCameraInitialized || !isDbLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Ingredient Checker")),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(controller),
          // Overlay Guide
          Center(
            child: Container(
              width: 300,
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Capture Button
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: isProcessing 
              ? const CircularProgressIndicator(color: Colors.white)
              : FloatingActionButton.large(
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.camera_alt, color: Colors.black),
                  onPressed: captureAndAnalyze,
                ),
            ),
          )
        ],
      ),
    );
  }
}