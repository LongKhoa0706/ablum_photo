import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:photo_manager/photo_manager.dart';

class ThumbnailPath extends ImageProvider<ThumbnailPath> {
  final AssetPathEntity entity;
  final double scale;
  final int thumbSize;
  final int index;

  const ThumbnailPath(
    this.entity, {
    this.scale = 1.0,
    this.thumbSize = 120,
    this.index = 0,
  });

  @override
  ImageStreamCompleter loadBuffer(
      ThumbnailPath key, DecoderBufferCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
    );
  }

  Future<ui.Codec> _loadAsync(
      ThumbnailPath key, DecoderBufferCallback decode) async {
    assert(key == this);

    final coverEntity =
        (await key.entity.getAssetListRange(start: index, end: index + 1))
            .first;

    final bytes = await coverEntity
        .thumbnailDataWithSize(ThumbnailSize(thumbSize, thumbSize));

    final fromUint8List = await ImmutableBuffer.fromUint8List(bytes!);

    return decode(fromUint8List);
  }

  @override
  Future<ThumbnailPath> obtainKey(ImageConfiguration configuration) async {
    return this;
  }
}
