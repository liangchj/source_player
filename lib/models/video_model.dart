
class VideoModel {
  final String id;
  final String name;

  VideoModel({required this.id, required this.name});

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: (json['vod_id'] ?? "").toString(),
      name: json['vod_name'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}