import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:music_player/screens/fav_page.dart';
import 'package:music_player/screens/music_play_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../resources/my_var.dart';
import '../widgets/silverAppbar_delegate.dart';

class LocalSongsListScreen extends StatefulWidget {
  const LocalSongsListScreen(
      {Key? key, required this.player, required this.songs})
      : super(key: key);
  final AudioPlayer player;
  final List<SongInfo> songs;

  @override
  State<LocalSongsListScreen> createState() => _LocalSongsListScreenState();
}

class _LocalSongsListScreenState extends State<LocalSongsListScreen>
    with TickerProviderStateMixin {
  late final AnimationController _playPauseButtonAnimationController;
  late final AnimationController _controller;
  final MiniplayerController _miniplayerController = MiniplayerController();
  late final TextEditingController _searchTextController;
  late final FocusNode myFocus;
  late final TabController _tabController;
  final audioQuery = FlutterAudioQuery();

  double? screenHeight;
  double? screenWidth;
  // List<SongInfo> widgetsongs = [];
  List<ArtistInfo> artists = [];
  List<AlbumInfo> albums = [];
  List<SongInfo> favList = [];
  int id = 0;

  List<dynamic> searchList = [];
  List<SongInfo> selectedAlbumList = [];

  List<SongInfo> selectedArtistsList = [];
  // late File art;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _searchTextController = TextEditingController();
    myFocus = FocusNode();
    _tabController = TabController(length: 3, vsync: this);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );
    _playPauseButtonAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    widget.player.onPlayerComplete.listen((complete) {
      widget.player.stop();
      // MyVar.isPlaying = false;
      setState(() {});
    });
    // AwesomeNotifications().actionStream.listen((action) {
    //   if (action.buttonKeyPressed == "open") {
    //     print("Open button is pressed");
    //   } else if (action.buttonKeyPressed == "delete") {
    //     print("Delete button is pressed.");
    //   } else {
    //     print(action.payload); //notification was pressed
    //   }
    // });

    getMusic();
  }

  void getMusic() async {
    // widget.songs = await audioQuery.getSongs();
    artists = await audioQuery.getArtists();
    albums = await audioQuery.getAlbums();
    //  log('$widget.songs');

    await getDataFromSharedPref();
    MyVar.selectedSongIndex = MyVar.savedIndex;
    MyVar.selectedSongId = widget.songs[MyVar.savedIndex].id;
    setState(() {});
    widget.player.setSourceDeviceFile(widget.songs[MyVar.savedIndex].filePath);
    //log('$songs');
  }

  Future<Uint8List> metaData(String path) async {
    final metadata = await MetadataRetriever.fromFile(File(path));

    return metadata.albumArt!;
  }

  saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt('songIndex', getSongIndexFromId(MyVar.selectedSongId));
    // prefs.setString('songId', songs[_selectedSongIndex].id);
    //  log('set data');
  }

  int getSongIndexFromId(String id) {
    var idx = widget.songs.indexWhere((element) => element.id == id);
    return idx;
  }

  getDataFromSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    MyVar.savedIndex = prefs.getInt('songIndex') ?? 0;
    setState(() {});
    // log('get data : $savedIndex');
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        body: Stack(children: [
          NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  title: searchBar(),
                  pinned: true,
                  floating: false,
                  flexibleSpace: FlexibleSpaceBar(
                    background: topElements(),
                    //  title: Text('all songs'),
                  ),
                  elevation: 0,
                  forceElevated: innerBoxIsScrolled,
                  backgroundColor: Colors.white,
                  expandedHeight: screenHeight! * 0.21,
                ),
                SliverPersistentHeader(
                    pinned: true,
                    floating: false,
                    delegate: SliverAppBarDelegate(
                      TabBar(
                        tabs: const <Tab>[
                          Tab(text: 'Songs'),
                          Tab(text: 'Artists'),
                          Tab(text: 'Albums')
                        ],
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorColor: Colors.purple,
                        labelColor: Colors.grey[800],
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        unselectedLabelColor: Colors.grey[600],
                        unselectedLabelStyle:
                            TextStyle(fontWeight: FontWeight.normal),
                      ),
                    )),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: <Widget>[songsTab(), artistsTab(), albumsTab()],
            ),
          ),
          Miniplayer(
              controller: _miniplayerController,
              minHeight: screenHeight! * 0.08,
              maxHeight: MediaQuery.of(context).size.height,
              elevation: 0,
              builder: (height, percentage) {
                MyVar.isPlaying ? _controller.repeat() : _controller.stop();
                if (percentage < 0.03) {
                  return miniPlayer();
                } else {
                  return MusicPlayScreen(
                    // selectedSong: songs[savedIndex!],
                    player: widget.player,
                    favList: favList,
                    playPauseButtonAnimationController:
                        _playPauseButtonAnimationController,
                    songs: widget.songs,
                  );
                }
              })
        ]),
      ),
    );
  }

  Widget miniPlayer() {
    return Stack(children: [
      Container(
        // color: Colors.purple.shade800,
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.blue.shade100,
            Colors.deepPurple.shade100,
            Colors.deepPurple.shade100,
          ],
        )),
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: NeverScrollableScrollPhysics(),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          RotationTransition(
            turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
            child: Container(
                padding: EdgeInsets.only(
                    left: screenWidth! * 0.035,
                    top: screenWidth! * 0.01,
                    bottom: screenWidth! * 0.01,
                    right: screenWidth! * 0.03),
                child: widget.songs.isNotEmpty
                    ? Stack(children: [
                        Image.asset(
                          'assets/images/cassete.png',
                          fit: BoxFit.fill,
                        ),
                        Container(
                            margin: EdgeInsets.all(screenWidth! * 0.02),
                            child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(screenWidth! * 0.5),
                                child: thumbnail(
                                    widget.songs[MyVar.savedIndex].id)))
                      ])
                    : Image.asset(
                        'assets/images/music.png',
                      )),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: screenWidth! * 0.66,
                child: Text(
                  widget.songs.isNotEmpty
                      ? widget.songs[MyVar.savedIndex].title
                      : 'Loading...',
                  style: TextStyle(fontSize: screenWidth! * 0.045),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Container(
                width: screenWidth! * 0.66,
                child: Text(
                  widget.songs.isNotEmpty
                      ? widget.songs[MyVar.savedIndex].artist
                      : 'Loading...',
                  style: TextStyle(
                      fontSize: screenWidth! * 0.033, color: Colors.grey[700]),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  MyVar.isPlaying = !MyVar.isPlaying;
                });
                if (MyVar.isPlaying == true) {
                  widget.player.resume();
                  _playPauseButtonAnimationController.forward();
                } else {
                  widget.player.pause();
                  _playPauseButtonAnimationController.reverse();
                }
              },
              icon: AnimatedIcon(
                icon: AnimatedIcons.play_pause,
                progress: _playPauseButtonAnimationController,
                size: screenWidth! * 0.075,
              ))
        ]),
      ),
    ]);
  }

  Widget artistsTab() {
    return ListView.builder(
        itemCount: artists.length,
        itemBuilder: (BuildContext context, index) => InkWell(
              onTap: () {
                selectedArtistsList.clear();
                for (var song in widget.songs) {
                  if (artists[index].id == song.artistId) {
                    selectedArtistsList.add(song);
                  }
                  setState(() {});
                }
                artistsOnTapBottomSheet(index);
              },
              child: ListTile(
                title: Text(
                  artists[index].name,
                ),
                subtitle: artists[index].numberOfTracks == '1'
                    ? Text('${artists[index].numberOfTracks} Song')
                    : Text('${artists[index].numberOfTracks} Songs'),
              ),
            ));
  }

  void artistsOnTapBottomSheet(int idx) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenHeight! * 0.02),
      ),
      backgroundColor: Colors.grey.shade50,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: screenHeight! * 0.6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Container(
                  margin: EdgeInsets.only(
                      top: screenHeight! * 0.01, bottom: screenHeight! * 0.01),
                  height: screenHeight! * 0.007,
                  width: screenWidth! * 0.17,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[400],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  artists[idx].name,
                  style: TextStyle(fontSize: screenWidth! * 0.06),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Container(
                height: screenHeight! * 0.5,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: selectedArtistsList.length,
                  itemBuilder: (BuildContext context, index) => InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      songsTabOnTapFunction(selectedArtistsList[index].id);
                    },
                    child: ListTile(
                      leading: Container(
                          width: screenWidth! * 0.15,
                          child: thumbnail(selectedArtistsList[index].id)),
                      title: Text(
                        selectedArtistsList[index].title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                            color: selectedArtistsList[index].id ==
                                    widget.songs[MyVar.savedIndex].id
                                ? Colors.purple.shade800
                                : null),
                      ),
                      subtitle: selectedArtistsList[index].artist != '<unknown>'
                          ? Text(
                              selectedArtistsList[index].artist +
                                  ' | ' +
                                  selectedArtistsList[index].album,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  color: selectedArtistsList[index].id ==
                                          widget.songs[MyVar.savedIndex].id
                                      ? Colors.purple.shade800
                                      : null),
                            )
                          : Text('Unknown Artist | Unknown Album'),
                      trailing: selectedArtistsList[index].id ==
                              widget.songs[MyVar.savedIndex].id
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
              ),
            ],
          ),
        );
      },
    );
  }

  Widget albumsTab() {
    return ListView.builder(
        itemCount: albums.length,
        itemBuilder: (BuildContext context, index) => InkWell(
              onTap: () {
                selectedAlbumList.clear();
                for (var song in widget.songs) {
                  if (albums[index].title == song.album) {
                    selectedAlbumList.add(song);
                  }
                  setState(() {});
                }
                albumsOnTapBottomSheet(index);
              },
              child: ListTile(
                leading: Stack(children: [
                  Image.asset('assets/images/cassete.png'),
                  Container(
                    height: screenHeight! * 0.1,
                    width: screenWidth! * 0.1,
                    color: Colors.purple.shade50,
                    child: Center(
                        child: Text(
                      albums[index].title.substring(0, 1),
                      style: TextStyle(
                          fontSize: screenWidth! * 0.05,
                          color: Colors.purple.shade700),
                    )),
                  ),
                ]),
                title: Text(albums[index].title),
                subtitle: albums[index].numberOfSongs == '1'
                    ? Text('${albums[index].numberOfSongs} Song')
                    : Text('${albums[index].numberOfSongs} Songs'),
              ),
            ));
  }

  void albumsOnTapBottomSheet(int idx) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenHeight! * 0.02),
      ),
      backgroundColor: Colors.deepPurple.shade50,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: screenHeight! * 0.63,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Container(
                  margin: EdgeInsets.only(
                      top: screenHeight! * 0.01, bottom: screenHeight! * 0.01),
                  height: screenHeight! * 0.007,
                  width: screenWidth! * 0.17,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[400],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Stack(children: [
                      Image.asset(
                        'assets/images/cassete.png',
                        scale: screenWidth! * 0.014,
                      ),
                      Container(
                        height: screenHeight! * 0.07,
                        width: screenWidth! * 0.09,
                        color: Colors.purple.shade50,
                        child: Center(
                            child: Text(
                          albums[idx].title.substring(0, 1),
                          style: TextStyle(
                              fontSize: screenWidth! * 0.05,
                              color: Colors.purple.shade700),
                        )),
                      ),
                    ]),
                    Padding(
                      padding: EdgeInsets.only(left: screenWidth! * 0.02),
                      child: Container(
                        width: screenWidth! * 0.75,
                        child: Text(
                          albums[idx].title,
                          style: TextStyle(fontSize: screenWidth! * 0.05),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: screenHeight! * 0.5,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: selectedAlbumList.length,
                  itemBuilder: (BuildContext context, index) => InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      songsTabOnTapFunction(selectedAlbumList[index].id);
                    },
                    child: ListTile(
                      leading: Container(
                          width: screenWidth! * 0.15,
                          child: thumbnail(selectedAlbumList[index].id)),
                      title: Text(
                        selectedAlbumList[index].title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                            color: selectedAlbumList[index].id ==
                                    widget.songs[MyVar.savedIndex].id
                                ? Colors.purple.shade800
                                : null),
                      ),
                      subtitle: selectedAlbumList[index].artist != '<unknown>'
                          ? Text(
                              selectedAlbumList[index].artist +
                                  ' | ' +
                                  selectedAlbumList[index].album,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  color: selectedAlbumList[index].id ==
                                          widget.songs[MyVar.savedIndex].id
                                      ? Colors.purple.shade800
                                      : null),
                            )
                          : Text('Unknown Artist | Unknown Album'),
                      trailing: selectedAlbumList[index].id ==
                              widget.songs[MyVar.savedIndex].id
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
              ),
            ],
          ),
        );
      },
    );
  }

  Widget songsTab() {
    return myFocus.hasFocus
        ? searchList.isNotEmpty
            ? ListView.builder(
                padding: EdgeInsets.only(
                    top: screenHeight! * 0.013, bottom: screenHeight! * 0.08),
                physics: BouncingScrollPhysics(),
                itemCount: searchList.length,
                itemBuilder: (BuildContext context, index) {
                  return InkWell(
                    onTap: () async {
                      songsTabOnTapFunction(searchList[index].id);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: screenHeight! * 0.00),
                      child: ListTile(
                        leading: Container(
                            width: screenWidth! * 0.15,
                            child: thumbnail(searchList[index].id)),
                        title: Text(
                          searchList[index].title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              color: searchList[index].id ==
                                      widget.songs[MyVar.savedIndex].id
                                  ? Colors.purple.shade800
                                  : null),
                        ),
                        subtitle: searchList[index].artist != '<unknown>'
                            ? Text(
                                searchList[index].artist +
                                    ' | ' +
                                    searchList[index].album,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    color: searchList[index].id ==
                                            widget.songs[MyVar.savedIndex].id
                                        ? Colors.purple.shade800
                                        : null),
                              )
                            : Text('Unknown Artist | Unknown Album'),
                        trailing: searchList[index].id ==
                                widget.songs[MyVar.savedIndex].id
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
                  );
                })
            : Center(
                child: Text('No matching song found '),
              )
        : ListView.builder(
            padding: EdgeInsets.only(
                top: screenHeight! * 0.013, bottom: screenHeight! * 0.08),
            physics: BouncingScrollPhysics(),
            itemCount: widget.songs.length,
            itemBuilder: (BuildContext context, index) {
              return InkWell(
                onTap: () async {
                  songsTabOnTapFunction(widget.songs[index].id);
                },
                child: Padding(
                  padding: EdgeInsets.only(top: screenHeight! * 0.00),
                  child: ListTile(
                    leading: Container(
                        width: screenWidth! * 0.15,
                        child: thumbnail(widget.songs[index].id)),
                    title: Text(
                      widget.songs[index].title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          color: widget.songs[index].id ==
                                  widget.songs[MyVar.savedIndex].id
                              ? Colors.purple.shade800
                              : null),
                    ),
                    subtitle: widget.songs[index].artist != '<unknown>'
                        ? Text(
                            widget.songs[index].artist +
                                ' | ' +
                                widget.songs[index].album,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                color: index == MyVar.savedIndex
                                    ? Colors.purple.shade800
                                    : null),
                          )
                        : Text('Unknown Artist | Unknown Album'),
                    trailing: index == MyVar.savedIndex
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
              );
            });
  }

  void songsTabOnTapFunction(String id) async {
    myFocus.unfocus();
    setState(() {
      MyVar.selectedSongIndex = getSongIndexFromId(id);
      MyVar.selectedSongId = id;
    });
    await saveData();
    await getDataFromSharedPref();
    //  log('${MyVar.selectedSongId}');

    setState(() {});
    _miniplayerController.animateToHeight(
        state: PanelState.MAX, duration: const Duration(milliseconds: 600));
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

  Widget searchBar() {
    return Padding(
      padding: EdgeInsets.only(top: screenHeight! * 0.007),
      child: Container(
        height: screenHeight! * 0.045,
        child: TextField(
            focusNode: myFocus,
            controller: _searchTextController,
            onChanged: onSearchTextChanged,
            decoration: InputDecoration(
              hintText: 'Search',
              contentPadding: EdgeInsets.only(top: screenHeight! * 0.02),
              prefixIcon: Icon(Icons.search),
              suffixIcon: myFocus.hasFocus
                  ? IconButton(
                      onPressed: () {
                        myFocus.unfocus();
                        _searchTextController.clear();
                        searchList.clear();
                      },
                      icon: Icon(Icons.cancel_rounded))
                  : IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.mic, color: Colors.purple)),
              filled: true,
              fillColor: Colors.grey[200],
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(width: 0, color: Colors.white), //<-- SEE HERE
                borderRadius: BorderRadius.circular(50.0),
              ),
              focusColor: Color.fromARGB(250, 132, 99, 204),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(50.0)),
            )),
      ),
    );
  }

  Widget topElements() {
    return Padding(
      padding: EdgeInsets.only(top: screenWidth! * 0.25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              createNotification();
            },
            child: Container(
              height: screenHeight! * 0.11,
              width: screenWidth! * 0.29,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color.fromARGB(150, 91, 146, 255),
                      Color.fromARGB(250, 68, 133, 255),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(screenWidth! * 0.02)),
              child: insideTopElements(Icons.queue_music, 'Playlists'),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FavPage(
                            favList: favList,
                            songs: widget.songs,
                            miniplayerController: _miniplayerController,
                          )));
            },
            child: Container(
                height: screenHeight! * 0.11,
                width: screenWidth! * 0.29,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color.fromARGB(150, 122, 66, 155),
                        Color.fromARGB(250, 109, 62, 167),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(screenWidth! * 0.02)),
                child: insideTopElements(Icons.favorite, 'Favorite')),
          ),
          Container(
            height: screenHeight! * 0.11,
            width: screenWidth! * 0.29,
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color.fromARGB(200, 59, 225, 167),
                    Color.fromARGB(255, 0, 141, 103),
                  ],
                ),
                borderRadius: BorderRadius.circular(screenWidth! * 0.02)),
            child: insideTopElements(Icons.history, 'Recenty Played'),
          )
        ],
      ),
    );
  }

  Widget insideTopElements(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(
          top: screenHeight! * 0.045, left: screenWidth! * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white,
          ),
          Text(
            text,
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }

  Future<void> createNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 1,
          channelKey: 'channel1',
          title: widget.songs[MyVar.selectedSongIndex].title,
          body: widget.songs[MyVar.selectedSongIndex].artist,
          // bigPicture: 'asset://assets/images/music.png',
          autoDismissible: false,
          largeIcon: 'asset://assets/images/music.png',
          // category: NotificationCategory.Service,
          locked: true,
          progress: 50,
          displayOnForeground: true,
          actionType: ActionType.SilentBackgroundAction,
          notificationLayout: NotificationLayout.MediaPlayer),
      actionButtons: [
        NotificationActionButton(
            key: 'play',
            label: '',
            icon: 'asset://assets/icons/forward.png',
            color: Colors.black,
            // actionType: ActionType.SilentAction,
            showInCompactView: false,
            // enabled: ,
            autoDismissible: true),
        NotificationActionButton(
            key: 'next',
            label: '',
            icon: 'asset://assets/icons/forward.png',
            color: Colors.black,
            // actionType: ActionType.SilentAction,
            showInCompactView: false,
            isDangerousOption: true,
            enabled: false,
            autoDismissible: true),
        NotificationActionButton(
            key: 'pause',
            label: '',
            icon: 'asset://assets/icons/forward.png',
            color: Colors.black,
            actionType: ActionType.SilentBackgroundAction,
            showInCompactView: false,
            enabled: false,
            autoDismissible: true),
      ],
    );
  }

  Future<void> onSearchTextChanged(String text) async {
    searchList.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    for (var song in widget.songs) {
      if (song.title!.toLowerCase().contains(text.toLowerCase())) {
        searchList.add(song);
      }
    }

    setState(() {});
  }
}
