class ShopItem {
  final String id;
  final String name;
  final String? description;
  final int price;
  final String category;
  final String rarity;
  final String? glbAssetPath;
  final bool isOwned;

  const ShopItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.category,
    required this.rarity,
    this.glbAssetPath,
    this.isOwned = false,
  });

  factory ShopItem.fromJson(Map<String, dynamic> json) => ShopItem(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['desc'] as String?,
        price: json['price'] as int,
        category: json['cat'] as String,
        rarity: json['rarity'] as String,
        glbAssetPath: json['glb'] as String?,
        isOwned: json['owned'] as bool? ?? false,
      );

  ShopItem copyWith({bool? isOwned}) => ShopItem(
        id: id,
        name: name,
        description: description,
        price: price,
        category: category,
        rarity: rarity,
        glbAssetPath: glbAssetPath,
        isOwned: isOwned ?? this.isOwned,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'desc': description,
        'price': price,
        'cat': category,
        'rarity': rarity,
        'glb': glbAssetPath,
        'owned': isOwned,
      };
}
