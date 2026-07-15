import 'package:flutter/material.dart';
import 'package:mvvm_flutter_app/model/apis/api_response.dart';
import 'package:mvvm_flutter_app/model/media.dart';
import 'package:mvvm_flutter_app/view/widgets/player_list_widget.dart';
import 'package:mvvm_flutter_app/view/widgets/player_widget.dart';
import 'package:mvvm_flutter_app/view_model/media_view_model.dart';

import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _artistController = TextEditingController();
  final _filterController = TextEditingController();

  @override
  void dispose() {
    _artistController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  Widget getMediaWidget(BuildContext context, MediaViewModel viewModel, ApiResponse apiResponse) {
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        return RefreshIndicator(
          onRefresh: viewModel.refresh,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                child: TextField(
                  controller: _filterController,
                  onChanged: viewModel.updateSearchQuery,
                  decoration: InputDecoration(
                    isDense: true,
                    prefixIcon: Icon(Icons.filter_alt_outlined, size: 18),
                    suffixIcon: _filterController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _filterController.clear();
                              viewModel.clearSearchQuery();
                            },
                          ),
                    hintText: 'Filter loaded results by name...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
                  ),
                ),
              ),
              if (viewModel.refreshError != null)
                Container(
                  width: double.infinity,
                  color: Colors.red.withAlpha(30),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Refresh failed. Showing last loaded results.'),
                      ),
                      TextButton(
                        onPressed: viewModel.refresh,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              if (viewModel.isRefreshing)
                LinearProgressIndicator(minHeight: 2),
              Expanded(
                flex: 8,
                child: PlayerListWidget(viewModel.visibleMediaList, (Media media) {
                  Provider.of<MediaViewModel>(context, listen: false)
                      .setSelectedMedia(media);
                }),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: PlayerWidget(
                    function: () {
                      setState(() {});
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      case Status.ERROR:
        return Center(
          child: Text('Please try again latter!!!'),
        );
      case Status.INITIAL:
      default:
        return Center(
          child: Text('Search the song by Artist'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MediaViewModel>(context);
    ApiResponse apiResponse = viewModel.response;
    return Scaffold(
      appBar: AppBar(
        title: Text('Media Player'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary.withAlpha(50),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: TextField(
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Colors.grey,
                        ),
                        controller: _artistController,
                        onChanged: (value) {},
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            Provider.of<MediaViewModel>(context, listen: false)
                                .setSelectedMedia(null);
                            Provider.of<MediaViewModel>(context, listen: false)
                                .fetchMediaData(value);
                          }
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          hintText: 'Enter Artist Name',
                        )),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: getMediaWidget(context, viewModel, apiResponse)),
        ],
      ),
    );
  }
}
