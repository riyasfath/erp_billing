import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/views/widget/Custom-ui/container.dart';

class ItemFormScreen extends StatefulWidget {
  const ItemFormScreen({super.key});

  @override
  _ItemFormScreenState createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  String itemType = 'Goods';
  TextEditingController itemNameController = TextEditingController();
  TextEditingController unitController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 7, 92, 221),
        title: const Text(
          'Items',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Save functionality here
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Search functionality here
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First container for Item Type, Add Image, Item Name, and Unit
                Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Item Type',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Radio<String>(
                                      value: 'Goods',
                                      groupValue: itemType,
                                      onChanged: (value) {
                                        setState(() {
                                          itemType = value!;
                                        });
                                      },
                                    ),
                                    const Text('Goods'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Radio<String>(
                                      value: 'Service',
                                      groupValue: itemType,
                                      onChanged: (value) {
                                        setState(() {
                                          itemType = value!;
                                        });
                                      },
                                    ),
                                    const Text('Service'),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            // InkWell(
                            //   onTap: () {
                            //     // Add image functionality here
                            //   },
                            //   child: const DashedBorderContainer(
                            //     width: 120,
                            //     height: 140,
                            //     imagePath: AppAssets.logo,
                            //   ),
                            // ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: itemNameController,
                          decoration: const InputDecoration(
                            labelText: 'Item Name *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: unitController,
                          decoration: const InputDecoration(
                            labelText: 'Unit',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Second container for Sales Information
                const ElevationOnSelectContainer(),
                const SizedBox(height: 50),
                Center(
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(20),
                    child: ElevatedButton(
                      onPressed: () {
                        // Submit action here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        minimumSize: const Size(300, 60),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
