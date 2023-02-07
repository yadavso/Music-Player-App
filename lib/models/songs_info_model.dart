import 'dart:convert';

class SongsInfoModel {
  String? filePath;
  String? albumArtwork;
  String? displayName;
  String? artist;
  String? year;
  String? album;
  String? composer;
  bool? isMusic;
  bool? isRingtone;
  String? title;
  String? uri;
  String? artistId;
  bool? isPodcast;
  int? duration;
  int? size;
  bool? isAlarm;
  String? bookmark;
  String? albumId;
  bool? isNotification;
  String? id;
  String? track;

  SongsInfoModel(
      {this.filePath,
      this.albumArtwork,
      this.displayName,
      this.artist,
      this.year,
      this.album,
      this.composer,
      this.isMusic,
      this.isRingtone,
      this.title,
      this.uri,
      this.artistId,
      this.isPodcast,
      this.duration,
      this.size,
      this.isAlarm,
      this.bookmark,
      this.albumId,
      this.isNotification,
      this.id,
      this.track});

  SongsInfoModel.fromJson(Map<String, dynamic> json) {
    filePath = json['filePath'];
    albumArtwork = json['album_artwork'];
    displayName = json['display_name'];
    artist = json['artist'];
    year = json['year'];
    album = json['album'];
    composer = json['composer'];
    isMusic = json['is_music'];
    isRingtone = json['is_ringtone'];
    title = json['title'];
    uri = json['uri'];
    artistId = json['artist_id'];
    isPodcast = json['is_podcast'];
    duration = json['duration'];
    size = json['size'];
    isAlarm = json['is_alarm'];
    bookmark = json['bookmark'];
    albumId = json['album_id'];
    isNotification = json['is_notification'];
    id = json['id'];
    track = json['track'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['filePath'] = this.filePath;
    data['album_artwork'] = this.albumArtwork;
    data['display_name'] = this.displayName;
    data['artist'] = this.artist;
    data['year'] = this.year;
    data['album'] = this.album;
    data['composer'] = this.composer;
    data['is_music'] = this.isMusic;
    data['is_ringtone'] = this.isRingtone;
    data['title'] = this.title;
    data['uri'] = this.uri;
    data['artist_id'] = this.artistId;
    data['is_podcast'] = this.isPodcast;
    data['duration'] = this.duration;
    data['size'] = this.size;
    data['is_alarm'] = this.isAlarm;
    data['bookmark'] = this.bookmark;
    data['album_id'] = this.albumId;
    data['is_notification'] = this.isNotification;
    data['id'] = this.id;
    data['track'] = this.track;
    return data;
  }

  static Map<String, dynamic> toMap(SongsInfoModel songs) => {
        'id': songs.id,
        'title': songs.title,
        'album': songs.album,
        'albumId': songs.albumId,
        'artist': songs.artist,
        'artistId': songs.artistId,
      };

  static String encode(List<SongsInfoModel> songs) => json.encode(
        songs
            .map<Map<String, dynamic>>((music) => SongsInfoModel.toMap(music))
            .toList(),
      );

  static List<SongsInfoModel> decode(String musics) =>
      (json.decode(musics) as List<dynamic>)
          .map<SongsInfoModel>((item) => SongsInfoModel.fromJson(item))
          .toList();
}
