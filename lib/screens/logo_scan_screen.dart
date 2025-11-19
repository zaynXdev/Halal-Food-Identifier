import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:permission_handler/permission_handler.dart';

class LogoScanScreen extends StatefulWidget {
  const LogoScanScreen({super.key});

  @override
  State<LogoScanScreen> createState() => _LogoScanScreenState();
}

class _LogoScanScreenState extends State<LogoScanScreen> {
  late FlutterVision vision;
  late CameraController controller;
  bool isLoaded = false;
  bool isDetecting = false;
  List<Map<String, dynamic>> yoloResults = [];
  CameraImage? cameraImage;
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  // Initialize Camera and Model
  init() async {
    // 1. Check Permissions
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }

    // 2. Initialize Vision Tool
    vision = FlutterVision();

    // 3. Load YOLO Model
    await loadYoloModel();

    // 4. Start Camera
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      controller = CameraController(cameras[0], ResolutionPreset.high);
      await controller.initialize();
      setState(() {
        isCameraInitialized = true;
        isLoaded = true;
      });
      
      // Start feeding frames to the model
      startDetection();
    }
  }

  Future<void> loadYoloModel() async {
    await vision.loadYoloModel(
      labels: 'assets/labels.txt',
      modelPath: 'assets/halal_logo_detector.tflite',
      modelVersion: "yolov8",
      numThreads: 2,
      useGpu: true,
    );
    print("✅ YOLO Model Loaded Successfully");
  }

  Future<void> startDetection() async {
    setState(() {
      isDetecting = true;
    });
    if (controller.value.isStreamingImages) return;

    await controller.startImageStream((image) async {
      if (isDetecting) {
        cameraImage = image;
        yoloOnFrame(image);
      }
    });
  }

  Future<void> yoloOnFrame(CameraImage cameraImage) async {
    final result = await vision.yoloOnFrame(
      bytesList: cameraImage.planes.map((plane) => plane.bytes).toList(),
      imageHeight: cameraImage.height,
      imageWidth: cameraImage.width,
      iouThreshold: 0.4,
      confThreshold: 0.4,
      classThreshold: 0.5,
    );
    
    if (result.isNotEmpty) {
      setState(() {
        yoloResults = result;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    vision.closeYoloModel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded || !isCameraInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Halal Logo Detector")),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. The Camera Feed
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(controller),
          ),
          
          // 2. Bounding Boxes Overlay
          ...displayBoxesAroundRecognizedObjects(MediaQuery.of(context).size),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Toggle detection to save battery if needed
          setState(() {
            isDetecting = !isDetecting;
            yoloResults.clear();
          });
        },
        child: Icon(isDetecting ? Icons.stop : Icons.play_arrow),
      ),
    );
  }

  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    if (yoloResults.isEmpty) return [];
    
    double factorX = screen.width / (cameraImage?.height ?? 1);
    double factorY = screen.height / (cameraImage?.width ?? 1);

    Color colorPick = const Color.fromARGB(255, 50, 233, 30);

    return yoloResults.map((result) {
      // Render the bounding box
      return Positioned(
        left: result["box"][0] * factorX,
        top: result["box"][1] * factorY,
        width: (result["box"][2] - result["box"][0]) * factorX,
        height: (result["box"][3] - result["box"][1]) * factorY,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: Colors.pink, width: 2.0),
          ),
          child: Text(
            "${result['tag']} ${(result['box'][4] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()..color = colorPick,
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }).toList();
  }
}