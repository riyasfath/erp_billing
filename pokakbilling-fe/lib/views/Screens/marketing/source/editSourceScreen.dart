// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/models/data-models/marketing_model/source.dart';
// import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
// import 'package:provider/provider.dart';

// class EditSourcePage extends StatefulWidget {
//   final Source source;

//   const EditSourcePage({super.key, required this.source});

//   @override
//   State<EditSourcePage> createState() => _EditSourcePageState();
// }

// class _EditSourcePageState extends State<EditSourcePage> {
//   late TextEditingController sourceController;

//   @override
//   void initState() {
//     super.initState();
//     sourceController = TextEditingController(text: widget.source.name);
//   }

//   @override
//   void dispose() {
//     sourceController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset:
//           true, // ✅ allows screen to resize instead of overflow
//       appBar: AppBar(
//         backgroundColor: AppColors.violetblue,
//         title: const Text(
//           'Edit Source',
//           style: TextStyle(color: AppColors.white, fontSize: 16),
//         ),
//         leading: IconButton(
//           icon: const Icon(
//             CupertinoIcons.arrow_left,
//             color: AppColors.white,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return SingleChildScrollView(
//               // ✅ scrolls only when keyboard appears
//               physics: const ClampingScrollPhysics(),
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(
//                   minHeight: constraints.maxHeight,
//                 ),
//                 child: IntrinsicHeight(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       children: [
//                         // Card near the top
//                         Card(
//                           color: AppColors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           elevation: 8,
//                           shadowColor: Colors.grey.withOpacity(0.3),
//                           child: Container(
//                             height: 179,
//                             width: 350,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 16),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Text(
//                                   'Name',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                     color: AppColors.headerPurple,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 SizedBox(
//                                   height: 43,
//                                   width: 327,
//                                   child: TextField(
//                                     controller: sourceController,
//                                     style: const TextStyle(fontSize: 14),
//                                     decoration: InputDecoration(
//                                       hintText: 'Enter source name',
//                                       hintStyle: const TextStyle(
//                                           color: AppColors.hintTextGrey),
//                                       filled: true,
//                                       fillColor: AppColors.inputFill,
//                                       contentPadding:
//                                           const EdgeInsets.symmetric(
//                                               horizontal: 12, vertical: 8),
//                                       enabledBorder: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(8),
//                                         borderSide: const BorderSide(
//                                             color: AppColors.softBorder),
//                                       ),
//                                       focusedBorder: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(8),
//                                         borderSide: const BorderSide(
//                                             color: AppColors.softBorder),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),

//                         const Spacer(),

//                         // Update button
//                         Consumer<SourceViewmodel>(
//                           builder: (context, provider, child) {
//                             return SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 onPressed: provider.editSourceLoading
//                                     ? null
//                                     : () {
//                                         final name =
//                                             sourceController.text.trim();
//                                         if (name.isNotEmpty) {
//                                           provider.editSource(
//                                               widget.source.id, name, context);
//                                         }
//                                       },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: AppColors.violetblue,
//                                   padding:
//                                       const EdgeInsets.symmetric(vertical: 14),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                                 child: provider.editSourceLoading
//                                     ? const SizedBox(
//                                         height: 20,
//                                         width: 20,
//                                         child: CircularProgressIndicator(
//                                           color: AppColors.white,
//                                           strokeWidth: 2,
//                                         ),
//                                       )
//                                     : const Text(
//                                         'Update',
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           color: AppColors.white,
//                                         ),
//                                       ),
//                               ),
//                             );
//                           },
//                         ),

//                         const SizedBox(height: 16),

//                         // Cancel button
//                         SizedBox(
//                           width: double.infinity,
//                           child: OutlinedButton(
//                             onPressed: () => Navigator.pop(context, false),
//                             style: OutlinedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               side:
//                                   const BorderSide(color: AppColors.softBorder),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: const Text(
//                               'Cancel',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: AppColors.softBorder,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/marketing_model/source.dart'
    as SModel;
import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
import 'package:provider/provider.dart';

const _kIndigo = Color(0xFF6366F1);
const _kIndigoLight = Color(0xFF818CF8);
const _kIndigoDark = Color(0xFF4338CA);
const _kMetricInk = Color(0xFF1E1B4B);
const _kSoftLilac = Color(0xFFF0EEFF);

// ── Shared edit field decoration ──────────────────────────────────────────────
InputDecoration _editFieldDeco(String hint, {bool isDark = false}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
        color: isDark ? Colors.white30 : Colors.black38, fontSize: 13.5),
    filled: true,
    fillColor: isDark ? Colors.white.withValues(alpha: 0.07) : _kSoftLilac,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
          color: isDark
              ? _kIndigoLight.withValues(alpha: 0.2)
              : _kIndigo.withValues(alpha: 0.2),
          width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: _kIndigo.withValues(alpha: 0.55), width: 1.5),
    ),
  );
}

Widget _fieldLabel(String text, bool isDark) => Text(text,
    style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12.5,
        color: isDark ? _kIndigoLight : _kIndigoDark));

class EditSourcePage extends StatefulWidget {
  final SModel.Source source;
  const EditSourcePage({super.key, required this.source});
  @override
  State<EditSourcePage> createState() => _EditSourcePageState();
}

class _EditSourcePageState extends State<EditSourcePage> {
  late TextEditingController sourceController;
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    sourceController = TextEditingController(text: widget.source.name);
  }

  @override
  void dispose() {
    sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _isDark ? const Color(0xFF0F0D1E) : const Color(0xFFF5F4FF),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: _isDark ? const Color(0xFF1A1730) : _kIndigo,
        elevation: 0,
        title: const Text('Edit Source',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.arrow_left, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: _isDark
                                ? Colors.white.withValues(alpha: 0.07)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: _isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : _kIndigo.withValues(alpha: 0.15)),
                            boxShadow: _isDark
                                ? null
                                : [
                                    BoxShadow(
                                      color: _kIndigo.withValues(alpha: 0.07),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: _isDark
                                        ? _kIndigo.withValues(alpha: 0.2)
                                        : _kIndigo.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Icon(Icons.share_outlined,
                                        color: _isDark
                                            ? _kIndigoLight
                                            : _kIndigoDark,
                                        size: 18),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text('Source Details',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: _isDark
                                            ? Colors.white
                                            : _kMetricInk)),
                              ]),
                              const SizedBox(height: 18),
                              _fieldLabel('Source Name', _isDark),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 46,
                                child: TextField(
                                  controller: sourceController,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          _isDark ? Colors.white : _kMetricInk),
                                  decoration: _editFieldDeco(
                                      'Enter source name',
                                      isDark: _isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Consumer<SourceViewmodel>(
                          builder: (context, provider, child) {
                            return Column(children: [
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: provider.editSourceLoading
                                      ? null
                                      : () {
                                          final name =
                                              sourceController.text.trim();
                                          if (name.isNotEmpty) {
                                            provider.editSource(
                                                widget.source.id,
                                                name,
                                                context);
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _kIndigo,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  child: provider.editSourceLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2))
                                      : const Text('Update Source',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white)),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: OutlinedButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: _isDark
                                            ? Colors.white.withValues(alpha: 0.2)
                                            : _kIndigo.withValues(alpha: 0.25)),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  child: Text('Cancel',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _isDark
                                              ? Colors.white60
                                              : Colors.black54)),
                                ),
                              ),
                            ]);
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
