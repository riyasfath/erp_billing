class TermsItem {
  final int id;
  final String title;
  final DateTime? createdAt;

  TermsItem({
    required this.id,
    required this.title,
    this.createdAt,
  });

  factory TermsItem.fromJson(Map<String, dynamic> json) {
    return TermsItem(
      id: (json['id'] is int)
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      title: json['title']?.toString() ?? '',
      createdAt: (json['created_at'] != null)
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
