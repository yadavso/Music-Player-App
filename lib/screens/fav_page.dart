import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

class FavPage extends StatefulWidget {
  FavPage({Key? key, required this.favList}) : super(key: key);
  List<SongInfo> favList;

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[50],
        elevation: 1,
        title: Text(
          'Favorites',
        ),
      ),
      body: widget.favList.isNotEmpty
          ? ListView.builder(
              itemCount: widget.favList.length,
              itemBuilder: (BuildContext context, index) => ListTile(
                    title: Text(widget.favList[index].title),
                    subtitle: Text(widget.favList[index].artist),
                  ))
          : Center(
              child: Text(
                'No Favorite songs',
                style: TextStyle(fontSize: 20),
              ),
            ),
    );
  }
}
