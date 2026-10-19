import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/models/services/invoice_service.dart';
import 'package:pokakbilling/viewmodels/invoice_viewmodel.dart';
import 'package:pokakbilling/views/Screens/invoice/add_invoice/add_invoice.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/views/Screens/invoice/single_invoice_card.dart';

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
  int selectedTab = 0;

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

    Future.microtask(() async {
      final provider = Provider.of<InvoiceViewModel>(
        context,
        listen: false,
      );

      /// ACTIVE
      final activeInvoices = await InvoiceServices.getInvoices(
        status: "FINAL",
      );

      /// DRAFT
      final draftInvoices = await InvoiceServices.getInvoices(
        status: "DRAFT",
      );

      /// CANCEL
      final cancelInvoices = await InvoiceServices.getInvoices(
        status: "CANCELLED",
      );

      provider.activeCount = activeInvoices.length;
      provider.draftCount = draftInvoices.length;
      provider.cancelCount = cancelInvoices.length;

      /// DEFAULT LOAD
      provider.invoiceList = activeInvoices;

      provider.notifyListeners();
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
    return Consumer<InvoiceViewModel>(
      builder: (context, inv, _) {
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
                                text: '${inv.invoiceList.length}',
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
                        const AddInvoices(
                          isEdit: false,
                          invoiceNumber: '',
                        ),
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
                            color: AppColors.c1.withOpacity(0.25),
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
                          inv.searchInvoice(value);
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
                          isDense: true, // ← fixes vertical centering
                          contentPadding: EdgeInsets
                              .zero, // ← removes extra top/bottom padding
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
    return Consumer<InvoiceViewModel>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              /// ACTIVE / DRAFT TAB
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
                      title: "Active",
                      count: provider.activeCount,
                      index: 0,
                      status: "FINAL",
                    ),
                    _tabButton(
                      title: "Draft",
                      count: provider.draftCount,
                      index: 1,
                      status: "DRAFT",
                    ),
                    _tabButton(
                      title: "Cancel",
                      count: provider.cancelCount,
                      index: 2,
                      status: "CANCELLED",
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
    required int count,
    required int index,
    required String status,
  }) {
    final isSelected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () async {
          setState(() {
            selectedTab = index;
          });

          final provider = Provider.of<InvoiceViewModel>(
            context,
            listen: false,
          );

          await provider.getAllInvoices(
            status: status,
          );
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
                      color: Colors.black.withOpacity(0.05),
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
    return Consumer<InvoiceViewModel>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
              child: CircularProgressIndicator(
            color: AppColors.c1,
            strokeWidth: 2.5,
          ));
        }

        if (provider.invoiceList.isEmpty) {
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
          itemCount: provider.invoiceList.length,
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
                      color: AppColors.c1.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleInvoiceCard(index: index),
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
