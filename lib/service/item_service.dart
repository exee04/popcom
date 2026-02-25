import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:popcom/models/item.dart';

class ItemService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch ALL items (temporary)
  Future<List<Item>> fetchItems({
    String? search,
    ItemStatus? status,
    String sortField = 'date_added',
    bool ascending = false,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("User not authenticated");

    var query = _supabase
        .from('Item')
        .select('''
        *,
        category:Categories(category_name),
        manufacturer:Manufacturer(name),
        shelf:Shelf(shelf_num),
        ip:Intellectual_Property(ip_name)
      ''')
        .eq('seller_id', user.id);

    /// SEARCH
    if (search != null && search.isNotEmpty) {
      query = query.or('name.ilike.%$search%,sku.ilike.%$search%');
    }

    /// STATUS FILTER
    if (status != null) {
      switch (status) {
        case ItemStatus.approved:
          query = query.eq('is_approved', true).eq('is_pulled_out', false);
          break;

        case ItemStatus.pending:
          query = query.eq('is_approved', false).eq('is_pulled_out', false);
          break;

        case ItemStatus.pulledOut:
          query = query.eq('is_pulled_out', true);
          break;
      }
    }

    /// SORT WHITELIST
    const allowedSortFields = [
      'name',
      'sku',
      'store_price',
      'quantity',
      'date_added',
      'units_sold',
    ];

    if (!allowedSortFields.contains(sortField)) {
      sortField = 'date_added';
    }

    final data = await query.order(sortField, ascending: ascending);

    return (data as List).map((e) => Item.fromMap(e)).toList();
  }

  /// CATEGORY OPTIONS
  Future<List<Map<String, dynamic>>> fetchCategoryOptions() async {
    final data = await _supabase
        .from('Categories')
        .select('category_id, category_name')
        .order('category_name');
    return List<Map<String, dynamic>>.from(data);
  }

  /// MANUFACTURER OPTIONS
  Future<List<Map<String, dynamic>>> fetchManufacturerOptions() async {
    final data = await _supabase
        .from('Manufacturer')
        .select('manufacturer_id, name')
        .order('name');
    return List<Map<String, dynamic>>.from(data);
  }

  /// IP OPTIONS
  Future<List<Map<String, dynamic>>> fetchIPOptions() async {
    final data = await _supabase
        .from('Intellectual_Property')
        .select('ip_id, ip_name')
        .order('ip_name');
    return List<Map<String, dynamic>>.from(data);
  }

  /// SHELF OPTIONS
  /// TEMP: returns all shelves
  /// FUTURE: filter by renter
  Future<List<Map<String, dynamic>>> fetchShelfOptions() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      print("No logged-in user.");
      return [];
    }

    final userId = user.id;
    print("trying to get renters");
    // STEP 1: get renter_id from profile
    final renterRes = await _supabase
        .from('Renter')
        .select('renter_id')
        .eq('profile_id', userId)
        .maybeSingle();

    if (renterRes == null) {
      print("User has no renter record.");
      return [];
    }
    print("Renter record: $renterRes");
    final renterId = renterRes['renter_id'];

    // STEP 2: get shelves assigned to renter
    final data = await _supabase
        .from('Renter_Shelf')
        .select('''
        Shelf (
          shelf_id,
          shelf_num
        )
      ''')
        .eq('renter_id', renterId);

    print("RENTED SHELVES RAW:");
    print(data);

    // STEP 3: extract Shelf objects
    final shelves = (data as List)
        .map((e) => e['Shelf'])
        .where((shelf) => shelf != null)
        .cast<Map<String, dynamic>>()
        .toList();

    print("FILTERED SHELF OPTIONS:");
    print(shelves);

    return shelves;
  }

  /// ADD ITEM
  Future<Map<String, dynamic>> addItem({
    required String name,
    required double storePrice,
    required int quantity,
    required String categoryId,
    required String manufacturerId,
    required String ipId,
    required String shelfId,
    required String description,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not authenticated");
    }

    final result = await _supabase
        .from('Item')
        .insert({
          'name': name,
          'store_price': storePrice,
          'quantity': quantity,
          'category_id': categoryId,
          'manufacturer_id': manufacturerId,
          'ip_id': ipId,
          'shelf_id': shelfId,
          'description': description,
          'seller_id': user.id,
        })
        .select()
        .single();

    return result;
  }

  Future<String> uploadThumbnail({
    required XFile image,
    required String renterId,
    required String sku,
  }) async {
    final fileBytes = await image.readAsBytes();

    final path = "$renterId/$sku/thumbnail.jpg";

    await _supabase.storage.from('item_images').uploadBinary(path, fileBytes);

    final publicUrl = _supabase.storage.from('item_images').getPublicUrl(path);

    return publicUrl;
  }

  Future<String> uploadItemImages({
    required List<XFile> images,
    required String renterId,
    required String sku,
  }) async {
    final folderPath = "$renterId/$sku/images";

    for (final image in images) {
      final fileBytes = await image.readAsBytes();
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";

      await _supabase.storage
          .from('item_images')
          .uploadBinary("$folderPath/$fileName", fileBytes);
    }

    return folderPath; // we store folder, not URLs
  }

  Future<void> updateItemImages({
    required String sku,
    required String thumbnailUrl,
    required String imageFolderPath,
  }) async {
    final updated = await _supabase
        .from('Item')
        .update({
          'thumbnail_img_link': thumbnailUrl,
          'image_folder_link': imageFolderPath,
        })
        .eq('sku', sku)
        .select();

    print("Updated result: $updated");
  }

  Future<List<String>> fetchItemGallery(String folderPath) async {
    if (folderPath.isEmpty) return [];

    // remove trailing slash if exists
    folderPath = folderPath.endsWith('/')
        ? folderPath.substring(0, folderPath.length - 1)
        : folderPath;

    print("Listing storage folder: $folderPath");

    final files = await _supabase.storage
        .from('item_images')
        .list(path: folderPath);

    print("Files returned: $files");

    final urls = files.map((file) {
      final fullPath = "$folderPath/${file.name}";
      return _supabase.storage.from('item_images').getPublicUrl(fullPath);
    }).toList();

    return urls;
  }
}
