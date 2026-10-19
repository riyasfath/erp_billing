import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
import 'package:pokakbilling/views/Screens/sales_person/add_sales_person.dart';
import 'package:pokakbilling/views/Screens/sales_person/single_sales_person.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_dropdown.dart';
import 'package:provider/provider.dart';

/// ─── 3 COLOR PALETTE ─────────────────────────────
class _C {
  _C._();

  static const Color navy = AppColors.navy;
  static const Color cyan = AppColors.cyan;
  static const Color ice = AppColors.ice;
  static const Color white = AppColors.white;
}

/// ────────────────────────────────────────────────

class SalesPersonMain extends StatefulWidget {
  const SalesPersonMain({super.key});

  @override
  State<SalesPersonMain> createState() => _SalesPersonMainState();
}

class _SalesPersonMainState extends State<SalesPersonMain>
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

    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );

    _animCtrl.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final provider = Provider.of<SalesPersonViewmodel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.salesPersonList.isEmpty && !provider.getSalesPersonLoading) {
        provider.getAllSalesPerson();
      }

      if (provider.selectedSalesPersonId != 0) {
        provider.getSalesPersonById(provider.selectedSalesPersonId);
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _C.ice,
      body: Column(
        children: [
          _buildHeader(context, sw, topPad),
          _buildSearchCard(context, sw),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: _buildList(context),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// ─── HEADER ────────────────────────────────────
  Widget _buildHeader(BuildContext context, double sw, double topPad) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPad + 12,
        bottom: 28,
        left: sw * 0.03,
        right: sw * 0.04,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          /// Top right decorative circle
          Positioned(
            top: -20,
            right: -10,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: _C.cyan.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),

          /// Bottom decorative circle
          Positioned(
            bottom: -24,
            left: sw * 0.25,
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: _C.cyan.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          /// Header content
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

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sales Person',
                      style: TextStyle(
                        color: _C.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Consumer<SalesPersonViewmodel>(
                      builder: (ctx, p, _) => Text(
                        '${p.salesPersonList.length} total sales persons',
                        style: TextStyle(
                          color: _C.ice.withOpacity(0.75),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// New Sales Person button
              GestureDetector(
                onTap: () {
                  pushNavigation(
                    context,
                    const AddSalesPerson(isEdit: false),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _C.cyan,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: _C.cyan.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, color: _C.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'New Sales Person',
                        style: TextStyle(
                          color: _C.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Search / Filter Card ──────────────────────────────────────────────────
  Widget _buildSearchCard(BuildContext context, double sw) {
    return Transform.translate(
      offset: const Offset(0, -14),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _C.cyan.withOpacity(0.20)),
            boxShadow: [
              BoxShadow(
                color: _C.navy.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _C.cyan.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.filter_list_rounded,
                      color: _C.cyan,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filter Sales Person',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _C.navy.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Consumer<SalesPersonViewmodel>(
                builder: (context, provider, child) {
                  return CustomDropdown(
                      selectedValue: provider.selectedSalesPerson.isEmpty
                          ? null
                          : provider.selectedSalesPerson,
                      hint: "Select Sales Persons",
                      dropdownItems: [
                        "All Sales Persons",
                        ...provider.salesPersonList
                            .map((c) => "${c.firstName} ${c.lastName}")
                            .toSet()
                            .toList(),
                      ],
                      onChanged: (String? newValue) async {
                        if (newValue == null) return;

                        if (newValue == "All Sales Persons") {
                          provider.updateSelectedSalesPersonId(0);
                          provider.selectSalesPerson("");
                          await provider.getAllSalesPerson();
                        } else {
                          var selectedCustomer =
                              provider.salesPersonList.firstWhere(
                            (c) => "${c.firstName} ${c.lastName}" == newValue,
                          );

                          provider.updateSelectedSalesPersonId(
                              selectedCustomer.salesPersonId);
                          provider.selectSalesPerson(newValue);

                          await provider.getSalesPersonById(
                              selectedCustomer.salesPersonId);
                        }
                      });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── List ──────────────────────────────────────────────────────────────────
  Widget _buildList(BuildContext context) {
    return Consumer<SalesPersonViewmodel>(
      builder: (context, provider, child) {
        if (provider.getSalesPersonLoading ||
            provider.singleSalesPersonLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: _C.cyan,
              strokeWidth: 2.5,
            ),
          );
        }

        // Single customer view
        if (provider.selectedSalesPersonId != 0 &&
            provider.singleSalesPersonList.isNotEmpty) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildListHeader(1),
              _StaggeredItem(
                delay: const Duration(milliseconds: 60),
                child: _CardWrapper(
                  child: SingleSalePersonCard(
                    index: provider.salesPersonList.indexWhere(
                      (c) =>
                          c.salesPersonId ==
                          provider.singleSalesPersonList.first.salesPersonId,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        if (provider.salesPersonList.isEmpty) {
          return _buildEmptyState();
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          itemCount: provider.salesPersonList.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildListHeader(provider.salesPersonList.length);
            }
            final i = index - 1;
            return _StaggeredItem(
              delay: Duration(milliseconds: 40 + i * 50),
              child: _CardWrapper(
                child: SingleSalePersonCard(index: i),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListHeader(int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            'ALL SALES PERSONS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _C.navy.withOpacity(0.55),
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _C.cyan.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _C.cyan,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _C.cyan.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_alt_outlined,
              color: _C.cyan.withOpacity(0.6),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Sales person Yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _C.navy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap "New Sales Person " to add your first client',
            style: TextStyle(
              fontSize: 13,
              color: _C.navy.withOpacity(0.45),
            ),
          ),
        ],
      ),
    );
  }
}

/// ─── CARD WRAPPER ───────────────────────────────
class _CardWrapper extends StatelessWidget {
  final Widget child;

  const _CardWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.cyan.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: _C.navy.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 3),
          )
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: child,
    );
  }
}

/// ─── STAGGERED ANIMATION ────────────────────────
class _StaggeredItem extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _StaggeredItem({
    required this.child,
    required this.delay,
  });

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
