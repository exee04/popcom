import 'package:flutter/material.dart';
import 'dart:ui';

double rs(BuildContext context, double size) {
  final width = MediaQuery.of(context).size.width;
  return size * (width / 375).clamp(0.9, 1.2);
}

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _shelfNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _mobileNumController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: rs(context, kToolbarHeight + MediaQuery.of(context).padding.top),
        left: rs(context, 16),
        right: rs(context, 16),
      ),
      child: glassPanel(
        context,
        child: Padding(
          padding: EdgeInsets.all(rs(context, 16)),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // STORE INFO SECTION
                _sectionHeader(
                  icon: Icons.storefront_sharp,
                  title: "STORE INFO",
                ),

                SizedBox(height: rs(context, 10)),
                _label("Shelf Code / Name"),
                SizedBox(height: rs(context, 8)),
                _input(_shelfNameController, "Shelf Name / Code"),

                SizedBox(height: rs(context, 25)),

                // PERSONAL DETAILS
                _sectionHeader(
                  icon: Icons.person_sharp,
                  title: "PERSONAL DETAILS",
                ),

                SizedBox(height: rs(context, 10)),
                _label("First Name"),
                SizedBox(height: rs(context, 8)),
                _input(_firstNameController, "First Name"),

                SizedBox(height: rs(context, 15)),
                _label("Last Name"),
                SizedBox(height: rs(context, 8)),
                _input(_lastNameController, "Last Name"),

                SizedBox(height: rs(context, 15)),
                _label("Address"),
                SizedBox(height: rs(context, 8)),
                _input(_addressController, "Address"),

                SizedBox(height: rs(context, 25)),

                // CONTACT
                _sectionHeader(icon: Icons.contacts_sharp, title: "CONTACT"),

                SizedBox(height: rs(context, 10)),
                _label("Mobile Number"),
                SizedBox(height: rs(context, 8)),
                _input(_mobileNumController, "Mobile Number"),

                SizedBox(height: rs(context, 15)),
                _label("E-Mail Address"),
                SizedBox(height: rs(context, 8)),
                _input(_emailController, "E-Mail Address"),

                SizedBox(height: rs(context, 40)),
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

  Widget _sectionHeader({required IconData icon, required String title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: rs(context, 20), color: Colors.black87),
            SizedBox(width: rs(context, 6)),
            Text(
              title,
              style: TextStyle(
                fontSize: rs(context, 15),
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Divider(color: Colors.black87, thickness: 1),
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: rs(context, 12), color: Colors.black87),
    );
  }

  Widget _input(TextEditingController controller, String hint) {
    return SizedBox(
      height: rs(context, 35),
      child: TextField(
        textAlign: TextAlign.left,
        style: TextStyle(fontSize: rs(context, 12)),
        controller: controller,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            vertical: rs(context, 10),
            horizontal: rs(context, 5),
          ),
          hintText: hint,
          filled: true,
          fillColor: Colors.white70.withOpacity(0.65),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.black54, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.yellow.shade700, width: 2),
          ),
        ),
      ),
    );
  }
}
