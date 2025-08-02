import 'package:flutter/material.dart';
import 'package:source_player/player/ui/player_bottom_ui.dart';
import 'package:source_player/player/ui/player_top_ui.dart';

import 'background_event_ui.dart';

class PlayerUI extends StatefulWidget {
  const PlayerUI({super.key});

  @override
  State<PlayerUI> createState() => _PlayerUIState();
}

class _PlayerUIState extends State<PlayerUI> {
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          const Positioned.fill(child: BackgroundEventUI()),

          // 顶部UI（资源信息）
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            child: PlayerTopUI(),
          ),


          // 底部UI（进度和控制信息）
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: PlayerBottomUI(),
          ),
        ]
      )
    );
  }
}
