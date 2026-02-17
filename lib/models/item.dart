class Item {
  final String sku;
  final String name;
  final double price;
  final int quantity;
  final String sellerId;
  final String imageLink;
  final String dateAdded;
  final String description;
  final String itemId;
  final String categoryId;
  final int unitsSold;
  final double webPrice;
  final String manufacturerId;
  final String ipId;
  final String shelfId;

  final String? categoryName;

  Item({
    required this.sku,
    required this.name,
    required this.price,
    required this.quantity,
    required this.sellerId,
    required this.imageLink,
    required this.dateAdded,
    required this.description,
    required this.itemId,
    required this.categoryId,
    required this.unitsSold,
    required this.webPrice,
    required this.manufacturerId,
    required this.ipId,
    required this.shelfId,
    this.categoryName,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      sku: map['sku'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      sellerId: map['seller_id'] ?? '',
      imageLink: map['image_link'] ?? '',
      dateAdded: map['date_added'] ?? '',
      description: map['description'] ?? '',
      itemId: map['item_id'] ?? '',
      categoryId: map['category_id'] ?? '',
      unitsSold: map['units_sold'] ?? 0,
      webPrice: (map['web_price'] ?? 0).toDouble(),
      manufacturerId: map['manufacturer_id'] ?? '',
      ipId: map['ip_id'] ?? '',
      shelfId: map['shelf_id'] ?? '',
      categoryName: map['category']?['category_name'],
    );
  }

  @override
  String toString() {
    return 'Name: $name\nCategory: $categoryName \n SKU: $sku\nPrice: \$${price.toStringAsFixed(2)}\nWeb Price: \$${webPrice.toStringAsFixed(2)}\nQuantity: $quantity\nUnits Sold: $unitsSold\nDate Added: $dateAdded\nDescription: $description\nImage: $imageLink';
  }
}
