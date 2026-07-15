import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm_flutter_app/model/apis/api_response.dart';
import 'package:mvvm_flutter_app/model/media.dart';
import 'package:mvvm_flutter_app/model/media_repository.dart';
import 'package:mvvm_flutter_app/view_model/media_view_model.dart';

/// Fake repository so ViewModel tests never touch the live iTunes API.
class FakeMediaRepository extends MediaRepository {
  FakeMediaRepository(this._results);

  List<Media> _results;
  Object? errorToThrow;
  int callCount = 0;

  void setResults(List<Media> results) => _results = results;

  @override
  Future<List<Media>> fetchMediaList(String value) async {
    callCount++;
    if (errorToThrow != null) throw errorToThrow!;
    return _results;
  }
}

Media _media(String track, String artist) => Media(trackName: track, artistName: artist);

void main() {
  group('search (Task 5.3)', () {
    test('filters visibleMediaList case-insensitively without mutating the loaded list', () async {
      final repo = FakeMediaRepository([_media('Thriller', 'Michael Jackson'), _media('Beat It', 'Michael Jackson')]);
      final viewModel = MediaViewModel(repository: repo);

      await viewModel.fetchMediaData('michael');
      final originalList = viewModel.response.data as List<Media>;
      expect(originalList.length, 2);

      viewModel.updateSearchQuery('THRILLER');
      await Future.delayed(const Duration(milliseconds: 450));

      expect(viewModel.visibleMediaList.length, 1);
      expect(viewModel.visibleMediaList.first.trackName, 'Thriller');
      // The original loaded list must be untouched by filtering.
      expect((viewModel.response.data as List<Media>).length, 2);
    });

    test('does not refilter before the debounce window elapses', () async {
      final repo = FakeMediaRepository([_media('Thriller', 'Michael Jackson')]);
      final viewModel = MediaViewModel(repository: repo);
      await viewModel.fetchMediaData('michael');

      viewModel.updateSearchQuery('no match');
      await Future.delayed(const Duration(milliseconds: 100));

      // Still within the debounce window: query hasn't committed yet.
      expect(viewModel.visibleMediaList.length, 1);
    });

    test('clearing the query restores the full list', () async {
      final repo = FakeMediaRepository([_media('Thriller', 'Michael Jackson'), _media('Beat It', 'Michael Jackson')]);
      final viewModel = MediaViewModel(repository: repo);
      await viewModel.fetchMediaData('michael');

      viewModel.updateSearchQuery('thriller');
      await Future.delayed(const Duration(milliseconds: 450));
      expect(viewModel.visibleMediaList.length, 1);

      viewModel.clearSearchQuery();
      expect(viewModel.visibleMediaList.length, 2);
    });
  });

  group('refresh (Task 5.4)', () {
    test('success replaces the visible list with fresh data', () async {
      final repo = FakeMediaRepository([_media('Old Song', 'Artist')]);
      final viewModel = MediaViewModel(repository: repo);
      await viewModel.fetchMediaData('artist');

      repo.setResults([_media('New Song', 'Artist')]);
      await viewModel.refresh();

      expect(viewModel.response.status, Status.COMPLETED);
      expect((viewModel.response.data as List<Media>).first.trackName, 'New Song');
      expect(viewModel.refreshError, isNull);
    });

    test('failure keeps the previously loaded data visible and sets a retryable error', () async {
      final repo = FakeMediaRepository([_media('Old Song', 'Artist')]);
      final viewModel = MediaViewModel(repository: repo);
      await viewModel.fetchMediaData('artist');

      repo.errorToThrow = Exception('network down');
      await viewModel.refresh();

      expect(viewModel.response.status, Status.COMPLETED);
      expect((viewModel.response.data as List<Media>).first.trackName, 'Old Song');
      expect(viewModel.refreshError, isNotNull);
      expect(viewModel.isRefreshing, isFalse);
    });
  });
}
