class AyahTiming {
  final int ayah;
  final Duration startTime;

  const AyahTiming({required this.ayah, required this.startTime});

  factory AyahTiming.fromJson(Map<String, dynamic> json) {
    return AyahTiming(
      ayah: json['ayah'] as int,
      startTime: Duration(milliseconds: json['start_time'] as int),
    );
  }
}
