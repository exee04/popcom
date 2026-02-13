import 'dart:ui';
import 'package:flutter/material.dart';

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
  final _searchController = TextEditingController();

  bool _isGrid = true;

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
                  height: rs(context, 45),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: rs(context, 18),
                    ),
                    decoration: InputDecoration(
                      labelText: null,
                      hintText: "Search Items",
                      hintStyle: TextStyle(
                        fontSize: rs(context, 18),
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

              SizedBox(width: rs(context, 8)),

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
              SizedBox(width: rs(context, 8)),
              IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 5,
                        shadowColor: Colors.black45,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Add Item",
                        style: TextStyle(
                          fontSize: rs(context, 16),
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(height: rs(context, 8)),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 5,
                        shadowColor: Colors.black45,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Pull Out",
                        style: TextStyle(
                          fontSize: rs(context, 16),
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
        ],
      ),
    );
  }
}

// reusable button template
Widget _actionButton({required IconData icon, required VoidCallback onTap}) {
  return Builder(
    builder: (context) {
      return Container(
        height: rs(context, 45),
        width: rs(context, 45),
        decoration: BoxDecoration(
          color: const Color(0xFFFDC62D).withOpacity(0.85),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black87),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(0, 4)),
          ],
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.black87, size: rs(context, 22)),
          onPressed: onTap,
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
                          fontSize: rs(context, 16),
                        ),
                      ),
                      Text(
                        "SKU: ", // change SKU here
                        style: TextStyle(fontSize: rs(context, 15)),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        "Qty: ", // change Qty here
                        style: TextStyle(fontSize: rs(context, 15)),
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
                      fontSize: rs(context, 16),
                    ),
                  ),
                  SizedBox(height: rs(context, 5)),
                  Text(
                    "SKU: ", // change SKU here
                    style: TextStyle(fontSize: rs(context, 14)),
                  ),
                  SizedBox(height: rs(context, 5)),
                  Text(
                    "Qty: ", // change Qty here
                    style: TextStyle(fontSize: rs(context, 14)),
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
