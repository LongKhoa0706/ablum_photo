import 'dart:typed_data';
import 'package:album_image/src/album_image_picker.dart';
import 'package:album_image/src/controller/gallery_provider.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class ThumbnailImageWidget extends StatelessWidget {
  /// asset entity
  final AssetEntity asset;

  /// image quality thumbnail
  final int thumbnailQuality;

  /// image provider
  final PickerDataProvider provider;

  /// builder icon selection
  final DisableWidgetBuilder? disableBuilder;

  final bool Function(AssetEntity)? onEnableItem;

  /// thumbnail box fit
  final BoxFit fit;

  const ThumbnailImageWidget({
    Key? key,
    required this.asset,
    required this.provider,
    this.thumbnailQuality = 200,
    this.fit = BoxFit.cover,
    this.disableBuilder,
    this.onEnableItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        /// thumbnail image
        FutureBuilder<Uint8List?>(
          future: asset.thumbnailDataWithSize(ThumbnailSize(thumbnailQuality, thumbnailQuality)),
          builder: (_, data) {
            if (data.hasData && data.data != null) {
              return SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Image.memory(
                  data.data!,
                  gaplessPlayback: true,
                  fit: fit,
                ),
              );
            } else {
              return Container(
                color: Colors.grey.shade200,
              );
            }
          },
        ),

        /// selected image color mask
        /// icon selection
        AnimatedBuilder(
          animation: provider,
          builder: (_, __) {
            final pickIndex = provider.pickIndex(asset);
            final picked = pickIndex >= 0;
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: picked ? Colors.grey.withOpacity(0.5) : Colors.transparent,
                    border: Border.all(
                      color: picked ? Theme.of(context).primaryColor : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),

                /// selected image check
                defaultIconSelectionBuilder(context, picked),

                /// check media enable
                if (onEnableItem?.call(asset) == false)
                  disableBuilder?.call(context, asset, pickIndex) ??
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        alignment: Alignment.center,
                        child:
                            const Icon(Icons.warning_amber_outlined, color: Colors.white, size: 40),
                      ),
              ],
            );
          },
        ),

        /// video duration widget
        if (asset.type == AssetType.video)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.video_camera_back_sharp,
                    color: Colors.white,
                    size: 18,
                  ),
                  Text(
                    _parseDuration(asset.videoDuration.inSeconds),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget defaultIconSelectionBuilder(BuildContext context, bool picked) {
    return Align(
      alignment: Alignment.topRight,
      child: Opacity(
        opacity: picked ? 1 : 0,
        child: Container(
          height: 22,
          width: 22,
          margin: const EdgeInsets.only(right: 5, top: 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: picked ? Theme.of(context).primaryColor : Colors.transparent,
            border: Border.all(width: 1.5, color: Colors.white),
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 13,
          ),
        ),
      ),
    );
  }
}

/// parse second to duration
String _parseDuration(int seconds) {
  if (seconds < 600) {
    return '${Duration(seconds: seconds)}'.toString().substring(3, 7);
  } else if (seconds > 600 && seconds < 3599) {
    return '${Duration(seconds: seconds)}'.toString().substring(2, 7);
  } else {
    return '${Duration(seconds: seconds)}'.toString().substring(1, 7);
  }
}
