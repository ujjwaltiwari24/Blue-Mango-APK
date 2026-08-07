import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TestFirebase extends StatefulWidget {
  const TestFirebase({super.key});

  @override
  State<TestFirebase> createState() => _TestFirebaseState();
}

class _TestFirebaseState extends State<TestFirebase> {
  String status = "Testing...";

  @override
  void initState() {
    super.initState();
    testFirebase();
  }

  Future<void> testFirebase() async {
    try {
      await FirebaseFirestore.instance
          .collection("test")
          .add({
        "message": "BlueMango Connected 🚀",
        "time": Timestamp.now(),
      });

      setState(() {
        status = "Firebase Connected Successfully 🎉";
      });
    } catch (e) {
      setState(() {
        status = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          status,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}