import 'dart:typed_data';

/*
 * A Serializable image class.
 * This is used to serialize correctly an image data.
 * 
 * 21/02/2025 @ Luca Raffo
 */
class WallpaperSerializableImage {
  final int width;
  final int height;
  final ByteBuffer buffer;

  WallpaperSerializableImage({
    required this.width,
    required this.height,
    required this.buffer,
  });

  Map<String, dynamic> toJson() => {
    'width': width,
    'height': height,
    'buffer': buffer, 
  };

  factory WallpaperSerializableImage.fromJson(Map<String, dynamic> json) {
    return WallpaperSerializableImage(
      width: json['width'],
      height: json['height'],
      buffer: json['buffer'],
    );
  }
}
