import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:popcom/pages/home_page.dart';

double rs(BuildContext context, double size) {
  final width = MediaQuery.of(context).size.width;
  return size * (width / 375).clamp(0.9, 1.2);
}

class ItemViewPage extends StatelessWidget {
  final TempItem item;

  const ItemViewPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.6),
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(rs(context, 10)),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.85),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black87),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(0, 4)),
                ],
              ),
              child: Icon(
                Icons.arrow_back,
                color: Colors.yellow.shade500,
                size: 20,
              ),
            ),
          ),
        ),
        title: Text(
          "View ${item.name}",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: rs(context, 18),
          ),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _itemSummary(context, item),

                    SizedBox(height: rs(context, 16)),

                    Text(
                      "TRANSACTION HISTORY (SALES)",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: rs(context, 14),
                      ),
                    ),

                    SizedBox(height: rs(context, 10)),

                    _transactionHistoryTable(context, item),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _itemSummary(BuildContext context, TempItem item) {
  void showImagePreview(BuildContext context, String imagePath) {
    final isNetwork = imagePath.startsWith('http');
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(rs(context, 16)),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                  ),
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
        );
      },
    );
  }

  final List<String> galleryImages = [
    'lib/assets/images/popcom logo.png',
    'lib/assets/images/popcom logo.png',
    'lib/assets/images/popcom logo.png',
    'lib/assets/images/popcom logo.png',
  ];

  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: EdgeInsets.all(rs(context, 16)),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border(
            top: BorderSide(color: Colors.black87, width: 1),
            left: BorderSide(color: Colors.black87, width: 1),
            bottom: BorderSide(color: Colors.black87, width: 4),
            right: BorderSide(color: Colors.black87, width: 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Image container
                GestureDetector(
                  onTap: () => showImagePreview(
                    context,
                    'lib/assets/images/popcom logo.png',
                  ),
                  child: Container(
                    width: rs(context, 120),
                    height: rs(context, 120),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.black87.withOpacity(0.6),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage('lib/assets/images/popcom logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: rs(context, 10)),
                Column(
                  children: [
                    _skuBadge(context, item.sku),
                    SizedBox(height: rs(context, 8)),
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: rs(context, 18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: rs(context, 3)),
                    Padding(
                      padding: EdgeInsetsGeometry.only(left: 8),
                      child: Text(
                        "Item Description",
                        style: TextStyle(
                          fontSize: rs(context, 11),
                          fontStyle: FontStyle.italic,
                          color: Colors.black87.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: rs(context, 10)),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black87),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(1, 1),
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: rs(context, 5),
                      horizontal: rs(context, 30),
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "QUANTITY\n",
                            style: TextStyle(
                              fontSize: rs(context, 9),
                              color: Colors.black87.withOpacity(0.8),
                            ),
                          ),
                          TextSpan(
                            text: "${item.quantity} UNIT(S)",
                            style: TextStyle(
                              fontSize: rs(context, 12),
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: rs(context, 8)),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFDC62D),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black87),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(1, 1),
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: rs(context, 5),
                      horizontal: rs(context, 30),
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "PRICE\n",
                            style: TextStyle(
                              fontSize: rs(context, 9),
                              color: Colors.black87.withOpacity(0.8),
                            ),
                          ),
                          TextSpan(
                            text: "₱${item.price.toStringAsFixed(0)}",
                            style: TextStyle(
                              fontSize: rs(context, 12),
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: rs(context, 18)),

            Text(
              "GALLERY",
              style: TextStyle(
                fontSize: rs(context, 12),
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: rs(context, 8)),

            SizedBox(
              height: rs(
                context,
                90,
              ), // controls how much vertical space gallery uses
              child: ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      Colors.black,
                      Colors.black,
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.05, 0.95, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: galleryImages.length,
                  separatorBuilder: (_, __) => SizedBox(width: rs(context, 8)),
                  itemBuilder: (context, index) {
                    final imagePath = galleryImages[index];

                    return GestureDetector(
                      onTap: () => showImagePreview(context, imagePath),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          constraints: BoxConstraints(
                            minWidth: rs(context, 70),
                            maxWidth: rs(context, 120),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            border: Border.all(
                              color: Colors.black87.withOpacity(0.6),
                            ),
                          ),
                          child: Image.asset(imagePath, fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _transactionHistoryTable(BuildContext context, TempItem item) {
  final transactions = [
    {
      "date": "02/10/2026",
      "action": "Sold (In-Store)",
      "qty": "-2",
      "amount": "₱2400",
    },
    {"date": "01/28/2026", "action": "Restock", "qty": "+12", "amount": "-"},
  ];

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Table headers
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

        // Transaction rows
        ...transactions.map(
          (tx) => Padding(
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
          ),
        ),
        SizedBox(height: rs(context, 3)),
        Divider(thickness: rs(context, 1), color: Colors.black87),
        SizedBox(height: rs(context, 8)),
        Padding(
          padding: EdgeInsetsGeometry.only(left: 5),
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

Widget _dataCellRight(BuildContext context, String text, {required int flex}) {
  return Expanded(
    flex: flex,
    child: Text(
      text,
      textAlign: TextAlign.end,
      style: TextStyle(fontSize: rs(context, 10), color: Colors.black87),
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
          border: Border.all(color: Colors.white.withOpacity(0.4)),
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
