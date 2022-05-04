// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';
import '../widget/image_item_widget.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final FilterOptionGroup _filterOptionGroup = FilterOptionGroup(
      imageOption:
          const FilterOption(sizeConstraint: SizeConstraint(ignoreSize: true)));
  AssetPathEntity? _path;
  List<AssetEntity>? _entities;
  int _totalEntitiesCount = 0;

  final int _sizePerPage = 50; //só lượng ảnh cập nhật mỗi lần gọi

  int _page = 0; //số trang

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreToLoad = true;
  @override
  initState() {
    _requestAsset();
    super.initState();
  }

  //hàm yêu cầu truy cập ảnh
  Future<void> _requestAsset() async {
    setState(() {
      _isLoading = true;
    });
    final PermissionState _requestPer =
        await PhotoManager.requestPermissionExtend();
    if (!mounted) {
      return;
    }
    if (_requestPer != PermissionState.authorized &&
        _requestPer != PermissionState.limited) {
      setState(() {
        _isLoading = false;
      });
      showToast('Ko truy cap vao anh vui long thu lai');
      return;
    }
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        onlyAll: true, filterOption: _filterOptionGroup);
    if (!mounted) {
      return;
    }
    if (paths.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      showToast("Ko truy cap duoc vao duong dan");
    }
    setState(() {
      _path = paths.first;
    });
    _totalEntitiesCount = _path!.assetCount;
    final List<AssetEntity> entities =
        await _path!.getAssetListPaged(page: 0, size: _sizePerPage);
    if (!mounted) {
      return;
    }
    setState(() {
      _entities = entities;
      _isLoading = false;
      _hasMoreToLoad = _entities!.length < _totalEntitiesCount;
    });
  }

  //hàm load thêm ảnh nếu có sự thay đổi về số lượng
  Future<void> _loadMoreAsset() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final List<AssetEntity> entities =
        await _path!.getAssetListPaged(page: _page + 1, size: _sizePerPage);
    if (!mounted) {
      return;
    }
    setState(() {
      _entities!.addAll(entities);
      _page++;
      _hasMoreToLoad = _entities!.length < _totalEntitiesCount;
      _isLoadingMore = false;
    });
  }

  //widget xây dựng ảnh theo lưới
  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }
    if (_path == null) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Text("Chua cap quyen truy cap file"),
        ),
      );
    }
    if (_entities!.isNotEmpty != true) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Text("Ko co anh tren may"),
        ),
      );
    } else {
      return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4),
          delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == _entities!.length - 8 &&
                    !_isLoadingMore &&
                    _hasMoreToLoad) {
                  _loadMoreAsset();
                }
                final AssetEntity entity = _entities![index];
                return ImageItemWidget(
                    entity: entity,
                    option:
                        const ThumbnailOption(size: ThumbnailSize.square(200)));
              },
              childCount: _entities!.length,
              findChildIndexCallback: (Key key) {
                if (key is ValueKey<int>) {
                  return key.value;
                }
                return null;
              }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadMoreAsset,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).primaryColor,
              leading: CircleAvatar(
                  child: ClipRRect(
                child: Image.asset("assets/avatar/avatar.jpg"),
                borderRadius: const BorderRadius.all(Radius.circular(50)),
              )),
              actions: [
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert),
                    color: Colors.black),
              ],
              flexibleSpace:
                  const FlexibleSpaceBar(title: Text("Photos Gallery")),
              pinned: true,
              floating: true,
              snap: true,
              expandedHeight: 150,
            ),
            SliverPadding(
              padding: const EdgeInsets.all(5),
              sliver: _buildBody(context),
            ),
          ],
        ),
      ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: _requestAsset,
      //   child: const Icon(Icons.developer_board),
      // ),
    );
  }
}
