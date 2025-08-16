import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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
          decoration: InputDecoration(
            // label: Text(hintText),
            labelStyle: TextStyle(color: Color(0xff8f8f8f)),
            hintText: 'Search',
            // hintStyle: TextStyle(color: Color(0xff8f8f8f)),
            fillColor: Color(0xff121212),
            border: OutlineInputBorder(
              borderSide: Divider.createBorderSide(context),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: .6),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xff3b3b3b), width: 1),
            ),
            filled: true,
            contentPadding: EdgeInsets.all(8),
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
          return _searchController.text.isNotEmpty
              ? StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where(
                        'username',
                        isGreaterThanOrEqualTo: _searchController.text,
                      )
                      .where(
                        'username',
                        isLessThan: '${_searchController.text}\uf8ff',
                      )
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
                            backgroundImage:
                                _searchList[index]['photoUrl'] != null
                                ? NetworkImage(_searchList[index]['photoUrl'])
                                : AssetImage('assets/profile_icon.jpg'),
                          ),
                          title: Text(_searchList[index]['username']),
                          onTap: () {
                            // Navigator.of(context).push(
                            //   MaterialPageRoute(
                            //     builder: (context) => ProfileScreen(
                            //       uid: snapshot.data!.docs[index]['uid'],
                            //     ),
                            //   ),
                            // );
                          },
                        );
                      },
                    );
                  },
                )
              : FutureBuilder(
                  future: FirebaseFirestore.instance.collection('posts').get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    return MasonryGridView.builder(
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      gridDelegate:
                          SliverSimpleGridDelegateWithFixedCrossAxisCount(
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
                );
        },
      ),
    );
  }
}
