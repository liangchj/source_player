
import 'package:get/get.dart';

import '../hive/hive_models/history/play_history.dart';
import '../hive/storage.dart';

class HistoryController extends GetxController {

  // 缓存排序后的历史记录列表
  late List<PlayHistory> _sortedHistoryList;
  bool _isCacheValid = false;

  // 获取排序后的历史记录
  Future<List<PlayHistory>> getSortedHistory() async {
    if (!_isCacheValid) {
      await _refreshCache();
      _isCacheValid = true;
    }
    return _sortedHistoryList;
  }

  // 刷新缓存
  Future<void> _refreshCache() async {
    // 从 Hive 读取所有历史记录
    final allHistory = GStorage.histories.values.toList();

    // 按最后播放时间倒序排序
    allHistory.sort((a, b) => a.lastPlayTime.compareTo(b.lastPlayTime));
    _sortedHistoryList = allHistory;
  }

  // 更新某个历史记录（播放新视频后调用）
  void updateHistory(PlayHistory history) {
    if (_isCacheValid) {
      // 找到是否已存在该历史记录
      final existingIndex = _sortedHistoryList.indexWhere((item) => item.resource.resourceUrl == history.resource.resourceUrl);

      if (existingIndex >= 0) {
        // 更新现有记录
        _sortedHistoryList[existingIndex] = history;
        // 重新排序受影响的部分
        _sortedHistoryList.sort((a, b) => b.lastPlayTime.compareTo(a.lastPlayTime));
      } else {
        // 添加新记录到正确位置
        _sortedHistoryList.add(history);
        _sortedHistoryList.sort((a, b) => b.lastPlayTime.compareTo(a.lastPlayTime));
      }
    }
  }

  // 当进入历史页面时调用
  void onHistoryPageOpened() {
    // 可以在这里做一些预加载操作
  }

}