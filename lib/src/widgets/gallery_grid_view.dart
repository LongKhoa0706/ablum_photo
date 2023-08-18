// ignore_for_file: use_build_context_synchronously

import 'package:album_image/src/album_image_picker.dart';
import 'package:album_image/src/controller/gallery_provider.dart';
import 'package:album_image/src/widgets/thumbnail_image_widget.dart';
import 'package:flutter/material.dart';

import 'package:photo_manager/photo_manager.dart';

typedef OnAssetItemClick = void Function(BuildContext context, AssetEntity entity, int index);

class GalleryGridView extends StatefulWidget {
  /// asset album
  final AssetPathEntity path;

  /// on tap thumbnail
  final OnAssetItemClick? onAssetItemClick;

  /// picker data provider
  final PickerDataProvider provider;

  /// gridView background color
  final Color gridViewBackgroundColor;

  /// gridView physics
  final ScrollPhysics? gridViewPhysics;

  /// gridView controller
  final ScrollController? gridViewController;

  /// builder icon selection
  final DisableWidgetBuilder? disableBuilder;

  /// thumbnail box fit
  final BoxFit thumbnailBoxFix;

  /// image quality thumbnail
  final int thumbnailQuality;

  /// check enable item
  final bool Function(AssetEntity)? onEnableItem;

  const GalleryGridView(
      {Key? key,
      required this.path,
      required this.provider,
      this.onAssetItemClick,
      this.gridViewBackgroundColor = Colors.white,
      this.gridViewController,
      this.gridViewPhysics,
      this.thumbnailBoxFix = BoxFit.cover,
      this.thumbnailQuality = 200,
      this.disableBuilder,
      this.onEnableItem})
      : super(key: key);

  @override
  GalleryGridViewState createState() => GalleryGridViewState();
}

class GalleryGridViewState extends State<GalleryGridView> {
  static Map<int?, AssetEntity?> _createMap() {
    return {};
  }

  /// create cache for images
  var cacheMap = _createMap();

  /// notifier for scroll events
  final scrolling = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: FutureBuilder<int>(
          future: widget.path.assetCountAsync,
          builder: (context, snapshot) {
            if ((snapshot.data ?? 0) == 0) {
              return Icon(
                Icons.perm_media,
                color: Colors.grey.shade300,
                size: 100,
              );
            }
            return GridView.builder(
              key: ValueKey(widget.path),
              padding: const EdgeInsets.symmetric(horizontal: 1),
              physics: widget.gridViewPhysics,
              controller: widget.gridViewController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 0.78,
                crossAxisCount: screenWidth <= 400
                    ? 3
                    : screenWidth <= 600
                        ? 4
                        : 5,
                mainAxisSpacing: 1.5,
                crossAxisSpacing: 1.5,
              ),

              /// render thumbnail
              itemBuilder: (context, index) => _buildItem(context, index, widget.provider),
              itemCount: snapshot.data ?? 0,
            );
          }),
    );
  }

  Widget _buildItem(BuildContext context, index, PickerDataProvider provider) {
    return GestureDetector(
      /// on tap thumbnail
      onTap: () async {
        final asset = cacheMap[index] ??
            (await widget.path.getAssetListRange(start: index, end: index + 1))[0];
        if (widget.onEnableItem?.call(asset) != false) {
          widget.onAssetItemClick?.call(context, asset, index);
        }
      },

      /// render thumbnail
      child: _buildScrollItem(context, index, provider),
    );
  }

  Widget _buildScrollItem(BuildContext context, int index, PickerDataProvider provider) {
    /// load cache images
    return FutureBuilder<List<AssetEntity>>(
      future: widget.path.getAssetListRange(start: index, end: index + 1),
      builder: (ctx, snapshot) {
        final cachedImage = cacheMap[index];
        if (cachedImage == null && (!snapshot.hasData || snapshot.data!.isEmpty)) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey.shade200,
          );
        }

        final asset = cachedImage ?? snapshot.data!.first;
        cacheMap[index] = asset;

        /// thumbnail widget
        return ThumbnailImageWidget(
          asset: asset,
          provider: provider,
          thumbnailQuality: widget.thumbnailQuality,
          disableBuilder: widget.disableBuilder,
          fit: widget.thumbnailBoxFix,
          onEnableItem: widget.onEnableItem,
        );
      },
    );
  }

  /// scroll notifier
  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      scrolling.value = false;
    } else if (notification is ScrollStartNotification) {
      scrolling.value = true;
    }
    return false;
  }

  /// update widget on scroll
  @override
  void didUpdateWidget(GalleryGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      cacheMap.clear();
      scrolling.value = false;
      if (mounted) {
        setState(() {});
      }
    }
  }
}
