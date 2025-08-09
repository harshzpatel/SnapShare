import 'package:flutter/material.dart';
import 'package:instagram/theme/theme.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key});

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
                      '1000 likes',
                      // '${widget.snap['likes'].length} likes',
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
                          text: 'username',
                          // text: widget.snap['username'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' description',
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
                      'View all 50 comments',
                      // 'View all $commentLen comments',
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
                    '09/02/2011'
                    // DateFormat.yMMMd()
                    //     .format(widget.snap['datePublished'].toDate()),
                    // style: const TextStyle(
                    //   color: secondaryColor,
                    // ),
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
        'https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW1hZ2V8ZW58MHx8MHx8fDA%3D',
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
              'https://yt3.ggpht.com/yti/ANjgQV8sJ3Ji-ggJxkWTzwW6qwsSQQiARYU9gobaM2O6HUflT6hB=s88-c-k-c0x00ffffff-no-rj',
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
                    'username',
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
