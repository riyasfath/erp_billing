import 'package:flutter/material.dart';

class ElevationOnSelectContainer extends StatefulWidget {
  const ElevationOnSelectContainer({super.key});

  @override
  _ElevationOnSelectContainerState createState() =>
      _ElevationOnSelectContainerState();
}

class _ElevationOnSelectContainerState
    extends State<ElevationOnSelectContainer> {
  double _elevation = 0;

  // Initial elevation value

  void _onTap() {
    setState(() {
      // Toggle elevation when container is tapped
      _elevation = _elevation == 0 ? 8 : 0; // Toggle between 0 and 8
    });
  }

  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap, // Trigger the elevation change on tap
      child: Material(
        elevation: _elevation, // Apply the elevation to the Material
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            color: const Color.fromARGB(255, 236, 224, 251),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Invoice ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                    labelText: 'note ', labelStyle: TextStyle(fontSize: 20)),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Customer',
                  labelStyle: TextStyle(fontSize: 20),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
