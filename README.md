# 🟢 Halal Vision - Halal Food Identifier

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![TensorFlow](https://img.shields.io/badge/TensorFlow-%23FF6F00.svg?style=for-the-badge&logo=TensorFlow&logoColor=white)
![YOLOv8](https://img.shields.io/badge/YOLOv8-%2300FFFF.svg?style=for-the-badge&logo=yolo&logoColor=black)
![ML Kit](https://img.shields.io/badge/Google_ML_Kit-4285F4?style=for-the-badge&logo=google&logoColor=white)

**Halal Vision** is a comprehensive mobile application designed to assist Muslim consumers in identifying Halal products efficiently using advanced Computer Vision and AI technologies.

The app integrates three distinct scanning methods into a single, user-friendly Flutter interface to provide real-time verification of food products.

---

## 🚀 Key Features

### 1. 🔍 Real-Time Halal Logo Detection
* **Tech:** YOLOv8 (You Only Look Once) custom-trained model converted to TensorFlow Lite (`.tflite`).
* **Function:** Instantly detects and draws bounding boxes around certified Halal logos (e.g., JAKIM, MUI, etc.) directly on the camera feed.
* **Performance:** Runs offline on-device using `flutter_vision`.

### 2. 📝 Ingredient Scanner (OCR + NLP)
* **Tech:** Google ML Kit Text Recognition.
* **Function:** Scans the ingredient list on product packaging using Optical Character Recognition (OCR).
* **Analysis:** Automatically cross-references extracted text against a local database of known **Haram** (e.g., E120, Gelatin, Pork) and **Mushbooh** (Doubtful) ingredients.
* **Alerts:** Provides immediate visual feedback (Green/Red/Orange) based on the risk level.

### 3. 📱 Barcode Product Lookup
* **Tech:** Mobile Scanner.
* **Function:** Scans standard product barcodes (UPC/EAN).
* **Database:** Looks up the product ID in a local JSON database to retrieve its specific Halal certification status.

---

## 📱 App Screenshots

| Home Screen | Logo Detection | Ingredient Check |
|:---:|:---:|:---:|
| <img src="https://github.com/zaynXdev/Halal-Food-Identifier/blob/main/Screenshots/homepage%20.jpg" width="200" /> | <img src="https://github.com/zaynXdev/Halal-Food-Identifier/blob/main/Screenshots/Logo%20Detection.jpg" width="200" /> | <img src="https://github.com/zaynXdev/Halal-Food-Identifier/blob/main/Screenshots/Ingredients%20detection.jpg" width="200" /> |



---

## 🛠️ Tech Stack

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **AI/ML Models:**
    * **Object Detection:** YOLOv8 Nano (Custom trained on Roboflow, exported to TFLite).
    * **OCR:** Google ML Kit On-Device Text Recognition.
* **Databases:** JSON-based local storage for ingredients and barcode lookups.
* **Plugins:**
    * `flutter_vision`: For running TFLite models.
    * `camera`: For handling video streams.
    * `mobile_scanner`: For barcode processing.

---

## 📂 Project Structure

```bash
halal_vision_app/
├── android/            # Android native code
├── assets/             # AI Models and Databases
│   ├── halal_logo_detector.tflite  # The YOLOv8 TFLite model
│   ├── labels.txt                  # Class names for the model
│   ├── halal_ingredients_db.json   # Database of Haram ingredients
│   └── barcode_status_db.json      # Mock database for barcodes
├── lib/
│   ├── screens/
│   │   ├── home_screen.dart            # Main Menu
│   │   ├── logo_scan_screen.dart       # Feature 1: YOLO Logic
│   │   ├── ingredient_check_screen.dart# Feature 2: OCR Logic
│   │   └── barcode_scan_screen.dart    # Feature 3: Barcode Logic
│   └── main.dart       # App Entry Point
└── pubspec.yaml        # Dependencies and Asset definitions
```

⚙️ Installation & Setup
Clone the Repository



Conversion: The model was exported to .tflite (Float32) for mobile optimization.

Integration:

Logo: We use the camera stream to pass pixel buffers to the TFLite interpreter.

Text: We capture an image, pass it to ML Kit, and parse the resulting string to find "red flag" keywords defined in our JSON database.

🤝 Contributing
Contributions are welcome! If you want to expand the ingredient database or improve the model accuracy:

Fork the Project.

Create your Feature Branch (git checkout -b feature/AmazingFeature).

Commit your Changes (git commit -m 'Add some AmazingFeature').

Push to the Branch (git push origin feature/AmazingFeature).

Open a Pull Request.



