import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:popcom/models/item.dart';
import 'package:popcom/pages/item_view_page.dart';
import 'package:popcom/service/item_service.dart';
import 'package:popcom/widget/add_item_modal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

double rs(BuildContext context, double size) {
  final width = MediaQuery.of(context).size.width;
  return size * (width / 375).clamp(0.9, 1.2);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();
  final ItemService _itemService = ItemService();
  List<Item> _items = [];
  bool _isLoading = true;
  Timer? _debounce;

  ItemStatus? _selectedStatus; // For filtering, null = All
  bool _isGrid = true;
  String _sortField = 'date_added'; // default sort field
  bool _ascending = false; // default sort is ascending

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);

    try {
      final items = await _itemService.fetchItems(
        search: _searchController.text,
        status: _selectedStatus,
        sortField: _sortField,
        ascending: _ascending,
      );

      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading items: $e");
      setState(() => _isLoading = false);
    }
  }

  // grid view widget
  Widget _buildGridView(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final crossAxisCount = width < 600 ? 2 : 3;

        return GridView.builder(
          padding: EdgeInsets.only(
            top: rs(context, 20),
            bottom: rs(context, 5),
          ),
          itemCount: _items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: rs(context, 12),
            mainAxisSpacing: rs(context, 12),
            childAspectRatio: crossAxisCount == 2 ? 0.72 : 0.62,
          ),
          itemBuilder: (context, index) {
            final item = _items[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ItemViewPage(item: item)),
                );
              },
              child: _itemCard(context, item),
            );
          },
        );
      },
    );
  }

  // list view widget
  Widget _buildListView(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.only(top: rs(context, 20), bottom: rs(context, 5)),
      itemCount: _items.length,
      separatorBuilder: (_, ___) => SizedBox(height: rs(context, 12)),
      itemBuilder: (context, index) {
        final item = _items[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ItemViewPage(item: item)),
            );
          },
          child: _itemCard(context, item, isList: true),
        );
      },
    );
  }

  // temp sort function
  void _changeSort(String field, bool ascending) {
    setState(() {
      _sortField = field;
      _ascending = ascending;
    });
    _loadItems();
  }

  Widget _itemCard(BuildContext context, Item item, {bool isList = false}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ItemViewPage(item: item)),
        );
      },
      child: _buildGlassCard(context, item, isList: isList),
    );
  }

  // Sort options
  Widget _sortMenu(BuildContext context) {
    final icon = _ascending ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      height: rs(context, 35),
      width: rs(context, 35),
      decoration: BoxDecoration(
        color: const Color(0xFFFDC62D).withOpacity(0.85),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black87),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(0, 4))],
      ),
      child: PopupMenuButton<String>(
        icon: Icon(icon, color: Colors.black87, size: rs(context, 18)),
        onSelected: (value) {
          final parts = value.split('_');
          _changeSort(parts[0], parts[1] == 'asc');
        },
        itemBuilder: (_) => [
          _sortItem("name", true, "Item Name (Asc)"),
          _sortItem("name", false, "Item Name (Desc)"),
          _sortItem("sku", true, "SKU (Asc)"),
          _sortItem("sku", false, "SKU (Desc)"),
          _sortItem("store_price", true, "Price (Asc)"),
          _sortItem("store_price", false, "Price (Desc)"),
          _sortItem("quantity", true, "Quantity (Asc)"),
          _sortItem("quantity", false, "Quantity (Desc)"),
        ],
      ),
    );
  }

  PopupMenuItem<String> _sortItem(String field, bool asc, String label) {
    final isSelected = _sortField == field && _ascending == asc;

    return PopupMenuItem<String>(
      value: "${field}_${asc ? 'asc' : 'desc'}",
      child: Row(
        children: [
          if (isSelected)
            Icon(
              Icons.check,
              size: 16,
              color: Colors.yellow.shade800.withAlpha(240),
            )
          else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Colors.yellow.shade800.withAlpha(240)
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Filter options
  Widget _statusFilterDropdown(BuildContext context) {
    return Container(
      height: rs(context, 35),
      width: rs(context, 35),
      decoration: BoxDecoration(
        color: const Color(0xFFFDC62D).withOpacity(0.85),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black87),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(0, 4))],
      ),
      child: PopupMenuButton<ItemStatus?>(
        icon: Icon(
          Icons.filter_alt,
          size: rs(context, 18),
          color: Colors.black87,
        ),
        onSelected: (value) {
          setState(() {
            _selectedStatus = value;
            if (value == null) {
              _searchController.clear();
            }
            _loadItems();
          });
        },
        itemBuilder: (_) => [
          _filterItem(null, "All"),
          _filterItem(ItemStatus.approved, "Approved"),
          _filterItem(ItemStatus.pending, "Pending Approval"),
          _filterItem(ItemStatus.pulledOut, "Pulled Out"),
        ],
      ),
    );
  }

  PopupMenuItem<ItemStatus?> _filterItem(ItemStatus? value, String label) {
    final isSelected =
        (_selectedStatus == null && value == null) || _selectedStatus == value;

    return PopupMenuItem<ItemStatus?>(
      value: value,
      child: Row(
        children: [
          if (isSelected)
            Icon(
              Icons.check,
              size: 16,
              color: Colors.yellow.shade800.withAlpha(240),
            )
          else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Colors.yellow.shade800.withAlpha(240)
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.only(
        top: rs(context, kToolbarHeight + MediaQuery.of(context).padding.top),
        left: rs(context, 16),
        right: rs(context, 16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // search bar
              Expanded(
                child: SizedBox(
                  height: rs(context, 35),
                  child: TextField(
                    textAlign: TextAlign.left,
                    controller: _searchController,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: rs(context, 15),
                    ),
                    decoration: InputDecoration(
                      labelText: null,
                      hintText: "Search Items",
                      hintStyle: TextStyle(
                        fontSize: rs(context, 12),
                        color: Colors.black54.withAlpha(70),
                      ),

                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.black54,
                      ),
                      filled: true,
                      fillColor: Colors.white70.withOpacity(0.65),
                      alignLabelWithHint: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: rs(context, 12),
                        horizontal: rs(context, 12),
                      ),
                      labelStyle: TextStyle(color: Colors.black87),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black54, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.yellow.shade700,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: rs(context, 5)),

              // filter button
              _statusFilterDropdown(context),
              SizedBox(width: rs(context, 8)),

              // sort button
              _sortMenu(context),

              SizedBox(width: rs(context, 8)),

              // toggle view
              _actionButton(
                icon: _isGrid ? Icons.grid_view : Icons.view_list,
                onTap: () {
                  setState(() {
                    _isGrid = !_isGrid;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: rs(context, 10)),
          SizedBox(
            height: rs(context, 40),
            child: Row(
              children: [
                _textButton(
                  label: "Add Item",
                  onTap: () {
                    _showAddItemModal(context);
                    print("Add Item pressed");
                  },
                ),
                SizedBox(width: rs(context, 15)),
                _textButton(
                  label: "Pull Out",
                  onTap: () {
                    print("Pull Out pressed");
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: rs(context, 16)),
          Expanded(
            child: glassPanel(
              context,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (_isGrid
                        ? _buildGridView(context)
                        : _buildListView(context)),
            ),
          ),
          SizedBox(height: rs(context, 16)),
        ],
      ),
    );
  }
}

void _showAddItemModal(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => const AddItemModal(),
  );
}

// reusable icon button template
Widget _actionButton({required IconData icon, required VoidCallback onTap}) {
  return Builder(
    builder: (context) {
      return Container(
        height: rs(context, 35),
        width: rs(context, 35),
        decoration: BoxDecoration(
          color: const Color(0xFFFDC62D).withOpacity(0.85),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black87),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(0, 4)),
          ],
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.black87, size: rs(context, 18)),
          onPressed: onTap,
        ),
      );
    },
  );
}

// reusable text button template
Widget _textButton({required String label, required VoidCallback onTap}) {
  return Builder(
    builder: (context) {
      return Container(
        height: rs(context, 35),
        decoration: BoxDecoration(
          color: const Color(0xFFFDC62D).withOpacity(0.85),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black87),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(0, 4)),
          ],
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFDC62D).withOpacity(0.85),
            foregroundColor: Colors.black87,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.black87),
            ),
            padding: EdgeInsets.symmetric(horizontal: rs(context, 18)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: rs(context, 13),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    },
  );
}

// Cards for items displayed
Widget _buildGlassCard(BuildContext context, Item item, {bool isList = false}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        height: isList ? rs(context, 120) : null,
        padding: EdgeInsets.all(rs(context, 12)),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.4)),
        ),
        child: isList
            ?
              // list view
              Row(
                children: [
                  _previewImage(
                    context,
                    imagePath:
                        item.thumbnailImgLink ??
                        "lib/assets/images/popcom logo.png",
                    width: rs(context, 80),
                    height: rs(context, 80),
                  ),
                  SizedBox(width: rs(context, 12)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: rs(context, 30)),
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: rs(context, 15),
                        ),
                      ),
                      SizedBox(height: rs(context, 5)),
                      _skuBadge(context, item.sku),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      SizedBox(height: rs(context, 30)),
                      Text(
                        "₱${item.storePrice.toStringAsFixed(0)}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: rs(context, 13),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFDC143C),
                        ),
                      ),
                      SizedBox(height: rs(context, 5)),
                      Text(
                        "Qty: ${item.quantity}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: rs(context, 13)),
                      ),
                    ],
                  ),
                ],
              )
            :
              // grid view
              SizedBox(
                height: rs(context, 56),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _previewImage(
                        context,
                        imagePath:
                            item.thumbnailImgLink ??
                            "lib/assets/images/popcom logo.png",
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: rs(context, 15),
                            ),
                          ),
                        ),
                        SizedBox(width: rs(context, 6)),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: rs(context, 60),
                          ),
                          child: Text(
                            "₱${item.storePrice.toStringAsFixed(0)}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: rs(context, 13),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFDC143C),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: rs(context, 4)),
                    Row(
                      children: [
                        _skuBadge(context, item.sku),
                        const Spacer(),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: rs(context, 50),
                          ),
                          child: Text(
                            "Qty: ${item.quantity}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: rs(context, 13)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    ),
  );
}

Widget glassPanel(BuildContext context, {required Widget child}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          rs(context, 12),
          0,
          rs(context, 12),
          rs(context, 12),
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.40),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.6)),
        ),
        child: child,
      ),
    ),
  );
}

Widget _skuBadge(BuildContext context, String sku) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: rs(context, 8),
      vertical: rs(context, 3),
    ),
    decoration: BoxDecoration(
      color: const Color(0xFFFDC62D), // yellow background
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Colors.black, width: 1),
    ),
    child: Text(
      sku,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: rs(context, 11),
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
  );
}

Widget _previewImage(
  BuildContext context, {
  required String imagePath,
  double? width,
  double? height,
}) {
  final isNetwork = imagePath.startsWith('http');

  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: isNetwork
          ? Image.network(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 32),
            )
          : Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 32),
            ),
    ),
  );
}
