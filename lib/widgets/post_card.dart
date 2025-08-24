import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram/screens/comment_screen.dart';
import 'package:instagram/theme/theme.dart';
import 'package:instagram/widgets/like_animation.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as ta;
import 'package:transparent_image/transparent_image.dart';

import '../models/user.dart' as model;
import '../providers/user_provider.dart';
import '../resources/firestore_methods.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> snap;

  const PostCard({super.key, required this.snap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  bool isSmallLikeAnimating = false;
  int _comments = 0;

  void _getCommentsCount() async {
    try {
      var snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .count()
          .get();

      if (!mounted) return;

      setState(() {
        _comments = snap.count ?? 0;
      });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getCommentsCount();
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          _header(context),
          _image(context, user),
          _buttons(user),
          _postDetails(context),
        ],
      ),
    );
  }

  Container _postDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: RichText(
              text: TextSpan(
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                children: [
                  TextSpan(
                    text: widget.snap['username'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' ${widget.snap['description']}'),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              ta.format(widget.snap['datePublished'].toDate()),
              style: GoogleFonts.signikaNegative(
                textStyle: Theme.of(context).textTheme.bodyMedium,
                color: AppColors.secondary,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row _buttons(model.User user) {
    final bool isLiked = widget.snap['likes'].contains(user.uid);

    return Row(
      children: [
        LikeAnimation(
          isAnimating: isSmallLikeAnimating,
          onEnd: () {
            setState(() {
              isSmallLikeAnimating = false;
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: SizedBox(
              width: 24,
              // height: 24,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                onPressed: () async {
                  if (user.uid == 'loading...') return;

                  setState(() {
                    isSmallLikeAnimating = true;
                  });

                  await FirestoreMethods().likePost(
                    postId: widget.snap['postId'],
                    uid: user.uid,
                    likes: widget.snap['likes'],
                  );
                },
                icon: SvgPicture.asset(
                  isLiked ? 'assets/heart_fill.svg' : 'assets/heart.svg',
                  colorFilter: ColorFilter.mode(
                    isLiked ? Colors.red : AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 4),
        Text(
          '${widget.snap['likes'].length} Likes',
          style: GoogleFonts.signikaNegative(
            textStyle: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        SizedBox(width: 4),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CommentScreen(snap: widget.snap),
              ),
            ),
            borderRadius: BorderRadius.circular(16.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 8.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon(Icons.comment_outlined, color: AppColors.primary),
                  SvgPicture.asset(
                    'assets/comment_icon.svg',
                    colorFilter: ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_comments Comments',
                    style: GoogleFonts.signikaNegative(
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  GestureDetector _image(BuildContext context, model.User user) {
    return GestureDetector(
      onDoubleTap: () async {
        if (user.uid == 'loading...') return;

        await FirestoreMethods().likePost(
          postId: widget.snap['postId'],
          uid: user.uid,
          likes: widget.snap['likes'],
        );
        setState(() {
          isLikeAnimating = true;
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: widget.snap['postUrl'],
              fit: BoxFit.cover,
              fadeInDuration: Duration(milliseconds: 200),
              fadeOutDuration: Duration(milliseconds: 100),
              imageErrorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.secondary.withValues(alpha: .1),
                  child: Center(
                    child: Icon(
                      Icons.error_outline,
                      color: AppColors.secondary,
                      size: 50,
                    ),
                  ),
                );
              },
            ),
          ),
          AnimatedOpacity(
            opacity: isLikeAnimating ? 1 : 0,
            duration: Duration(milliseconds: 200),
            child: LikeAnimation(
              isAnimating: isLikeAnimating,
              onEnd: () {
                setState(() {
                  isLikeAnimating = false;
                });
              },
              child: SvgPicture.asset(
                'assets/heart_fill.svg',
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                width: 120,
                height: 120,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _header(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 4, bottom: 12, left: 16, right: 0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage('assets/profile_icon.jpg'),
            foregroundImage: widget.snap['profImage'] != null
                ? NetworkImage(widget.snap['profImage'])
                : AssetImage('assets/profile_icon.jpg'),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.snap['username'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          if (FirebaseAuth.instance.currentUser!.uid == widget.snap['uid'])
            SizedBox(
              height: 32,
              child: IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      title: Text('Delete Post'),
                      content: Text(
                        'Are you sure you want to delete this post?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await FirestoreMethods().deletePost(
                              widget.snap['postId'],
                            );
                          },
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(Icons.more_vert, color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
