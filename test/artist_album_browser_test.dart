import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/presentation/artist_album_browser.dart';
import 'package:muzia/features/library/presentation/track_actions.dart';
import 'package:muzia/shared/theme/muzia_theme.dart';

const _tracks = [
  Track(
    filePath: '/a/2.mp3',
    fileExtension: '.mp3',
    title: 'Golden Static',
    artist: 'Midnight Arcade',
    album: 'Parallel Lines',
    trackNumber: 3,
    releaseYear: 2024,
    genre: 'Synth-pop',
    durationMs: 224000,
  ),
  Track(
    filePath: '/a/1.mp3',
    fileExtension: '.mp3',
    title: 'Neon Hours',
    artist: 'Midnight Arcade',
    album: 'Parallel Lines',
    trackNumber: 1,
    releaseYear: 2024,
    genre: 'Synth-pop',
    durationMs: 238000,
  ),
  Track(
    filePath: '/b/1.mp3',
    fileExtension: '.mp3',
    title: 'Small Hour',
    artist: 'Midnight Arcade',
    album: 'Small Hours',
    releaseYear: 2021,
    durationMs: 5000000,
  ),
  Track(
    filePath: '/c/1.mp3',
    fileExtension: '.mp3',
    title: 'Coastlines',
    artist: 'Hollow Coast',
    album: 'Tidewater',
  ),
];

Future<void> _pump(
  WidgetTester tester, {
  TrackActions? actions,
  String? playingPath,
}) async {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  await tester.pumpWidget(
    MaterialApp(
      theme: MuziaTheme.light(),
      home: Scaffold(
        body: ArtistAlbumBrowser(
          tracks: _tracks,
          actions: actions,
          playingPath: playingPath,
          playbackActive: true,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('マスター列は332pxで件数サブヘッダと44pxサムネの行を持つ', (tester) async {
    await _pump(tester);

    expect(
      tester.getSize(find.byKey(const ValueKey('artist-master'))).width,
      332,
    );
    expect(find.text('2 アーティスト'), findsOneWidget);
    expect(find.text('名前順'), findsOneWidget);
    // 行のサブタイトルは代表ジャンル、なければ件数
    expect(find.text('Synth-pop'), findsWidgets);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('artist-row-Hollow Coast')),
        matching: find.text('1アルバム · 1曲'),
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('アーティストヒーローはアーティスト全体のメタ行と再生ボタンを持つ', (tester) async {
    Track? played;
    List<Track>? playedQueue;
    await _pump(
      tester,
      actions: TrackActions(
        onPlay: (track, {required queue}) {
          played = track;
          playedQueue = queue;
        },
        onEdit: (_, _) async => true,
        onRemove: (_) async => true,
      ),
    );

    // 最初のアーティスト（Hollow Coast）→ Midnight Arcade を選ぶ
    await tester.tap(find.byKey(const ValueKey('artist-row-Midnight Arcade')));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.byKey(const ValueKey('artist-hero-meta'))).data,
      '2アルバム · 3曲 · Synth-pop · 1時間31分',
    );
    // アルバムグリッドはカードに年を出す
    expect(
      find.byKey(const ValueKey('album-card-Parallel Lines')),
      findsOneWidget,
    );
    expect(find.text('2024'), findsOneWidget);
    // 楽曲セクションはアルバム順・トラック順
    expect(find.text('Neon Hours'), findsOneWidget);
    double y(String t) => tester.getTopLeft(find.text(t)).dy;
    expect(y('Neon Hours'), lessThan(y('Golden Static')));
    expect(y('Golden Static'), lessThan(y('Small Hour')));

    await tester.tap(find.byKey(const ValueKey('artist-play')));
    expect(played?.filePath, '/a/1.mp3');
    // 連続再生: アーティストの楽曲一覧（表示順）がキューになる
    expect(playedQueue?.map((t) => t.filePath), [
      '/a/1.mp3',
      '/a/2.mp3',
      '/b/1.mp3',
    ]);
  });

  testWidgets('アルバムカードでアルバム詳細を開き、#はトラック番号で表示する', (tester) async {
    await _pump(tester, playingPath: '/a/2.mp3');
    await tester.tap(find.byKey(const ValueKey('artist-row-Midnight Arcade')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('album-card-Parallel Lines')));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.byKey(const ValueKey('album-hero-meta'))).data,
      '2024 · 2曲 · 7分',
    );
    expect(find.text('タイトル'), findsOneWidget);
    expect(find.text('時間'), findsOneWidget);
    // 1行目はトラック番号1、2行目（再生中）はイコライザ
    final firstRow = find.byKey(const ValueKey('album-track-0'));
    expect(
      find.descendant(of: firstRow, matching: find.text('1')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('album-track-1')),
        matching: find.byKey(const ValueKey('now-playing-equalizer')),
      ),
      findsOneWidget,
    );
    expect(find.text('3:58'), findsOneWidget);
    expect(find.text('Small Hour'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('album-back')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('artist-hero-meta')), findsOneWidget);
  });

  testWidgets('楽曲行はダブルクリックで再生し、右クリックメニューから編集・削除できる', (tester) async {
    Track? played;
    List<Track>? removed;
    await _pump(
      tester,
      actions: TrackActions(
        onPlay: (track, {required queue}) => played = track,
        onEdit: (_, _) async => true,
        onRemove: (tracks) async {
          removed = tracks;
          return true;
        },
      ),
    );
    await tester.tap(find.byKey(const ValueKey('artist-row-Midnight Arcade')));
    await tester.pumpAndSettle();

    final row = find.text('Golden Static');
    await tester.tap(row);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(played?.filePath, '/a/2.mp3');

    await tester.tap(row, buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    expect(find.text('曲を再生'), findsOneWidget);
    await tester.tap(find.text('曲を編集…'));
    await tester.pumpAndSettle();
    expect(find.text('曲を編集'), findsOneWidget);
    expect(find.text('Golden Static — Parallel Lines'), findsOneWidget);
    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();

    await tester.tap(row, buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ライブラリから削除…'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'ライブラリから削除'));
    await tester.pumpAndSettle();
    expect(removed?.single.filePath, '/a/2.mp3');
  });
}
