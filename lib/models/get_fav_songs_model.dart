class GetFavSongs {
  String? filePath;
  String? artist;
  String? album;
  String? title;
  String? artistId;
  String? albumId;
  String? id;

  GetFavSongs(
      {this.filePath,
      this.artist,
      this.album,
      this.title,
      this.artistId,
      this.albumId,
      this.id});

  GetFavSongs.fromJson(Map<String, dynamic> json) {
    filePath = json['filePath'];
    artist = json['artist'];
    album = json['album'];
    title = json['title'];
    artistId = json['artist_id'];
    albumId = json['album_id'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['filePath'] = this.filePath;
    data['artist'] = this.artist;
    data['album'] = this.album;
    data['title'] = this.title;
    data['artist_id'] = this.artistId;
    data['album_id'] = this.albumId;
    data['id'] = this.id;
    return data;
  }
}
