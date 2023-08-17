import 'package:album_image/src/controller/gallery_provider.dart';
import 'package:album_image/src/widgets/app_bar_album.dart';
import 'package:album_image/src/widgets/gallery_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'enum/album_type.dart';

typedef DisableWidgetBuilder = Widget Function(BuildContext context, AssetEntity item, int index);

class AlbumImagePicker extends StatefulWidget {
  /// maximum images allowed (default 1)
  final int maxSelectionImage;

  /// maximum images allowed (default 1)
  final int maxSelectionVideo;

  /// preSelected images
  final List<AssetEntity>? selected;

  /// The album type when requesting paths.
  ///
  ///  * [all] - Request paths that return images and videos.
  ///  * [image] - Request paths that only return images.
  ///  * [video] - Request paths that only return videos.
  final AlbumType type;

  /// image quality thumbnail
  final int thumbnailQuality;

  /// On reach max
  final VoidCallback? onSelectedMaxVideo;

  final VoidCallback? onSelectedMaxImage;

  /// thumbnail box fit
  final BoxFit thumbnailBoxFix;

  /// gridView physics
  final ScrollPhysics? scrollPhysics;

  /// gridView controller
  final ScrollController? scrollController;

  /// dropdown appbar color
  final Color appBarColor;

  ///Icon widget builder
  ///index = -1, not selected yet
  final DisableWidgetBuilder? disableBuilder;

  ///Close widget
  final Widget? closeWidget;

  ///appBar actions widgets
  final List<Widget>? appBarActionWidgets;

  /// album text color
  final double appBarHeight;

  /// check enable item
  final bool Function(AssetEntity)? onEnableItem;

  const AlbumImagePicker(
      {Key? key,
      this.maxSelectionImage = 1,
      this.maxSelectionVideo = 1,
      this.selected,
      this.type = AlbumType.all,
      this.thumbnailBoxFix = BoxFit.cover,
      this.thumbnailQuality = 200,
      this.appBarColor = Colors.white,
      this.appBarHeight = 45,
      this.appBarActionWidgets,
      this.closeWidget,
      this.disableBuilder,
      this.scrollPhysics,
      this.scrollController,
      this.onSelectedMaxVideo,
      this.onSelectedMaxImage,
      this.onEnableItem})
      : super(key: key);

  @override
  AlbumImagePickerState createState() => AlbumImagePickerState();
}

class AlbumImagePickerState extends State<AlbumImagePicker> with AutomaticKeepAliveClientMixin {
  /// create object of PickerDataProvider
  late PickerDataProvider provider;

  @override
  void initState() {
    _initProvider();
    _getPermission();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AlbumImagePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.maxSelectionImage != widget.maxSelectionImage) {
      provider.maxImage = widget.maxSelectionImage;
    }

    if (oldWidget.maxSelectionVideo != widget.maxSelectionVideo) {
      provider.maxVideo = widget.maxSelectionVideo;
    }
    if (oldWidget.type != widget.type) {
      _refreshPathList();
    }
  }

  void _initProvider() {
    provider = PickerDataProvider(
        picked: widget.selected ?? [],
        maxSelectionImageCount: widget.maxSelectionImage,
        maxSelectionVideoCount: widget.maxSelectionVideo);
    provider.onPickMaxImage.addListener(onPickMaxImage);
    provider.onPickMaxVideo.addListener(onPickMaxVideo);
  }

  void _getPermission() async {
    var result = await PhotoManager.requestPermissionExtend(
        requestOption: const PermissionRequestOption(iosAccessLevel: IosAccessLevel.readWrite));
    if (result.isAuth) {
      PhotoManager.startChangeNotify();
      PhotoManager.addChangeCallback((value) {
        _refreshPathList();
      });

      if (provider.pathList.isEmpty) {
        _refreshPathList();
      }
    } else {
      PhotoManager.openSetting();
    }
  }

  void _refreshPathList() {
    late RequestType type;
    switch (widget.type) {
      case AlbumType.all:
        type = RequestType.common;
        break;
      case AlbumType.image:
        type = RequestType.image;
        break;
      case AlbumType.video:
        type = RequestType.video;
        break;
    }
    PhotoManager.getAssetPathList(type: type).then((pathList) {
      /// don't delete setState
      setState(() {
        provider.resetPathList(pathList);
      });
    });
  }

  void onPickMaxVideo() {
    widget.onSelectedMaxVideo?.call();
  }

  void onPickMaxImage() {
    widget.onSelectedMaxImage?.call();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          /// album drop down
          AppBarAlbum(
            provider: provider,
            appBarColor: widget.appBarColor,
            height: widget.appBarHeight,
            appBarLeadingWidget: widget.closeWidget,
            appBarActionWidgets: [
              ...widget.appBarActionWidgets ?? [],
              const SizedBox(width: 15),
              TextButton(
                  onPressed: () => Navigator.pop(context, provider.picked),
                  child: const Text('Done')),
              const SizedBox(width: 5),
            ],
          ),

          /// grid image view
          Expanded(
            child: ValueListenableBuilder<AssetPathEntity?>(
              valueListenable: provider.currentPathNotifier,
              builder: (context, currentPath, child) => currentPath != null
                  ? GalleryGridView(
                      path: currentPath,
                      thumbnailQuality: widget.thumbnailQuality,
                      provider: provider,
                      gridViewBackgroundColor: Colors.white,
                      gridViewController: widget.scrollController,
                      gridViewPhysics: widget.scrollPhysics,
                      disableBuilder: widget.disableBuilder,
                      thumbnailBoxFix: widget.thumbnailBoxFix,
                      onAssetItemClick: (ctx, asset, index) async {
                        provider.pickEntity(asset);
                      },
                      onEnableItem: widget.onEnableItem,
                    )
                  : const SizedBox.shrink(),
            ),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
