import 'package:flutter/material.dart';
import 'package:instagram/theme/theme.dart';
import 'package:intl/intl.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> snap;

  const PostCard({super.key, required this.snap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          _header(context),
          _image(context),
          _buttons(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DefaultTextStyle(
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontWeight: FontWeight.w800),
                    child: Text(
                      '${snap['likes'].length} likes',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: AppColors.primary),
                      children: [
                        TextSpan(
                          text: snap['username'],
                          // text: widget.snap['username'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' ${snap['description']}',
                          // text: ' ${widget.snap['description']}',
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      // 'View all ${snap['comments'].length} comments',

                      'View all 69 comments',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  // onTap: () => Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => CommentsScreen(
                  //       postId: widget.snap['postId'].toString(),
                  //     ),
                  //   ),
                  // ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    DateFormat.yMMMd().format(snap['datePublished'].toDate()),
                    style: const TextStyle(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Row _buttons() {
    return Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.favorite, color: Colors.red),
        ),
        IconButton(
          onPressed: () {},
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

  SizedBox _image(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.35,
      width: double.infinity,
      child: Image.network(
        snap['postUrl'],
        fit: BoxFit.cover,
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
            backgroundImage: NetworkImage(
              snap['profImage'],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    snap['username'],
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
