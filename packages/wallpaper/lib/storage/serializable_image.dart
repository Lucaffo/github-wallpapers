import 'dart:typed_data';

/*
 * Serializable Image class.
 * This is used to serialize correctly an image data.
 * 
 * 21/02/2025 @ Luca Raffo
 */
class SerializableImage {

  DateTime time;
  final int width;
  final int height;
  final ByteBuffer buffer;

  SerializableImage({
    required this.time,
    required this.width,
    required this.height,
    required this.buffer,
  });

  Map<String, dynamic> toJson() => {
    'time': time,
    'width': width,
    'height': height,
    'buffer': buffer, 
  };

  factory SerializableImage.fromJson(Map<String, dynamic> json) {
    return SerializableImage(
      time: json['time'] ?? DateTime.now(),
      width: json['width'],
      height: json['height'],
      buffer: json['buffer'],
    );
  }
}
