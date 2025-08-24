import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram/screens/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool isShowUsers = false;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _searchList = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: _searchController,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            labelStyle: TextStyle(color: Color(0xff8f8f8f)),
            hintText: 'Search',
            fillColor: Color(0xff121212),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: Divider.createBorderSide(context),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(
                color: Colors.white.withAlpha(153),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(color: Color(0xff3b3b3b), width: 1),
            ),
            filled: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
          ),
          onFieldSubmitted: (String _) {
            // setState(() {
            //   isShowUsers = true;
            // });
          },
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: _searchController,
        builder: (context, value, child) {
          return _searchController.text.isNotEmpty ? _usersList() : _posts();
        },
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> _usersList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: _searchController.text)
          .where('username', isLessThan: '${_searchController.text}\uf8ff')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _searchList = snapshot.data!.docs;
        }

        return ListView.builder(
          itemCount: _searchList.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/profile_icon.jpg'),
                foregroundImage: _searchList[index]['photoUrl'] != null
                    ? NetworkImage(_searchList[index]['photoUrl'])
                    : AssetImage('assets/profile_icon.jpg'),
              ),
              title: Text(_searchList[index]['username']),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfileScreen(uid: _searchList[index]['uid']),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Padding _posts() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: FutureBuilder(
        future: FirebaseFirestore.instance.collection('posts').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return MasonryGridView.builder(
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              return Image.network(
                '${snapshot.data!.docs[index]['postUrl']}',
              );
            },
          );
        },
      ),
    );
  }
}
