import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/providers/user_provider.dart';
import 'package:instagram/resources/firestore_methods.dart';
import 'package:instagram/theme/theme.dart';
import 'package:instagram/utils/utils.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  double _currentDisplayProgress = 0.0;
  bool _didCache = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final User? user = context.read<UserProvider>().getUser;

    if (user != null && !_didCache && user.photoUrl != null) {
      precacheImage(NetworkImage(user.photoUrl!), context);
      _didCache = true;
    }
  }

  // Smooth animation for the progress bar
  void _animateToProgress(double targetProgress) {
    const updateInterval = Duration(milliseconds: 16); // ~60fps
    const animationDuration = Duration(milliseconds: 500);
    final startTime = DateTime.now();
    final startProgress = _currentDisplayProgress;

    void updateProgress() {
      if (!_isLoading) return; // Stop animation if loading is cancelled
      final elapsedTime = DateTime.now().difference(startTime);

      if (elapsedTime < animationDuration) {
        final t =
            elapsedTime.inMilliseconds / animationDuration.inMilliseconds;
        setState(() {
          _currentDisplayProgress =
              startProgress + (targetProgress - startProgress) * t;
        });
        Future.delayed(updateInterval, updateProgress);
      } else {
        setState(() {
          _currentDisplayProgress = targetProgress;
        });
      }
    }
    updateProgress();
  }

  _selectImage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Create a post'),
        children: [
          SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            onPressed: () async {
              Navigator.of(context).pop();
              Uint8List? file = await pickImage(ImageSource.camera);
              if (file != null) {
                setState(() {
                  _file = file;
                });
              }
            },
            child: const Text('Take a photo'),
          ),
          SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            onPressed: () async {
              Navigator.of(context).pop();
              Uint8List? file = await pickImage(ImageSource.gallery);
              if (file != null) {
                setState(() {
                  _file = file;
                });
              }
            },
            child: const Text('Choose from gallery'),
          ),
          SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _postImage({
    required String uid,
    required String username,
    required String? profImage,
  }) async {
    setState(() {
      _isLoading = true;
      _currentDisplayProgress = 0.0;
    });

    String res = await FirestoreMethods().uploadPost(
      description: _descriptionController.text,
      file: _file!,
      uid: uid,
      username: username,
      profImage: profImage,
      progressCallback: (progress) {
        // Calling the smooth animation method
        _animateToProgress(progress);
      },
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (res == 'success') {
      showSnackBar('Posted!', context);
      setState(() {
        _file = null;
      });
    } else {
      showSnackBar(res, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser;

    if (user == null) {
      // Handles case where user data is still loading
      return const Center(child: CircularProgressIndicator());
    }

    return _file == null
    // UPLOAD SCREEN VIEW
        ? Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        centerTitle: false,
      ),
      body: Center(
        child: InkWell(
          onTap: () => _selectImage(context),
          borderRadius: BorderRadius.circular(24), // Rounded ripple effect
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Keep the column compact
              children: [
                Icon(
                  Icons.upload_file_outlined,
                  size: 50,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select a Photo to Post',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    )
    // POSTING SCREEN VIEW
        : Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            setState(() {
              _file = null;
            });
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          TextButton(
            onPressed: () => _postImage(
              uid: user.uid,
              username: user.username,
              profImage: user.photoUrl,
            ),
            child: Text(
              'Post',
              style: TextStyle(
                color: AppColors.link,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _isLoading
                ? LinearProgressIndicator(
              value: _currentDisplayProgress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.link,
              ),
              minHeight: 4.0,
            )
                : const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : const AssetImage(
                            'assets/profile_icon.jpg')
                        as ImageProvider,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            hintText: 'Write a caption...',
                            border: InputBorder.none,
                          ),
                          maxLines: 4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: MemoryImage(_file!),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}