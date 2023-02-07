import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
//import 'package:just_audio/just_audio.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:music_player/resources/my_var.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/songs_info_model.dart';

class MusicPlayScreen extends StatefulWidget {
  MusicPlayScreen({
    Key? key,
    required this.player,
    required this.favList,
    required this.playPauseButtonAnimationController,
    required this.songs,
  }) : super(key: key);

  AudioPlayer player;
  List<SongInfo> songs;
  List<SongInfo> favList;

  AnimationController playPauseButtonAnimationController;

  @override
  State<MusicPlayScreen> createState() => _MusicPlayScreenState();
}

class _MusicPlayScreenState extends State<MusicPlayScreen>
    with TickerProviderStateMixin {
  final audioQuery = FlutterAudioQuery();
  // late AnimationController _playPauseButtonAnimationController;

  double? screenHeight;
  double? screenWidth;
  // bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  Uint8List? thumbnail;
  bool favorite = false;
  late int idx;

  late SongsInfoModel songsInfoModel;

  @override
  void initState() {
    // TODO: implement initState
    songsInfoModel = SongsInfoModel();

    playMusic();

    widget.player.onPlayerStateChanged.listen((state) {
      setState(() {
        MyVar.isPlaying = state == PlayerState.playing;
      });
    });
    widget.player.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });
    widget.player.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
    widget.player.onPlayerComplete.listen((complete) {
      widget.player.stop();
      MyVar.isPlaying = false;
    });

    // data = player.audioCache.loadedFiles;

    super.initState();
  }

  playMusic() async {
    var tempIdx = widget.songs
        .indexWhere((element) => element.id == MyVar.selectedSongId);
    if (tempIdx == -1) {
      setState(() {
        idx = MyVar.savedIndex!;
      });
    } else {
      setState(() {
        idx = tempIdx;
      });
    }

    var source = widget.songs[idx].filePath;
    await widget.player.setSourceDeviceFile(source);
    MyVar.isPlaying = true;
    widget.playPauseButtonAnimationController.forward();
    widget.player.resume();
    setState(() {});
    await metaData();
  }

  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  metaData() async {
    try {
      final metadata =
          await MetadataRetriever.fromFile(File(widget.songs[idx].filePath));
      thumbnail = metadata.albumArt ?? null;
    } catch (e) {
      print(e.toString());
    }

    setState(() {});
  }

  saveFavListInSharedPref(List<SongInfo> _favList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _favList.forEach((element) {
      songsInfoModel.title = element.title;
      songsInfoModel.artistId = element.artistId;
      songsInfoModel.artist = element.artist;
      songsInfoModel.albumId = element.albumId;
      songsInfoModel.album = element.album;
      songsInfoModel.filePath = element.filePath;
      setState(() {});
    });
    final String temp = SongsInfoModel.encode([songsInfoModel]);
    log('$temp');
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      // appBar: AppBar(title: Text('Music App')),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Stack(children: [
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.purple[900],
                  image: thumbnail != null
                      ? DecorationImage(
                          image: MemoryImage(thumbnail!), fit: BoxFit.fill)
                      : null,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                      decoration:
                          BoxDecoration(color: Colors.black.withOpacity(0.5))),
                ),
              ),
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: screenHeight! * 0.05,
                    ),
                    IconButton(
                      onPressed: () {
                        //  Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: screenWidth! * 0.1,
                      ),
                    ),
                    SizedBox(
                      height: screenHeight! * 0.02,
                    ),
                    Container(
                      height: screenHeight! * 0.43,
                      width: screenWidth! * 0.85,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: thumbnail != null
                            ? DecorationImage(
                                image: MemoryImage(thumbnail!),
                                fit: BoxFit.fill)
                            : const DecorationImage(
                                image: AssetImage('assets/images/music.png')),
                        color: Colors.black38,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: screenWidth! * 0.11, bottom: screenWidth! * 0.1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: screenWidth! * 0.8,
                            child: Text(
                              widget.songs[idx].title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: screenWidth! * 0.06,
                                  color: Colors.white),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              setState(() {
                                favorite = !favorite;
                              });
                              // favorite
                              //     ? widget.favList.add(widget.songs[idx])
                              //     : widget.favList.remove(widget.songs[idx]);
                              widget.favList.add(widget.songs[idx]);
                              setState(() {});
                              saveFavListInSharedPref(widget.favList);
                            },
                            icon: favorite
                                ? Icon(Icons.favorite, color: Colors.red[800])
                                : Icon(Icons.favorite_border_outlined,
                                    color: Colors.white),
                            iconSize: screenWidth! * 0.083,
                            //color: Colors.white,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth! * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatTime(position.inSeconds).substring(3, 8),
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                              formatTime((duration - position).inSeconds)
                                  .substring(3, 8),
                              style: TextStyle(color: Colors.white))
                        ],
                      ),
                    ),
                    slider(),
                    SizedBox(
                      height: screenHeight! * 0.04,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        backwardButton(),
                        pausePlayButton(),
                        forwordButton()
                      ],
                    ),
                  ],
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget slider() {
    return SliderTheme(
      data: SliderThemeData(trackHeight: screenHeight! * 0.001),
      child: Slider(
        min: 0.0,
        max: duration.inSeconds.toDouble(),
        value: position.inSeconds.toDouble(),
        activeColor: Colors.white,
        inactiveColor: Colors.grey,
        onChanged: (value) {
          changeToSeconds(value.toInt());

          widget.player.resume();
        },
      ),
    );
  }

  void changeToSeconds(int second) {
    Duration newDuration = Duration(seconds: second);
    widget.player.seek(newDuration);
  }

  Widget pausePlayButton() {
    return CircleAvatar(
      radius: screenWidth! * 0.07,
      backgroundColor: Colors.white38,
      child: IconButton(
          onPressed: () {
            setState(() {
              MyVar.isPlaying = !MyVar.isPlaying;
            });
            if (MyVar.isPlaying == true) {
              widget.player.resume();
              widget.playPauseButtonAnimationController.forward();
            } else {
              widget.player.pause();
              widget.playPauseButtonAnimationController.reverse();
            }
            // MyVar.isPlaying ? widget.player.resume() : widget.player.pause();
          },
          icon: AnimatedIcon(
            icon: AnimatedIcons.play_pause,
            progress: widget.playPauseButtonAnimationController,
            color: Colors.white,
            size: screenWidth! * 0.075,
          )),
    );
  }

  Widget forwordButton() {
    return IconButton(
      onPressed: () async {
        final prefs = await SharedPreferences.getInstance();

        setState(() {
          idx = idx + 1;
        });
        await prefs.setInt('songIndex', idx);
        MyVar.savedIndex = idx;
        MyVar.selectedSongIndex = idx;
        MyVar.selectedSongId = widget.songs[idx].id;
        setState(() {});
        playMusic();
      },
      icon: const ImageIcon(
        AssetImage('assets/icons/forword.png'),
        color: Colors.white,
      ),
    );
  }

  Widget backwardButton() {
    return IconButton(
      onPressed: () async {
        final prefs = await SharedPreferences.getInstance();

        idx = idx - 1;
        setState(() {});
        await prefs.setInt('songIndex', idx);
        MyVar.savedIndex = idx;
        MyVar.selectedSongIndex = idx;
        MyVar.selectedSongId = widget.songs[idx].id;
        setState(() {});
        playMusic();
      },
      icon: const ImageIcon(
        AssetImage('assets/icons/backword.png'),
        color: Colors.white,
      ),
    );
  }
}
