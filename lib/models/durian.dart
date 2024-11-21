// class Durian {
//   final int? id;
//   final String ripenessLevel;
//   final String timestamp;
//   final String imagePath;

//   Durian({
//     this.id,
//     required this.ripenessLevel,
//     required this.timestamp,
//     required this.imagePath,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'ripeness_level': ripenessLevel,
//       'timestamp': timestamp,
//       'image_path': imagePath,
//     };
//   }

//   factory Durian.fromMap(Map<String, dynamic> map) {
//     return Durian(
//       imagePath: map['image_path'],
//       ripenessLevel: map['ripeness_level'],
//       timestamp: map['timestamp'],
//     );
//   }
// }

