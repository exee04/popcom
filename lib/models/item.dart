enum ItemStatus { approved, pending, pulledOut }

class Item {
  final String sku;
  final String name;
  final double storePrice;
  final int quantity;
  final String sellerId;
  final String? imageFolderLink;
  final String? dateAdded;
  final String? description;
  final String itemId;
  final String? categoryId;
  final int unitsSold;
  final double? webPrice;
  final String? manufacturerId;
  final String? ipId;
  final String? shelfId;

  final String? categoryName;
  final String? manufacturerName;
  final String? shelfNumber;
  final String? ipName;

  final bool isPulledOut;
  final bool isDiscounted;
  final double discountRate;
  final bool isApproved;
  final String? thumbnailImgLink;

  Item({
    required this.sku,
    required this.name,
    required this.storePrice,
    required this.quantity,
    required this.sellerId,
    this.imageFolderLink,
    this.dateAdded,
    this.description,
    required this.itemId,
    this.categoryId,
    required this.unitsSold,
    this.webPrice,
    this.manufacturerId,
    this.manufacturerName,
    this.shelfNumber,
    this.ipName,
    this.ipId,
    this.shelfId,
    required this.isPulledOut,
    required this.isDiscounted,
    required this.discountRate,
    required this.isApproved,
    this.thumbnailImgLink,
    this.categoryName,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      sku: map['sku'] ?? '',
      name: map['name'] ?? '',
      storePrice: (map['store_price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      sellerId: map['seller_id'] ?? '',
      imageFolderLink: map['image_folder_link'],
      dateAdded: map['date_added']?.toString(),
      description: map['description'],
      itemId: map['item_id'] ?? '',
      categoryId: map['category_id'],
      unitsSold: map['units_sold'] ?? 0,
      webPrice: map['web_price'] != null
          ? (map['web_price'] as num).toDouble()
          : null,
      manufacturerId: map['manufacturer_id'],
      ipId: map['ip_id'],
      shelfId: map['shelf_id'],
      isPulledOut: map['is_pulled_out'] ?? false,
      isDiscounted: map['is_discounted'] ?? false,
      discountRate: (map['discount_rate'] ?? 0).toDouble(),
      isApproved: map['is_approved'] ?? true,
      thumbnailImgLink: map['thumbnail_img_link'],

      // joined names
      categoryName: map['category']?['category_name'],
      manufacturerName: map['manufacturer']?['name'],
      shelfNumber: map['shelf']?['shelf_num']?.toString(),
      ipName: map['ip']?['ip_name'],
    );
  }

  @override
  String toString() {
    return '''
Name: $name
Category: $categoryName
SKU: $sku
Store Price: ₱${storePrice.toStringAsFixed(2)}
Web Price: ${webPrice != null ? "₱${webPrice!.toStringAsFixed(2)}" : "N/A"}
Quantity: $quantity
Units Sold: $unitsSold
Pulled Out: $isPulledOut
Discounted: $isDiscounted
Discount Rate: ${discountRate * 100}%
Approved: $isApproved
Date Added: $dateAdded
Description: $description
Thumbnail: $thumbnailImgLink
Image Folder: $imageFolderLink
''';
  }
}
