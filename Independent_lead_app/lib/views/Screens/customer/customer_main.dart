import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
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
  int? _selectedId;
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<CustomerViewmodel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.customerList.isEmpty && !provider.getCustomerLoader) {
        provider.getAllCustomers();
      }
      if (provider.selectedCustomerId != 0) {
        provider.getCustomerById(provider.selectedCustomerId);
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Filtering ─────────────────────────────────────────────────────────────
  List<CustomerModel> _filter(List<CustomerModel> list) {
    if (_searchTerm.isEmpty) return list;

    final q = _searchTerm.toLowerCase();

    return list.where((user) {
      final name = (user.firstName ?? '').toLowerCase();
      final company = (user.companyName ?? '').toLowerCase();
      final phone = (user.phoneNumber ?? '').toLowerCase();

      return name.contains(q) || company.contains(q) || phone.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
            // gradient: LinearGradient(
            //   colors: [_C.cyan1, _C.cyan, _C.cyan2, _C.cyan3],
            //   stops: [0.0, 0.35, 0.65, 1.0],
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            // ),
            ),
        child: Column(
          children: [
            Consumer<CustomerViewmodel>(
              builder: (context, provider, _) {
                return _buildHeader(
                  context,
                  topPad, // ✅ correct order
                  sw,
                  provider.customerList.length, // ✅ pass count
                );
              },
            ),
            // _buildSearchCard(context, sw),
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

  Widget _buildHeader(
    BuildContext context,
    double topPad,
    double sw,
    int count,
  ) {
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
          Row(children: [
            const SizedBox(width: 12),
            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Client',
                      style: TextStyle(
                        color: AppColors.cdark,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      )),
                  const SizedBox(height: 2),
                  Text('$count lead${count != 1 ? 's' : ''} available',
                      style: const TextStyle(
                          color: AppColors.ctext, fontSize: 12)),
                ],
              ),
            ),

            // ── NEW button (replaces filter) ─────────────────────────
            GestureDetector(
              onTap: () => pushNavigation(
                context,
                const CreateNewCustomer(isEdit: false),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: AppColors.white, size: 15),
                    SizedBox(width: 4),
                    Text('New',
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ]),

          const SizedBox(height: 16),

          // Search bar
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.cxl,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cborder),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(children: [
              const SizedBox(width: 14),
              const Icon(Icons.search_rounded,
                  color: AppColors.ctext, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchTerm = v),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.cdark,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: const InputDecoration(
                    hintText: 'Search by name...',
                    hintStyle: TextStyle(color: AppColors.ctext, fontSize: 13),
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              if (_searchTerm.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchCtrl.clear();
                    setState(() => _searchTerm = '');
                  },
                  child: const Icon(Icons.close_rounded,
                      size: 16, color: AppColors.ctext),
                ),
            ]),
          ),
        ],
      ),
    );
  }

  // ── List ──────────────────────────────────────────────────────────────────
  Widget _buildList(BuildContext context) {
    return Consumer<CustomerViewmodel>(
      builder: (context, provider, child) {
        if (provider.getCustomerLoader || provider.singleCustomerLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.c1,
              strokeWidth: 2.5,
            ),
          );
        }

        // Single customer view
        if (provider.selectedCustomerId != 0 &&
            provider.singleCustomer != null) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildListHeader(1),
              _StaggeredItem(
                delay: const Duration(milliseconds: 60),
                child: _CustomerCardWrapper(
                  child: SingleCustomerCard(
                    index: provider.customerList.indexWhere(
                      (c) =>
                          c.customerId == provider.singleCustomer!.customerId,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        // Empty state
        if (provider.customerList.isEmpty) {
          return _buildEmptyState();
        }
        final filteredList = _filter(provider.customerList);
        // Full list
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          // itemCount: provider.customerList.length + 1,

          itemCount: filteredList.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildListHeader(provider.customerList.length);
            }
            // final i = index - 1;
            // return _StaggeredItem(
            //   delay: Duration(milliseconds: 40 + i * 50),
            //   child: _CustomerCardWrapper(
            //     child: SingleCustomerCard(index: i),
            //   ),
            // );
            final i = index - 1;
            final customer = filteredList[i];

            return _StaggeredItem(
              delay: Duration(milliseconds: 40 + i * 50),
              child: _CustomerCardWrapper(
                child: SingleCustomerCard(
                  index: provider.customerList
                      .indexOf(customer), // 🔥 map to original index
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListHeader(int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        children: [
          const Text(
            'ALL CLIENTS',
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              color: AppColors.ctext,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.cl,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cborder),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.cdark,
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
              color: AppColors.cxl,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cborder),
            ),
            child: const Icon(
              Icons.people_alt_outlined,
              color: AppColors.c1,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Clients Yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.cdark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap "New Client" to add your first client',
            style: TextStyle(fontSize: 13, color: AppColors.ctext),
          ),
        ],
      ),
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
      child: child,
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
