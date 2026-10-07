class AyahTiming {
  final int ayah;
  final Duration startTime;
  final Duration endTime;

  const AyahTiming({
    required this.ayah,
    required this.startTime,
    required this.endTime,
  });

  factory AyahTiming.fromJson(Map<String, dynamic> json) {
    return AyahTiming(
      ayah: json['ayah'] as int,
      startTime: Duration(milliseconds: json['start_time'] as int),
      endTime: Duration(milliseconds: json['end_time'] as int),
    );
  }
}
