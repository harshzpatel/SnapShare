import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapshare/providers/user_provider.dart';
import 'package:snapshare/services/firestore_methods.dart';
import 'package:snapshare/core/theme.dart';
import 'package:snapshare/core/utils.dart';
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
    final User user = context.read<UserProvider>().getUser;

    if (!_didCache && user.photoUrl != null) {
      precacheImage(NetworkImage(user.photoUrl!), context);
      _didCache = true;
    }
  }

  void _animateToProgress(double targetProgress) {
    const updateInterval = Duration(milliseconds: 16);
    const animationDuration = Duration(milliseconds: 500);
    final startTime = DateTime.now();
    final startProgress = _currentDisplayProgress;

    void updateProgress() {
      if (!_isLoading) return;
      final elapsedTime = DateTime.now().difference(startTime);

      if (elapsedTime < animationDuration) {
        final t = elapsedTime.inMilliseconds / animationDuration.inMilliseconds;
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

  _selectImage(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      barrierColor: AppColors.background.withValues(alpha: 0.4),
      backgroundColor: AppColors.darkGrey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Create a post',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: const Icon(Icons.camera_alt_outlined),
                      title: const Text('Take a photo'),
                      onTap: () async {
                        Navigator.of(context).pop();
                        Uint8List? file = await pickImage(ImageSource.camera);
                        if (file != null) {
                          setState(() {
                            _file = file;
                          });
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library_outlined),
                      title: const Text('Choose from gallery'),
                      onTap: () async {
                        Navigator.of(context).pop();
                        Uint8List? file = await pickImage(ImageSource.gallery);
                        if (file != null) {
                          setState(() {
                            _file = file;
                          });
                        }
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.close),
                      title: const Text('Cancel'),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
        _animateToProgress(progress);
      },
    );

    _descriptionController.clear();

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
    final User user = Provider.of<UserProvider>(context).getUser;

    return _file == null ? _selectPhoto(context) : _upLoadPost(user);
  }

  Scaffold _selectPhoto(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post'), centerTitle: false),
      body: Center(
        child: InkWell(
          onTap: () => _selectImage(context),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.upload_file_outlined,
                  size: 50,
                  color: AppColors.primary,
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
    );
  }

  Scaffold _upLoadPost(User user) {
    return Scaffold(
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
      ),
      body: _postPreview(user),
    );
  }

  Widget _postPreview(User user) {
    final mq = MediaQuery.of(context);

    return SafeArea(
      child: Column(
        children: [
          _isLoading
              ? LinearProgressIndicator(
                  value: _currentDisplayProgress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.link),
                  minHeight: 4.0,
                )
              : const SizedBox(height: 4),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: mq.size.height * 0.35,
                  maxWidth: mq.size.width * 0.95,
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: MemoryImage(_file!),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.background.withValues(alpha: .1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: mq.viewInsets.bottom + 16,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : const AssetImage('assets/profile_icon.jpg')
                            as ImageProvider,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Write a caption...',
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    maxLines: null,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: AppColors.link),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _postImage(
                      uid: user.uid,
                      username: user.username,
                      profImage: user.photoUrl,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
