import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:music_player/screens/local_songs_list.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late AudioPlayer player;
  var _widgetOptions = <Widget>[];
  int _selectedIndex = 0;
  double? screenHeight;
  double? screenWidth;
  final audioQuery = FlutterAudioQuery();
  List<SongInfo> songs = [];

  static const IconData globe = IconData(0xf68d);

  @override
  void initState() {
    // TODO: implement initState
    player = AudioPlayer();
    start();

    super.initState();
  }

  start() async {
    songs = await audioQuery.getSongs();
    setState(() {});
    _widgetOptions = <Widget>[
      LocalSongsListScreen(
        player: player,
        songs: songs,
      ),
      const Center(
        child: Text('Online Music Page',
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
      ),
      const Center(
        child: Text('Search Page',
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.headphones,
              ),
              label: 'My Music',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/icons/online.png')),
              label: 'Online',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
              ),
              label: 'Search',
            ),
          ],
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.purple[800],
          unselectedItemColor: Colors.grey[700],
          showUnselectedLabels: false,
          iconSize: screenWidth! * 0.08,
          selectedFontSize: screenWidth! * 0.03,
          unselectedFontSize: screenWidth! * 0.02,
          onTap: _onItemTapped,
          elevation: 0),
    );
  }
}
