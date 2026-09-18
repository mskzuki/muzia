import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:muzia/shared/theme/muzia_theme.dart';

/// 再生中行の #セルに出す3本バーのイコライザ（デザイン `.eq`）。
///
/// 再生中だけ 0.9 秒周期で動き、一時停止中と Reduce Motion 時は静止する。
class NowPlayingEqualizer extends StatefulWidget {
  const NowPlayingEqualizer({
    super.key,
    required this.color,
    required this.animating,
    this.alignment = Alignment.centerRight,
  });

  final Color color;
  final bool animating;
  final AlignmentGeometry alignment;

  @override
  State<NowPlayingEqualizer> createState() => _NowPlayingEqualizerState();
}

class _NowPlayingEqualizerState extends State<NowPlayingEqualizer>
    with SingleTickerProviderStateMixin {
  static const _heights = [0.6, 1.0, 0.4];
  static const _phases = [-0.2 / 0.9, -0.5 / 0.9, 0.0];
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: MuziaMotion.equalizerLoop,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animate =
        widget.animating && !MediaQuery.disableAnimationsOf(context);
    if (animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!animate && _controller.isAnimating) {
      _controller.stop();
    }
    return Align(
      alignment: widget.alignment,
      child: SizedBox(
        key: const ValueKey('now-playing-equalizer'),
        height: 11,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 1.5),
                _bar(i, animate),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _bar(int index, bool animate) {
    // 0% と 100% で scaleY(0.35)、50% で scaleY(1) の ease-in-out。静止時は 0.7。
    final t = (_controller.value + _phases[index]) % 1;
    final scale = animate
        ? 0.35 + 0.65 * (0.5 - 0.5 * math.cos(2 * math.pi * t))
        : 0.7;
    return Container(
      width: 2,
      height: 11 * _heights[index] * scale,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
