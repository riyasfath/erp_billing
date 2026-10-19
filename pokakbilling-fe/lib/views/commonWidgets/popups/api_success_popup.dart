import 'package:flutter/material.dart';

Future<bool> successPopup(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Done'),
        content: const Text('Add Success'),
        actions: <Widget>[
          TextButton(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.pop(context, true); // ✅ Return a bool value
            },
          ),
        ],
      );
    },
  ).then((value) => value ?? false); // ✅ Ensure a bool is always returned
}
