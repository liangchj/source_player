import 'dart:io';
import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

enum MediaFileSourceType { localFile, playListFile }

class MediaFileModel {
  File? file;

  // 本地文件、播放列表文件
  MediaFileSourceType fileSourceType;

  String? danmakuPath;
  String? subtitlePath;

  AssetEntity? assetEntity;

  Uint8List? thumbnailUint8List;

  MediaFileModel({
    this.file,
    this.fileSourceType = MediaFileSourceType.localFile,
    this.danmakuPath,
    this.subtitlePath,
    this.assetEntity,
    this.thumbnailUint8List,
  }) {
    if (file == null && assetEntity != null) {
      assetEntity!.file.then((value) => file = value);
    }
  }

  MediaFileModel copyWith({
    File? file,
    MediaFileSourceType? fileSourceType,
    String? danmakuPath,
    String? subtitlePath,
    AssetEntity? assetEntity,
    Uint8List? thumbnailUint8List,
  }) {
    return MediaFileModel(
      file: file ?? this.file,
      fileSourceType: fileSourceType ?? this.fileSourceType,
      danmakuPath: danmakuPath ?? this.danmakuPath,
      subtitlePath: subtitlePath ?? this.subtitlePath,
      assetEntity: assetEntity ?? this.assetEntity,
      thumbnailUint8List: thumbnailUint8List ?? this.thumbnailUint8List,
    );
  }


  String? get fullFilePath => file?.path;
  String? get filePath =>
      fullFilePath?.substring(fullFilePath!.lastIndexOf("/") + 1);
  String? get filePathName =>
      filePath?.substring(0, filePath!.lastIndexOf("."));

  String get fileName => filePathName ?? assetEntity?.title ?? "";

  String get suffix => filePath == null ? "" : filePath!.contains(".") ? filePath!.split(".").last : "";
}
