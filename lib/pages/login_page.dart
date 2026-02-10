import 'package:flutter/material.dart';
import 'package:popcom/auth/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // get auth service
  final authService = AuthService();

  //logout button pressed
  void logout() async {
    await authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        title: Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Home',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(255, 54, 54, 54),
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 50),
        children: [
          SizedBox(height: 40),
          Center(
            child: SizedBox(
              width: 170,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // button color
                  foregroundColor: Colors.white, // text color
                  minimumSize: const Size.fromHeight(48), // button size
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.add),
                    SizedBox(width: 5),
                    Text("Add Record"),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          Center(
            child: SizedBox(
              width: 170,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // button color
                  foregroundColor: Colors.white, // text color
                  minimumSize: const Size.fromHeight(48), // button size
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.table_view_outlined),
                    SizedBox(width: 5),
                    Text("View Records"),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          Center(
            child: SizedBox(
              width: 170,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // button color
                  foregroundColor: Colors.white, // text color
                  minimumSize: const Size.fromHeight(48), // button size
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.calendar_month_outlined),
                    SizedBox(width: 5),
                    Text("Appointments"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
