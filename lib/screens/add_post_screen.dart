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
  double _uploadProgress = 0.0;
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeInOut,
      ),
    );
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
      _uploadProgress = 0.0;
      _progressAnimationController.value = 0.0;
    });

    String res = await FirestoreMethods().uploadPost(
      description: _descriptionController.text,
      file: _file!,
      uid: uid,
      username: username,
      profImage: profImage,
      progressCallback: (progress) {
        // Animate to new progress value
        _progressAnimation = Tween<double>(
          begin: _progressAnimationController.value,
          end: progress,
        ).animate(
          CurvedAnimation(
            parent: _progressAnimationController,
            curve: Curves.easeInOut,
          ),
        );

        _progressAnimationController.forward(from: 0);

        setState(() {
          _uploadProgress = progress;
        });
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
  void dispose() {
    _progressAnimationController.dispose();
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
                onPressed: null,
                icon: Icon(Icons.arrow_back),
              ),
            ),
            body: Column(
              children: [
                if (_isLoading)
                  AnimatedBuilder(
                    animation: _progressAnimationController,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: _progressAnimation.value,
                        backgroundColor: Colors.grey[200],
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.link),
                        minHeight: 4.0,
                      );
                    },
                  ),
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
