// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import '../services/classification_service.dart';


// class ScanPage extends StatefulWidget {
//   const ScanPage({super.key});

//   @override
//   State<ScanPage> createState() => _ScanPageState();
// }

// class _ScanPageState extends State<ScanPage>
//     with TickerProviderStateMixin {
//   final ImagePicker _picker = ImagePicker();
//   final ClassificationService _classificationService = ClassificationService();
  
//   File? _selectedImage;
//   ClassificationResult? _result;
//   bool _isLoading = false;
  
//   late AnimationController _imageAnimationController;
//   late AnimationController _resultAnimationController;
//   late Animation<double> _imageAnimation;
//   late Animation<double> _resultAnimation;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//   }

//   void _initializeAnimations() {
//     _imageAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
    
//     _resultAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );

//     _imageAnimation = CurvedAnimation(
//       parent: _imageAnimationController,
//       curve: Curves.easeOutCubic,
//     );
    
//     _resultAnimation = CurvedAnimation(
//       parent: _resultAnimationController,
//       curve: Curves.elasticOut,
//     );
    
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _resultAnimationController,
//       curve: Curves.easeOutCubic,
//     ));
//   }

//   @override
//   void dispose() {
//     _imageAnimationController.dispose();
//     _resultAnimationController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final XFile? image = await _picker.pickImage(
//         source: source,
//         maxWidth: 1024,
//         maxHeight: 1024,
//         imageQuality: 85,
//       );

//       if (image != null) {
//         setState(() {
//           _selectedImage = File(image.path);
//           _result = null;
//         });
//         _imageAnimationController.forward();
//         _resultAnimationController.reset();
//       }
//     } catch (e) {
//       _showErrorSnackBar('Failed to pick image: $e');
//     }
//   }

//   Future<void> _classifyImage() async {
//     if (_selectedImage == null) {
//       _showErrorSnackBar('Please select an image first');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final result = await _classificationService.classifyImage(_selectedImage!);
//       setState(() {
//         _result = result;
//         _isLoading = false;
//       });
//       _resultAnimationController.forward();
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       _showErrorSnackBar('Classification failed: $e');
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Theme.of(context).colorScheme.error,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }

//   void _resetScan() {
//     setState(() {
//       _selectedImage = null;
//       _result = null;
//     });
//     _imageAnimationController.reset();
//     _resultAnimationController.reset();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'AI Image Scanner',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Theme.of(context).colorScheme.surface,
//         actions: [
//           if (_selectedImage != null || _result != null)
//             IconButton(
//               onPressed: _resetScan,
//               icon: const Icon(Icons.refresh),
//               tooltip: 'Reset',
//             ),
//         ],
//       ),
//       body: LoadingOverlay(
//         isLoading: _isLoading,
//         message: 'Analyzing image...',
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Image Display Section
//               ImageDisplayCard(
//                 imageFile: _selectedImage,
//                 animation: _imageAnimation,
//               ),
              
//               const SizedBox(height: 24),
              
//               // Action Buttons Section
//               _buildActionButtons(),
              
//               const SizedBox(height: 24),
              
//               // Classification Result Section
//               if (_result != null)
//                 SlideTransition(
//                   position: _slideAnimation,
//                   child: FadeTransition(
//                     opacity: _resultAnimation,
//                     child: ScaleTransition(
//                       scale: _resultAnimation,
//                       child: ClassificationResultCard(result: _result!),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButtons() {
//     return Column(
//       children: [
//         // Image Selection Buttons
//         Row(
//           children: [
//             Expanded(
//               child: ActionButton(
//                 icon: Icons.camera_alt,
//                 label: 'Camera',
//                 onPressed: () => _pickImage(ImageSource.camera),
//                 gradient: LinearGradient(
//                   colors: [
//                     Theme.of(context).colorScheme.primary,
//                     Theme.of(context).colorScheme.primaryContainer,
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: ActionButton(
//                 icon: Icons.photo_library,
//                 label: 'Gallery',
//                 onPressed: () => _pickImage(ImageSource.gallery),
//                 gradient: LinearGradient(
//                   colors: [
//                     Theme.of(context).colorScheme.secondary,
//                     Theme.of(context).colorScheme.secondaryContainer,
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
        
//         const SizedBox(height: 16),
        
//         // Classify Button
//         if (_selectedImage != null)
//           ActionButton(
//             icon: Icons.psychology,
//             label: 'Classify Image',
//             onPressed: _classifyImage,
//             gradient: LinearGradient(
//               colors: [
//                 Theme.of(context).colorScheme.tertiary,
//                 Theme.of(context).colorScheme.tertiaryContainer,
//               ],
//             ),
//           ),
//       ],
//     );
//   }
// }