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
        top: kToolbarHeight + MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
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

              const SizedBox(width: 8),

              // filter button
              _actionButton(
                icon: Icons.filter_alt,
                onTap: () {
                  print("Filter pressed");
                },
              ),
              const SizedBox(width: 8),

              // sort button
              _actionButton(
                icon: Icons.sort,
                onTap: () {
                  print("Sort pressed");
                },
              ),
              const SizedBox(width: 8),

              // toggle view
              _actionButton(
                icon: _isGrid ? Icons.view_list : Icons.grid_view,
                onTap: () {
                  setState(() {
                    _isGrid = !_isGrid;
                  });
                },
              ),

              const SizedBox(height: 16),
              Expanded(child: _isGrid ? _buildGridView() : _buildListView()),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _actionButton({required IconData icon, required VoidCallback onTap}) {
  return Builder(
    builder: (context) {
      return Container(
        height: rs(context, 45),
        width: rs(context, 45),
        decoration: BoxDecoration(
          color: const Color(0xFFE61A4B).withOpacity(0.85),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black87),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(0, 4)),
          ],
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.yellow.shade500, size: 22),
          onPressed: onTap,
        ),
      );
    },
  );
}
// grid view widget
Widget _buildGridView() {
  return GridView.builder(
    itemCount: 10,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.8,
    ),
    itemBuilder: (context, index) {
      return _buildGlassCard(index);
    },
  );
}

// list view widget
Widget _buildListView() {
  return ListView.separated(itemCount: 10,
  separatorBuilder: (_,),)
}
