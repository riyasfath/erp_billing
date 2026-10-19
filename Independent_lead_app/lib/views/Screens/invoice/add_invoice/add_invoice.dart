
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/customer_viewmodel.dart';
import 'package:pokakbilling/viewmodels/invoice_viewmodel.dart';
import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/terms&condition_viewmodel.dart';
import 'package:pokakbilling/views/Screens/invoice/add_prouduct/add_product.dart';
import 'package:provider/provider.dart';

class AddInvoices extends StatefulWidget {
  final bool isEdit;
  final String invoiceNumber;
  final int? invoiceId;

  const AddInvoices({
    super.key,
    required this.invoiceNumber,
    required this.isEdit,
    this.invoiceId,
  });

  @override
  State<AddInvoices> createState() => _AddInvoicesState();
}

class _AddInvoicesState extends State<AddInvoices> {
  // Controllers
  late TextEditingController invoiceNumberTextcontroller;
  late TextEditingController invoiceDateTextcontroller;
  late TextEditingController dueDateTextController;
  late TextEditingController clientTextcontroller;
  late TextEditingController projectTextcontroller;
  late TextEditingController addressTextcontroller;
  late TextEditingController locationTextcontroller;
  late TextEditingController paidAmountController;
  late TextEditingController remarkController;

  // Selection state
  int? selectedQuotationId;
  String? selectedQuotationNumber;
  String? selectedClientId;
  String? selectedType;
  String? selectedStatus;
  String? selectedPaymentStatus;
  String? selectedPaymentMethod;

  // Manual errors - set only on submit
  String? _errQuotation;
  String? _errClient;
  String? _errProject;
  String? _errInvoiceType;
  String? _errInvoiceStatus;
  String? _errAddress;
  String? _errLocation;
  String? _errInvoiceDate;
  String? _errDueDate;
  String? _errPaidAmount;
  String? _errPaymentMethod;
  String? _errTerms;

  // Static lists
  final invoiceStatusList = [
    {"label": "Draft", "value": "DRAFT"},
    {"label": "Final", "value": "FINAL"},
    {"label": "Cancelled", "value": "CANCELLED"},
  ];
  final paymentMethodList = ["Bank Transfer", "Cash", "UPI", "Cheque"];
  final invoiceTypes = ["Sales Invoice", "Purchase Invoice", "Credit Note"];
  final paymentStatusList = ["Unpaid", "Partial", "Paid"];

  String _invoiceTypeApi(String? t) {
    switch (t) {
      case "Sales Invoice":
        return "SALES";
      case "Purchase Invoice":
        return "PURCHASE";
      case "Credit Note":
        return "CREDIT_NOTE";
      default:
        return "SALES";
    }
  }

  String _paymentStatusApi(String? s) {
    switch (s) {
      case "Unpaid":
        return "UNPAID";
      case "Partial":
        return "PARTIAL";
      case "Paid":
        return "PAID";
      default:
        return "UNPAID";
    }
  }

  @override
  void initState() {
    super.initState();
    invoiceNumberTextcontroller =
        TextEditingController(text: widget.invoiceNumber);
    invoiceDateTextcontroller = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    dueDateTextController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    clientTextcontroller = TextEditingController();
    projectTextcontroller = TextEditingController();
    addressTextcontroller = TextEditingController();
    locationTextcontroller = TextEditingController();
    paidAmountController = TextEditingController(text: "0");
    remarkController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerViewmodel>().getAllCustomers();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final invoiceVM = context.read<InvoiceViewModel>();
      if (widget.isEdit && widget.invoiceId != null) {
        await invoiceVM.getInvoiceById(widget.invoiceId!);
        final invoice = invoiceVM.singleInvoice;
        if (invoice != null) {
          invoiceVM.setEditDataToControllers(
            invoice: invoice,
            invoiceNumber: invoiceNumberTextcontroller,
            invoiceDate: invoiceDateTextcontroller,
            dueDate: dueDateTextController,
            project: projectTextcontroller,
            address: addressTextcontroller,
            location: locationTextcontroller,
            paidAmount: paidAmountController,
            notes: remarkController,
            setType: (v) => selectedType = v ?? "",
            setStatus: (v) => selectedStatus = v ?? "",
            setPaymentStatus: (v) => selectedPaymentStatus = v ?? "",
            setPaymentMethod: (v) => selectedPaymentMethod = v ?? "",
          );
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    invoiceNumberTextcontroller.dispose();
    invoiceDateTextcontroller.dispose();
    dueDateTextController.dispose();
    clientTextcontroller.dispose();
    projectTextcontroller.dispose();
    addressTextcontroller.dispose();
    locationTextcontroller.dispose();
    paidAmountController.dispose();
    remarkController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();
    final termsVM = context.read<TermsViewModel>();

    final quotationErr =
        (selectedQuotationNumber == null || selectedQuotationNumber!.isEmpty)
            ? 'Please select a quotation'
            : null;
    final clientErr = (selectedClientId == null || selectedClientId!.isEmpty)
        ? 'Please select a client'
        : null;
    final projectErr = projectTextcontroller.text.trim().isEmpty
        ? 'Project name is required'
        : null;
    final typeErr = (selectedType == null || selectedType!.isEmpty)
        ? 'Invoice type is required'
        : null;
    final statusErr = (selectedStatus == null || selectedStatus!.isEmpty)
        ? 'Invoice status is required'
        : null;
    final addressErr = addressTextcontroller.text.trim().isEmpty
        ? 'Company address is required'
        : null;
    final locationErr = locationTextcontroller.text.trim().isEmpty
        ? 'Location is required'
        : null;
    final invoiceDateErr = invoiceDateTextcontroller.text.trim().isEmpty
        ? 'Invoice date is required'
        : null;
    final dueDateErr = dueDateTextController.text.trim().isEmpty
        ? 'Due date is required'
        : null;
    final termsErr = termsVM.selectedTermsTitle.isEmpty
        ? 'Please select terms & conditions'
        : null;

    String? paidAmountErr;
    String? paymentMethodErr;
    if (selectedPaymentStatus == 'Partial' || selectedPaymentStatus == 'Paid') {
      final v = paidAmountController.text.trim();
      if (v.isEmpty) {
        paidAmountErr = 'Paid amount is required';
      } else {
        final amt = double.tryParse(v);
        if (amt == null)
          paidAmountErr = 'Enter a valid amount';
        else if (amt < 0) paidAmountErr = 'Amount cannot be negative';
      }
      if (selectedPaymentMethod == null || selectedPaymentMethod!.isEmpty) {
        paymentMethodErr = 'Payment method is required';
      }
    }

    setState(() {
      _errQuotation = quotationErr;
      _errClient = clientErr;
      _errProject = projectErr;
      _errInvoiceType = typeErr;
      _errInvoiceStatus = statusErr;
      _errAddress = addressErr;
      _errLocation = locationErr;
      _errInvoiceDate = invoiceDateErr;
      _errDueDate = dueDateErr;
      _errPaidAmount = paidAmountErr;
      _errPaymentMethod = paymentMethodErr;
      _errTerms = termsErr;
    });

    if ([
      quotationErr,
      clientErr,
      projectErr,
      typeErr,
      statusErr,
      addressErr,
      locationErr,
      invoiceDateErr,
      dueDateErr,
      paidAmountErr,
      paymentMethodErr,
      termsErr
    ].any((e) => e != null)) return;

    final invoiceVM = context.read<InvoiceViewModel>();
    final quotationVM = context.read<QuotationViewmodel>();
    final customerVM = context.read<CustomerViewmodel>();

    final selectedCustomer = customerVM.customerList
        .firstWhere((e) => e.customerId.toString() == selectedClientId);

    final items = widget.isEdit
        ? quotationVM.getFormattedEditItems()
        : quotationVM.getFormattedItems();

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add at least one product')));
      return;
    }

    if (widget.isEdit) {
      await invoiceVM.editInvoice(
        id: widget.invoiceId!,
        invoiceNumber: invoiceNumberTextcontroller.text,
        date: invoiceDateTextcontroller.text,
        dueDate: dueDateTextController.text,
        projectName: projectTextcontroller.text,
        location: locationTextcontroller.text,
        address: addressTextcontroller.text,
        clientId: selectedCustomer.customerId!,
        quotationId: selectedQuotationId,
        invoiceType: _invoiceTypeApi(selectedType),
        status: selectedStatus ?? 'DRAFT',
        paymentStatus: _paymentStatusApi(selectedPaymentStatus),
        paymentMethod: selectedPaymentMethod ?? 'Bank Transfer',
        paidAmount:
            paidAmountController.text.isEmpty ? '0' : paidAmountController.text,
        notes: remarkController.text,
        terms: termsVM.selectedTermsTitle,
        items: items,
        context: context,
      );
    } else {
      await invoiceVM.createInvoice(
        invoiceNumber: invoiceNumberTextcontroller.text,
        date: invoiceDateTextcontroller.text,
        dueDate: dueDateTextController.text,
        projectName: projectTextcontroller.text,
        location: locationTextcontroller.text,
        address: addressTextcontroller.text,
        clientId: selectedCustomer.customerId!,
        quotationId: selectedQuotationId,
        invoiceType: _invoiceTypeApi(selectedType),
        status: selectedStatus ?? 'DRAFT',
        paymentStatus: _paymentStatusApi(selectedPaymentStatus),
        paymentMethod: selectedPaymentMethod ?? 'Bank Transfer',
        paidAmount:
            paidAmountController.text.isEmpty ? '0' : paidAmountController.text,
        notes: remarkController.text,
        terms: termsVM.selectedTermsTitle,
        items: items,
        context: context,
      );
    }

    if (context.mounted) Navigator.pop(context);
  }

  // ===========================================================================
  // DECORATION HELPERS
  // ===========================================================================

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    bool isRequired = false,
    bool hasError = false,
    bool isEnabled = true,
    Widget? customSuffix,
  }) {
    return InputDecoration(
      labelText: label,
      // ✅ Label turns red on error
      labelStyle: TextStyle(
        fontSize: 13,
        color: hasError ? AppColors.red : AppColors.ctext.withOpacity(0.75),
      ),
      prefixIcon:
          Icon(icon, size: 18, color: hasError ? AppColors.red : AppColors.c1),
      suffixIcon: customSuffix ??
          (isRequired
              ? Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(Icons.circle, size: 6, color: AppColors.red),
                )
              : null),
      suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      filled: true,
      fillColor: !isEnabled
          ? AppColors.cxl.withOpacity(0.5)
          : hasError
              ? AppColors.red.withOpacity(0.04)
              : AppColors.cxl,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
            color:
                hasError ? AppColors.red.withOpacity(0.60) : AppColors.cborder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
            color:
                hasError ? AppColors.red.withOpacity(0.60) : AppColors.cborder),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.cborder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
            color: hasError ? AppColors.red : AppColors.c1, width: 1.5),
      ),
    );
  }

  InputDecoration _dropdownDecoration(
    String label,
    IconData icon, {
    bool isRequired = false,
    bool hasError = false,
  }) {
    return InputDecoration(
      labelText: label,
      // ✅ Label turns red on error
      labelStyle: TextStyle(
        fontSize: 13,
        color: hasError ? AppColors.red : AppColors.ctext.withOpacity(0.75),
      ),
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
            color:
                hasError ? AppColors.red.withOpacity(0.60) : AppColors.cborder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
            color:
                hasError ? AppColors.red.withOpacity(0.60) : AppColors.cborder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
            color: hasError ? AppColors.red : AppColors.c1, width: 1.5),
      ),
    );
  }

  Widget _errorRow(String error) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 13, color: AppColors.red),
          const SizedBox(width: 4),
          Flexible(
            child: Text(error,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.red,
                    height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isRequired = false,
    bool isEnabled = true,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? error,
    void Function(String)? onChanged,
    int maxLines = 1,
    Widget? customSuffix,
  }) {
    final hasError = error != null && error.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            enabled: isEnabled,
            keyboardType: keyboardType,
            maxLines: maxLines,
            cursorColor: AppColors.c1,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14, color: AppColors.cdark),
            decoration: _inputDecoration(label, icon,
                isRequired: isRequired,
                hasError: hasError,
                isEnabled: isEnabled,
                customSuffix: customSuffix),
          ),
          if (hasError) _errorRow(error),
        ],
      ),
    );
  }

  Widget _dropdownWrap({required Widget child, String? error}) {
    final hasError = error != null && error.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
          if (hasError) _errorRow(error),
        ],
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    bool isRequired = false,
    String? error,
    String? hint,
  }) {
    final hasError = error != null && error.isNotEmpty;
    return _dropdownWrap(
      error: error,
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        dropdownColor: AppColors.white,
        icon: const SizedBox.shrink(),
        style: const TextStyle(
            fontSize: 14, color: AppColors.cdark, fontWeight: FontWeight.w500),
        // ✅ Hint text turns red on error
        hint: hint != null
            ? Text(
                hint,
                style: TextStyle(
                  fontSize: 13,
                  color: hasError
                      ? AppColors.red.withOpacity(0.70)
                      : AppColors.ctext.withOpacity(0.55),
                ),
              )
            : null,
        items: items,
        onChanged: onChanged,
        decoration: _dropdownDecoration(label, icon,
            isRequired: isRequired, hasError: hasError),
      ),
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    final invoiceProvider = context.watch<InvoiceViewModel>();
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            _buildHeader(context, sw, topPad),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSection(
                        title: 'Invoice Information',
                        icon: Icons.description_outlined,
                        children: _invoiceFields()),
                    const SizedBox(height: 10),
                    _buildSection(
                        title: 'Add Products',
                        icon: Icons.inventory_2_outlined,
                        children: [_productSection()]),
                    const SizedBox(height: 10),
                    _buildSection(
                        title: 'Pricing Summary',
                        icon: Icons.calculate_outlined,
                        children: [_totalSection()]),
                    const SizedBox(height: 10),
                    _buildSection(
                        title: 'Payment Details',
                        icon: Icons.account_balance_wallet_outlined,
                        children: [_paymentSection()]),
                    const SizedBox(height: 10),
                    _buildSection(
                        title: 'Terms & Conditions',
                        icon: Icons.article_outlined,
                        children: [_termsSection()]),
                    const SizedBox(height: 10),
                    _buildSection(
                        title: 'Remark',
                        icon: Icons.notes_outlined,
                        children: [_remarkSection()]),
                    const SizedBox(height: 20),
                    _buildSaveBar(invoiceProvider),
                    SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double sw, double topPad) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
          top: topPad + 12, bottom: 28, left: sw * 0.03, right: sw * 0.04),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border:
            Border(bottom: BorderSide(color: AppColors.cborder, width: 1.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: AppColors.cxl,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cborder)),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.c3, size: 15),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.isEdit ? 'Edit Invoice' : 'New Invoice',
                  style: const TextStyle(
                      color: AppColors.cdark,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              Text(
                widget.isEdit
                    ? 'Update invoice details'
                    : 'Fill in the details below to generate a new invoice',
                style: const TextStyle(color: AppColors.ctext, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cborder),
        boxShadow: [
          BoxShadow(
              color: AppColors.c1.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: AppColors.cxl,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cborder)),
                child: Icon(icon, color: AppColors.c1, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cdark))),
            ],
          ),
          const Divider(height: 20, thickness: 1, color: AppColors.cborder),
          ...children,
        ],
      ),
    );
  }

  // ===========================================================================
  // INVOICE INFORMATION FIELDS
  // ===========================================================================
  List<Widget> _invoiceFields() {
    return [
      _field(invoiceNumberTextcontroller, 'Invoice No', Icons.numbers,
          isEnabled: false),

      _field(invoiceDateTextcontroller, 'Invoice Date', Icons.calendar_today,
          isRequired: true, error: _errInvoiceDate, onChanged: (_) {
        if (_errInvoiceDate != null) setState(() => _errInvoiceDate = null);
      }),

      _field(dueDateTextController, 'Due Date', Icons.calendar_today,
          isRequired: true, error: _errDueDate, onChanged: (_) {
        if (_errDueDate != null) setState(() => _errDueDate = null);
      }),

      // Quotation
      Consumer<QuotationViewmodel>(builder: (context, quotationVM, _) {
        if (quotationVM.getQuotationLoader &&
            quotationVM.quotationList.isEmpty) {
          return const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator());
        }
        return _dropdown<String>(
          label: 'Quotation',
          icon: Icons.description,
          isRequired: true,
          error: _errQuotation,
          hint: 'Select Quotation',
          value: selectedQuotationNumber,
          items: quotationVM.quotationList
              .map((q) => DropdownMenuItem<String>(
                  value: q.quotationNumber,
                  child: Text(q.quotationNumber ?? '',
                      style: const TextStyle(
                          color: AppColors.cdark, fontSize: 14))))
              .toList(),
          onChanged: (value) async {
            if (value == null) return;
            if (_errQuotation != null) setState(() => _errQuotation = null);
            final sel = quotationVM.quotationList
                .firstWhere((q) => q.quotationNumber == value);
            selectedQuotationId = sel.quotationId;
            selectedQuotationNumber = sel.quotationNumber;
            await quotationVM.getQuotationById(sel.quotationId);
            final q = quotationVM.singleQuotation;
            selectedClientId = q?.client?.toString();
            clientTextcontroller.text =
                q?.clientNameDisplay ?? q?.clientName ?? '';
            projectTextcontroller.text = q?.projectName ?? '';
            addressTextcontroller.text = q?.companyAddress ?? '';
            locationTextcontroller.text = q?.companyLocation ?? '';
            selectedType = 'Sales Invoice';
            selectedStatus = q?.status;
            selectedPaymentStatus = 'Unpaid';
            paidAmountController.text = '0';
            remarkController.text = q?.notes ?? '';
            setState(() {});
          },
        );
      }),

      // Client
      Consumer<CustomerViewmodel>(builder: (context, provider, _) {
        if (provider.getCustomerLoader && provider.customerList.isEmpty) {
          return const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator());
        }
        final validId = (selectedClientId != null &&
                provider.customerList
                    .any((e) => e.customerId.toString() == selectedClientId))
            ? selectedClientId
            : null;
        return _dropdown<String>(
          label: 'Client',
          icon: Icons.person,
          isRequired: true,
          error: _errClient,
          hint: 'Select Client',
          value: validId,
          items: provider.customerList.map((e) {
            final name = '${e.firstName ?? ''} ${e.lastName ?? ''}'.trim();
            return DropdownMenuItem<String>(
                value: e.customerId.toString(),
                child: Text(name,
                    style:
                        const TextStyle(color: AppColors.cdark, fontSize: 14)));
          }).toList(),
          onChanged: (v) {
            if (v == null) return;
            if (_errClient != null) setState(() => _errClient = null);
            final sel = provider.customerList
                .firstWhere((e) => e.customerId.toString() == v);
            selectedClientId = v;
            clientTextcontroller.text =
                '${sel.firstName ?? ''} ${sel.lastName ?? ''}'.trim();
            addressTextcontroller.text = sel.address ?? '';
            setState(() {});
          },
        );
      }),

      _field(projectTextcontroller, 'Project Name', Icons.work_outline,
          isRequired: true, error: _errProject, onChanged: (_) {
        if (_errProject != null) setState(() => _errProject = null);
      }),

      _dropdown<String>(
        label: 'Invoice Type',
        icon: Icons.receipt,
        isRequired: true,
        error: _errInvoiceType,
        hint: 'Select Invoice Type',
        value: invoiceTypes.contains(selectedType) ? selectedType : null,
        items: invoiceTypes
            .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e,
                    style:
                        const TextStyle(color: AppColors.cdark, fontSize: 14))))
            .toList(),
        onChanged: (v) {
          if (_errInvoiceType != null) setState(() => _errInvoiceType = null);
          setState(() => selectedType = v);
        },
      ),

      _dropdown<String>(
        label: 'Invoice Status',
        icon: Icons.info,
        isRequired: true,
        error: _errInvoiceStatus,
        hint: 'Select Invoice Status',
        value: invoiceStatusList.any((x) => x['value'] == selectedStatus)
            ? selectedStatus
            : null,
        items: invoiceStatusList
            .map((e) => DropdownMenuItem<String>(
                value: e['value'],
                child: Text(e['label']!,
                    style:
                        const TextStyle(color: AppColors.cdark, fontSize: 14))))
            .toList(),
        onChanged: (v) {
          if (_errInvoiceStatus != null)
            setState(() => _errInvoiceStatus = null);
          setState(() => selectedStatus = v);
        },
      ),

      _field(addressTextcontroller, 'Company Address', Icons.home_outlined,
          isRequired: true, error: _errAddress, onChanged: (_) {
        if (_errAddress != null) setState(() => _errAddress = null);
      }),

      _field(locationTextcontroller, 'Company Location',
          Icons.location_on_outlined, isRequired: true, error: _errLocation,
          onChanged: (_) {
        if (_errLocation != null) setState(() => _errLocation = null);
      }),
    ];
  }

  // ===========================================================================
  // SECTIONS
  // ===========================================================================
  Widget _productSection() {
    final vm = context.watch<QuotationViewmodel>();
    final items = widget.isEdit ? vm.editItemList : vm.itemList;
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.add, color: AppColors.c1),
            onPressed: widget.isEdit ? vm.addEditItem : vm.addItem,
          ),
        ),
        const SizedBox(height: 10),
        if (items.isEmpty)
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
                color: AppColors.cxl,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cborder)),
            child: const Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.shopping_cart_outlined,
                    color: AppColors.c1, size: 30),
                SizedBox(height: 10),
                Text('No Product Selected',
                    style: TextStyle(
                        color: AppColors.ctext,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Click ',
                      style: TextStyle(color: AppColors.ctext, fontSize: 12)),
                  Icon(Icons.add, size: 14, color: AppColors.cdark),
                  Text(' to add product',
                      style: TextStyle(color: AppColors.ctext, fontSize: 12)),
                ]),
              ]),
            ),
          )
        else
          Column(
            children: items
                .map((e) => InvoiceAddProduct(
                    itemNumber: e.itemNumber, isEditMode: widget.isEdit))
                .toList(),
          ),
      ],
    );
  }

  Widget _totalSection() {
    return Consumer<QuotationViewmodel>(builder: (_, vm, __) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.cxl,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cborder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _row('Subtotal (Before Tax)', vm.calcSubtotal.toStringAsFixed(2)),
          _row('Taxable Amount', vm.calcSubtotal.toStringAsFixed(2)),
          _row('Total Tax', vm.calcTax.toStringAsFixed(2)),
          const Divider(height: 20, thickness: 1, color: AppColors.cborder),
          _row('Grand Total', vm.calcGrandTotal.toStringAsFixed(2),
              isBold: true, color: AppColors.green),
        ]),
      );
    });
  }

  Widget _row(String title, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title,
            style: TextStyle(
                color: AppColors.cdark,
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w400)),
        Text('₹ $value',
            style: TextStyle(
                color: color ?? AppColors.ctext,
                fontSize: isBold ? 16 : 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
      ]),
    );
  }

  Widget _paymentSection() {
    final vm = context.watch<QuotationViewmodel>();
    final balance =
        vm.calcGrandTotal - (double.tryParse(paidAmountController.text) ?? 0.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dropdown<String>(
          label: 'Payment Status',
          icon: Icons.payment,
          hint: 'Select Payment Status',
          value: paymentStatusList.contains(selectedPaymentStatus)
              ? selectedPaymentStatus
              : null,
          items: paymentStatusList
              .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e,
                      style: const TextStyle(
                          color: AppColors.cdark, fontSize: 14))))
              .toList(),
          onChanged: (v) {
            setState(() {
              selectedPaymentStatus = v;
              if (v == 'Paid')
                paidAmountController.text =
                    vm.calcGrandTotal.toStringAsFixed(2);
              else if (v == 'Unpaid') paidAmountController.text = '0';
              _errPaidAmount = null;
              _errPaymentMethod = null;
            });
          },
        ),
        if (selectedPaymentStatus == 'Partial' ||
            selectedPaymentStatus == 'Paid') ...[
          _field(paidAmountController, 'Paid Amount', Icons.currency_rupee,
              isRequired: true,
              keyboardType: TextInputType.number,
              error: _errPaidAmount, onChanged: (_) {
            if (_errPaidAmount != null) setState(() => _errPaidAmount = null);
          }),
          _dropdown<String>(
            label: 'Payment Method',
            icon: Icons.account_balance_wallet,
            isRequired: true,
            error: _errPaymentMethod,
            hint: 'Select Payment Method',
            value: paymentMethodList.contains(selectedPaymentMethod)
                ? selectedPaymentMethod
                : null,
            items: paymentMethodList
                .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e,
                        style: const TextStyle(
                            color: AppColors.cdark, fontSize: 14))))
                .toList(),
            onChanged: (v) {
              if (_errPaymentMethod != null)
                setState(() => _errPaymentMethod = null);
              setState(() => selectedPaymentMethod = v);
            },
          ),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
              color: AppColors.cxl,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cborder)),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Balance Due',
                style: TextStyle(
                    color: AppColors.ctext,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            Text('₹ ${balance.toStringAsFixed(2)}',
                style: TextStyle(
                    color: balance == 0
                        ? AppColors.green.withOpacity(0.45)
                        : AppColors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
          ]),
        ),
      ],
    );
  }

  Widget _termsSection() {
    return Consumer<TermsViewModel>(builder: (context, vm, _) {
      final hasError = _errTerms != null && _errTerms!.isNotEmpty;
      return _dropdownWrap(
        error: _errTerms,
        child: TextField(
          key: ValueKey(vm.selectedTermsTitle),
          controller: TextEditingController(text: vm.selectedTermsTitle),
          readOnly: true,
          style: const TextStyle(fontSize: 14, color: AppColors.ctext),
          decoration: _inputDecoration(
            'Terms & Conditions',
            Icons.article,
            isRequired: true,
            hasError: hasError,
            customSuffix: Icon(Icons.keyboard_arrow_down_rounded,
                size: 20, color: hasError ? AppColors.red : AppColors.c1),
          ),
          onTap: () async {
            if (vm.termsList.isEmpty) await vm.getAllTermsTitle();
            if (!context.mounted) return;
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20))),
              builder: (context) => Container(
                decoration: BoxDecoration(
                    color: AppColors.cxl,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    border: Border.all(color: AppColors.cborder, width: 1.5)),
                child: Consumer<TermsViewModel>(builder: (context, model, _) {
                  if (model.isLoading)
                    return const Center(child: CircularProgressIndicator());
                  if (model.termsList.isEmpty)
                    return const Center(child: Text('No Terms Available'));
                  return ListView.builder(
                    itemCount: model.termsList.length,
                    itemBuilder: (_, index) {
                      final item = model.termsList[index];
                      return ListTile(
                        title: Text(item.name ?? '',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ctext)),
                        onTap: () async {
                          model.selectTerms(item);
                          await model.getTermsById(item.id ?? 0);
                          if (_errTerms != null)
                            setState(() => _errTerms = null);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                }),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _remarkSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: remarkController,
        maxLines: 4,
        cursorColor: AppColors.c1,
        style: const TextStyle(fontSize: 14, color: AppColors.ctext),
        decoration: _inputDecoration('Remark', Icons.notes),
      ),
    );
  }

  Widget _buildSaveBar(InvoiceViewModel invoiceProvider) {
    final isLoading =
        invoiceProvider.createLoading || invoiceProvider.editLoading;
    return SafeArea(
      top: false,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.c1,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                  color: AppColors.c1.withOpacity(0.30),
                  blurRadius: 14,
                  offset: const Offset(0, 5))
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: AppColors.white, strokeWidth: 2))
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(
                        widget.isEdit
                            ? Icons.check_rounded
                            : Icons.inventory_2_outlined,
                        color: AppColors.white,
                        size: 18),
                    const SizedBox(width: 8),
                    Text(widget.isEdit ? 'Save Changes' : 'Save Invoice',
                        style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8)),
                  ]),
          ),
        ),
      ),
    );
  }
}
