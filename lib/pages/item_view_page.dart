import 'package:flutter/material.dart';
import 'package:popcom/models/item.dart';
import 'package:popcom/service/item_service.dart';
import 'dart:ui';

double rs(BuildContext context, double size) {
  final width = MediaQuery.of(context).size.width;
  return size * (width / 375).clamp(0.9, 1.2);
}

class ItemViewPage extends StatefulWidget {
  final Item item;
  const ItemViewPage({super.key, required this.item});

  @override
  State<ItemViewPage> createState() => _ItemViewPageState();
}

class _ItemViewPageState extends State<ItemViewPage> {
  late Future<List<String>> _galleryFuture;

  @override
  void initState() {
    super.initState();
    _galleryFuture = ItemService().fetchItemGallery(
      widget.item.imageFolderLink ?? "",
    );
    print(
      "Loading gallery for ${widget.item.name} from folder: ${widget.item.imageFolderLink}",
    );
  }

  void _showImagePreview(String imagePath) {
    final isNetwork = imagePath.startsWith('http');

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.black.withOpacity(0.85),
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: isNetwork
                      ? Image.network(imagePath, fit: BoxFit.contain)
                      : Image.asset(imagePath, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.6),
        elevation: 0,
        title: Text("View ${item.name}"),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity, // 🔥 IMPORTANT
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE61A4B), Color(0xFFFFEA21)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(rs(context, 16)),
            child: _glassContainer(
              context,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _itemSummary(widget.item),
                            SizedBox(height: rs(context, 18)),
                            _gallerySection(),
                            SizedBox(height: rs(context, 18)),
                            _transactionHistoryTable(context, widget.item),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ===============================
  /// ITEM SUMMARY
  /// ===============================
  Widget _itemSummary(Item item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => _showImagePreview(
                item.thumbnailImgLink ?? "lib/assets/images/popcom logo.png",
              ),
              child: Container(
                width: rs(context, 120),
                height: rs(context, 120),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: item.thumbnailImgLink != null
                        ? NetworkImage(item.thumbnailImgLink!)
                        : const AssetImage("lib/assets/images/popcom logo.png")
                              as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(width: rs(context, 10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _skuBadge(item.sku),
                  SizedBox(height: rs(context, 6)),
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: rs(context, 18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: rs(context, 4)),
                  Text(
                    item.description ?? "No description",
                    style: TextStyle(
                      fontSize: rs(context, 12),
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: rs(context, 12)),
        Row(
          children: [
            Expanded(child: _statBox("QUANTITY", "${item.quantity}")),
            SizedBox(width: rs(context, 8)),
            Expanded(
              child: _statBox(
                "PRICE",
                "₱${item.storePrice.toStringAsFixed(0)}",
                highlight: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// ===============================
  /// GALLERY
  /// ===============================
  Widget _gallerySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("GALLERY", style: TextStyle(fontWeight: FontWeight.bold)),

        SizedBox(height: rs(context, 8)),

        FutureBuilder<List<String>>(
          future: _galleryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 90,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox(
                height: 90,
                child: Center(child: Text("No images")),
              );
            }

            final images = snapshot.data!;

            return SizedBox(
              height: rs(context, 90),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => SizedBox(width: rs(context, 8)),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _showImagePreview(images[i]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(images[i], fit: BoxFit.cover),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// ===============================
  /// TRANSACTIONS (ready for DB)
  /// ===============================
  Widget _transactionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "TRANSACTION HISTORY",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        _transactionHistoryTable(context, widget.item),
        Text("No transactions yet"),
      ],
    );
  }

  /// ===============================
  /// REUSABLE UI
  /// ===============================
  Widget _statBox(String label, String value, {bool highlight = false}) {
    return Container(
      padding: EdgeInsets.all(rs(context, 10)),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFFDC62D) : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _glassContainer(BuildContext context, {required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: EdgeInsets.all(rs(context, 12)),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.35),
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _skuBadge(String sku) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: rs(context, 8),
        vertical: rs(context, 3),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFDC62D),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        sku,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  /// =========================================================
  /// TRANSACTION HISTORY TABLE
  /// TEMP: Hardcoded data
  /// FUTURE: Replace with Supabase query
  /// =========================================================
  Widget _transactionHistoryTable(BuildContext context, Item item) {
    /// ---------------------------------------------------------
    /// TEMP DATA (REMOVE WHEN DB IS READY)
    /// ---------------------------------------------------------
    /// This simulates real transactions.
    /// Later this will come from:
    /// ItemService.fetchTransactionsBySku(item.sku)
    /// ---------------------------------------------------------
    final transactions = [
      {
        "date": "02/10/2026",
        "action": "Sold (In-Store)",
        "qty": "-2",
        "amount": "₱2400",
      },
      {"date": "01/28/2026", "action": "Restock", "qty": "+12", "amount": "-"},
    ];

    /// ---------------------------------------------------------
    /// FUTURE STRUCTURE
    /// ---------------------------------------------------------
    /// Replace this entire variable with:
    ///
    /// final transactions = await ItemService()
    ///     .fetchTransactionsBySku(item.sku);
    ///
    /// Data format expected:
    /// [
    ///   {
    ///     "date": "2026-02-10",
    ///     "action": "sale",
    ///     "qty": -2,
    ///     "amount": 2400,
    ///   }
    /// ]
    /// ---------------------------------------------------------

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ================= HEADER =================
          Padding(
            padding: EdgeInsets.symmetric(vertical: rs(context, 6)),
            child: Row(
              children: [
                SizedBox(width: rs(context, 10)),
                _headerCell(context, "Date", flex: 2),
                SizedBox(width: rs(context, 45)),
                _headerCell(context, "Action", flex: 3),
                SizedBox(width: rs(context, 25)),
                _headerCell(context, "Qty", flex: 1),
                SizedBox(width: rs(context, 5)),
                _headerCell(context, "Amount", flex: 2),
              ],
            ),
          ),

          Divider(thickness: rs(context, 1), color: Colors.black87),
          SizedBox(height: rs(context, 8)),

          /// ================= TRANSACTION ROWS =================
          /// TEMP: mapping hardcoded data
          /// FUTURE: map Supabase response
          ...transactions.map((tx) {
            return Padding(
              padding: EdgeInsets.only(bottom: rs(context, 8)),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.black87.withOpacity(0.8),
                    width: 1,
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: rs(context, 8),
                  horizontal: rs(context, 12),
                ),
                child: Row(
                  children: [
                    _dataCellLeft(context, tx["date"]!, flex: 4),
                    SizedBox(width: rs(context, 15)),
                    _dataCellLeft(context, tx["action"]!, flex: 4),
                    SizedBox(width: rs(context, 25)),
                    _dataCellLeft(context, tx["qty"]!, flex: 1),
                    SizedBox(width: rs(context, 8)),
                    _dataCellRight(context, tx["amount"]!, flex: 2),
                  ],
                ),
              ),
            );
          }),

          SizedBox(height: rs(context, 3)),
          Divider(thickness: rs(context, 1), color: Colors.black87),
          SizedBox(height: rs(context, 8)),

          /// ================= TOTAL =================
          /// TEMP: Hardcoded total
          /// FUTURE:
          /// Calculate from DB:
          /// total = sum(transaction.amount where type == sale)
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              "TOTAL: ₱2400",
              style: TextStyle(
                color: Colors.red.shade800,
                fontSize: rs(context, 14),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(BuildContext context, String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: rs(context, 12),
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _dataCellLeft(BuildContext context, String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.start,
        style: TextStyle(fontSize: rs(context, 10), color: Colors.black87),
      ),
    );
  }

  Widget _dataCellRight(
    BuildContext context,
    String text, {
    required int flex,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.end,
        style: TextStyle(fontSize: rs(context, 10), color: Colors.black87),
      ),
    );
  }
}
