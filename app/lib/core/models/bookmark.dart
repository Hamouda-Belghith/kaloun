class Bookmark {
  final int page;
  final DateTime createdAt;
  final String? label;

  const Bookmark({required this.page, required this.createdAt, this.label});

  Map<String, dynamic> toJson() => {
        'page': page,
        'createdAt': createdAt.toIso8601String(),
        'label': label,
      };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        page: json['page'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        label: json['label'] as String?,
      );
}
