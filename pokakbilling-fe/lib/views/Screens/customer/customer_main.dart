import 'package:flutter/material.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:pokakbilling/models/data-models/customer_model.dart';
import 'package:pokakbilling/viewmodels/customer_viewmodel.dart';
import 'package:pokakbilling/views/Screens/customer/create_new_customer.dart';
import 'package:pokakbilling/views/Screens/customer/single_customer_card.dart';
import 'package:provider/provider.dart';

class CustomerMain extends StatefulWidget {
  const CustomerMain({super.key});

  @override
  State<CustomerMain> createState() => _CustomerMainState();
}

class _CustomerMainState extends State<CustomerMain>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  String _searchTerm = '';
  final TextEditingController _searchCtrl = TextEditingController();

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

    // Clear any previously selected single-customer filter every time this
    // screen opens, same behaviour as the previous version.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetCustomerFilter();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<CustomerViewmodel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.customerList.isEmpty && !provider.getCustomerLoader) {
        provider.getAllCustomers();
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _resetCustomerFilter() {
    final provider = Provider.of<CustomerViewmodel>(context, listen: false);
    provider.updateSelectedCustomerId(0);
    provider.selectCustomer("");
  }

  Future<void> _openNewCustomer() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateNewCustomer(isEdit: false),
      ),
    );
    if (mounted) _resetCustomerFilter();
  }

  // ── Filtering ─────────────────────────────────────────────────────────────
  List<CustomerModel> _filter(List<CustomerModel> list) {
    if (_searchTerm.isEmpty) return list;

    final q = _searchTerm.toLowerCase();

    return list.where((user) {
      final name = user.firstName.toLowerCase();
      final company = user.companyName.toLowerCase();
      final phone = user.phone.toLowerCase();

      return name.contains(q) || company.contains(q) || phone.contains(q);
    }).toList();
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
            Consumer<CustomerViewmodel>(
              builder: (context, provider, _) {
                return _buildHeader(
                  context,
                  topPad,
                  sw,
                  provider.customerList,
                );
              },
            ),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: _buildList(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    double topPad,
    double sw,
    List<CustomerModel> all,
  ) {
    final count = all.length;
    final leads = all.where((c) => c.moduleType == 'lead').length;
    final clients = count - leads;

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
              child: Icon(Icons.people_alt_rounded,
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
                Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Customers',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            )),
                        const SizedBox(height: 2),
                        Text(
                            '$count customer${count != 1 ? 's' : ''} available',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14)),
                      ],
                    ),
                  ),

                  // ── NEW button ──────────────────────────────────────
                  ErpPressable(
                    onTap: _openNewCustomer,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: ErpColors.cyanDeep.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_add_alt_1_rounded,
                              color: ErpColors.cyanDeep, size: 18),
                          SizedBox(width: 5),
                          Text('New',
                              style: TextStyle(
                                  color: ErpColors.cyanDeep,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 14),

                // ── Mini stats ────────────────────────────────────────
                Row(children: [
                  _headerStat('Total', count, Icons.groups_rounded),
                  const SizedBox(width: 8),
                  _headerStat('Clients', clients, Icons.verified_user_rounded),
                  const SizedBox(width: 8),
                  _headerStat('Leads', leads, Icons.trending_up_rounded),
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
                  child: Row(children: [
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
                        onChanged: (v) => setState(() => _searchTerm = v),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ErpColors.ink,
                        ),
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: 'Search name, company or phone…',
                          hintStyle: TextStyle(
                              color: ErpColors.slate.withValues(alpha: 0.7),
                              fontSize: 13.5),
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                    if (_searchTerm.isNotEmpty)
                      ErpPressable(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() => _searchTerm = '');
                        },
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: ErpColors.slate.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              size: 15, color: ErpColors.slate),
                        ),
                      ),
                    const SizedBox(width: 4),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
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

  Widget _headerStat(String label, int count, IconData icon) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
          ),
          child: Row(children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$count',
                      style: const TextStyle(
                          fontSize: 16,
                          height: 1.1,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.9))),
                ],
              ),
            ),
          ]),
        ),
      );

  // ── List ──────────────────────────────────────────────────────────────────
  Widget _buildList(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Consumer<CustomerViewmodel>(
      builder: (context, provider, child) {
        if (provider.getCustomerLoader || provider.singleCustomerLoading) {
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

        // Single customer view (filtered by selectedCustomerId)
        if (provider.selectedCustomerId != 0 &&
            provider.singleCustomerList.isNotEmpty) {
          final singleCustomer = provider.singleCustomerList.first;
          final origIndex = provider.customerList.indexWhere(
            (c) => c.customerId == singleCustomer.customerId,
          );

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(sw * 0.04, 0, sw * 0.04, 24),
            children: [
              _buildListHeader(1),
              if (origIndex != -1)
                ErpFadeIn(
                  child: _CustomerCardWrapper(
                    child: SingleCustomerCard(index: origIndex),
                  ),
                ),
            ],
          );
        }

        // Empty state
        if (provider.customerList.isEmpty) {
          return _buildEmptyState(
              'No Customers Yet', 'Tap "New" to add your first customer');
        }

        final filteredList = _filter(provider.customerList);

        if (filteredList.isEmpty) {
          return _buildEmptyState(
              'No matches found', 'Try a different name, company or phone');
        }

        // Full list
        return RefreshIndicator(
          color: ErpColors.cyan,
          onRefresh: () async => provider.getAllCustomers(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            padding: EdgeInsets.fromLTRB(sw * 0.04, 0, sw * 0.04, 24),
            itemCount: filteredList.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildListHeader(filteredList.length);
              }
              final i = index - 1;
              final customer = filteredList[i];

              return ErpFadeIn(
                key: ValueKey('cust_${customer.customerId}'),
                index: i < 10 ? i : 10,
                child: _CustomerCardWrapper(
                  child: SingleCustomerCard(
                    index: provider.customerList.indexOf(customer),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildListHeader(int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10, left: 2),
      child: Row(
        children: [
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
            'All Customers',
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
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        const SizedBox(height: 60),
        ErpEmptyState(
          icon: Icons.people_alt_rounded,
          title: title,
          subtitle: subtitle,
          actionLabel: 'Add Customer',
          actionIcon: Icons.person_add_alt_1_rounded,
          onAction: _openNewCustomer,
        ),
      ],
    );
  }
}

// ─── Card wrapper ─────────────────────────────────────────────────────────────
class _CustomerCardWrapper extends StatelessWidget {
  final Widget child;
  const _CustomerCardWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: child,
    );
  }
}