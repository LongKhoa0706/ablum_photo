import 'package:album_image/src/controller/gallery_provider.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class AppBarAlbum extends StatelessWidget {
  /// picker provider
  final PickerDataProvider provider;

  final Color appBarColor;

  /// appBar leading widget
  final Widget? appBarLeadingWidget;

  ///appBar actions widgets
  final List<Widget>? appBarActionWidgets;

  final double height;

  final bool centerTitle;

  final Widget? emptyAlbumThumbnail;

  const AppBarAlbum(
      {Key? key,
      required this.provider,
      required this.appBarColor,
      this.height = 65,
      this.centerTitle = true,
      this.appBarLeadingWidget,
      this.appBarActionWidgets,
      this.emptyAlbumThumbnail})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: provider.currentPathNotifier,
      builder: (_, value, __) => AppBar(
        automaticallyImplyLeading: false,
        leading: appBarLeadingWidget,
        toolbarHeight: height,
        backgroundColor: appBarColor,
        actions: appBarActionWidgets,
        title: _buildAlbumButton(context, ValueNotifier(false)),
        centerTitle: centerTitle,
      ),
    );
  }

  Widget _buildAlbumButton(
    BuildContext context,
    ValueNotifier<bool> arrowDownNotifier,
  ) {
    if (provider.pathList.isEmpty || provider.currentPath == null) {
      return const SizedBox.shrink();
    }

    final decoration = BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(35),
    );
    if (provider.currentPath == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: decoration,
      );
    } else {
      return Scrollbar(
        thumbVisibility: true,
        child: PopupMenuButton<AssetPathEntity>(
          constraints: const BoxConstraints(minHeight: 10, maxHeight: 250),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          offset: const Offset(0, 30),
          onSelected: (val) {
            provider.currentPath = val;
          },
          itemBuilder: (BuildContext context) {
            return provider.pathList
                .map(
                  (e) => PopupMenuItem<AssetPathEntity>(
                    value: e,
                    padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                    child: FutureBuilder(
                      future: e.assetCountAsync,
                      builder: (context, snapshot) {
                        return Text(
                          '${e.name} (${snapshot.data})',
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        );
                      },
                    ),
                  ),
                )
                .toList();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                provider.currentPath!.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal),
              ),
              const SizedBox(width: 3),
              const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 18),
            ],
          ),
        ),
      );
    }
  }
}
