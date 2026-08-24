class DailyDeal {
  final String itemId;
  final int discountPercent;
  final DateTime expiresAt;

  const DailyDeal({
    required this.itemId,
    required this.discountPercent,
    required this.expiresAt,
  });

  factory DailyDeal.fromJson(Map<String, dynamic> json) => DailyDeal(
        itemId: json['item'] as String,
        discountPercent: json['discount'] as int,
        expiresAt: DateTime.parse(json['expires'] as String),
      );

  DailyDeal copyWith({DateTime? expiresAt}) => DailyDeal(
        itemId: itemId,
        discountPercent: discountPercent,
        expiresAt: expiresAt ?? this.expiresAt,
      );

  Map<String, dynamic> toJson() => {
        'item': itemId,
        'discount': discountPercent,
        'expires': expiresAt.toIso8601String(),
      };
}
