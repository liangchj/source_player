class VideoTypeModel {
  final String id;
  final String? enName;
  final String name;
  final String? parentId;

  VideoTypeModel({
    required this.id,
    this.enName,
    required this.name,
    this.parentId,
  });
  factory VideoTypeModel.fromJson(Map<String, dynamic> json) {
    return VideoTypeModel(
      id: (json['id'] ?? "").toString(),
      enName: json['enName'],
      name: json['name'],
      parentId: (json['parentId'] ?? "").toString(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enName': enName,
      'name': name,
      'parentId': parentId,
    };
  }
}
