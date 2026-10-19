import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/global_viewmodel.dart';
import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
import 'package:pokakbilling/views/Screens/quotation/add/add_quotation.dart';
import 'package:pokakbilling/views/Screens/quotation/single_quotation_card.dart';
import 'package:provider/provider.dart';

class QuotationMain extends StatefulWidget {
  const QuotationMain({super.key});

  @override
  State<QuotationMain> createState() => _QuotationMainState();
}

class _QuotationMainState extends State<QuotationMain>
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
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuotationViewmodel>(context, listen: false)
          .getAllQuotations();
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
      //----------------------- Body --------------------------------
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        // decoration: const BoxDecoration(
        //   gradient: LinearGradient(
        //     colors: [_C.cyan1, _C.cyan, _C.cyan2, _C.cyan3],
        //     stops: [0.0, 0.35, 0.65, 1.0],
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //   ),
        // ),
        child: Column(
          children: [
            _buildHeader(context, topPad, sw),
            const SizedBox(
              height: 10,
            ),
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

  // ------------------Header---------------------------------------
  Widget _buildHeader(BuildContext context, double topPad, double sw) {
    return Consumer2<QuotationViewmodel, GlobalViewmodel>(
      builder: (context, q, g, _) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: topPad + 14,
            bottom: 28,
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
              /// 🔹 TOP ROW
              Row(
                children: [
                  const SizedBox(width: 12),

                  /// TITLE + COUNT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quotations',
                          style: TextStyle(
                            color: AppColors.cdark,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${q.filteredQuotationList.length} quotations available',
                          style: const TextStyle(
                            color: AppColors.ctext,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// 🔥 NEW BUTTON (same style)
                  GestureDetector(
                    onTap: () async {
                      await g.getAllLeads("QU");
                      if (!context.mounted) return;

                      pushNavigation(
                        context,
                        AddQuotation(
                          quotationNumber: g.orderNumber,
                          isEdit: false,
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

              const SizedBox(height: 16),

              /// 🔍 SEARCH BAR (same height as Product)
              Container(
                height: 40, // 👈 IMPORTANT (same as Product)
                decoration: BoxDecoration(
                  color: AppColors.cxl,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cborder),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        color: AppColors.ctext, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          q.searchQuotation(value);
                        },
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.cdark,
                        ),
                        textAlignVertical: TextAlignVertical.center,
                        decoration: const InputDecoration(
                          hintText: 'Search quotations...',
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

  // --------------------------- LIST ------------------------------
  Widget _buildList() {
    return Consumer<QuotationViewmodel>(
      builder: (context, provider, _) {
        if (provider.getQuotationLoader) {
          return const Center(
              child: CircularProgressIndicator(
            color: AppColors.c1,
            strokeWidth: 2.5,
          ));
        }

        if (provider.filteredQuotationList.isEmpty) {
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
                    Icons.receipt_long,
                    color: AppColors.c1,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "No Quotations Yet",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cdark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tap "New Quotation" to add your first Quotation',
                  style: TextStyle(fontSize: 13, color: AppColors.ctext),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          itemCount: provider.filteredQuotationList.length,
          itemBuilder: (context, index) {
            return _StaggeredItem(
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
                child: SingleQuotationCard(index: index),
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Staggered entrance ───────────────────────────────────────────────────────
class _StaggeredItem extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _StaggeredItem({required this.child, required this.delay});

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
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      );
}
