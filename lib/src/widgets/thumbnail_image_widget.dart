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

  /// background image color
  final Color imageBackgroundColor;

  /// image provider
  final PickerDataProvider provider;

  /// selected background color
  final Color selectedBackgroundColor;

  /// builder icon selection
  final SelectionWidgetBuilder? selectionBuilder;

  final bool Function(AssetEntity)? onEnableItem;

  /// selected Check Background Color
  final Color selectedCheckBackgroundColor;

  /// thumbnail box fit
  final BoxFit fit;

  const ThumbnailImageWidget({
    Key? key,
    required this.asset,
    required this.provider,
    this.thumbnailQuality = 200,
    this.imageBackgroundColor = Colors.white,
    this.selectedBackgroundColor = Colors.white,
    this.fit = BoxFit.cover,
    this.selectedCheckBackgroundColor = Colors.white,
    this.selectionBuilder,
    this.onEnableItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(color: imageBackgroundColor),
        ),

        /// thumbnail image
        FutureBuilder<Uint8List?>(
          future: asset.thumbnailDataWithSize(
              ThumbnailSize(thumbnailQuality, thumbnailQuality)),
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
              return Container();
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: picked
                        ? selectedBackgroundColor.withOpacity(0.5)
                        : Colors.transparent,
                  ),
                ),

                /// selected image check
                selectionBuilder != null
                    ? selectionBuilder!.call(context, picked, pickIndex)
                    : defaultIconSelectionBuilder(context, picked),

                /// check media enable
                if (onEnableItem?.call(asset) == false)
                  Container(
                    decoration: BoxDecoration(
                      color: selectedBackgroundColor.withOpacity(0.5),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.warning_amber_outlined,
                        color: Colors.white, size: 40),
                  ),
              ],
            );
          },
        ),

        /// video duration widget
        if (asset.type == AssetType.video)
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(right: 5, bottom: 5),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 40,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        _parseDuration(asset.videoDuration.inSeconds),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                    ],
                  )),
            ),
          )
      ],
    );
  }

  Widget defaultIconSelectionBuilder(BuildContext context, bool picked) {
    return Align(
      alignment: Alignment.topRight,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: picked ? 1 : 0,
        child: Container(
          height: 30,
          width: 30,
          margin: const EdgeInsets.only(right: 5, top: 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: picked
                ? selectedCheckBackgroundColor.withOpacity(0.6)
                : Colors.transparent,
            border: Border.all(width: 1.5, color: Colors.white),
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

/// parse second to duration
_parseDuration(int seconds) {
  if (seconds < 600) {
    return '${Duration(seconds: seconds)}'.toString().substring(3, 7);
  } else if (seconds > 600 && seconds < 3599) {
    return '${Duration(seconds: seconds)}'.toString().substring(2, 7);
  } else {
    return '${Duration(seconds: seconds)}'.toString().substring(1, 7);
  }
}
