import 'package:flutter/material.dart';
import 'dart:ui';

double rs(BuildContext context, double size) {
  final width = MediaQuery.of(context).size.width;
  return size * (width / 375).clamp(0.9, 1.2);
}

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  @override
  Widget build(BuildContext context) {
    final reviews = [
      Review(
        rating: 5,
        itemName: "HG 1/144 Gundam",
        text: '"Great product! Quality is good and transaction is quick."',
        date: "02/12/2026",
      ),
    ];

    return Padding(
      padding: EdgeInsets.all(rs(context, 16)),
      child: ListView.separated(
        itemCount: reviews.length, // Review card counter

        separatorBuilder: (_, __) => SizedBox(height: rs(context, 16)),
        itemBuilder: (context, index) {
          return ReviewGlassCard(
            review: reviews[index],
            itemName: "HG 1/144 Gundam",
            itemImage: "lib/assets/images/popcom logo.png",
          );
        },
      ),
    );
  }
}

class ReviewGlassCard extends StatelessWidget {
  final Review review;
  final String itemName;
  final String itemImage;

  const ReviewGlassCard({
    super.key,
    required this.review,
    required this.itemName,
    required this.itemImage,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.all(rs(context, 16)),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // Item Name
                    children: [
                      Text(
                        review.itemName,
                        style: TextStyle(
                          fontSize: rs(context, 12),
                          color: Colors.black87.withOpacity(0.9),
                        ),
                      ),
                      // Stars
                      _buildStars(review.rating, context),
                    ],
                  ),

                  // Date
                  Text(
                    review.date,
                    style: TextStyle(
                      fontSize: rs(context, 12),
                      color: Colors.black87.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              SizedBox(height: rs(context, 12)),

              // Review Text
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(rs(context, 12)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black12),
                ),
                child: Text(
                  review.text,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: rs(context, 14),
                    color: Colors.black87,
                  ),
                ),
              ),

              SizedBox(height: rs(context, 16)),

              // Reply Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: rs(context, 40),
                    child: Row(
                      children: [
                        _replyButton(
                          label: "Reply",
                          onTap: () {
                            _openReplyModal(
                              context,
                              review,
                              itemName,
                              itemImage,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _openReplyModal(
  BuildContext context,
  Review selectedReview,
  String itemName,
  String itemImage,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (_) {
      return ReplyDialog(
        selectedReview: selectedReview,
        itemName: itemName,
        itemImage: itemImage,
      );
    },
  );
}

class Review {
  final int rating;
  final String itemName;
  final String text;
  final String date;

  Review({
    required this.rating,
    required this.itemName,
    required this.text,
    required this.date,
  });
}

class ReplyDialog extends StatefulWidget {
  final Review selectedReview;
  final String itemName;
  final String itemImage;

  const ReplyDialog({
    super.key,
    required this.selectedReview,
    required this.itemName,
    required this.itemImage,
  });

  @override
  State<ReplyDialog> createState() => _ReplyDialogState();
}

class _ReplyDialogState extends State<ReplyDialog> {
  final TextEditingController _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _submitReply() {
    final reply = _replyController.text.trim();
    if (reply.isEmpty) return;

    debugPrint("Reply submitted: $reply");

    _replyController.clear();
    Navigator.pop(context);
  }

  Widget _inlineReplyField(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: rs(context, 12),
        vertical: rs(context, 8),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              // Inline reply
              controller: _replyController,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: "Write a reply...",
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFDC62D)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54),
                ),
                isDense: true,
              ),
              style: TextStyle(
                fontSize: rs(context, 14),
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(width: rs(context, 8)),
          // Inline reply button
          GestureDetector(
            onTap: _submitReply,
            child: Container(
              padding: EdgeInsets.all(rs(context, 8)),
              decoration: BoxDecoration(
                color: const Color(0xFFFDC62D),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black87),
                boxShadow: const [
                  BoxShadow(
                    spreadRadius: 1,
                    color: Colors.black,
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                Icons.send,
                size: rs(context, 18),
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double modalWidth = MediaQuery.of(context).size.width * 0.85;
    double imageSize = rs(context, 140);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              width: modalWidth,
              constraints: const BoxConstraints(maxHeight: 600),
              padding: EdgeInsets.all(rs(context, 16)),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item Image
                      Container(
                        height: imageSize,
                        width: imageSize,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade300,
                          image: DecorationImage(
                            image: AssetImage(widget.itemImage),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: rs(context, 12)),

                      // Item name + stars
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.itemName,
                              style: TextStyle(
                                fontSize: rs(context, 18),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: rs(context, 8)),
                            _buildStars(widget.selectedReview.rating, context),
                          ],
                        ),
                      ),

                      // Close button
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  SizedBox(height: rs(context, 12)),

                  Text(
                    "Selected Review",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: rs(context, 14),
                    ),
                  ),

                  SizedBox(height: rs(context, 8)),

                  // review text
                  _reviewBubble(
                    review: widget.selectedReview,
                    highlight: true,
                    context: context,
                  ),

                  /// Reply field
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: _inlineReplyField(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _reviewBubble({
  required Review review,
  required bool highlight,
  required BuildContext context,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: EdgeInsets.all(rs(context, 12)),
    decoration: BoxDecoration(
      color: highlight ? Colors.yellow.shade100 : Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.black12),
    ),
    child: Text(review.text, style: TextStyle(fontSize: rs(context, 13))),
  );
}

Widget _buildStars(int rating, context) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(5, (index) {
      return Icon(
        index < rating ? Icons.star : Icons.star_border,
        size: rs(context, 16),
        color: Colors.amber.shade700,
      );
    }),
  );
}

Widget _replyButton({required String label, required VoidCallback onTap}) {
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
