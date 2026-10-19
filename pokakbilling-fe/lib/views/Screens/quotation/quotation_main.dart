import 'package:flutter/material.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:pokakbilling/core/navigations.dart';
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

  String _query = '';
  final TextEditingController _searchCtrl = TextEditingController();
  bool _opening = false; // spinner on "New" while the number is generated

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
    _searchCtrl.dispose();
    super.dispose();
  }

  // Same flow as before: fetch the next QU number, then open Add Quotation.
  Future<void> _openNewQuotation(GlobalViewmodel g) async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      await g.getAllLeads('QU');
      if (!mounted) return;
      pushNavigation(
        context,
        AddQuotation(quotationNumber: g.orderNumber),
      );
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: ErpColors.pageBg,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            _buildHeader(context, topPad, sw),
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

  // ── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, double topPad, double sw) {
    return Consumer2<QuotationViewmodel, GlobalViewmodel>(
      builder: (context, q, g, _) {
        final filtered = q.quotationList
            .where((item) => item.quotationNumber
                .toLowerCase()
                .contains(_query.trim().toLowerCase()))
            .toList();

        return Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: ErpColors.headerGradient,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: ErpColors.cyan.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -34,
                top: -44,
                child: _bubble(150, 0.10),
              ),
              Positioned(
                left: -26,
                bottom: -34,
                child: _bubble(90, 0.08),
              ),
              Positioned(
                right: 104,
                top: topPad + 2,
                child: Transform.rotate(
                  angle: -0.25,
                  child: Icon(Icons.request_quote_rounded,
                      size: 86, color: Colors.white.withValues(alpha: 0.12)),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: topPad + 14,
                  bottom: 20,
                  left: sw * 0.045,
                  right: sw * 0.045,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Quotations',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${filtered.length} quotation${filtered.length == 1 ? '' : 's'} available',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── NEW button ──────────────────────────────────
                        ErpPressable(
                          onTap: _opening ? null : () => _openNewQuotation(g),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: ErpColors.cyanDeep
                                      .withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _opening
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: ErpColors.cyanDeep),
                                      )
                                    : const Icon(Icons.add_rounded,
                                        color: ErpColors.cyanDeep, size: 18),
                                const SizedBox(width: 5),
                                const Text(
                                  'New',
                                  style: TextStyle(
                                    color: ErpColors.cyanDeep,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Mini stat ─────────────────────────────────────────
                    Row(children: [
                      _headerPill(Icons.description_rounded,
                          '${q.quotationList.length} total'),
                      if (_query.trim().isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _headerPill(Icons.filter_alt_rounded,
                            '${filtered.length} matching'),
                      ],
                    ]),
                    const SizedBox(height: 14),

                    // ── Search bar ────────────────────────────────────────
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: ErpColors.cyanDeep.withValues(alpha: 0.18),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: ErpColors.cyan.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.search_rounded,
                                color: ErpColors.cyanDeep, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              cursorColor: ErpColors.cyan,
                              onChanged: (value) {
                                setState(() => _query = value);
                              },
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ErpColors.ink,
                              ),
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                hintText: 'Search by quotation number…',
                                hintStyle: TextStyle(
                                  color:
                                      ErpColors.slate.withValues(alpha: 0.7),
                                  fontSize: 13.5,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_query.isNotEmpty)
                            ErpPressable(
                              onTap: () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color:
                                      ErpColors.slate.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close_rounded,
                                    size: 15, color: ErpColors.slate),
                              ),
                            ),
                          const SizedBox(width: 4),
                        ],
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

  static Widget _bubble(double s, double a) => Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: a),
          shape: BoxShape.circle,
        ),
      );

  Widget _headerPill(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(text,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
        ]),
      );

  // ── LIST ──────────────────────────────────────────────────────────────────
  Widget _buildList() {
    final sw = MediaQuery.of(context).size.width;

    return Consumer2<QuotationViewmodel, GlobalViewmodel>(
      builder: (context, provider, g, _) {
        if (provider.getQuotationLoader) {
          return const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: ErpColors.cyan,
                strokeWidth: 2.5,
              ),
            ),
          );
        }

        final filtered = provider.quotationList
            .where((item) => item.quotationNumber
                .toLowerCase()
                .contains(_query.trim().toLowerCase()))
            .toList();

        Future<void> refresh() async => provider.getAllQuotations();

        if (filtered.isEmpty) {
          final searching = _query.trim().isNotEmpty;
          return RefreshIndicator(
            color: ErpColors.cyan,
            onRefresh: refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              children: [
                const SizedBox(height: 60),
                ErpEmptyState(
                  icon: Icons.request_quote_rounded,
                  title: searching ? 'No matches found' : 'No Quotations Yet',
                  subtitle: searching
                      ? 'No quotation number matches "${_query.trim()}"'
                      : 'Tap "New" to add your first Quotation',
                  actionLabel: searching ? 'Clear search' : 'New Quotation',
                  actionIcon:
                      searching ? Icons.close_rounded : Icons.add_rounded,
                  onAction: searching
                      ? () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        }
                      : () => _openNewQuotation(g),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: ErpColors.cyan,
          onRefresh: refresh,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            padding: EdgeInsets.fromLTRB(sw * 0.04, 0, sw * 0.04, 24),
            itemCount: filtered.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return _listHeader(filtered.length);
              final i = index - 1;
              final originalIndex = provider.quotationList.indexWhere(
                (x) => x.quotationNumber == filtered[i].quotationNumber,
              );
              return ErpFadeIn(
                key: ValueKey('qt_${filtered[i].quotationNumber}'),
                index: i < 10 ? i : 10,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: ErpColors.line),
                    boxShadow: [
                      BoxShadow(
                        color: ErpColors.cyan.withValues(alpha: 0.10),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 4,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [
                            ErpColors.cyanDeep,
                            ErpColors.cyan,
                            ErpColors.cyanLight,
                          ]),
                        ),
                      ),
                      SingleQuotationCard(index: originalIndex),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _listHeader(int count) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 10, left: 2),
        child: Row(children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [ErpColors.cyanLight, ErpColors.cyanDeep],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'All Quotations',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: ErpColors.ink,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              gradient: ErpColors.headerGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ]),
      );
}