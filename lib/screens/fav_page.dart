import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:music_player/models/get_fav_songs_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../resources/my_var.dart';

class FavPage extends StatefulWidget {
  const FavPage(
      {Key? key,
      required this.favList,
      required this.songs,
      required this.miniplayerController})
      : super(key: key);
  final List<SongInfo> favList;
  final List<SongInfo> songs;
  final MiniplayerController miniplayerController;

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  List<String> stringFavList1 = [];
  var responseModel = GetFavSongs();

  List<GetFavSongs> temp1 = [];

  double? screenHeight;

  double? screenWidth;
  getFavListFromSharedPref() async {
    temp1.clear();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    stringFavList1 = prefs.getStringList('favList') ?? [];
    setState(() {});

    // responseModel = GetFavSongs.fromJson(json.decode(stringFavList1));
    //responseModel = GetFavSongs.fromJson(json.decode(stringFavList1[0]));
    stringFavList1.forEach((element) {
      temp1.add(GetFavSongs.fromJson(json.decode(element)));
    });
    setState(() {});
    // log('${temp1.first.title}');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFavListFromSharedPref();
  }

  int getSongIndexFromId(String id) {
    var idx = widget.songs.indexWhere((element) => element.id == id);
    return idx;
  }

  saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt('songIndex', getSongIndexFromId(MyVar.selectedSongId));
  }

  getDataFromSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    MyVar.savedIndex = prefs.getInt('songIndex') ?? 0;
    setState(() {});
    // log('get data : $savedIndex');
  }

  Future<Uint8List> metaData(String path) async {
    final metadata = await MetadataRetriever.fromFile(File(path));

    return metadata.albumArt!;
  }

  Widget thumbnail(String id) {
    int idx = widget.songs.indexWhere((element) => element.id == id);
    return FutureBuilder<Uint8List>(
      future: metaData(widget.songs[idx].filePath),
      builder: (context, snapshot) {
        return snapshot.hasData
            ? Image.memory(
                snapshot.data!,
                scale: screenWidth! * 0.01,
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/images/music.png',
              );
      },
    );
  }

  void favListOnTapFunction(String id) async {
    setState(() {
      MyVar.selectedSongIndex = getSongIndexFromId(id);
      MyVar.selectedSongId = id;
    });
    await saveData();
    await getDataFromSharedPref();
    //  log('${MyVar.selectedSongId}');
    setState(() {});
    Navigator.pop(context);

    widget.miniplayerController.animateToHeight(
        state: PanelState.MAX, duration: const Duration(milliseconds: 600));
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[50],
        elevation: 1,
        title: Text(
          'Favorites',
        ),
        actions: [
          TextButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                stringFavList1.clear();
                setState(() {});
                prefs.setStringList('favList', stringFavList1);
                getFavListFromSharedPref();
              },
              child: Text(
                'Clear all',
                style: TextStyle(
                    color: Colors.deepPurple, fontSize: screenWidth! * 0.04),
              ))
        ],
      ),
      body: temp1.isNotEmpty
          ? ListView.builder(
              itemCount: temp1.length,
              itemBuilder: (BuildContext context, index) => Padding(
                padding: EdgeInsets.only(top: screenHeight! * 0.00),
                child: InkWell(
                  onTap: () {
                    favListOnTapFunction(temp1[index].id!);
                  },
                  child: ListTile(
                    leading: thumbnail(temp1[index].id!),
                    title: Text(
                      temp1[index].title!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          color: temp1[index].id ==
                                  widget.songs[MyVar.savedIndex].id
                              ? Colors.purple.shade800
                              : null),
                    ),
                    subtitle: temp1[index].artist != '<unknown>'
                        ? Text(
                            temp1[index].artist! + ' | ' + temp1[index].album!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                color: temp1[index].id ==
                                        widget.songs[MyVar.savedIndex].id
                                    ? Colors.purple.shade800
                                    : null),
                          )
                        : Text('Unknown Artist | Unknown Album'),
                    trailing:
                        temp1[index].id == widget.songs[MyVar.savedIndex].id
                            ? Icon(
                                Icons.bar_chart,
                                color: Colors.purple.shade800,
                              )
                            : const Icon(
                                Icons.add,
                                color: Colors.transparent,
                              ),
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                'No Favorite songs',
                style: TextStyle(fontSize: 20),
              ),
            ),
    );
  }
}
