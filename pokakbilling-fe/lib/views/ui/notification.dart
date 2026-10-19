import 'package:flutter/material.dart';
import 'package:pokakbilling/viewmodels/notifica_state.dart';

class NotificationScreen extends StatelessWidget {
  final NotificationController notificationController;

  const NotificationScreen({super.key, required this.notificationController});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(fontSize: height * 0.027),
        ),
        elevation: 0,
        toolbarHeight: height * 0.08,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.04,
          ),
          child: Center(
            child: Text(
              'This feature will come soon',
              style: TextStyle(
                fontSize: height * 0.025,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
