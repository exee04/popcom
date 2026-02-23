import 'dart:ui';
import 'package:flutter/material.dart';

double rs(BuildContext context, double size) {
  final width = MediaQuery.of(context).size.width;
  return size * (width / 375).clamp(0.9, 1.2);
}

const double _modalInputHeight = 38;

class AddItemModal extends StatelessWidget {
  const AddItemModal({super.key});

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

  Widget _categoryDropdown(BuildContext context, String hint) {
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
              backgroundColor: const Color(0x00ff4b33).withOpacity(0.85),
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

  @override
  Widget build(BuildContext context) {
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
              color: const Color(0xFFDC143C).withOpacity(0.9),
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

                  SizedBox(height: rs(context, 12)),

                  Row(
                    children: [
                      Expanded(
                        child: _labeledField(
                          context: context,
                          label: "Quantity",
                          child: _modalInput(context, "Enter Quantity"),
                        ),
                      ),
                      SizedBox(width: rs(context, 8)),
                      Expanded(
                        child: _labeledField(
                          context: context,
                          label: "Price",
                          child: _modalInput(context, "Enter Price"),
                        ),
                      ),
                    ],
                  ),

                  _labeledField(
                    context: context,
                    label: "Category",
                    child: _categoryDropdown(context, "Category"),
                  ),
                  SizedBox(height: rs(context, 12)),

                  _labeledField(
                    context: context,
                    label: "Manufacturer",
                    child: _manufacturerDropdown(context, "Manufacturer"),
                  ),
                  SizedBox(height: rs(context, 12)),

                  _labeledField(
                    context: context,
                    label: "Intellectual Property",
                    child: _ipDropdown(context, "Intellectual Property"),
                  ),
                  SizedBox(height: rs(context, 12)),

                  _labeledField(
                    context: context,
                    label: "Item Description",
                    child: _modalTextArea(context, "Item Description"),
                  ),
                  SizedBox(height: rs(context, 12)),

                  _labeledField(
                    context: context,
                    label: "Image Thumbnail",
                    child: _uploadButton(context),
                  ),
                  SizedBox(height: rs(context, 12)),

                  _labeledField(
                    context: context,
                    label: "Image Carousel",
                    child: _uploadButton(context),
                  ),

                  SizedBox(height: rs(context, 12)),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _cancelModalButton(onTap: () => Navigator.pop(context)),
                      SizedBox(width: rs(context, 10)),
                      _saveModalButton(
                        onTap: () {},
                      ), // insert save function here
                    ],
                  ),
                  SizedBox(height: rs(context, 15)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
