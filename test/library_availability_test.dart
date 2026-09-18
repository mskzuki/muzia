import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/features/library/data/file_availability_service.dart';
import 'package:muzia/features/library/data/music_repository.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';

class _FixedAvailability implements FileAvailabilityService {
  _FixedAvailability(this.missing);
  final Set<String> missing;

  @override
  Future<bool> exists(String filePath) async => !missing.contains(filePath);
}

const _tracks = [
  Track(filePath: '/m/a.mp3', fileExtension: '.mp3', title: 'A'),
  Track(filePath: '/m/b.mp3', fileExtension: '.mp3', title: 'B'),
  Track(filePath: '/m/c.mp3', fileExtension: '.mp3', title: 'C'),
];

Future<LibraryViewModel> _load(Set<String> missing) async {
  final repository = InMemoryMusicRepository();
  await repository.registerFolder('/m', _tracks);
  final viewModel = LibraryViewModel(
    repository: repository,
    availabilityService: _FixedAvailability(missing),
  );
  await viewModel.initialize();
  return viewModel;
}

void main() {
  test('起動時にファイルが見つからない楽曲を利用不可としてマークする', () async {
    final viewModel = await _load({'/m/b.mp3'});

    expect(viewModel.status, LibraryStatus.ready);
    expect(viewModel.unavailableTracks.map((t) => t.title), ['B']);
    expect(viewModel.tracks.map((t) => t.isAvailable), [true, false, true]);
    expect(viewModel.showsUnavailableBanner, isTrue);
  });

  test('ファイルが再び見つかれば利用不可を解除する', () async {
    final repository = InMemoryMusicRepository();
    await repository.registerFolder('/m', [
      _tracks[0].copyWith(isAvailable: false),
      _tracks[1],
    ]);
    final viewModel = LibraryViewModel(
      repository: repository,
      availabilityService: _FixedAvailability(const {}),
    );
    await viewModel.initialize();

    expect(viewModel.unavailableTracks, isEmpty);
    expect(viewModel.showsUnavailableBanner, isFalse);
  });

  test('バナーを閉じると同じ組み合わせでは再表示せず、変化すれば再表示する', () async {
    final viewModel = await _load({'/m/b.mp3'});
    viewModel.dismissUnavailableBanner();
    expect(viewModel.showsUnavailableBanner, isFalse);

    // 利用不可の曲を削除すると組み合わせが変わる（0件なので非表示）。
    await viewModel.removeTracks(viewModel.unavailableTracks);
    expect(viewModel.unavailableTracks, isEmpty);
    expect(viewModel.showsUnavailableBanner, isFalse);
  });

  test('利用不可の楽曲を削除するとライブラリから消え、他の曲は残る', () async {
    final viewModel = await _load({'/m/a.mp3', '/m/c.mp3'});
    expect(viewModel.unavailableTracks, hasLength(2));

    expect(await viewModel.removeTracks(viewModel.unavailableTracks), isTrue);
    expect(viewModel.tracks.where((t) => !t.isRemoved).map((t) => t.title), [
      'B',
    ]);
  });
}
