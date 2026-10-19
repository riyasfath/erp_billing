// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/models/data-models/salesperson_model.dart';
// import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';
// import 'package:pokakbilling/views/commonWidgets/view_widget/view_buildfield.dart';
// import 'package:pokakbilling/views/commonWidgets/view_widget/view_namecontainer.dart';

// class ViewSalesPersonScreen extends StatelessWidget {
//   final SalesPersonModel salesPerson;
//   const ViewSalesPersonScreen({super.key, required this.salesPerson});

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: AppColors.white,
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Container(
//                 height: screenHeight * 0.18,
//                 decoration: const BoxDecoration(
//                   color: AppColors.violetblue,
//                 ),
//                 child: Padding(
//                   padding: EdgeInsets.only(
//                     left: screenWidth * 0.02,
//                     right: screenWidth * 0.03,
//                   ),
//                   child: AppBar(
//                     leading: IconButton(
//                       icon: const Icon(
//                         Icons.arrow_back,
//                         color: AppColors.white,
//                       ),
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                     ),
//                     title: Text(
//                       'Sales Person',
//                       style: TextStyle(
//                         color: AppColors.white,
//                         fontWeight: FontWeight.w500,
//                         fontSize: screenWidth * 0.05,
//                       ),
//                     ),
//                     backgroundColor: Colors.transparent,
//                     elevation: 0,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Positioned(
//             top: screenHeight * 0.15,
//             left: screenWidth * 0.04,
//             right: screenWidth * 0.04,
//             child: Container(
//               height: screenHeight - screenHeight * 0.18,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 child: Column(
//                   children: [
//                     ViewNamecontainer(
//                       screenHeight: screenHeight,
//                       screenWidth: screenWidth,
//                       id: salesPerson.salesPersonId,
//                       name: "${salesPerson.firstName} ${salesPerson.lastName}",
//                     ),
//                     SizedBox(
//                       height: screenHeight * 0.03,
//                     ),
//                     Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 4.0),
//                       padding: const EdgeInsets.all(16.0),
//                       decoration: BoxDecoration(
//                         color: AppColors.white,
//                         borderRadius: BorderRadius.circular(8.0),
//                         boxShadow: const [
//                           BoxShadow(
//                             color: AppColors.grey,
//                             blurRadius: 1,
//                             spreadRadius: 1,
//                             offset: Offset(0, 0),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         children: [
//                           ViewBuildfield(
//                             label: "First Name",
//                             value: salesPerson.firstName,
//                           ),
//                           ViewBuildfield(
//                             label: "Last Name",
//                             value: salesPerson.lastName,
//                           ),
//                           ViewBuildfield(
//                             label: "Designation",
//                             value: salesPerson.designation,
//                           ),
//                           ViewBuildfield(
//                             label: "Country",
//                             value: salesPerson.country,
//                           ),
//                           ViewBuildfield(
//                             label: "State",
//                             value: salesPerson.state,
//                           ),
//                           ViewBuildfield(
//                             label: "City",
//                             value: salesPerson.city,
//                           ),
//                           ViewBuildfield(
//                             label: "Address",
//                             value: salesPerson.address,
//                           ),
//                           ViewBuildfield(
//                             label: "Email",
//                             value: salesPerson.email,
//                           ),
//                           ViewBuildfield(
//                             label: "Phone",
//                             value: salesPerson.phone,
//                           ),
//                           ViewBuildfield(
//                             label: "Mobile",
//                             value: salesPerson.mobile,
//                           ),
//                           ViewBuildfield(
//                             label: "Incentive",
//                             value: salesPerson.incentive,
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(
//                       height: screenHeight * 0.03,
//                     ),
//                     const ExitCustomButton(text: "Exit"),
//                   ],
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/core/utils/text_utils.dart';
import 'package:pokakbilling/models/data-models/salesperson_model.dart';

// ─── Strict 3-color palette ───────────────────────────────────────────────────
class _C {
  _C._();
  static const Color navy = AppColors.navy;
  static const Color cyan = AppColors.cyan;
  static const Color ice = AppColors.ice;
  static const Color white = AppColors.white;
}
// ─────────────────────────────────────────────────────────────────────────────

class ViewSalesPersonScreen extends StatefulWidget {
  final SalesPersonModel salesPerson;

  const ViewSalesPersonScreen({super.key, required this.salesPerson});

  @override
  State<ViewSalesPersonScreen> createState() => _ViewSalesPersonScreenState();
}

class _ViewSalesPersonScreenState extends State<ViewSalesPersonScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.salesPerson;
    final topPad = MediaQuery.of(context).padding.top;
    final sw = MediaQuery.of(context).size.width;

    final initials = "${user.firstName.isNotEmpty ? user.firstName[0] : ''}"
            "${user.lastName.isNotEmpty ? user.lastName[0] : ''}"
        .toUpperCase();

    return Scaffold(
      backgroundColor: _C.ice,
      body: Column(
        children: [
          _buildHeader(context, sw, topPad, user, initials),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: Column(
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -8),
                        child: Column(
                          children: [
                            /// PERSONAL
                            _buildInfoCard(
                              icon: Icons.person_outline,
                              title: "Personal Details",
                              rows: [
                                _InfoRow(
                                  Icons.badge_outlined,
                                  "First Name",
                                  user.firstName,
                                ),
                                _InfoRow(Icons.badge_outlined, "Last Name",
                                    user.lastName),
                                _InfoRow(Icons.work_outline, "Designation",
                                    user.designation),
                              ],
                            ),

                            const SizedBox(height: 12),

                            /// LOCATION
                            _buildInfoCard(
                              icon: Icons.location_on_outlined,
                              title: "Location",
                              rows: [
                                _InfoRow(Icons.flag_outlined, "Country",
                                    user.country),
                                _InfoRow(Icons.location_city_outlined, "State",
                                    user.state),
                                _InfoRow(
                                    Icons.location_city, "City", user.city),
                                _InfoRow(Icons.home_outlined, "Address",
                                    user.address),
                              ],
                            ),

                            const SizedBox(height: 12),

                            /// CONTACT
                            _buildInfoCard(
                              icon: Icons.phone_outlined,
                              title: "Contact Details",
                              rows: [
                                _InfoRow(
                                    Icons.email_outlined, "Email", user.email),
                                _InfoRow(
                                    Icons.phone_outlined, "Phone", user.phone),
                                _InfoRow(Icons.smartphone_outlined, "Mobile",
                                    user.mobile),
                              ],
                            ),

                            const SizedBox(height: 12),

                            /// INCENTIVE
                            _buildInfoCard(
                              icon: Icons.attach_money,
                              title: "Incentive",
                              rows: [
                                _InfoRow(
                                    Icons.money, "Incentive", user.incentive),
                              ],
                            ),

                            const SizedBox(height: 20),

                            _buildExitButton(context),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, double sw, double topPad,
      SalesPersonModel user, String initials) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPad + 12,
        bottom: 40,
        left: sw * 0.045,
        right: sw * 0.045,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -10,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _C.cyan.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: sw * 0.30,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: _C.cyan.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + title row
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _C.cyan.withOpacity(0.20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: _C.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Sales Person View',
                    style: TextStyle(
                      color: _C.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  // ID badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _C.cyan.withOpacity(0.20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ID #${user.salesPersonId}',
                      style: const TextStyle(
                        color: _C.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Avatar + name row
              Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: _C.cyan.withOpacity(0.20),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _C.cyan.withOpacity(0.50),
                        width: 2.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: _C.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.firstName} ${user.lastName}'
                              .trim()
                              .toUpperCase(),
                          style: const TextStyle(
                            color: _C.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (user.designation.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.work_outline,
                                  size: 12, color: _C.ice.withOpacity(0.80)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  capitalizeWords(user.designation),
                                  style: TextStyle(
                                    color: _C.ice.withOpacity(0.90),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (user.email.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.email_outlined,
                                  size: 12, color: _C.ice.withOpacity(0.70)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  user.email,
                                  style: TextStyle(
                                    color: _C.ice.withOpacity(0.75),
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Info card ─────────────────────────────────────────────────────────────
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<_InfoRow> rows,
  }) {
    final visibleRows = rows.where((r) => r.value.isNotEmpty).toList();
    if (visibleRows.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.cyan.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: _C.navy.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _C.cyan.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: _C.cyan, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  capitalizeWords(
                    title,
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _C.navy,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: _C.cyan.withOpacity(0.12),
          ),

          // Field rows
          ...visibleRows.asMap().entries.map((entry) {
            final i = entry.key;
            final row = entry.value;
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: _C.ice,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(row.icon,
                            size: 14, color: _C.navy.withOpacity(0.50)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.label,
                              style: TextStyle(
                                fontSize: 11,
                                color: _C.navy.withOpacity(0.45),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              row.formattedValue,
                              style: const TextStyle(
                                fontSize: 14,
                                color: _C.navy,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < visibleRows.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: _C.cyan.withOpacity(0.10),
                    indent: 56,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ── Exit / Go Back button ─────────────────────────────────────────────────
  Widget _buildExitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_C.cyan, _C.navy],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: _C.cyan.withOpacity(0.30),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back_ios_new_rounded, color: _C.white, size: 14),
              SizedBox(width: 8),
              Text(
                'Go Back',
                style: TextStyle(
                  color: _C.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(this.icon, this.label, this.value);

  String get formattedValue => capitalizeWords(value);
}
