import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/viewmodels/customer_viewmodel.dart';
import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
import 'package:pokakbilling/viewmodels/privacy_policy/privacy_policy_viewmodel.dart';
import 'package:pokakbilling/views/Screens/quotation/add/add_single_product.dart';
import 'package:pokakbilling/views/Screens/quotation/add/contract_page.dart';
import 'package:provider/provider.dart';

class AddQuotation extends StatefulWidget {
  final String quotationNumber;
  const AddQuotation({super.key, required this.quotationNumber});

  @override
  State<AddQuotation> createState() => _AddQuotationState();
}

class _AddQuotationState extends State<AddQuotation>
    with SingleTickerProviderStateMixin {
  // ── Controllers ───────────────────────────────────────────────────────────
  late TextEditingController quotationNumberCtrl;
  late TextEditingController quotationDateCtrl;
  late TextEditingController customerNameCtrl;
  late TextEditingController termsCtrl;
  late TextEditingController deliveryAddressCtrl;
  late TextEditingController deliveryLocationCtrl;
  late TextEditingController projectNameCtrl;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int? _selectedTermsId;

  // ── Field errors ──────────────────────────────────────────────────────────
  String? _errClient;
  String? _errSalesPerson;
  String? _errTerms;
  String? _errProducts;
  String? _errDate;

  // ── Animation ─────────────────────────────────────────────────────────────
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();

    quotationNumberCtrl = TextEditingController(text: widget.quotationNumber);
    quotationDateCtrl = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    customerNameCtrl = TextEditingController();
    termsCtrl = TextEditingController();
    deliveryAddressCtrl = TextEditingController();
    deliveryLocationCtrl = TextEditingController();
    projectNameCtrl = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuotationViewmodel>(context, listen: false).removeAll();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    quotationNumberCtrl.dispose();
    quotationDateCtrl.dispose();
    customerNameCtrl.dispose();
    termsCtrl.dispose();
    deliveryAddressCtrl.dispose();
    deliveryLocationCtrl.dispose();
    projectNameCtrl.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────
  bool _validateAll(QuotationViewmodel provider) {
    final dateErr = quotationDateCtrl.text.trim().isEmpty
        ? 'Quotation date is required'
        : null;
    final clientErr = customerNameCtrl.text.trim().isEmpty
        ? 'Please select a client to continue'
        : null;
    final productsErr =
        provider.itemList.isEmpty ? 'Please add at least one product' : null;
    final salesErr = provider.selectedSalesPersonName.trim().isEmpty
        ? 'Sales person is required'
        : null;
    final termsErr = (_selectedTermsId == null || termsCtrl.text.trim().isEmpty)
        ? 'Please select terms & conditions'
        : null;

    setState(() {
      _errDate = dateErr;
      _errClient = clientErr;
      _errProducts = productsErr;
      _errSalesPerson = salesErr;
      _errTerms = termsErr;
    });

    if (dateErr != null ||
        clientErr != null ||
        productsErr != null ||
        salesErr != null ||
        termsErr != null) {
      return false;
    }
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      return false;
    }
    return true;
  }

  // ── Section card ──────────────────────────────────────────────────────────
  Widget _buildSection({
    required int index,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return ErpFadeIn(
      index: index,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: ErpColors.line),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.09),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Accent strip
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [ErpColors.tint(color, 0.35), color],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    ErpGradientTile(icon: icon, color: color, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                              color: ErpColors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: ErpColors.slate,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (trailing != null) trailing,
                  ]),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(
                        height: 1, thickness: 1, color: ErpColors.line),
                  ),
                  ...children,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Text field ────────────────────────────────────────────────────────────
  Widget _field(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    Color color = ErpColors.cyan,
    bool isRequired = false,
    bool isEnabled = true,
    bool readOnly = false,
    String? error,
    Widget? suffix,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function()? onTap,
  }) {
    final hasError = error != null && error.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ErpFieldLabel(label, isRequired: isRequired),
          TextFormField(
            controller: controller,
            enabled: isEnabled,
            readOnly: readOnly,
            maxLines: maxLines,
            onChanged: onChanged,
            onTap: onTap,
            validator: validator,
            cursorColor: color,
            style: TextStyle(
              fontSize: 14,
              color: isEnabled ? ErpColors.ink : ErpColors.slate,
              fontWeight: FontWeight.w700,
            ),
            decoration: erpInputDecoration(
              hint: hint,
              icon: icon,
              hasError: hasError,
              color: color,
            ).copyWith(
              // Show validator messages (kit hides them by default).
              errorStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ErpColors.red,
              ),
              suffixIcon: suffix != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: suffix,
                    )
                  : null,
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 32, minHeight: 32),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: ErpColors.line),
              ),
            ),
          ),
          if (hasError) ErpErrorText(error),
        ],
      ),
    );
  }

  // ── Round arrow for dropdowns / pickers ──────────────────────────────────
  Widget _roundArrow(Color color, {bool hasError = false}) {
    final c = hasError ? ErpColors.red : color;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.keyboard_arrow_down_rounded,
          size: 20, color: ErpColors.shade(c, 0.1)),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ErpColors.pageBg,
      resizeToAvoidBottomInset: true,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            _buildHeader(context, sw, topPad),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding:
                          EdgeInsets.fromLTRB(sw * 0.04, 18, sw * 0.04, 32),
                      child: Consumer<QuotationViewmodel>(
                        builder: (context, qVm, _) => Column(
                          children: [
                            // ── Section 1: Quotation Info ────────────
                            _buildSection(
                              index: 0,
                              icon: Icons.receipt_long_rounded,
                              color: ErpColors.cyan,
                              title: 'Quotation Info',
                              subtitle: 'Number, date and client',
                              children: _quotationInfoFields(qVm),
                            ),

                            // ── Section 2: Products ──────────────────
                            _buildSection(
                              index: 1,
                              icon: Icons.inventory_2_rounded,
                              color: ErpColors.blue,
                              title: 'Products',
                              subtitle: qVm.itemList.isEmpty
                                  ? 'Add the items to quote'
                                  : '${qVm.itemList.length} item${qVm.itemList.length == 1 ? '' : 's'} added',
                              trailing: _addProductPill(qVm),
                              children: [_productSection(qVm)],
                            ),

                            // ── Section 3: Grand Total ───────────────
                            _buildSection(
                              index: 2,
                              icon: Icons.calculate_rounded,
                              color: ErpColors.green,
                              title: 'Total',
                              subtitle: 'Calculated from products',
                              children: [_totalSection(qVm)],
                            ),

                            // ── Section 4: Sales & Terms ─────────────
                            _buildSection(
                              index: 3,
                              icon: Icons.handshake_rounded,
                              color: ErpColors.violet,
                              title: 'Sales & Terms',
                              subtitle: 'Salesperson, terms and project',
                              children: _salesTermsFields(qVm),
                            ),

                            // ── Section 5: Delivery ──────────────────
                            _buildSection(
                              index: 4,
                              icon: Icons.local_shipping_rounded,
                              color: ErpColors.orange,
                              title: 'Delivery Details',
                              subtitle: 'Where the order should go',
                              children: _deliveryFields(),
                            ),

                            // ── Action Buttons ───────────────────────
                            ErpFadeIn(
                              index: 5,
                              child: _buildActionButtons(qVm),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, double sw, double topPad) {
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
            right: -30,
            top: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -24,
            bottom: -30,
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 14,
            bottom: -12,
            child: Transform.rotate(
              angle: -0.25,
              child: Icon(Icons.request_quote_rounded,
                  size: 96, color: Colors.white.withValues(alpha: 0.12)),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: topPad + 12,
              bottom: 24,
              left: sw * 0.045,
              right: sw * 0.045,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ErpPressable(
                      onTap: () => Navigator.pop(context),
                      child: const ErpGlassCircle(
                          icon: Icons.arrow_back_ios_new_rounded,
                          iconSize: 19),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'New Quotation',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Fill in all required fields',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _headerPill(Icons.tag_rounded, quotationNumberCtrl.text),
                  _headerPill(Icons.looks_one_rounded, 'Step 1 of 2'),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: Colors.white),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ]),
    );
  }

  // ── Quotation Info fields ─────────────────────────────────────────────────
  List<Widget> _quotationInfoFields(QuotationViewmodel qVm) {
    return [
      // Quotation number + date row
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: _field(
              quotationNumberCtrl,
              'Quotation No',
              'Quotation No',
              Icons.tag_rounded,
              isEnabled: false,
              suffix: const Tooltip(
                message: 'Auto-generated',
                child: Icon(Icons.info_outline_rounded,
                    size: 16, color: ErpColors.cyanDeep),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: _field(
              quotationDateCtrl,
              'Date',
              'Date',
              Icons.calendar_today_rounded,
              isRequired: true,
              readOnly: true,
              error: _errDate,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  builder: (ctx, child) => erpPickerTheme(ctx, child),
                );
                if (picked != null) {
                  quotationDateCtrl.text =
                      DateFormat('yyyy-MM-dd').format(picked);
                  setState(() => _errDate = null);
                }
              },
            ),
          ),
        ],
      ),

      // Client dropdown
      Consumer<CustomerViewmodel>(
        builder: (context, provider, _) {
          final hasError = _errClient != null && _errClient!.isNotEmpty;
          final items = provider.customerList
              .map((c) => '${c.firstName} ${c.lastName}')
              .toSet()
              .toList();
          final sel = items.contains(customerNameCtrl.text)
              ? customerNameCtrl.text
              : null;

          if (provider.getCustomerLoader && provider.customerList.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ErpFieldLabel('Client', isRequired: true),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      minHeight: 5,
                      color: ErpColors.cyan,
                      backgroundColor: ErpColors.cyan.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ErpFieldLabel('Client', isRequired: true),
              DropdownButtonFormField<String>(
                initialValue: sel,
                isExpanded: true,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(16),
                icon: _roundArrow(ErpColors.cyan, hasError: hasError),
                style: const TextStyle(
                  fontSize: 14,
                  color: ErpColors.ink,
                  fontWeight: FontWeight.w700,
                ),
                hint: Text(
                  'Select client',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: hasError
                        ? ErpColors.red.withValues(alpha: 0.7)
                        : ErpColors.slate.withValues(alpha: 0.7),
                  ),
                ),
                items: items
                    .map((e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(e,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: ErpColors.ink,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                        ))
                    .toList(),
                onChanged: (v) async {
                  if (v == null) return;
                  if (_errClient != null) {
                    setState(() => _errClient = null);
                  }
                  final c = provider.customerList
                      .firstWhere((c) => '${c.firstName} ${c.lastName}' == v);
                  await provider.getCustomerById(c.customerId);
                  final cust = provider.singleCustomerList.isNotEmpty
                      ? provider.singleCustomerList[0]
                      : null;
                  if (cust != null) {
                    qVm.updateSalesPersonId(cust.salesPersonId);
                    qVm.updateSalesPersonName(cust.salesPersonName);
                  }
                  qVm.updateClientId(c.customerId);
                  provider.selectCustomer(v);
                  customerNameCtrl.text = v;
                  setState(() => _errSalesPerson = null);
                },
                decoration: erpInputDecoration(
                  hint: '',
                  icon: Icons.person_rounded,
                  hasError: hasError,
                ),
              ),
              if (hasError) ErpErrorText(_errClient!),
            ],
          );
        },
      ),
    ];
  }

  // ── Add Product pill (section header) ────────────────────────────────────
  Widget _addProductPill(QuotationViewmodel qVm) {
    return ErpPressable(
      onTap: () {
        qVm.addItem();
        setState(() => _errProducts = null);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [ErpColors.tint(ErpColors.blue, 0.2), ErpColors.blue],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ErpColors.blue.withValues(alpha: 0.32),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 16),
            SizedBox(width: 4),
            Text(
              'Add Product',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Products section ──────────────────────────────────────────────────────
  Widget _productSection(QuotationViewmodel qVm) {
    final hasError = _errProducts != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (qVm.itemList.isEmpty)
          ErpPressable(
            onTap: () {
              qVm.addItem();
              setState(() => _errProducts = null);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
              decoration: BoxDecoration(
                color: hasError
                    ? ErpColors.red.withValues(alpha: 0.04)
                    : ErpColors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasError
                      ? ErpColors.red.withValues(alpha: 0.5)
                      : ErpColors.blue.withValues(alpha: 0.25),
                  width: 1.3,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (hasError ? ErpColors.red : ErpColors.blue)
                          .withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add_shopping_cart_rounded,
                        size: 22,
                        color: hasError ? ErpColors.red : ErpColors.blue),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No products yet',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: ErpColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Tap here or "Add Product" to start',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: ErpColors.slate,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (hasError) ErpErrorText(_errProducts!),
        if (qVm.itemList.isNotEmpty)
          Column(
            children: qVm.itemList
                .map((item) => QuotationItem(itemNumber: item.itemNumber))
                .toList(),
          ),
      ],
    );
  }

  // ── Grand Total section ───────────────────────────────────────────────────
  Widget _totalSection(QuotationViewmodel qVm) {
    return Consumer<QuotationViewmodel>(
      builder: (_, p, __) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [ErpColors.tint(ErpColors.green, 0.15), ErpColors.green],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: ErpColors.green.withValues(alpha: 0.32),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(13),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.40)),
              ),
              child: const Icon(Icons.currency_rupee_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Grand Total',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withValues(alpha: 0.92),
                ),
              ),
            ),
            Text(
              '₹ ${p.grandTotal}',
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sales & Terms fields ──────────────────────────────────────────────────
  List<Widget> _salesTermsFields(QuotationViewmodel qVm) {
    return [
      // Sales Person (read-only, auto-filled)
      Consumer<QuotationViewmodel>(
        builder: (_, p, __) {
          final empty = p.selectedSalesPersonName.trim().isEmpty;
          final hasError =
              _errSalesPerson != null && _errSalesPerson!.isNotEmpty;
          final accent = hasError ? ErpColors.red : ErpColors.violet;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ErpFieldLabel('Sales Person', isRequired: true),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: hasError
                        ? ErpColors.red.withValues(alpha: 0.04)
                        : ErpColors.pageBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: hasError
                          ? ErpColors.red.withValues(alpha: 0.6)
                          : ErpColors.line,
                    ),
                  ),
                  child: Row(children: [
                    empty
                        ? Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.person_pin_rounded,
                                size: 17,
                                color: ErpColors.shade(accent, 0.12)),
                          )
                        : Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  ErpColors.tint(ErpColors.violet, 0.2),
                                  ErpColors.violet
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                p.selectedSalesPersonName.trim()[0]
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        empty
                            ? 'Auto-filled on client selection'
                            : p.selectedSalesPersonName,
                        style: TextStyle(
                          fontSize: empty ? 13.5 : 14,
                          fontWeight:
                              empty ? FontWeight.w500 : FontWeight.w800,
                          color: empty
                              ? ErpColors.slate.withValues(alpha: 0.8)
                              : ErpColors.ink,
                        ),
                      ),
                    ),
                    if (!empty)
                      const ErpStatusChip(
                          label: 'Auto', color: ErpColors.violet),
                  ]),
                ),
                if (hasError) ErpErrorText(_errSalesPerson!),
              ],
            ),
          );
        },
      ),

      // Terms & Conditions (bottom sheet picker)
      _termsSelector(),

      // Project Name
      _field(
        projectNameCtrl,
        'Project Name',
        'Enter project name',
        Icons.folder_rounded,
        color: ErpColors.violet,
        isRequired: true,
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Project name is required' : null,
        onChanged: (_) => setState(() {}),
      ),
    ];
  }

  // ── Terms selector ────────────────────────────────────────────────────────
  Widget _termsSelector() {
    final hasError = _errTerms != null && _errTerms!.isNotEmpty;
    final selected = termsCtrl.text.isNotEmpty;
    final accent = hasError ? ErpColors.red : ErpColors.violet;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ErpFieldLabel('Terms & Conditions', isRequired: true),
          ErpPressable(
            onTap: () async {
              final picked = await _showTermsSheet(context);
              if (picked != null) {
                setState(() {
                  _selectedTermsId = picked.$1;
                  termsCtrl.text = picked.$2;
                  _errTerms = null;
                });
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: hasError
                    ? ErpColors.red.withValues(alpha: 0.04)
                    : (selected
                        ? ErpColors.violet.withValues(alpha: 0.06)
                        : ErpColors.pageBg),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasError
                      ? ErpColors.red.withValues(alpha: 0.6)
                      : (selected
                          ? ErpColors.violet.withValues(alpha: 0.55)
                          : ErpColors.line),
                  width: (hasError || selected) ? 1.4 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  selected && !hasError
                      ? const ErpGradientTile(
                          icon: Icons.article_rounded,
                          color: ErpColors.violet,
                          size: 32)
                      : Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.article_rounded,
                              size: 16, color: ErpColors.shade(accent, 0.12)),
                        ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      selected ? termsCtrl.text : 'Select terms & conditions',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w500,
                        color: hasError
                            ? ErpColors.red.withValues(alpha: 0.8)
                            : (selected
                                ? ErpColors.ink
                                : ErpColors.slate.withValues(alpha: 0.8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _roundArrow(ErpColors.violet, hasError: hasError),
                ],
              ),
            ),
          ),
          if (hasError) ErpErrorText(_errTerms!),
        ],
      ),
    );
  }

  // ── Delivery fields ───────────────────────────────────────────────────────
  List<Widget> _deliveryFields() {
    return [
      _field(
        deliveryAddressCtrl,
        'Delivery Address',
        'Enter delivery address',
        Icons.home_rounded,
        color: ErpColors.orange,
        isRequired: true,
        validator: (v) => (v == null || v.trim().isEmpty)
            ? 'Delivery address is required'
            : null,
        onChanged: (_) => setState(() {}),
      ),
      _field(
        deliveryLocationCtrl,
        'Delivery Location',
        'Enter delivery location',
        Icons.place_rounded,
        color: ErpColors.orange,
        isRequired: true,
        validator: (v) => (v == null || v.trim().isEmpty)
            ? 'Delivery location is required'
            : null,
        onChanged: (_) => setState(() {}),
      ),
    ];
  }

  // ── Action Buttons ────────────────────────────────────────────────────────
  Widget _buildActionButtons(QuotationViewmodel provider) {
    return Column(
      children: [
        const SizedBox(height: 6),
        ErpPrimaryButton(
          text: 'Next: Contract',
          icon: Icons.arrow_forward_rounded,
          onTap: () {
            provider.editablePointsMap.clear();
            provider.editableSectionsMap.clear();
            if (_validateAll(provider)) {
              pushNavigation(
                context,
                ContractPage(
                  quotationNumber: quotationNumberCtrl.text,
                  quotationDate: quotationDateCtrl.text,
                  clientId: provider.selectedClientId,
                  termsId: _selectedTermsId ?? 0,
                  deliveryAddress: deliveryAddressCtrl.text,
                  deliveryLocation: deliveryLocationCtrl.text,
                  projectName: projectNameCtrl.text,
                ),
              );
            } else {
              erpToast(
                context,
                'Please fill the highlighted fields',
                color: ErpColors.red,
                icon: Icons.error_outline_rounded,
              );
            }
          },
        ),
        const SizedBox(height: 12),
        ErpSecondaryButton(
          text: 'Cancel',
          onTap: () => Navigator.pop(context),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
      ],
    );
  }

  // ── Terms Bottom Sheet ────────────────────────────────────────────────────
  Future<(int, String)?> _showTermsSheet(BuildContext context) {
    return showModalBottomSheet<(int, String)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => ChangeNotifierProvider(
        create: (_) => PrivacyPolicyViewmodel()..fetchTerms(),
        child: const _TermsSheet(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TERMS BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════
class _TermsSheet extends StatefulWidget {
  const _TermsSheet();

  @override
  State<_TermsSheet> createState() => _TermsSheetState();
}

class _TermsSheetState extends State<_TermsSheet> {
  String _query = '';
  int? _selected;

  static const Color _accent = ErpColors.violet;

  String _fmt(DateTime dt) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dt.day.toString().padLeft(2, '0')}-${m[dt.month - 1]}-${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 18,
              right: 18,
              top: 12,
            ),
            child: Consumer<PrivacyPolicyViewmodel>(
              builder: (_, vm, __) {
                if (vm.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: _accent, strokeWidth: 2.5),
                    ),
                  );
                }
                if (vm.errorMessage != null) {
                  return Padding(
                    padding: const EdgeInsets.all(30),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: ErpColors.red.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.cloud_off_rounded,
                                color: ErpColors.red, size: 26),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Error: ${vm.errorMessage}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: ErpColors.slate,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final list = vm.terms
                    .where((t) =>
                        _query.trim().isEmpty ||
                        (t.title ?? '')
                            .toLowerCase()
                            .contains(_query.toLowerCase()))
                    .toList();

                return Column(mainAxisSize: MainAxisSize.min, children: [
                  // Drag handle
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: ErpColors.line,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(children: [
                    const ErpGradientTile(
                        icon: Icons.article_rounded, color: _accent, size: 42),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: ErpColors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${vm.terms.length} template${vm.terms.length == 1 ? '' : 's'} available',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: ErpColors.slate,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),

                  // Search field
                  TextField(
                    cursorColor: _accent,
                    style: const TextStyle(
                        color: ErpColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                    decoration: erpInputDecoration(
                      hint: 'Search terms…',
                      icon: Icons.search_rounded,
                      color: _accent,
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  const SizedBox(height: 12),

                  // Terms list
                  Flexible(
                    child: list.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 28),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off_rounded,
                                    size: 30,
                                    color: _accent.withValues(alpha: 0.5)),
                                const SizedBox(height: 8),
                                const Text(
                                  'No matching results',
                                  style: TextStyle(
                                    color: ErpColors.slate,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: list.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final item = list[i];
                              final isSel = _selected == item.id;
                              return ErpPressable(
                                onTap: () =>
                                    setState(() => _selected = item.id),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 11),
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? _accent.withValues(alpha: 0.08)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSel
                                          ? _accent.withValues(alpha: 0.6)
                                          : ErpColors.line,
                                      width: isSel ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(children: [
                                    isSel
                                        ? const ErpGradientTile(
                                            icon: Icons.check_rounded,
                                            color: _accent,
                                            size: 34)
                                        : Container(
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              color: _accent.withValues(
                                                  alpha: 0.10),
                                              borderRadius:
                                                  BorderRadius.circular(11),
                                            ),
                                            child: Icon(Icons.article_rounded,
                                                size: 17,
                                                color: ErpColors.shade(
                                                    _accent, 0.1)),
                                          ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title ?? '',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: isSel
                                                  ? FontWeight.w900
                                                  : FontWeight.w700,
                                              color: ErpColors.ink,
                                            ),
                                          ),
                                          if (item.createdAt != null) ...[
                                            const SizedBox(height: 3),
                                            Row(children: [
                                              const Icon(
                                                  Icons.schedule_rounded,
                                                  size: 12,
                                                  color: ErpColors.slate),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Created: ${_fmt(item.createdAt!)}',
                                                style: const TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: ErpColors.slate,
                                                ),
                                              ),
                                            ]),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (isSel)
                                      const Icon(Icons.check_circle_rounded,
                                          color: _accent, size: 22),
                                  ]),
                                ),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 14),

                  // Buttons
                  Row(children: [
                    Expanded(
                      child: ErpSecondaryButton(
                        text: 'Cancel',
                        onTap: () => Navigator.pop(context, null),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _selected == null ? 0.5 : 1,
                      child: ErpPrimaryButton(
                        text: 'Use This',
                        icon: Icons.check_rounded,
                        color: _accent,
                        onTap: _selected == null
                            ? null
                            : () {
                                final chosen = vm.terms.firstWhere(
                                  (t) => t.id == _selected,
                                  orElse: () => vm.terms.first,
                                );
                                Navigator.pop<(int, String)>(
                                  context,
                                  (chosen.id, chosen.title ?? ''),
                                );
                              },
                      ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                ]);
              },
            ),
          ),
        ),
      ),
    );
  }
}