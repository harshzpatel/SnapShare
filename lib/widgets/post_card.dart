import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/comment_screen.dart';
import 'package:instagram/theme/theme.dart';
import 'package:instagram/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../models/user.dart';
import '../providers/user_provider.dart';
import '../resources/firestore_methods.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> snap;
  final int postIndex;

  const PostCard({super.key, required this.snap, required this.postIndex});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  bool isSmallLikeAnimating = false;
  int _comments = 0;
  bool _shouldLoadImage = false;

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
    final User user = Provider.of<UserProvider>(context).getUser;

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
          DefaultTextStyle(
            style: Theme.of(
              context,
            ).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w800),
            child: Text(
              '${widget.snap['likes'].length} likes',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 8),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: AppColors.primary),
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
          InkWell(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'View all $_comments comments',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.secondary,
                ),
              ),
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CommentScreen(snap: widget.snap),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              DateFormat.yMMMd().format(widget.snap['datePublished'].toDate()),
              style: const TextStyle(color: AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }

  Row _buttons(User? user) {
    return Row(
      children: [
        LikeAnimation(
          isAnimating: isSmallLikeAnimating,
          onEnd: () {
            setState(() {
              isSmallLikeAnimating = false;
            });
          },
          child: IconButton(
            onPressed: () async {
              if (user == null) return;

              setState(() {
                isSmallLikeAnimating = true;
              });

              await FirestoreMethods().likePost(
                postId: widget.snap['postId'],
                uid: user.uid,
                likes: widget.snap['likes'],
              );
            },
            icon: Icon(
              user != null && widget.snap['likes'].contains(user.uid)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: user != null && widget.snap['likes'].contains(user.uid)
                  ? Colors.red
                  : AppColors.primary,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CommentScreen(snap: widget.snap),
            ),
          ),
          icon: Icon(Icons.comment_outlined, color: AppColors.primary),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.send, color: AppColors.primary),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.bookmark_border, color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  GestureDetector _image(BuildContext context, User? user) {
    return GestureDetector(
      onDoubleTap: () async {
        if (user == null) return;

        await FirestoreMethods().likePost(
          postId: widget.snap['postId'],
          uid: user.uid,
          likes: widget.snap['likes'],
        );
        setState(() {
          isLikeAnimating = true;
        });
      },
      child: VisibilityDetector(
        key: Key('post-image-${widget.postIndex}'),
        onVisibilityChanged: (VisibilityInfo info) {
          if (info.visibleFraction > 0.1 && !_shouldLoadImage) {
            setState(() {
              _shouldLoadImage = true;
            });
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              child: _shouldLoadImage
                  ? FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: widget.snap['postUrl'],
                      fit: BoxFit.cover,
                      fadeInDuration: Duration(milliseconds: 100),
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
                    )
                  : Container(
                      color: AppColors.secondary.withValues(alpha: .05),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.secondary.withValues(alpha: .3),
                          strokeWidth: 2,
                        ),
                      ),
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
                child: Icon(Icons.favorite, color: Colors.white, size: 120),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _header(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 16,
      ).copyWith(right: 0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(widget.snap['profImage']),
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
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shrinkWrap: true,
                    children: ['Delete']
                        .map(
                          (e) => InkWell(
                            onTap: null,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              child: Text(e),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              );
            },
            icon: Icon(Icons.more_vert, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
