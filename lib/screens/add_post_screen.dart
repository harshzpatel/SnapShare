import 'package:flutter/material.dart';
import 'package:instagram/theme/theme.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  // _selectImage(BuildContext context) async {
  //   return showDialog(context: context, builder: (context) => SimpleDialog(
  //     title: Text('Create a post'),,
  //       children: [
  //         SimpleDialogOption(
  //       padding: EdgeInsets.all(20),
  //     child: Text('Take a photo'),
  //   )
  //     ],
  //   ));
  // }

  @override
  Widget build(BuildContext context) {
    // return Center(
    //   child: IconButton(onPressed: () {}, icon: Icon(Icons.upload)),
    // );

    return Scaffold(
      appBar: AppBar(
        title: Text('Post to'),
        actions: [
          TextButton(
            onPressed: null,
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
        leading: IconButton(onPressed: null, icon: Icon(Icons.arrow_back)),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQzHMDlwRCHOHZP_tX7jRYNxV8W8MpNEog45w&s',
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .45,
                child: TextField(
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
                        image: NetworkImage(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQzHMDlwRCHOHZP_tX7jRYNxV8W8MpNEog45w&s',
                        ),
                        fit: BoxFit.fill,
                        alignment: FractionalOffset.topCenter
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
