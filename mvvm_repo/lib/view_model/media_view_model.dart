import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mvvm_flutter_app/model/apis/api_response.dart';
import 'package:mvvm_flutter_app/model/media.dart';
import 'package:mvvm_flutter_app/model/media_repository.dart';

class MediaViewModel with ChangeNotifier {
  /// [repository] is injectable (defaulting to a real [MediaRepository]) so
  /// ViewModel tests can supply a fake and never hit the live network.
  MediaViewModel({MediaRepository? repository})
      : _repository = repository ?? MediaRepository();

  final MediaRepository _repository;

  ApiResponse _apiResponse = ApiResponse.initial('Empty data');

  Media? _media;

  /// Last artist query that successfully triggered [fetchMediaData], used by
  /// [refresh] to re-run the same search without the caller having to
  /// remember/re-type it.
  String _lastQuery = '';

  bool _isRefreshing = false;
  String? _refreshError;

  Timer? _searchDebounce;
  String _searchQuery = '';

  ApiResponse get response {
    return _apiResponse;
  }

  Media? get media {
    return _media;
  }

  bool get isRefreshing => _isRefreshing;

  /// Non-null when the most recent [refresh] attempt failed; the previously
  /// loaded [response] data is left untouched so the UI can keep showing it
  /// alongside a retryable error banner.
  String? get refreshError => _refreshError;

  String get searchQuery => _searchQuery;

  /// Case-insensitive filter over the currently loaded media list. Derived
  /// on every read from [_apiResponse]/[_searchQuery] rather than mutating
  /// the original list, so clearing the query always restores every item.
  List<Media> get visibleMediaList {
    final List<Media> all =
        _apiResponse.status == Status.COMPLETED ? (_apiResponse.data as List<Media>? ?? const []) : const [];
    if (_searchQuery.isEmpty) return all;
    final query = _searchQuery.toLowerCase();
    return all.where((media) {
      return (media.trackName ?? '').toLowerCase().contains(query) ||
          (media.artistName ?? '').toLowerCase().contains(query) ||
          (media.collectionName ?? '').toLowerCase().contains(query);
    }).toList();
  }

  /// Call the media service and gets the data of requested media data of
  /// an artist.
  Future<void> fetchMediaData(String value) async {
    _lastQuery = value;
    _refreshError = null;
    clearSearchQuery();
    _apiResponse = ApiResponse.loading('Fetching artist data');
    notifyListeners();
    try {
      List<Media> mediaList = await _repository.fetchMediaList(value);
      _apiResponse = ApiResponse.completed(mediaList);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }
    notifyListeners();
  }

  /// Re-runs the last successful search. While in flight the previously
  /// loaded [response] keeps being returned so the visible list never
  /// disappears; on failure [refreshError] is set instead of overwriting
  /// [response] with an error/empty state.
  Future<void> refresh() async {
    if (_lastQuery.isEmpty || _isRefreshing) return;
    _isRefreshing = true;
    _refreshError = null;
    notifyListeners();
    try {
      final mediaList = await _repository.fetchMediaList(_lastQuery);
      _apiResponse = ApiResponse.completed(mediaList);
    } catch (e) {
      _refreshError = e.toString();
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Debounced (~400ms) so [visibleMediaList] is not recomputed/re-rendered
  /// on every keystroke while the user is still typing.
  void updateSearchQuery(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _searchQuery = query.trim();
      notifyListeners();
    });
  }

  void clearSearchQuery() {
    _searchDebounce?.cancel();
    _searchQuery = '';
    notifyListeners();
  }

  void setSelectedMedia(Media? media) {
    _media = media;
    notifyListeners();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
