import 'dart:io';
import 'package:flutter/material.dart';
import '../services/classification_service.dart';
import '../services/image_service.dart';
import '../pages/scan_page.dart';


class ImageClassificationScreen extends StatefulWidget {
  const ImageClassificationScreen({super.key});

  @override
  State<ImageClassificationScreen> createState() => _ImageClassificationScreenState();
}

class _ImageClassificationScreenState extends State<ImageClassificationScreen>
    with TickerProviderStateMixin {
  final ClassificationService _classificationService = ClassificationService();
  final ImageService _imageService = ImageService();

  File? _selectedImage;
  ClassificationResult? _result;
  bool _isLoading = false;
  bool _isModelInitialized = false;
  String _statusMessage = 'Initializing AI Model...';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeModel();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeModel() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading AI Model...';
    });

    try {
      final success = await _classificationService.initializeModel();
      setState(() {
        _isModelInitialized = success;
        _statusMessage = success 
            ? 'AI Model Ready!' 
            : 'Failed to load model. Please check your assets.';
        _isLoading = false;
      });
      
      if (success) {
        _animationController.forward();
      }
    } catch (e) {
      setState(() {
        _isModelInitialized = false;
        _statusMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndClassifyImage(ImageSourceType sourceType) async {
    if (!_isModelInitialized) {
      _showSnackBar('AI Model not ready yet. Please wait.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final File? imageFile = await _imageService.pickImage(
        sourceType: sourceType,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (imageFile == null) {
        setState(() => _isLoading = false);
        return;
      }

      if (!await _imageService.isImageValid(imageFile)) {
        _showSnackBar('Invalid image file. Please select a valid image.', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      setState(() => _selectedImage = imageFile);

      final ClassificationResult? result = await _classificationService.classifyImage(
        imageFile.path,
      );

      setState(() {
        _result = result;
        _isLoading = false;
      });

      if (result != null) {
        _animationController.forward();
        _showSnackBar('Classification completed successfully!');
      } else {
        _showSnackBar('Could not classify the image. Please try another image.', isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error: ${e.toString()}', isError: true);
    }
  }

  void _clearResults() {
    setState(() {
      _selectedImage = null;
      _result = null;
    });
    _animationController.reset();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _classificationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'AI Image Classifier',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_isModelInitialized)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(
                                _isLoading ? Icons.hourglass_empty : Icons.error,
                                size: 48,
                                color: _isLoading 
                                    ? Theme.of(context).colorScheme.primary 
                                    : Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _statusMessage,
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    if (_isModelInitialized) ...[
                      ImageDisplayCard(
                        imageFile: _selectedImage,
                        animation: _fadeAnimation,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      if (_result != null)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: ClassificationResultCard(result: _result!),
                        ),
                      
                      const SizedBox(height: 24),
                      
                      Row(
                        children: [
                          Expanded(
                            child: ActionButton(
                              icon: Icons.camera_alt,
                              label: 'Take Photo',
                              onPressed: () => _pickAndClassifyImage(ImageSourceType.camera),
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.secondary,
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ActionButton(
                              icon: Icons.photo_library,
                              label: 'Gallery',
                              onPressed: () => _pickAndClassifyImage(ImageSourceType.gallery),
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.secondary,
                                  Theme.of(context).colorScheme.tertiary,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      if (_selectedImage != null) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _clearResults,
                            icon: const Icon(Icons.clear),
                            label: const Text('Clear Results'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}