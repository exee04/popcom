import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:popcom/models/item.dart';
import 'package:popcom/service/item_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

double rs(BuildContext context, double size) {
  final width = MediaQuery.of(context).size.width;
  return size * (width / 375).clamp(0.9, 1.2);
}

const double _modalInputHeight = 38;

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();
  final ItemService _itemService = ItemService();
  late Future<List<Item>> _itemsFuture;

  bool _isGrid = true;
  @override
  void initState() {
    super.initState();
    _itemsFuture = _itemService.fetchItems(); // async
    _itemsFuture = _supabase
        .from('Item') // lowercase table name
        .select(
          '*, category:Categories(category_name)',
        ) // lowercase table and relationship
        .then((response) {
          final data = response as List<dynamic>;
          return data
              .map((e) => Item.fromMap(e as Map<String, dynamic>))
              .toList();
        });
    _itemsFuture
        .then((items) {
          print("Fetched ${items.length} items:");
          for (var item in items) {
            print(item); // This will call the toString method of Item
          }
        })
        .catchError((error) {
          print("Error fetching items: $error");
        });
    print(
      "Fetched items: $_itemsFuture",
    ); // Debug print to check if items are fetched correctly
    print("Successfully initialized HomePage with items future: $_itemsFuture");
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
              _actionButton(
                icon: Icons.filter_alt,
                onTap: () {
                  print("Filter pressed");
                },
              ),
              SizedBox(width: rs(context, 8)),

              // sort button
              _actionButton(
                icon: Icons.sort,
                onTap: () {
                  print("Sort pressed");
                },
              ),
              SizedBox(width: rs(context, 8)),

              // toggle view
              _actionButton(
                icon: _isGrid ? Icons.view_list : Icons.grid_view,
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
              child: _isGrid
                  ? _buildGridView(context)
                  : _buildListView(context),
            ),
          ),
          SizedBox(height: rs(context, 16)),
        ],
      ),
    );
  }
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

// grid view widget
Widget _buildGridView(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  final crossAxisCount = width >= 400 ? 3 : 2;
  return GridView.builder(
    padding: EdgeInsets.only(top: rs(context, 20), bottom: rs(context, 5)),
    itemCount: 10,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: rs(context, 12),
      mainAxisSpacing: rs(context, 12),
      childAspectRatio: 0.65,
    ),
    itemBuilder: (context, index) {
      return _buildGlassCard(context, index);
    },
  );
}

// list view widget
Widget _buildListView(BuildContext context) {
  return ListView.separated(
    padding: EdgeInsets.only(top: rs(context, 20), bottom: rs(context, 5)),
    itemCount: 10,
    separatorBuilder: (_, ___) => SizedBox(height: rs(context, 12)),
    itemBuilder: (context, index) {
      return _buildGlassCard(context, index, isList: true);
    },
  );
}

// Cards for items displayed
Widget _buildGlassCard(BuildContext context, index, {bool isList = false}) {
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
            ? Row(
                // List view
                children: [
                  Container(
                    width: rs(context, 80),
                    height: rs(context, 80),
                    decoration: BoxDecoration(
                      // Change to image file if already available
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  SizedBox(width: rs(context, 12)),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: rs(context, 12)),
                      Text(
                        "Item Name", // change item name here
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: rs(context, 14),
                        ),
                      ),
                      Text(
                        "SKU: ", // change SKU here
                        style: TextStyle(fontSize: rs(context, 13)),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        "Qty: ", // change Qty here
                        style: TextStyle(fontSize: rs(context, 13)),
                      ),
                    ],
                  ),
                  SizedBox(width: rs(context, 12)),
                ],
              )
            : Column(
                // Grid view
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        // Change to image file if already available
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: rs(context, 8)),
                  Text(
                    "Item Name", // change item name here
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: rs(context, 15),
                    ),
                  ),
                  SizedBox(height: rs(context, 5)),
                  Text(
                    "SKU: ", // change SKU here
                    style: TextStyle(fontSize: rs(context, 13)),
                  ),
                  SizedBox(height: rs(context, 5)),
                  Text(
                    "Qty: ", // change Qty here
                    style: TextStyle(fontSize: rs(context, 13)),
                  ),
                ],
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

void _showAddItemModal(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: rs(context, 16),
          vertical: rs(context, 24),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: EdgeInsets.all(rs(context, 16)),
              decoration: BoxDecoration(
                color: Color(0xFFDC143C).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.6)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _modalHeader(context),
                    SizedBox(height: rs(context, 12)),

                    _labeledField(
                      context: context,
                      label: "Item Name",

                      child: _modalInput(context, "Enter Item Name"),
                    ),
                    _labeledField(
                      context: context,
                      label: "Manufacturer",
                      child: _manufacturerDropdown(context, "Manufacturer"),
                    ),
                    _labeledField(
                      context: context,
                      label: "Intellectual Property",
                      child: _ipDropdown(context, "Intellectual Property"),
                    ),

                    _labeledField(
                      context: context,
                      label: "Item Description",
                      child: _modalTextArea(context, "Item Description"),
                    ),

                    _labeledField(
                      context: context,
                      label: "Image URL",
                      child: _modalInput(context, "Image URL"),
                    ),

                    _labeledField(
                      context: context,
                      label: "Image File",
                      child: _uploadButton(context),
                    ),

                    SizedBox(height: rs(context, 12)),

                    Row(
                      children: [
                        Expanded(
                          child: _modalInput(
                            context,
                            "Quantity",
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: rs(context, 5)),
                        Expanded(
                          child: _modalInput(
                            context,
                            "Price",
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: rs(context, 12)),

                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _cancelModalButton(
                              onTap: () => Navigator.pop(context),
                            ),
                            SizedBox(width: rs(context, 10)),
                            _saveModalButton(
                              onTap: () {
                                print("Save pressed");
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: rs(context, 16)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _modalHeader(BuildContext context) {
  return Text(
    "Add New Item",
    style: TextStyle(
      fontSize: rs(context, 18),
      fontWeight: FontWeight.w500,
      color: Colors.white.withAlpha(240),
    ),
  );
}

Widget _modalInput(
  BuildContext context,
  String hint, {
  TextInputType keyboardType = TextInputType.text,
}) {
  return Padding(
    padding: EdgeInsets.only(bottom: rs(context, 12)),
    child: SizedBox(
      height: rs(context, 38),
      child: TextField(
        keyboardType: keyboardType,
        decoration: InputDecoration(
          contentPadding: EdgeInsetsDirectional.all(rs(context, 8)),
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.yellow.shade700, width: 2),
          ),
        ),
        style: TextStyle(fontSize: rs(context, 13)),
      ),
    ),
  );
}

Widget _labeledField({
  required BuildContext context,
  required String label,
  required Widget child,
}) {
  return Padding(
    padding: EdgeInsets.only(bottom: rs(context, 12), top: rs(context, 8)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: rs(context, 12),
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        SizedBox(height: rs(context, 6)),
        child,
      ],
    ),
  );
}

Widget _manufacturerDropdown(BuildContext context, String hint) {
  return Padding(
    padding: EdgeInsets.only(bottom: rs(context, 12)),
    child: SizedBox(
      height: rs(context, _modalInputHeight),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: rs(context, 8),
            vertical: rs(context, 10),
          ),
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        style: TextStyle(fontSize: rs(context, 13), color: Colors.black),
        items: const [
          DropdownMenuItem(value: "Option 1", child: Text("Option 1")),
          DropdownMenuItem(value: "Option 2", child: Text("Option 2")),
        ],
        onChanged: (value) {},
      ),
    ),
  );
}

Widget _ipDropdown(BuildContext context, String hint) {
  return Padding(
    padding: EdgeInsets.only(bottom: rs(context, 12)),
    child: SizedBox(
      height: rs(context, _modalInputHeight),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: rs(context, 8),
            vertical: rs(context, 10),
          ),
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        style: TextStyle(fontSize: rs(context, 13), color: Colors.black),
        items: const [
          DropdownMenuItem(value: "Option 1", child: Text("Option 1")),
          DropdownMenuItem(value: "Option 2", child: Text("Option 2")),
        ],
        onChanged: (value) {},
      ),
    ),
  );
}

Widget _modalTextArea(BuildContext context, String hint) {
  return Padding(
    padding: EdgeInsets.only(bottom: rs(context, 12)),
    child: TextField(
      maxLines: 4,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      style: TextStyle(fontSize: rs(context, 13)),
    ),
  );
}

Widget _uploadButton(BuildContext context) {
  return Padding(
    padding: EdgeInsets.only(bottom: rs(context, 12)),
    child: Center(
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.upload),
        label: const Text("Upload Image"),
        style: OutlinedButton.styleFrom(
          minimumSize: Size(rs(context, 150), rs(context, 38)),

          side: BorderSide(color: Colors.white, width: 1.5),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          foregroundColor: Colors.white,
          textStyle: TextStyle(
            fontSize: rs(context, 11),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}

Widget _cancelModalButton({required VoidCallback onTap}) {
  return Builder(
    builder: (context) {
      return Container(
        height: rs(context, 35),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.85),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black87),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(0, 4)),
          ],
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4B33).withOpacity(0.85),
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.black87),
            ),
            padding: EdgeInsets.symmetric(horizontal: rs(context, 18)),
          ),
          child: Text(
            "Cancel",
            style: TextStyle(
              fontSize: rs(context, 13),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    },
  );
}

Widget _saveModalButton({required VoidCallback onTap}) {
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
            "Save",
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
