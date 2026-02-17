import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:popcom/models/item.dart';

class ItemService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch items with category name
  Future<List<Item>> fetchItems() async {
    final data = await _supabase
        .from('Item')
        .select('*, category:Categories(category_name)');

    return (data as List).map<Item>((item) => Item.fromMap(item)).toList();
  }

  /// Insert new item
  Future<void> addItem(Item item) async {
    await _supabase.from('Item').insert({
      'sku': item.sku,
      'name': item.name,
      'price': item.price,
      'quantity': item.quantity,
      'seller_id': item.sellerId,
      'image_link': item.imageLink,
      'description': item.description,
      'category_id': item.categoryId,
      'web_price': item.webPrice,
      'manufacturer_id': item.manufacturerId,
      'ip_id': item.ipId,
      'shelf_id': item.shelfId,
    });
  }
}
