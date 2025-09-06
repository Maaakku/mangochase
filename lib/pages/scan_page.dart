import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/classification_service.dart';
import '../services/image_service.dart';

// Main ScanPage Widget
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final ClassificationService _classificationService = ClassificationService();
  final ImageService _imageService = ImageService();
  
  File? _selectedImage;
  ClassificationResult? _result;
  bool _isLoading = false;
  bool _isModelInitialized = false;
  String _statusMessage = 'Initializing AI Model...';
  
  late AnimationController _imageAnimationController;
  late AnimationController _resultAnimationController;
  late Animation<double> _imageAnimation;
  late Animation<double> _resultAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeModel();
  }

  void _initializeAnimations() {
    _imageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _resultAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _imageAnimation = CurvedAnimation(
      parent: _imageAnimationController,
      curve: Curves.easeOutCubic,
    );
    
    _resultAnimation = CurvedAnimation(
      parent: _resultAnimationController,
      curve: Curves.elasticOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _resultAnimationController,
      curve: Curves.easeOutCubic,
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
    } catch (e) {
      setState(() {
        _isModelInitialized = false;
        _statusMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _imageAnimationController.dispose();
    _resultAnimationController.dispose();
    _classificationService.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (!_isModelInitialized) {
      _showErrorSnackBar('AI Model not ready yet. Please wait.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final File? imageFile = await _imageService.pickImage(
        sourceType: source == ImageSource.camera 
            ? ImageSourceType.camera 
            : ImageSourceType.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (imageFile == null) {
        setState(() => _isLoading = false);
        return;
      }

      if (!await _imageService.isImageValid(imageFile)) {
        _showErrorSnackBar('Invalid image file. Please select a valid image.');
        setState(() => _isLoading = false);
        return;
      }

      setState(() {
        _selectedImage = imageFile;
        _result = null;
      });
      
      _imageAnimationController.forward();
      _resultAnimationController.reset();

      // Auto-classify the image
      await _classifyImage();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _classifyImage() async {
    if (_selectedImage == null) return;

    try {
      final result = await _classificationService.classifyImage(_selectedImage!.path);
      setState(() {
        _result = result;
        _isLoading = false;
      });
      
      if (result != null) {
        _resultAnimationController.forward();
        _showSuccessSnackBar('Classification completed successfully!');
      } else {
        _showErrorSnackBar('Could not classify the image. Please try another image.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Classification failed: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _resetScan() {
    setState(() {
      _selectedImage = null;
      _result = null;
    });
    _imageAnimationController.reset();
    _resultAnimationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Image Scanner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          if (_selectedImage != null || _result != null)
            IconButton(
              onPressed: _resetScan,
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset',
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Analyzing image...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Model Status Section
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
                // Image Display Section
                ImageDisplayCard(
                  imageFile: _selectedImage,
                  animation: _imageAnimation,
                ),
                
                const SizedBox(height: 24),
                
                // Action Buttons Section
                _buildActionButtons(),
                
                const SizedBox(height: 24),
                
                // Classification Result Section
                if (_result != null)
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _resultAnimation,
                      child: ScaleTransition(
                        scale: _resultAnimation,
                        child: ClassificationResultCard(result: _result!),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Image Selection Buttons
        Row(
          children: [
            Expanded(
              child: ActionButton(
                icon: Icons.camera_alt,
                label: 'Camera',
                onPressed: () => _pickImage(ImageSource.camera),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primaryContainer,
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ActionButton(
                icon: Icons.photo_library,
                label: 'Gallery',
                onPressed: () => _pickImage(ImageSource.gallery),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// LoadingOverlay Widget
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String message;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message = 'Loading...',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ImageDisplayCard Widget
class ImageDisplayCard extends StatelessWidget {
  final File? imageFile;
  final Animation<double>? animation;

  const ImageDisplayCard({
    super.key,
    this.imageFile,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: imageFile != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(
                imageFile!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No image selected',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap camera or gallery to get started',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
    );

    if (animation != null && imageFile != null) {
      return Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: FadeTransition(
          opacity: animation!,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation!, curve: Curves.easeOutBack),
            ),
            child: content,
          ),
        ),
      );
    }

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: content,
    );
  }
}

// ClassificationResultCard Widget
class ClassificationResultCard extends StatelessWidget {
  final ClassificationResult result;

  const ClassificationResultCard({
    super.key,
    required this.result,
  });

  Color _getConfidenceColor(BuildContext context, double confidence) {
    if (confidence >= 80) {
      return Colors.green;
    } else if (confidence >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  IconData _getConfidenceIcon(double confidence) {
    if (confidence >= 80) {
      return Icons.check_circle;
    } else if (confidence >= 60) {
      return Icons.warning;
    } else {
      return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final confidence = result.confidence;
    final confidenceColor = _getConfidenceColor(context, confidence);
    final confidenceIcon = _getConfidenceIcon(confidence);

    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: confidenceColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      confidenceIcon,
                      color: confidenceColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Classification Result',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'AI Analysis Complete',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: confidenceColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Detected Object:',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: confidenceColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${confidence.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: confidenceColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        result.label,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Confidence Progress Bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Confidence Level:',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: confidence / 100,
                          backgroundColor: Colors.grey.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(confidenceColor),
                          minHeight: 8,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Analyzed at ${result.timestamp.hour.toString().padLeft(2, '0')}:${result.timestamp.minute.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'AI Powered',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ActionButton Widget
class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Gradient? gradient;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}