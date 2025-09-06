import 'dart:io';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'dart:developer' as devtools;

class ClassificationResult {
  final String label;
  final double confidence;
  final DateTime timestamp;

  ClassificationResult({
    required this.label,
    required this.confidence,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        'confidence': confidence,
        'timestamp': timestamp.toIso8601String(),
      };
}

class ClassificationService {
  static final ClassificationService _instance = ClassificationService._internal();
  factory ClassificationService() => _instance;
  ClassificationService._internal();

  bool _isModelLoaded = false;
  bool get isModelLoaded => _isModelLoaded;

  Future<bool> initializeModel({
    String modelPath = "assets/model_unquant.tflite",
    String labelsPath = "assets/labels.txt",
    int numThreads = 1,
    bool useGpuDelegate = false,
  }) async {
    try {
      String? result = await Tflite.loadModel(
        model: modelPath,
        labels: labelsPath,
        numThreads: numThreads,
        isAsset: true,
        useGpuDelegate: useGpuDelegate,
      );
      
      _isModelLoaded = result != null;
      devtools.log('Model initialization: ${_isModelLoaded ? 'Success' : 'Failed'}');
      return _isModelLoaded;
    } catch (e) {
      devtools.log('Error initializing model: $e');
      _isModelLoaded = false;
      return false;
    }
  }

  Future<ClassificationResult?> classifyImage(
    String imagePath, {
    double imageMean = 0.0,
    double imageStd = 255.0,
    int numResults = 2,
    double threshold = 0.2,
  }) async {
    if (!_isModelLoaded) {
      throw Exception('Model not loaded. Please initialize the model first.');
    }

    try {
      var recognitions = await Tflite.runModelOnImage(
        path: imagePath,
        imageMean: imageMean,
        imageStd: imageStd,
        numResults: numResults,
        threshold: threshold,
        asynch: true,
      );

      if (recognitions == null || recognitions.isEmpty) {
        devtools.log("No recognitions found");
        return null;
      }

      devtools.log('Classification results: $recognitions');

      return ClassificationResult(
        label: recognitions[0]['label'].toString(),
        confidence: (recognitions[0]['confidence'] as double) * 100,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      devtools.log('Error during classification: $e');
      throw Exception('Classification failed: $e');
    }
  }

  void dispose() {
    Tflite.close();
    _isModelLoaded = false;
    devtools.log('Model disposed');
  }
}