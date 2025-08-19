import 'dart:io';
import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

enum MediaFileSourceType { localFile, playListFile }

class MediaFileModel {
  final File? file;

  // 本地文件、播放列表文件
  MediaFileSourceType fileSourceType;

  String? barragePath;
  String? subtitlePath;

  AssetEntity? assetEntity;

  Uint8List? thumbnailUint8List;

  MediaFileModel({
    this.file,
    this.fileSourceType = MediaFileSourceType.localFile,
    this.barragePath,
    this.subtitlePath,
    this.assetEntity,
    this.thumbnailUint8List,
  });
}
