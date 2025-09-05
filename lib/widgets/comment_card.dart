import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snapshare/core/theme.dart';
import 'package:timeago/timeago.dart' as ta;

class CommentCard extends StatefulWidget {
  final Map<String, dynamic> snap;

  const CommentCard({super.key, required this.snap});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: const AssetImage('assets/profile_icon.jpg'),
            foregroundImage: widget.snap['profImage'] != null
                ? NetworkImage(widget.snap['profImage'])
                : const AssetImage('assets/profile_icon.jpg'),
            radius: 18,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.snap['username'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        ta.format(widget.snap['datePublished'].toDate()),
                        style: GoogleFonts.signikaNegative(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.secondary
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(widget.snap['text']),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
