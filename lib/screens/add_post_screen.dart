import 'package:flutter/foundation.dart';
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

class _AddPostScreenState extends State<AddPostScreen>
    with SingleTickerProviderStateMixin {
  bool _didCache = false;
  Uint8List? _file;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  double _currentDisplayProgress = 0.0;

  @override
  void initState() {
    super.initState();
  }

  _selectImage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Create a post'),
        children: [
          SimpleDialogOption(
            padding: EdgeInsets.all(20),
            onPressed: () async {
              Navigator.of(context).pop();
              Uint8List file = await pickImage(ImageSource.camera);
              setState(() {
                _file = file;
              });
            },
            child: Text('Take a photo'),
          ),
          SimpleDialogOption(
            padding: EdgeInsets.all(20),
            onPressed: () async {
              Navigator.of(context).pop();
              Uint8List file = await pickImage(ImageSource.gallery);
              setState(() {
                _file = file;
              });
            },
            child: Text('Choose from gallery'),
          ),
          SimpleDialogOption(
            padding: EdgeInsets.all(20),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
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

  void _animateToProgress(double targetProgress) {
    // Gradually update the displayed progress in small increments
    const updateInterval = Duration(milliseconds: 16); // ~60fps
    const animationDuration = Duration(milliseconds: 500);
    final startTime = DateTime.now();
    final startProgress = _currentDisplayProgress;

    void updateProgress() {
      final elapsedTime = DateTime.now().difference(startTime);

      if (elapsedTime < animationDuration) {
        final t = elapsedTime.inMilliseconds / animationDuration.inMilliseconds;

        // Use a linear interpolation for smooth progression
        setState(() {
          _currentDisplayProgress =
              startProgress + (targetProgress - startProgress) * t;
        });

        // Schedule next update
        Future.delayed(updateInterval, updateProgress);
      } else {
        // Ensure we exactly reach the target
        setState(() {
          _currentDisplayProgress = targetProgress;
        });
      }
    }

    // Start the animation
    updateProgress();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final User? user = context.read<UserProvider>().getUser;

    if (!_didCache && user != null && user.photoUrl != null) {
      precacheImage(NetworkImage(user.photoUrl!), context);
      _didCache = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser;

    return _file == null
        ? Center(
            child: IconButton(
              onPressed: () => _selectImage(context),
              icon: Icon(Icons.upload),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text('Post to'),
              actions: [
                TextButton(
                  onPressed: () => _postImage(
                    uid: user!.uid,
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
              leading: IconButton(
                onPressed: () {
                  setState(() {
                    _file = null;
                  });
                },
                icon: Icon(Icons.arrow_back),
              ),
            ),
            body: Column(
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
                    : SizedBox(height: 4),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: user != null && user.photoUrl != null
                          ? NetworkImage(user.photoUrl!)
                          : AssetImage('assets/profile_icon.jpg'),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .45,
                      child: TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: 'Write a caption...',
                          border: InputBorder.none,
                        ),
                        maxLines: 8,
                      ),
                    ),
                    SizedBox(
                      height: 45,
                      width: 45,
                      child: AspectRatio(
                        aspectRatio: 487 / 451,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: MemoryImage(_file!),
                              fit: BoxFit.fill,
                              alignment: FractionalOffset.topCenter,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Divider(),
                  ],
                ),
              ],
            ),
          );
  }
}
