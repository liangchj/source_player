import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_player/utils/logger_utils.dart';

import '../enums/file_format.dart';
import '../getx_controller/my_file_selector_controller.dart';

class MyFileSelector extends StatefulWidget {
  const MyFileSelector({
    super.key,
    required this.directory,
    this.fileFormat,
    this.onConfirm,
    this.onCancel,
    this.onTapFile,
  });
  final Directory directory;
  final FileFormat? fileFormat;
  final Function? onConfirm;
  final Function? onCancel;
  final Function(File)? onTapFile;

  @override
  State<MyFileSelector> createState() => _MyFileSelectorState();
}

class _MyFileSelectorState extends State<MyFileSelector> {
  late final MyFileSelectorController fileSelectorController;
  late ScrollController scrollController;

  @override
  void initState() {
    fileSelectorController = Get.put(MyFileSelectorController());
    fileSelectorController.getFileAndDirByPath(
      widget.directory.path,
      fileFormat: widget.fileFormat,
    );
    fileSelectorController.createCurrentDirectoryNav(
      widget.directory,
      fileFormat: widget.fileFormat,
    );

    scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Obx(() {
            if (fileSelectorController.currentDirectoryNavLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return Row(
              children: [
                fileSelectorController
                    .currentDirectoryNavList[fileSelectorController
                        .currentDirectoryNavList
                        .length -
                    1],
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: fileSelectorController.currentDirectoryNavList
                          .getRange(
                            0,
                            fileSelectorController
                                    .currentDirectoryNavList
                                    .length -
                                1,
                          )
                          .toList()
                          .reversed
                          .map((e) => e)
                          .toList(),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
        Expanded(
          child: Obx(() {
            if (fileSelectorController.loading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              controller: scrollController,
              itemExtent: 50,
              itemCount: fileSelectorController.fileList.length,
              itemBuilder: (context, index) {
                File file = fileSelectorController.fileList[index];
                var isFile = FileSystemEntity.isFileSync(file.path);
                return InkWell(
                  onTap: () {
                    if (isFile) {
                      widget.onTapFile?.call(file);
                    } else {
                      LoggerUtils.logger.d("fileFormat: fileFormat");
                      fileSelectorController.createCurrentDirectoryNav(
                        Directory(file.path),
                        firstEntry: true,
                        fileFormat: widget.fileFormat,
                      );
                      fileSelectorController.getFileAndDirByPath(
                        file.path,
                        fileFormat: widget.fileFormat,
                      );
                    }
                  },
                  child: ListTile(
                    horizontalTitleGap: 0,
                    // contentPadding: const EdgeInsets.only(left: 16, right: 0),
                    leading: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(
                        Icons.file_copy_rounded,
                        size: 40,
                        color: Colors.black26,
                      ),
                    ),
                    title: Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Text(
                        file.path.split("/").last,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
