import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:muzia/features/library/domain/library_catalog.dart';
import 'package:muzia/features/library/domain/metadata_values.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/presentation/library_removal_dialog.dart';
import 'package:muzia/features/library/presentation/metadata_edit_dialog.dart';
import 'package:muzia/shared/theme/muzia_theme.dart';

/// 楽曲行に対する操作。楽曲一覧テーブルとアーティスト/アルバムブラウザで共有する。
class TrackActions {
  const TrackActions({
    required this.onPlay,
    required this.onEdit,
    required this.onRemove,
  });

  /// 何もしない既定値（操作を持たない画面・テスト用）。
  static final none = TrackActions(
    onPlay: (_) {},
    onEdit: (_, _) async => false,
    onRemove: (_) async => false,
  );

  final ValueChanged<Track> onPlay;
  final Future<bool> Function(Track track, MetadataValues values) onEdit;
  final Future<bool> Function(List<Track> tracks) onRemove;

  /// 曲編集ダイアログを開き、保存されたら [onEdit] を呼ぶ。
  Future<void> editTrack(
    BuildContext context,
    Track track,
    LibraryCatalog catalog,
  ) async {
    final values = await showDialog<MetadataValues>(
      context: context,
      builder: (context) =>
          MetadataEditDialog(track: track, genreSuggestions: catalog.genres),
    );
    if (values != null) await onEdit(track, values);
  }

  /// 削除確認ダイアログを表示し、確定したら [onRemove] を呼ぶ。削除できたら true。
  Future<bool> confirmRemove(BuildContext context, List<Track> tracks) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => LibraryRemovalDialog(count: tracks.length),
    );
    if (confirmed != true || !context.mounted) return false;
    return onRemove(tracks);
  }
}

/// コンテキストメニューの項目。
enum TrackMenuAction { play, edit, remove }

bool get _isMac => defaultTargetPlatform == TargetPlatform.macOS;

/// 「曲を編集…」のショートカット表記（macOS は ⌘I、それ以外は Ctrl+I）。
String get editShortcutLabel => _isMac ? '⌘I' : 'Ctrl+I';

/// 楽曲の右クリックメニュー（`15-context-menu`）: 曲を再生 / 曲を編集… / ライブラリから削除…。
Future<TrackMenuAction?> showTrackContextMenu(
  BuildContext context,
  Offset globalPosition,
) {
  final colors = Theme.of(context).extension<MuziaColors>()!;
  final overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
  return showMenu<TrackMenuAction>(
    context: context,
    position: RelativeRect.fromRect(
      globalPosition & const Size(1, 1),
      Offset.zero & overlay.size,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(MuziaRadius.r3),
    ),
    items: [
      const PopupMenuItem(
        value: TrackMenuAction.play,
        height: 32,
        child: TrackMenuLabel(icon: Icons.play_arrow, label: '曲を再生'),
      ),
      PopupMenuItem(
        value: TrackMenuAction.edit,
        height: 32,
        child: TrackMenuLabel(
          icon: Icons.edit_outlined,
          label: '曲を編集…',
          shortcut: editShortcutLabel,
        ),
      ),
      PopupMenuItem(
        value: TrackMenuAction.remove,
        height: 32,
        child: TrackMenuLabel(
          icon: Icons.close,
          label: 'ライブラリから削除…',
          color: colors.destructive,
        ),
      ),
    ],
  );
}

/// コンテキストメニュー項目（`.ctx-item`）: 先頭アイコン15px + ラベル + ショートカット。
class TrackMenuLabel extends StatelessWidget {
  const TrackMenuLabel({
    super.key,
    required this.icon,
    required this.label,
    this.shortcut,
    this.color,
  });

  final IconData icon;
  final String label;
  final String? shortcut;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    return Row(
      children: [
        SizedBox(
          width: 15,
          child: Icon(icon, size: 14, color: color ?? colors.fgSecondary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: MuziaTextStyles.body.copyWith(
              color: color ?? colors.fgPrimary,
            ),
          ),
        ),
        if (shortcut != null) ...[
          const SizedBox(width: MuziaSpacing.s4),
          Text(
            shortcut!,
            style: MuziaTextStyles.secondary.copyWith(
              color: colors.fgTertiary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ],
    );
  }
}
