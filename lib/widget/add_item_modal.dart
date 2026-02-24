import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:popcom/service/item_service.dart';
import 'package:image_picker/image_picker.dart';

double rs(BuildContext context, double size) {
  final width = MediaQuery.of(context).size.width;
  return size * (width / 375).clamp(0.9, 1.2);
}

const double _modalInputHeight = 38;

class AddItemModal extends StatefulWidget {
  const AddItemModal({super.key});

  @override
  State<AddItemModal> createState() => _AddItemModalState();
}

class _AddItemModalState extends State<AddItemModal> {
  String? _selectedManufacturerId;
  bool _isLoadingManufacturers = false;
  List<Map<String, dynamic>> _manufacturers = [];

  String? _selectedCategoryId;
  bool _isLoadingCategory = false;
  List<Map<String, dynamic>> _category = [];

  String? _selectedIPId;
  bool _isLoadingIP = false;
  List<Map<String, dynamic>> _ip = [];

  String? _selectedShelfId;
  bool _isLoadingShelf = false;
  List<Map<String, dynamic>> _shelf = [];

  late ItemService _itemService;

  final ImagePicker _picker = ImagePicker();

  XFile? _thumbnailImage;
  List<XFile> _itemImages = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _itemService = ItemService();
    _isLoadingManufacturers = true;
    _itemService
        .fetchManufacturerOptions()
        .then((data) {
          setState(() {
            _manufacturers = data;
            _isLoadingManufacturers = false;
          });
        })
        .catchError((error) {
          print("Error fetching manufacturers: $error");
          setState(() => _isLoadingManufacturers = false);
        });
    _isLoadingCategory = true;
    _itemService
        .fetchCategoryOptions()
        .then((data) {
          setState(() {
            _category = data;
            print(_category);
            _isLoadingCategory = false;
          });
        })
        .catchError((error) {
          print("Error fetching categories: $error");
          setState(() => _isLoadingCategory = false);
        });
    _isLoadingIP = true;
    _itemService
        .fetchIPOptions()
        .then((data) {
          setState(() {
            _ip = data;
            _isLoadingIP = false;
          });
        })
        .catchError((error) {
          print("Error fetching IP options: $error");
          setState(() => _isLoadingIP = false);
        });
    _isLoadingShelf = true;
    _itemService
        .fetchShelfOptions()
        .then((data) {
          setState(() {
            _shelf = data;
            _isLoadingShelf = false;
          });
        })
        .catchError((error) {
          print("Error fetching shelf options: $error");
          setState(() => _isLoadingShelf = false);
        });
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
                    child: _modalInput(
                      context,
                      "Enter Item Name",
                      controller: _nameController,
                    ),
                  ),

                  SizedBox(height: rs(context, 12)),

                  Row(
                    children: [
                      Expanded(
                        child: _labeledField(
                          context: context,
                          label: "Quantity",
                          child: _modalInput(
                            context,
                            "Enter Quantity",
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      SizedBox(width: rs(context, 8)),
                      Expanded(
                        child: _labeledField(
                          context: context,
                          label: "Price",
                          child: _modalInput(
                            context,
                            "Enter Price",
                            controller: _priceController,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  _labeledField(
                    context: context,
                    label: "Shelf",
                    child: _shelfDropdown(context, "Shelf"),
                  ),
                  SizedBox(height: rs(context, 12)),

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
                    child: _modalTextArea(
                      context,
                      "Item Description",
                      controller: _descriptionController,
                    ),
                  ),
                  SizedBox(height: rs(context, 12)),

                  _labeledField(
                    context: context,
                    label: "Image Thumbnail",
                    child: _thumbnailUploadButton(context),
                  ),
                  SizedBox(height: rs(context, 12)),

                  _labeledField(
                    context: context,
                    label: "Image Carousel",
                    child: _itemImagesUploadButton(context),
                  ),

                  SizedBox(height: rs(context, 12)),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _cancelModalButton(onTap: () => Navigator.pop(context)),
                      SizedBox(width: rs(context, 10)),
                      _saveModalButton(
                        onTap: () async {
                          try {
                            final user =
                                Supabase.instance.client.auth.currentUser;

                            if (user == null) {
                              print("User not logged in");
                              return;
                            }

                            if (_thumbnailImage == null) {
                              print("Thumbnail required");
                              return;
                            }

                            // optional: validate dropdowns
                            if (_selectedCategoryId == null ||
                                _selectedManufacturerId == null ||
                                _selectedIPId == null ||
                                _selectedShelfId == null) {
                              print("Missing required dropdown fields");
                              return;
                            }

                            final itemService = ItemService();

                            /// STEP 1 — INSERT ITEM (no images yet)
                            final inserted = await itemService.addItem(
                              name: _nameController.text,
                              storePrice:
                                  double.tryParse(_priceController.text) ?? 0.0,
                              quantity:
                                  int.tryParse(_quantityController.text) ?? 0,
                              categoryId: _selectedCategoryId!,
                              manufacturerId: _selectedManufacturerId!,
                              ipId: _selectedIPId!,
                              shelfId: _selectedShelfId!,
                              description: _descriptionController.text,
                            );

                            final sku = inserted['sku'];
                            final renterId = user.id;

                            print("Inserted item with SKU: $sku");

                            /// STEP 2 — UPLOAD THUMBNAIL
                            final thumbnailUrl = await itemService
                                .uploadThumbnail(
                                  image: _thumbnailImage!,
                                  renterId: renterId,
                                  sku: sku,
                                );

                            /// STEP 3 — UPLOAD ITEM IMAGES
                            final imageFolderPath = await itemService
                                .uploadItemImages(
                                  images: _itemImages,
                                  renterId: renterId,
                                  sku: sku,
                                );

                            /// STEP 4 — UPDATE ITEM WITH IMAGE LINKS
                            await itemService.updateItemImages(
                              sku: sku,
                              thumbnailUrl: thumbnailUrl,
                              imageFolderPath: imageFolderPath,
                            );

                            print("Item fully saved");

                            Navigator.pop(context);
                          } catch (e) {
                            print("SAVE ITEM ERROR: $e");
                          }
                        },
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
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: rs(context, 12)),
      child: SizedBox(
        height: rs(context, 38),
        child: TextField(
          controller: controller, // 👈 THIS is what lets you read the value
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

  Widget _thumbnailUploadButton(BuildContext context) {
    return Column(
      children: [
        // ORIGINAL BUTTON DESIGN
        Padding(
          padding: EdgeInsets.only(bottom: rs(context, 12)),
          child: Center(
            child: OutlinedButton.icon(
              onPressed: () async {
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery,
                );

                if (image != null) {
                  setState(() {
                    _thumbnailImage = image;
                  });
                }
              },
              icon: const Icon(Icons.upload),
              label: const Text("Upload Image"),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(rs(context, 150), rs(context, 38)),
                side: const BorderSide(color: Colors.white, width: 1.5),
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
        ),

        // PREVIEW
        if (_thumbnailImage != null)
          GestureDetector(
            onTap: () {
              // TAP = REMOVE
              setState(() {
                _thumbnailImage = null;
              });
            },
            onLongPress: () {
              // HOLD = ENLARGE
              showDialog(
                context: context,
                builder: (_) =>
                    Dialog(child: Image.file(File(_thumbnailImage!.path))),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(_thumbnailImage!.path),
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          ),
      ],
    );
  }

  Widget _itemImagesUploadButton(BuildContext context) {
    return Column(
      children: [
        // ORIGINAL BUTTON DESIGN
        Padding(
          padding: EdgeInsets.only(bottom: rs(context, 12)),
          child: Center(
            child: OutlinedButton.icon(
              onPressed: () async {
                final List<XFile>? images = await _picker.pickMultiImage();

                if (images != null && images.isNotEmpty) {
                  setState(() {
                    _itemImages.addAll(images);
                  });
                }
              },
              icon: const Icon(Icons.upload),
              label: const Text("Upload Image"),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(rs(context, 150), rs(context, 38)),
                side: const BorderSide(color: Colors.white, width: 1.5),
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
        ),

        // PREVIEW STRIP
        if (_itemImages.isNotEmpty)
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _itemImages.length,
              itemBuilder: (context, index) {
                final image = _itemImages[index];

                return GestureDetector(
                  onTap: () {
                    // TAP = REMOVE THIS IMAGE
                    setState(() {
                      _itemImages.removeAt(index);
                    });
                  },
                  onLongPress: () {
                    // HOLD = ENLARGE
                    showDialog(
                      context: context,
                      builder: (_) =>
                          Dialog(child: Image.file(File(image.path))),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(image.path),
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _manufacturerDropdown(BuildContext context, String hint) {
    if (_isLoadingManufacturers) {
      return const CircularProgressIndicator();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: rs(context, 12)),
      child: SizedBox(
        height: rs(context, _modalInputHeight),
        child: DropdownButtonFormField<String>(
          value: _selectedManufacturerId,
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

          // 🔥 dynamic list here
          items: _manufacturers.map((manufacturer) {
            return DropdownMenuItem<String>(
              value: manufacturer['manufacturer_id'].toString(),
              child: Text(manufacturer['name']),
            );
          }).toList(),

          onChanged: (value) {
            setState(() {
              _selectedManufacturerId = value;
              print(_selectedManufacturerId);
            });
          },
        ),
      ),
    );
  }

  Widget _categoryDropdown(BuildContext context, String hint) {
    if (_isLoadingCategory) {
      return const CircularProgressIndicator();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: rs(context, 12)),
      child: SizedBox(
        height: rs(context, _modalInputHeight),
        child: DropdownButtonFormField<String>(
          value: _selectedCategoryId,
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

          // 🔥 dynamic list here
          items: _category.map((category) {
            return DropdownMenuItem<String>(
              value: category['category_id'].toString(),
              child: Text(category['category_name']),
            );
          }).toList(),

          onChanged: (value) {
            setState(() {
              _selectedCategoryId = value;
              print(_selectedCategoryId);
            });
          },
        ),
      ),
    );
  }

  Widget _ipDropdown(BuildContext context, String hint) {
    if (_isLoadingIP) {
      return const CircularProgressIndicator();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: rs(context, 12)),
      child: SizedBox(
        height: rs(context, _modalInputHeight),
        child: DropdownButtonFormField<String>(
          value: _selectedIPId,
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

          // 🔥 dynamic list here
          items: _ip.map((ip) {
            return DropdownMenuItem<String>(
              value: ip['ip_id'].toString(),
              child: Text(ip['ip_name']),
            );
          }).toList(),

          onChanged: (value) {
            setState(() {
              _selectedIPId = value;
              print(_selectedIPId);
            });
          },
        ),
      ),
    );
  }

  Widget _shelfDropdown(BuildContext context, String hint) {
    if (_isLoadingShelf) {
      return const CircularProgressIndicator();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: rs(context, 12)),
      child: SizedBox(
        height: rs(context, _modalInputHeight),
        child: DropdownButtonFormField<String>(
          value: _selectedShelfId,
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

          // 🔥 dynamic list here
          items: _shelf.map((shelf) {
            return DropdownMenuItem<String>(
              value: shelf['shelf_id'].toString(),
              child: Text(shelf['shelf_num'].toString()),
            );
          }).toList(),

          onChanged: (value) {
            setState(() {
              _selectedShelfId = value;
              print(_selectedShelfId);
            });
          },
        ),
      ),
    );
  }

  Widget _modalTextArea(
    BuildContext context,
    String hint, {
    required TextEditingController controller,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: rs(context, 12)),
      child: TextField(
        controller: controller,
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
}
