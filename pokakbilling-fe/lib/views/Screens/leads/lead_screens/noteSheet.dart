// lib/views/Screens/leads/lead_screens/leads_bottomsheets/note_sheet.dart

import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

class NoteSheet extends StatefulWidget {
  final int? leadId;
  final String? leadName;

  const NoteSheet({
    super.key,
    this.leadId,
    this.leadName,
  });

  @override
  State<NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<NoteSheet> {
  final TextEditingController _noteCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Note',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context, false),
                child: const Icon(Icons.cancel_outlined,
                    size: 22, color: Colors.black45),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Label
          const Text(
            'Add notes',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 8),

          // Text area
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _noteCtrl,
              maxLines: 6,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              decoration: const InputDecoration(
                hintText: 'Write a note about this lead..',
                hintStyle: TextStyle(fontSize: 13, color: Colors.black38),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Save Note button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _saving
                  ? null
                  : () async {
                      if (_noteCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a note')),
                        );
                        return;
                      }
                      setState(() => _saving = true);
                      // TODO: call your API here
                      // e.g. await noteVm.addNote(leadId: widget.leadId, note: _noteCtrl.text.trim());
                      await Future.delayed(const Duration(
                          milliseconds: 300)); // remove when API ready
                      if (mounted) {
                        Navigator.pop(context, true);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.violetblue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Save Note',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
            ),
          ),
          const SizedBox(height: 10),

          // Cancel button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFCCCCCC)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
