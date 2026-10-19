import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/viewmodels/client_contract_viewmodel.dart';
import 'package:pokakbilling/viewmodels/customer_viewmodel.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/terms&condition_viewmodel.dart';
import 'package:pokakbilling/views/Screens/quotation/add/add_single_product.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:provider/provider.dart';

class AddQuotation extends StatefulWidget {
  final bool isEdit;
  final String quotationNumber;
  final int? quotationId;

  const AddQuotation({
    super.key,
    required this.quotationNumber,
    required this.isEdit,
    this.quotationId,
  });

  @override
  State<AddQuotation> createState() => _AddQuotationState();
}

class _AddQuotationState extends State<AddQuotation>
    with SingleTickerProviderStateMixin {
  // ── Animation ─────────────────────────────────────────────────────────────
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // ── Controllers ───────────────────────────────────────────────────────────
  late TextEditingController quotationNumberTextcontroller;
  late TextEditingController quotationDateTextController;
  late TextEditingController leadTextController;
  late TextEditingController customerNameTextController;
  late TextEditingController companyLocationController;
  late TextEditingController companyAddressController;
  late TextEditingController projectNameController;
  late TextEditingController quantityTextController;
  late TextEditingController unitPriceTextController;
  late TextEditingController termsTextController;
  late TextEditingController contractDetailsTextController;

  // ── FIX: track selected dropdown values by unique id, not by display text ──
  // Using the display string as a DropdownButtonFormField's `value` breaks the
  // moment two leads/customers share the same name — Flutter throws:
  // "There should be exactly one item with [DropdownButton]'s value".
  // Tracking the id instead guarantees uniqueness.
  int? _selectedLeadId;
  int? _selectedClientId;

  // ── Manual field errors (only set on button click) ────────────────────────
  String? _errClient;
  String? _errProjectName;
  String? _errLocation;
  String? _errAddress;
  String? _errTerms;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();

    quotationNumberTextcontroller =
        TextEditingController(text: widget.quotationNumber);
    quotationDateTextController = TextEditingController();
    leadTextController = TextEditingController();
    customerNameTextController = TextEditingController();
    companyLocationController = TextEditingController();
    companyAddressController = TextEditingController();
    projectNameController = TextEditingController();
    quantityTextController = TextEditingController();
    unitPriceTextController = TextEditingController();
    termsTextController = TextEditingController();
    contractDetailsTextController = TextEditingController();

    quotationDateTextController.text =
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final termsVM = Provider.of<TermsViewModel>(context, listen: false);
      final quotationVM =
          Provider.of<QuotationViewmodel>(context, listen: false);
      final contractVM = Provider.of<ContractViewmodel>(context, listen: false);
      final customerVM = Provider.of<CustomerViewmodel>(context, listen: false);
      final leadVM = Provider.of<LeadViewmodel>(context, listen: false);

      await Future.wait([
        customerVM.getAllCustomers(),
        leadVM.getAllLeads(),
      ]);
      if (!mounted) return;

      if (widget.isEdit && widget.quotationId != null) {
        await quotationVM.getQuotationById(widget.quotationId!);
        if (!mounted) return;
        final q = quotationVM.singleQuotation;
        if (q != null) {
          quotationNumberTextcontroller.text = q.quotationNumber;
          quotationDateTextController.text = q.date;
          projectNameController.text = q.projectName ?? '';
          companyLocationController.text = q.companyLocation ?? '';
          companyAddressController.text = q.companyAddress ?? '';
          if (q.lead != null) {
            quotationVM.updateLeadId(q.lead!);
            _selectedLeadId = q.lead; // FIX: seed dropdown value by id
            final matchedLead =
                leadVM.leadList.where((l) => l.id == q.lead).toList();
            if (matchedLead.isNotEmpty) {
              leadTextController.text = matchedLead.first.company;
            } else if (q.leadName != null && q.leadName!.isNotEmpty) {
              leadTextController.text = q.leadName!;
            }
          }
          if (q.client != null) {
            quotationVM.updateClientId(q.client!);
            _selectedClientId = q.client; // FIX: seed dropdown value by id
            final matchedCustomer = customerVM.customerList
                .where((c) => c.customerId == q.client)
                .toList();
            if (matchedCustomer.isNotEmpty) {
              customerNameTextController.text =
                  '${matchedCustomer.first.firstName} ${matchedCustomer.first.lastName}';
            } else {
              customerNameTextController.text =
                  (q.clientNameDisplay?.isNotEmpty == true)
                      ? q.clientNameDisplay!
                      : q.clientName ?? '';
            }
          }

          await termsVM.loadTermsForQuotation(q.termsTemplateId);

          if (q.contractId != null && q.contractId! > 0) {
            await contractVM.getContractById(q.contractId!);
            if (!mounted) return;
            final c = contractVM.currentContract;
            if (c != null) {
              contractDetailsTextController.text = c.name;
              quotationVM.updateContractId(c.id ?? 0);
            } else {
              contractDetailsTextController.text = 'No Contract Available';
              quotationVM.updateContractId(null);
            }
          } else {
            if (q.client != null) {
              contractDetailsTextController.text = 'Loading...';
              setState(() {});
              await _autoFillContract(q.client!, quotationVM, contractVM);
            } else {
              contractDetailsTextController.text = 'No Contract Available';
              quotationVM.updateContractId(null);
            }
          }

          setState(() {});
        }
      } else {
        termsVM.clearSelectedTerms();
        contractDetailsTextController.text = '';
        quotationVM.updateContractId(null);
        quotationVM.removeAll();
        _selectedLeadId = null; // FIX: reset dropdown ids for a fresh form
        _selectedClientId = null;

        if (quotationVM.quotationList.isEmpty) {
          await quotationVM.getAllQuotations();
          if (!mounted) return;
        }

        quotationNumberTextcontroller.text =
            quotationVM.generateNextQuotationNumber();

        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    quotationNumberTextcontroller.dispose();
    quotationDateTextController.dispose();
    leadTextController.dispose();
    customerNameTextController.dispose();
    companyLocationController.dispose();
    companyAddressController.dispose();
    projectNameController.dispose();
    quantityTextController.dispose();
    unitPriceTextController.dispose();
    termsTextController.dispose();
    contractDetailsTextController.dispose();
    super.dispose();
  }

  void showError(String? message) {
    if (message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.c1,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _autoFillContract(
    int customerId,
    QuotationViewmodel quotationVM,
    ContractViewmodel contractVM,
  ) async {
    final customerVM = Provider.of<CustomerViewmodel>(context, listen: false);
    await customerVM.getCustomerById(customerId);
    if (!mounted) return;

    final customer = customerVM.singleCustomer;

    if (customer != null &&
        customer.contractId != null &&
        customer.contractId! > 0) {
      await contractVM.getContractById(customer.contractId!);
      if (!mounted) return;

      final c = contractVM.currentContract;
      if (c != null) {
        contractDetailsTextController.text = c.name;
        quotationVM.updateContractId(c.id ?? 0);
        contractVM.selectContract(c.id ?? 0, c.name);
      } else {
        contractDetailsTextController.text = 'No Contract Available';
        quotationVM.updateContractId(null);
      }
    } else {
      contractDetailsTextController.text = 'No Contract Available';
      quotationVM.updateContractId(null);
    }

    setState(() {});
  }

  Future<void> _handleSubmit(QuotationViewmodel quotationProvider) async {
    final termsVM = Provider.of<TermsViewModel>(context, listen: false);

    // FIX: validate against the selected id, not the display text, so a
    // stale/duplicate-name text value can't accidentally pass validation.
    final clientErr =
        _selectedClientId == null ? 'Please select a client to continue' : null;
    final projectErr = projectNameController.text.trim().isEmpty
        ? 'Project name is required'
        : null;
    final locationErr = companyLocationController.text.trim().isEmpty
        ? 'Company location is required'
        : null;
    final addressErr = companyAddressController.text.trim().isEmpty
        ? 'Company address is required'
        : null;
    final termsErr = termsVM.selectedTermsTitle.isEmpty
        ? 'Please select terms & conditions'
        : null;

    setState(() {
      _errClient = clientErr;
      _errProjectName = projectErr;
      _errLocation = locationErr;
      _errAddress = addressErr;
      _errTerms = termsErr;
    });

    if (clientErr != null ||
        projectErr != null ||
        locationErr != null ||
        addressErr != null ||
        termsErr != null) return;

    if (widget.isEdit) {
      await quotationProvider.editQuotation(
        widget.quotationId!,
        quotationNumberTextcontroller.text,
        quotationDateTextController.text,
        projectNameController.text,
        companyLocationController.text,
        companyAddressController.text,
        context,
      );
    } else {
      await quotationProvider.createQuotation(
        quotationNumberTextcontroller.text,
        quotationDateTextController.text,
        projectNameController.text,
        companyLocationController.text,
        companyAddressController.text,
        context,
      );
    }

    if (mounted) {
      showError(quotationProvider.errorMessage);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final quotationProvider = Provider.of<QuotationViewmodel>(context);
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.white,
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
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    child: Column(
                      children: [
                        _buildSection(
                          icon: Icons.description_outlined,
                          title: 'Quotation Info',
                          children: _quotationFields(),
                        ),
                        const SizedBox(height: 14),
                        _buildSection(
                          icon: Icons.inventory_2_outlined,
                          title: 'Products',
                          children: [_productSection()],
                        ),
                        const SizedBox(height: 14),
                        _buildSection(
                          icon: Icons.calculate_outlined,
                          title: 'Total',
                          children: [_totalSection()],
                        ),
                        const SizedBox(height: 14),
                        _buildSection(
                          icon: Icons.article_outlined,
                          title: 'Terms & Conditions',
                          children: [_termsSection()],
                        ),
                        const SizedBox(height: 14),
                        _buildSection(
                          icon: Icons.description_outlined,
                          title: 'Contract',
                          children: [_contractSection()],
                        ),
                        const SizedBox(height: 24),
                        _buildActionButtons(quotationProvider),
                      ],
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
      padding: EdgeInsets.only(
        top: topPad + 14,
        bottom: 20,
        left: sw * 0.05,
        right: sw * 0.05,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.cborder, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => pushNavigation(context, const BottomBar(index: 0)),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.cxl,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cborder),
              ),
              child: Image.asset(
                AppAssets.homeIcon,
                width: 17,
                height: 17,
                color: AppColors.c3,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isEdit ? 'Edit Quotation' : 'New Quotation',
                  style: const TextStyle(
                    color: AppColors.cdark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.isEdit
                      ? 'Update quotation details'
                      : 'Fill in the details below',
                  style: const TextStyle(
                    color: AppColors.ctext,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.c1.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.isEdit ? Icons.edit_rounded : Icons.description_outlined,
              color: AppColors.c1,
              size: 17,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section card ──────────────────────────────────────────────────────────
  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.c1.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.c1,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.c1.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: AppColors.c1, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cdark,
                    ),
                  ),
                ]),
                Divider(
                  height: 20,
                  thickness: 1,
                  color: AppColors.c1.withOpacity(0.10),
                ),
                ...children,
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared error row ──────────────────────────────────────────────────────
  Widget _errorRow(String msg) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 13, color: AppColors.red),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              msg,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.red,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Required dot ─────────────────────────────────────────────────────────
  Widget _requiredDot() => const Padding(
        padding: EdgeInsets.only(right: 8),
        child: Icon(Icons.circle, size: 6, color: AppColors.red),
      );

  // ── Text field ────────────────────────────────────────────────────────────
  // No labelText on required fields — hint stays visible and turns red on error
  Widget _field(
    TextEditingController controller,
    String hint, // ← used as hint only (no floating label)
    IconData icon, {
    bool isRequired = false,
    bool isEnabled = true,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    Widget? suffix,
    String? error,
    void Function(String)? onChanged,
  }) {
    final hasError = error != null && error.isNotEmpty;
    final hasValue = controller.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            enabled: isEnabled,
            keyboardType: keyboardType,
            cursorColor: AppColors.c1,
            inputFormatters: inputFormatters,
            maxLines: maxLines,
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.cdark,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              // No labelText — hint always visible
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                // Red when error and field is empty, else normal hint colour
                color:
                    (hasError && !hasValue) ? AppColors.red : AppColors.ctext,
              ),
              prefixIcon: Icon(icon,
                  size: 18, color: hasError ? AppColors.red : AppColors.c1),
              suffixIcon: suffix != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: suffix,
                    )
                  : (isRequired ? _requiredDot() : null),
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 32, minHeight: 32),
              filled: true,
              fillColor:
                  hasError ? AppColors.red.withOpacity(0.04) : AppColors.cxl,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: hasError
                      ? AppColors.red.withOpacity(0.60)
                      : AppColors.cborder,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: hasError
                      ? AppColors.red.withOpacity(0.60)
                      : AppColors.cborder,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.cborder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: hasError ? AppColors.red : AppColors.c1,
                  width: 1.5,
                ),
              ),
            ),
          ),
          if (hasError) _errorRow(error),
        ],
      ),
    );
  }

  // ── Dropdown wrapper ──────────────────────────────────────────────────────
  Widget _dropdownWithError({
    required Widget dropdown,
    String? error,
  }) {
    final hasError = error != null && error.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          dropdown,
          if (hasError) _errorRow(error),
        ],
      ),
    );
  }

  // ── Shared dropdown decoration ────────────────────────────────────────────
  // No labelText — hint text is passed via the DropdownButtonFormField hint
  InputDecoration _dropdownDecoration(
    IconData icon, {
    bool isRequired = false,
    bool hasError = false,
  }) {
    return InputDecoration(
      // No labelText — hint widget on DropdownButtonFormField is used instead
      prefixIcon:
          Icon(icon, size: 18, color: hasError ? AppColors.red : AppColors.c1),
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.keyboard_arrow_down_rounded,
              color: hasError ? AppColors.red : AppColors.c1, size: 20),
          if (isRequired) ...[
            const SizedBox(width: 2),
            const Icon(Icons.circle, size: 6, color: AppColors.red),
          ],
          const SizedBox(width: 8),
        ],
      ),
      suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 32),
      filled: true,
      fillColor: hasError ? AppColors.red.withOpacity(0.04) : AppColors.cxl,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: hasError ? AppColors.red.withOpacity(0.60) : AppColors.cborder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: hasError ? AppColors.red.withOpacity(0.60) : AppColors.cborder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: hasError ? AppColors.red : AppColors.c1,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.red.withOpacity(0.60)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.red, width: 1.5),
      ),
    );
  }

  // ── Quotation fields ──────────────────────────────────────────────────────
  List<Widget> _quotationFields() {
    return [
      // Quotation number + date (not required — keep label style, no error)
      Row(
        children: [
          Expanded(
            child: _field(
              quotationNumberTextcontroller,
              'Quotation No',
              Icons.tag_rounded,
              isEnabled: widget.isEdit,
              suffix: !widget.isEdit
                  ? Tooltip(
                      message: 'Auto-generated. Editable in edit mode.',
                      child: Icon(Icons.info_outline_rounded,
                          size: 16, color: AppColors.c1),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _field(
              quotationDateTextController,
              'Date',
              Icons.calendar_today_outlined,
            ),
          ),
        ],
      ),

      // Lead dropdown — optional, no error state
      // FIX: value/items now keyed by unique lead id (int) instead of the
      // company name string, and the item list is deduped by id.
      Consumer<LeadViewmodel>(
        builder: (context, provider, _) {
          final quotationVM = context.read<QuotationViewmodel>();

          if (provider.getLeadLoader && provider.leadList.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(),
            );
          }

          final seenLeadIds = <int>{};
          final uniqueLeads =
              provider.leadList.where((e) => seenLeadIds.add(e.id)).toList();

          final validLeadId = uniqueLeads.any((e) => e.id == _selectedLeadId)
              ? _selectedLeadId
              : null;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DropdownButtonFormField<int>(
              value: validLeadId,
              isExpanded: true,
              dropdownColor: AppColors.white,
              icon: const SizedBox.shrink(),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.cdark,
                fontWeight: FontWeight.w500,
              ),
              // Hint stays visible (no labelText in decoration)
              hint: Text(
                'Select lead (Optional)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.ctext,
                ),
              ),
              items: uniqueLeads.map((e) {
                return DropdownMenuItem<int>(
                  value: e.id,
                  child: Text(e.company,
                      style: const TextStyle(
                          color: AppColors.cdark, fontSize: 14)),
                );
              }).toList(),
              onChanged: (v) {
                if (v == null) return;
                final selected = uniqueLeads.firstWhere((e) => e.id == v);
                quotationVM.updateLeadId(selected.id);
                leadTextController.text = selected.company;
                setState(() => _selectedLeadId = selected.id);
              },
              decoration: _dropdownDecoration(
                Icons.business_outlined,
              ),
            ),
          );
        },
      ),

      // Client dropdown — required, hint turns red on error
      // FIX: value/items now keyed by unique customerId (int) instead of the
      // "firstName lastName" string, and the item list is deduped by id.
      Consumer<CustomerViewmodel>(
        builder: (context, provider, _) {
          final quotationVM = context.read<QuotationViewmodel>();
          final hasError = _errClient != null && _errClient!.isNotEmpty;

          if (provider.getCustomerLoader && provider.customerList.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(),
            );
          }

          final seenCustomerIds = <int>{};
          final uniqueCustomers = provider.customerList
              .where((e) => seenCustomerIds.add(e.customerId))
              .toList();

          final validClientId =
              uniqueCustomers.any((e) => e.customerId == _selectedClientId)
                  ? _selectedClientId
                  : null;

          return _dropdownWithError(
            error: _errClient,
            dropdown: DropdownButtonFormField<int>(
              isExpanded: true,
              dropdownColor: AppColors.white,
              icon: const SizedBox.shrink(),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.cdark,
                fontWeight: FontWeight.w500,
              ),
              // Hint turns red when error
              hint: Text(
                'Select client',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: hasError ? AppColors.red : AppColors.ctext,
                ),
              ),
              value: validClientId,
              items: uniqueCustomers.map((e) {
                final name = '${e.firstName} ${e.lastName}';
                return DropdownMenuItem<int>(
                  value: e.customerId,
                  child: Text(name,
                      style: const TextStyle(
                          color: AppColors.cdark, fontSize: 14)),
                );
              }).toList(),
              onChanged: (v) async {
                if (v == null) return;
                if (_errClient != null) setState(() => _errClient = null);

                final selected = uniqueCustomers.firstWhere(
                  (e) => e.customerId == v,
                );

                quotationVM.updateClientId(selected.customerId);
                customerNameTextController.text =
                    '${selected.firstName} ${selected.lastName}';

                contractDetailsTextController.text = 'Loading...';
                quotationVM.updateContractId(null);
                setState(() => _selectedClientId = selected.customerId);

                final contractVM = context.read<ContractViewmodel>();
                await _autoFillContract(
                    selected.customerId, quotationVM, contractVM);
              },
              decoration: _dropdownDecoration(
                Icons.person_outline_rounded,
                isRequired: true,
                hasError: hasError,
              ),
            ),
          );
        },
      ),

      // Project name — required, hint turns red on error
      _field(
        projectNameController,
        'Project Name',
        Icons.work_outline_rounded,
        isRequired: true,
        error: _errProjectName,
        onChanged: (_) {
          if (_errProjectName != null) setState(() => _errProjectName = null);
        },
      ),

      // Company location — required, hint turns red on error
      _field(
        companyLocationController,
        'Company Location',
        Icons.location_on_outlined,
        isRequired: true,
        error: _errLocation,
        onChanged: (_) {
          if (_errLocation != null) setState(() => _errLocation = null);
        },
      ),

      // Company address — required, hint turns red on error
      _field(
        companyAddressController,
        'Company Address',
        Icons.home_outlined,
        isRequired: true,
        error: _errAddress,
        onChanged: (_) {
          if (_errAddress != null) setState(() => _errAddress = null);
        },
      ),
    ];
  }

  // ── Products section ──────────────────────────────────────────────────────
  Widget _productSection() {
    final vm = context.watch<QuotationViewmodel>();

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => widget.isEdit ? vm.addEditItem() : vm.addItem(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                  Text(
                    'Add Product',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: (widget.isEdit ? vm.editItemList : vm.itemList)
              .map((e) => QuotationItem(
                    itemNumber: e.itemNumber,
                    isEditMode: widget.isEdit,
                  ))
              .toList(),
        ),
      ],
    );
  }

  // ── Total section ─────────────────────────────────────────────────────────
  Widget _totalSection() {
    return Consumer<QuotationViewmodel>(
      builder: (_, vm, __) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Grand Total',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.ctext.withOpacity(0.75),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.c1.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.c1.withOpacity(0.20)),
            ),
            child: Text(
              '₹ ${vm.grandTotal}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.c1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Terms section ─────────────────────────────────────────────────────────
  Widget _termsSection() {
    return Consumer<TermsViewModel>(
      builder: (context, vm, _) {
        final hasError = _errTerms != null && _errTerms!.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () async {
                await vm.getAllTermsTitle();
                if (!context.mounted) return;

                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (context) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24)),
                        border:
                            Border.all(color: AppColors.cborder, width: 1.5),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(top: 12, bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.c1.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                            child: Row(children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: AppColors.c1.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.article_outlined,
                                    color: AppColors.c1, size: 15),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Select Terms & Conditions',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.cdark,
                                ),
                              ),
                            ]),
                          ),
                          Divider(
                              height: 1, color: AppColors.c1.withOpacity(0.10)),
                          Flexible(
                            child: Consumer<TermsViewModel>(
                              builder: (context, model, _) {
                                if (model.isLoading) {
                                  return Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: CircularProgressIndicator(
                                        color: AppColors.c1, strokeWidth: 2.5),
                                  );
                                }

                                if (model.termsList.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Text('No Terms Available',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.ctext)),
                                  );
                                }

                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 8, 16, 24),
                                  itemCount: model.termsList.length,
                                  separatorBuilder: (_, __) => Divider(
                                      color: AppColors.c1.withOpacity(0.08),
                                      height: 1),
                                  itemBuilder: (context, index) {
                                    final item = model.termsList[index];
                                    final isSelected =
                                        model.selectedTermsTitle ==
                                            (item.name ?? '');
                                    return ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 2),
                                      leading: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.c1
                                              : AppColors.c1.withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(7),
                                        ),
                                        child: Icon(
                                          isSelected
                                              ? Icons.check_rounded
                                              : Icons.article_outlined,
                                          size: 14,
                                          color: isSelected
                                              ? AppColors.white
                                              : AppColors.c1,
                                        ),
                                      ),
                                      title: Text(
                                        item.name ?? '',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: AppColors.cdark,
                                        ),
                                      ),
                                      onTap: () async {
                                        model.selectTerms(item);
                                        await model.getTermsById(item.id ?? 0);
                                        if (_errTerms != null) {
                                          setState(() => _errTerms = null);
                                        }
                                        if (context.mounted)
                                          Navigator.pop(context);
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: hasError
                      ? AppColors.red.withOpacity(0.04)
                      : AppColors.cxl,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: hasError
                        ? AppColors.red.withOpacity(0.60)
                        : (vm.selectedTermsTitle.isNotEmpty
                            ? AppColors.c1
                            : AppColors.cborder),
                    width: hasError || vm.selectedTermsTitle.isNotEmpty
                        ? 1.5
                        : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.article_outlined,
                        size: 18,
                        color: hasError ? AppColors.red : AppColors.c1),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              fontSize: 11,
                              color: hasError
                                  ? AppColors.red.withOpacity(0.80)
                                  : AppColors.ctext.withOpacity(0.65),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            vm.selectedTermsTitle.isNotEmpty
                                ? vm.selectedTermsTitle
                                : 'Select terms & conditions',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: vm.selectedTermsTitle.isNotEmpty
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              // Hint text turns red on error
                              color: hasError
                                  ? AppColors.red
                                  : (vm.selectedTermsTitle.isNotEmpty
                                      ? AppColors.cdark
                                      : AppColors.ctext),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.keyboard_arrow_down_rounded,
                            color: hasError ? AppColors.red : AppColors.c1,
                            size: 20),
                        const SizedBox(width: 2),
                        const Icon(Icons.circle, size: 6, color: AppColors.red),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (hasError) _errorRow(_errTerms!),
          ],
        );
      },
    );
  }

  // ── Contract section ──────────────────────────────────────────────────────
  Widget _contractSection() {
    final text = contractDetailsTextController.text;
    final isEmpty = text.isEmpty;
    final isLoading = text == 'Loading...';
    final hasContract = !isEmpty &&
        !isLoading &&
        text != 'No Contract Available' &&
        text != 'No Contract';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: hasContract ? AppColors.c1.withOpacity(0.06) : AppColors.cxl,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              hasContract ? AppColors.c1.withOpacity(0.20) : AppColors.cborder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: hasContract
                  ? AppColors.c1.withOpacity(0.12)
                  : AppColors.cborder.withOpacity(0.5),
              borderRadius: BorderRadius.circular(7),
            ),
            child: isLoading
                ? Padding(
                    padding: const EdgeInsets.all(7),
                    child: CircularProgressIndicator(
                        color: AppColors.c1, strokeWidth: 2),
                  )
                : Icon(
                    hasContract
                        ? Icons.description_rounded
                        : Icons.description_outlined,
                    size: 15,
                    color: hasContract ? AppColors.c1 : AppColors.ctext,
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isEmpty ? 'No Contract' : text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: hasContract ? FontWeight.w600 : FontWeight.w400,
                color: hasContract
                    ? AppColors.cdark
                    : AppColors.ctext.withOpacity(0.60),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Action buttons ────────────────────────────────────────────────────────
  Widget _buildActionButtons(QuotationViewmodel quotationProvider) {
    final isLoading =
        quotationProvider.addQuotationLoader || quotationProvider.editLoading;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed:
                isLoading ? null : () => _handleSubmit(quotationProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.c1,
              disabledBackgroundColor: AppColors.c1.withOpacity(0.50),
              foregroundColor: AppColors.white,
              elevation: 0,
              shadowColor: AppColors.c1.withOpacity(0.30),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26)),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: AppColors.white, strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.isEdit
                            ? Icons.check_rounded
                            : Icons.description_outlined,
                        color: AppColors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.isEdit ? 'Save Changes' : 'Save Quotation',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.cborder, width: 1.5),
              foregroundColor: AppColors.ctext,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26)),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.ctext,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
