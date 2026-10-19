import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/invoice/invoice_model.dart';
import 'package:pokakbilling/viewmodels/invoice_viewmodel.dart';
import 'package:pokakbilling/views/Screens/invoice/add_invoice.dart';
import 'package:pokakbilling/views/Screens/invoice/single_invoice_card.dart';
import 'package:provider/provider.dart';

class InvoiceMain extends StatefulWidget {
  const InvoiceMain({super.key});

  @override
  State<InvoiceMain> createState() => _InvoiceMainState();
}

class _InvoiceMainState extends State<InvoiceMain>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // 0 = All, 1 = Client, 2 = Student
  int selectedTab = 0;
  String _searchQuery = '';

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

    Future.microtask(() {
      Provider.of<InvoiceViewmodel>(context, listen: false).getAllInvoices();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  /// ──────────────────────────── FILTER HELPERS ────────────────────────────
  List<InvoiceModel> _filtered(List<InvoiceModel> all) {
    List<InvoiceModel> list = all;

    if (selectedTab == 1) {
      list = list.where((inv) => inv.invoiceType == 'client').toList();
    } else if (selectedTab == 2) {
      list = list.where((inv) => inv.invoiceType == 'intern').toList();
    }

    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((inv) {
        final name = (inv.invoiceType == 'client'
                ? (inv.clientName ?? '')
                : (inv.internName ?? ''))
            .toLowerCase();
        final num = inv.invoiceNumber.toLowerCase();
        return name.contains(q) || num.contains(q);
      }).toList();
    }

    return list;
  }

  int _countForTab(List<InvoiceModel> all, int tab) {
    if (tab == 0) return all.length;
    if (tab == 1) return all.where((i) => i.invoiceType == 'client').length;
    return all.where((i) => i.invoiceType == 'intern').length;
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            _buildHeader(context, topPad, sw),

            /// FILTER SECTION
            _buildFilterTabs(),
            const SizedBox(height: 10),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: _buildList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //======================================= Header =================================
  Widget _buildHeader(BuildContext context, double topPad, double sw) {
    return Consumer<InvoiceViewmodel>(
      builder: (context, inv, _) {
        final filtered = _filtered(inv.invoiceList);
        return Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: topPad + 14,
            bottom: 18,
            left: sw * 0.05,
            right: sw * 0.05,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.cborder, width: 1.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ── TOP ROW ─────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Invoices',
                          style: TextStyle(
                            color: AppColors.cdark,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Total ',
                                style: TextStyle(
                                  color: AppColors.ctext,
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: '${filtered.length}',
                                style: const TextStyle(
                                  color: AppColors.ctext,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(
                                text: ' invoices',
                                style: TextStyle(
                                  color: AppColors.ctext,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  /// NEW BUTTON
                  GestureDetector(
                    onTap: () {
                      pushNavigation(
                        context,
                        const AddInvoiceScreen(),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: AppColors.c1,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.c1.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add_rounded,
                              color: AppColors.white, size: 15),
                          SizedBox(width: 4),
                          Text(
                            'New',
                            style: TextStyle(
                              color: AppColors.white,
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

              const SizedBox(height: 14),

              /// ── SEARCH BAR ─────────────────────────────
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.cxl,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cborder),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: AppColors.ctext,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.cdark,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search by client name or invoice no.',
                          hintStyle: TextStyle(
                            color: AppColors.ctext,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterTabs() {
    return Consumer<InvoiceViewmodel>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              /// ALL / CLIENT / STUDENT TAB
              Container(
                height: 52,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xffF3F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _tabButton(
                      title: "All",
                      index: 0,
                      all: provider.invoiceList,
                    ),
                    _tabButton(
                      title: "Client",
                      index: 1,
                      all: provider.invoiceList,
                    ),
                    _tabButton(
                      title: "Student",
                      index: 2,
                      all: provider.invoiceList,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tabButton({
    required String title,
    required int index,
    required List<InvoiceModel> all,
  }) {
    final isSelected = selectedTab == index;
    final count = _countForTab(all, index);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            "$title ($count)",
            style: TextStyle(
              color: isSelected ? AppColors.c1 : AppColors.ctext,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  //======================== List of Invoice ===========================================
  Widget _buildList() {
    return Consumer<InvoiceViewmodel>(
      builder: (context, provider, _) {
        if (provider.getInvoiceLoader) {
          return const Center(
              child: CircularProgressIndicator(
            color: AppColors.c1,
            strokeWidth: 2.5,
          ));
        }

        final list = _filtered(provider.invoiceList);

        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.cxl,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cborder),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.c1,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "No Invoices Yet",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cdark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tap "New" to add your first invoice',
                  style: TextStyle(fontSize: 13, color: AppColors.ctext),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          itemCount: list.length,
          itemBuilder: (context, index) {
            return _ItemAnimation(
              delay: Duration(milliseconds: 40 + index * 40),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cborder),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.c1.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleInvoiceCard(invoice: list[index]),
              ),
            );
          },
        );
      },
    );
  }
}

// =========================== Animation =====================================================
class _ItemAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _ItemAnimation({required this.child, required this.delay});

  @override
  State<_ItemAnimation> createState() => _ItemAnimationState();
}

class _ItemAnimationState extends State<_ItemAnimation>
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
      begin: const Offset(0, 0.10),
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
