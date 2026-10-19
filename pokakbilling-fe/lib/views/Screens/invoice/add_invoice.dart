import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/customer_model.dart';
import 'package:pokakbilling/models/data-models/invoice/invoice_model.dart';
import 'package:pokakbilling/models/data-models/product_model.dart';
import 'package:pokakbilling/models/data-models/setup/terms&condition_model.dart';
import 'package:pokakbilling/models/services/customer_services.dart';
import 'package:pokakbilling/models/services/product_services.dart';
import 'package:pokakbilling/models/services/setup/terms&condition_services.dart';
import 'package:pokakbilling/models/student/course_model.dart';
import 'package:pokakbilling/models/student/student_model.dart';
import 'package:pokakbilling/viewmodels/internship_viewmodel.dart';
import 'package:pokakbilling/viewmodels/invoice_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/terms%26condition_viewmodel.dart';
import 'package:provider/provider.dart';

class AddInvoiceScreen extends StatefulWidget {
  final bool isEdit;
  final InvoiceModel? invoice;

  const AddInvoiceScreen({
    super.key,
    this.isEdit = false,
    this.invoice,
  });

  @override
  State<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  // ── type ──────────────────────────────────────────────────────────────────
  String _invoiceType = 'client'; // 'client' | 'intern'

  // ── shared controllers ────────────────────────────────────────────────────
  late TextEditingController _invoiceNumberCtrl;
  late TextEditingController _remarkCtrl;
  late TextEditingController _invoiceDateCtrl;

  // ── client ────────────────────────────────────────────────────────────────
  List<CustomerModel> _customers = [];
  CustomerModel? _selectedCustomer;
  List<ProductModel> _products = [];
  final List<_ItemRow> _itemRows = [];

  // ── intern ────────────────────────────────────────────────────────────────
  StudentModel? _selectedStudent;
  InternshipCourseModel? _selectedCourse;
  late TextEditingController _feeCtrl;
  late TextEditingController _sgstCtrl;
  late TextEditingController _cgstCtrl;
  late TextEditingController _descriptionCtrl;

  // ── terms ─────────────────────────────────────────────────────────────────
  TermsTitleModel? _selectedTerms;
  List<TermsTitleModel> _termsTitleList = [];
  bool _termsLoading = false;

  // ── screen-level loading (blocks the body until everything is ready) ─────
  bool _loadingScreen = true;

  // ── errors ─────────────────────────────────────────────────────────────────
  String? _errClient;
  String? _errItems;
  String? _errStudent;
  String? _errCourse;
  String? _errFee;
  String? _errInvoiceDate;

  @override
  void initState() {
    super.initState();
    final inv = widget.invoice;
    _invoiceType = (inv?.invoiceType == 'intern') ? 'intern' : 'client';

    // Seed controllers with whatever we already have (from the summary card,
    // if editing) so the UI isn't blank while the real fetch is in flight.
    _invoiceNumberCtrl =
        TextEditingController(text: inv?.invoiceNumber ?? _generateNumber());
    _remarkCtrl = TextEditingController(text: inv?.remark ?? '');
    _invoiceDateCtrl = TextEditingController(
        text: inv?.invoiceDate.isNotEmpty == true
            ? inv!.invoiceDate
            : DateFormat('yyyy-MM-dd').format(DateTime.now()));
    _feeCtrl = TextEditingController(text: inv?.feeAmount ?? '');
    _sgstCtrl = TextEditingController(text: inv?.sgstPercentage ?? '');
    _cgstCtrl = TextEditingController(text: inv?.cgstPercentage ?? '');
    _descriptionCtrl = TextEditingController(text: inv?.description ?? '');

    _initializeScreen();
  }

  @override
  void dispose() {
    _invoiceNumberCtrl.dispose();
    _remarkCtrl.dispose();
    _invoiceDateCtrl.dispose();
    _feeCtrl.dispose();
    _sgstCtrl.dispose();
    _cgstCtrl.dispose();
    _descriptionCtrl.dispose();
    for (final r in _itemRows) {
      r.dispose();
    }
    super.dispose();
  }

  String _generateNumber() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return 'INV-${ts.toString().substring(7)}';
  }

  // ── Null-safe "firstWhere" — returns null instead of throwing or silently
  //    falling back to the wrong item when no match is found. ───────────────
  T? _firstOrNull<T>(List<T> list, bool Function(T) test) {
    for (final item in list) {
      if (test(item)) return item;
    }
    return null;
  }

  // ── MAIN INIT FLOW ─────────────────────────────────────────────────────────
  // 1. If editing, fetch the FULL invoice detail by id (the list/summary
  //    object handed in from the invoice card is missing client/intern/
  //    course/terms/items on this API, so it can never be used for prefill).
  // 2. Load customers, products, and terms in parallel with that fetch.
  // 3. If the resolved invoice type is 'intern', wait for the student/course
  //    lists too.
  // 4. Apply everything to the form fields in one shot.
  Future<void> _initializeScreen() async {
    setState(() => _loadingScreen = true);
    setState(() => _termsLoading = true);

    try {
      final detailFuture = (widget.isEdit && widget.invoice != null)
          ? _fetchInvoiceDetail(widget.invoice!.id)
          : Future.value(widget.invoice);

      final results = await Future.wait([
        detailFuture,
        CustomerServices.getCustomers(),
        ProductServices.getProducts(),
        _fetchTermsList(),
      ]);

      final fullInvoice = results[0] as InvoiceModel?;
      _customers = results[1] as List<CustomerModel>;
      _products = results[2] as List<ProductModel>;
      _termsTitleList = results[3] as List<TermsTitleModel>;

      InternshipViewmodel? internVm;
      if (fullInvoice != null && fullInvoice.invoiceType == 'intern') {
        internVm = Provider.of<InternshipViewmodel>(context, listen: false);
        await _ensureInternListsLoaded(internVm);
      }

      if (fullInvoice != null) {
        _applyEditSelections(fullInvoice, internVm);
      }
    } catch (e) {
      debugPrint('Error initializing invoice screen: $e');
    }

    if (mounted) {
      setState(() {
        _loadingScreen = false;
        _termsLoading = false;
      });
    }
  }

  // NOTE: InvoiceViewmodel does not expose a `getInvoiceById` method — it
  // only loads/holds `invoiceList` via `getAllInvoices()`. Rather than
  // calling a non-existent method, we resolve the invoice from the
  // viewmodel's already-loaded (or freshly-loaded) `invoiceList` by id.
  //
  // If your backend's list endpoint returns "thin" invoice objects (missing
  // client/intern/course/terms/items), this will only be a true fix once
  // `InvoiceServices`/`InvoiceViewmodel` expose a real detail endpoint. Until
  // then this at least compiles correctly and uses the freshest data
  // available without touching invoice_viewmodel.dart.
  Future<InvoiceModel?> _fetchInvoiceDetail(int id) async {
    final vm = Provider.of<InvoiceViewmodel>(context, listen: false);

    if (vm.invoiceList.isEmpty && !vm.getInvoiceLoader) {
      await vm.getAllInvoices();
    } else {
      while (vm.getInvoiceLoader) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }

    final found = _firstOrNull(vm.invoiceList, (inv) => inv.id == id);
    // Fall back to the summary object only if not found — better to show
    // partial data than nothing.
    return found ?? widget.invoice;
  }

  Future<List<TermsTitleModel>> _fetchTermsList() async {
    try {
      final termsVm = Provider.of<TermsViewmodel>(context, listen: false);
      if (termsVm.termsTitleList.isNotEmpty) {
        return List.from(termsVm.termsTitleList);
      }
      await termsVm.getAllTermsTitle();
      return List.from(termsVm.termsTitleList);
    } catch (_) {
      try {
        return await TermsServices.getTermsTitle();
      } catch (_) {
        return [];
      }
    }
  }

  Future<void> _ensureInternListsLoaded(InternshipViewmodel internVm) async {
    if (internVm.studentList.isEmpty && !internVm.getStudentsLoader) {
      await internVm.getAllStudents();
    } else {
      while (internVm.getStudentsLoader) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }
    if (internVm.courseList.isEmpty && !internVm.getCoursesLoader) {
      await internVm.getAllCourses();
    } else {
      while (internVm.getCoursesLoader) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }
  }

  // ── Apply the fetched full invoice onto the form state ────────────────────
  void _applyEditSelections(InvoiceModel inv, InternshipViewmodel? internVm) {
    _invoiceType = inv.invoiceType == 'intern' ? 'intern' : 'client';

    if (inv.invoiceNumber.isNotEmpty) {
      _invoiceNumberCtrl.text = inv.invoiceNumber;
    }
    _remarkCtrl.text = inv.remark;
    if (inv.invoiceDate.isNotEmpty) _invoiceDateCtrl.text = inv.invoiceDate;
    _feeCtrl.text = inv.feeAmount;
    _sgstCtrl.text = inv.sgstPercentage;
    _cgstCtrl.text = inv.cgstPercentage;
    _descriptionCtrl.text = inv.description;

    if (_invoiceType == 'client') {
      if (inv.client != null) {
        _selectedCustomer =
            _firstOrNull(_customers, (c) => c.customerId == inv.client);
      }

      for (final r in _itemRows) {
        r.dispose();
      }
      _itemRows.clear();

      for (final item in inv.items) {
        final row = _ItemRow();
        row.quantityCtrl.text = item.quantity;
        row.unitPriceCtrl.text = item.unitPrice;
        row.sgstCtrl.text = item.sgstPercentage;
        row.cgstCtrl.text = item.cgstPercentage;
        if (item.product != null) {
          row.selectedProduct =
              _firstOrNull(_products, (p) => p.productId == item.product);
        }
        _itemRows.add(row);
      }
    } else {
      if (internVm != null) {
        if (inv.intern != null) {
          _selectedStudent =
              _firstOrNull(internVm.studentList, (s) => s.id == inv.intern);
        }
        if (inv.course != null) {
          _selectedCourse =
              _firstOrNull(internVm.courseList, (c) => c.id == inv.course);
        }
      }
    }

    if (inv.termsAndConditions != null) {
      _selectedTerms = _firstOrNull(
          _termsTitleList, (t) => t.titleId == inv.termsAndConditions);
    }
  }

  Future<void> _pickDate() async {
    DateTime initial;
    try {
      initial = DateFormat('yyyy-MM-dd').parse(_invoiceDateCtrl.text);
    } catch (_) {
      initial = DateTime.now();
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.c1),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _invoiceDateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      if (_errInvoiceDate != null) setState(() => _errInvoiceDate = null);
    }
  }

  void _onCourseSelected(InternshipCourseModel? course) {
    setState(() {
      _selectedCourse = course;
      if (course != null) {
        _feeCtrl.text = course.totalFee;
        _sgstCtrl.text = course.sgst.toString();
        _cgstCtrl.text = course.cgst.toString();
      } else {
        _feeCtrl.clear();
        _sgstCtrl.clear();
        _cgstCtrl.clear();
      }
      if (_errCourse != null) _errCourse = null;
    });
  }

  // ── SUBMIT ────────────────────────────────────────────────────────────────
  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();

    String? clientErr;
    String? itemsErr;
    String? studentErr;
    String? courseErr;
    String? feeErr;
    String? dateErr;

    if (_invoiceDateCtrl.text.trim().isEmpty) {
      dateErr = 'Invoice date is required';
    }

    if (_invoiceType == 'client') {
      if (_selectedCustomer == null) clientErr = 'Please select a client';
      if (_itemRows.isEmpty) {
        itemsErr = 'Add at least one product';
      } else {
        for (int i = 0; i < _itemRows.length; i++) {
          final r = _itemRows[i];
          if (r.selectedProduct == null) {
            itemsErr = 'Select a product for item ${i + 1}';
            break;
          }
          if (r.quantityCtrl.text.trim().isEmpty) {
            itemsErr = 'Enter quantity for item ${i + 1}';
            break;
          }
          if (r.unitPriceCtrl.text.trim().isEmpty) {
            itemsErr = 'Enter unit price for item ${i + 1}';
            break;
          }
        }
      }
    } else {
      if (_selectedStudent == null) studentErr = 'Please select a student';
      if (_selectedCourse == null) courseErr = 'Please select a course';
      if (_feeCtrl.text.trim().isEmpty) feeErr = 'Fee amount is required';
    }

    setState(() {
      _errClient = clientErr;
      _errItems = itemsErr;
      _errStudent = studentErr;
      _errCourse = courseErr;
      _errFee = feeErr;
      _errInvoiceDate = dateErr;
    });

    if ([clientErr, itemsErr, studentErr, courseErr, feeErr, dateErr]
        .any((e) => e != null)) {
      return;
    }

    final vm = Provider.of<InvoiceViewmodel>(context, listen: false);

    if (_invoiceType == 'client') {
      final items = _itemRows.map((r) {
        return {
          'product': r.selectedProduct!.productId,
          'quantity': r.quantityCtrl.text.trim(),
          'unit_price': r.unitPriceCtrl.text.trim(),
          'sgst_percentage':
              r.sgstCtrl.text.trim().isEmpty ? '0' : r.sgstCtrl.text.trim(),
          'cgst_percentage':
              r.cgstCtrl.text.trim().isEmpty ? '0' : r.cgstCtrl.text.trim(),
        };
      }).toList();

      if (widget.isEdit && widget.invoice != null) {
        await vm.editClientInvoice(
          widget.invoice!.id,
          items: items,
          remark: _remarkCtrl.text.trim(),
          context: context,
          onSuccess: () => Navigator.pop(context),
        );
      } else {
        await vm.createClientInvoice(
          invoiceNumber: _invoiceNumberCtrl.text.trim(),
          invoiceDate: _invoiceDateCtrl.text.trim(),
          clientId: _selectedCustomer!.customerId,
          items: items,
          remark: _remarkCtrl.text.trim(),
          termsAndConditions: _selectedTerms?.titleId,
          context: context,
          onSuccess: () => Navigator.pop(context),
        );
      }
    } else {
      if (widget.isEdit && widget.invoice != null) {
        await vm.editInternInvoice(
          widget.invoice!.id,
          feeAmount: _feeCtrl.text.trim(),
          sgstPercentage:
              _sgstCtrl.text.trim().isEmpty ? '0' : _sgstCtrl.text.trim(),
          cgstPercentage:
              _cgstCtrl.text.trim().isEmpty ? '0' : _cgstCtrl.text.trim(),
          remark: _remarkCtrl.text.trim(),
          context: context,
          onSuccess: () => Navigator.pop(context),
        );
      } else {
        await vm.createInternInvoice(
          invoiceNumber: _invoiceNumberCtrl.text.trim(),
          invoiceDate: _invoiceDateCtrl.text.trim(),
          studentId: _selectedStudent!.id,
          courseId: _selectedCourse!.id,
          feeAmount: _feeCtrl.text.trim(),
          sgstPercentage:
              _sgstCtrl.text.trim().isEmpty ? '0' : _sgstCtrl.text.trim(),
          cgstPercentage:
              _cgstCtrl.text.trim().isEmpty ? '0' : _cgstCtrl.text.trim(),
          remark: _remarkCtrl.text.trim(),
          description: _descriptionCtrl.text.trim(),
          termsAndConditions: _selectedTerms?.titleId,
          context: context,
          onSuccess: () => Navigator.pop(context),
        );
      }
    }
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;
    final vm = context.watch<InvoiceViewmodel>();

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            _buildHeader(sw, topPad),
            Expanded(
              child: _loadingScreen
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.c1))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (!widget.isEdit) ...[
                            _buildTypeToggle(),
                            const SizedBox(height: 10),
                          ],
                          _buildSection(
                            title: 'Invoice Details',
                            icon: Icons.description_outlined,
                            children: _invoiceDetailFields(),
                          ),
                          const SizedBox(height: 10),
                          if (_invoiceType == 'client') ...[
                            _buildSection(
                              title: 'Client',
                              icon: Icons.business_rounded,
                              children: [_clientDropdown()],
                            ),
                            const SizedBox(height: 10),
                            _buildSection(
                              title: 'Invoice Items',
                              icon: Icons.inventory_2_outlined,
                              children: [_itemsSection()],
                            ),
                          ] else ...[
                            _buildSection(
                              title: 'Student Details',
                              icon: Icons.school_rounded,
                              children: _studentFields(),
                            ),
                          ],
                          const SizedBox(height: 10),
                          _buildSection(
                            title: 'Terms & Conditions',
                            icon: Icons.article_outlined,
                            children: [_termsSection()],
                          ),
                          const SizedBox(height: 10),
                          _buildSection(
                            title: 'Remark',
                            icon: Icons.notes_outlined,
                            children: [_remarkSection()],
                          ),
                          const SizedBox(height: 20),
                          _buildSaveBar(vm),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).padding.bottom + 16),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── APP BAR / HEADER ──────────────────────────────────────────────────────
  Widget _buildHeader(double sw, double topPad) {
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
              Text(
                widget.isEdit ? 'Edit Invoice' : 'New Invoice',
                style: const TextStyle(
                    color: AppColors.cdark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800),
              ),
              Text(
                widget.isEdit
                    ? 'Update invoice details'
                    : 'Fill in the details to generate an invoice',
                style: const TextStyle(color: AppColors.ctext, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── TYPE TOGGLE ───────────────────────────────────────────────────────────
  Widget _buildTypeToggle() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xffF3F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _typeTab('client', 'Client Invoice', Icons.business_rounded),
          _typeTab('intern', 'Student Invoice', Icons.school_rounded),
        ],
      ),
    );
  }

  Widget _typeTab(String type, String label, IconData icon) {
    final selected = _invoiceType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _invoiceType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: selected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: selected
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 14, color: selected ? AppColors.c1 : AppColors.ctext),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.c1 : AppColors.ctext,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── SECTION WRAPPER ───────────────────────────────────────────────────────
  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cborder),
        boxShadow: [
          BoxShadow(
              color: AppColors.c1.withValues(alpha: 0.06),
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
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cdark)),
            ],
          ),
          const Divider(height: 20, thickness: 1, color: AppColors.cborder),
          ...children,
        ],
      ),
    );
  }

  // ── INVOICE DETAIL FIELDS ─────────────────────────────────────────────────
  List<Widget> _invoiceDetailFields() {
    return [
      _field(
        _invoiceNumberCtrl,
        'Invoice Number',
        Icons.tag,
        isEnabled: false,
      ),
      _field(
        _invoiceDateCtrl,
        'Invoice Date',
        Icons.calendar_today,
        isRequired: true,
        error: _errInvoiceDate,
        readOnly: true,
        onTap: _pickDate,
        customSuffix: const Icon(Icons.keyboard_arrow_down_rounded,
            color: AppColors.c1, size: 20),
      ),
    ];
  }

  // ── CLIENT DROPDOWN ───────────────────────────────────────────────────────
  Widget _clientDropdown() {
    final hasError = _errClient != null;
    return _dropdownWrap(
      error: _errClient,
      child: DropdownButtonFormField<CustomerModel>(
        initialValue: _selectedCustomer,
        isExpanded: true,
        dropdownColor: AppColors.white,
        icon: const SizedBox.shrink(),
        style: const TextStyle(
            fontSize: 14, color: AppColors.cdark, fontWeight: FontWeight.w500),
        hint: Text('Select Client',
            style: TextStyle(
                fontSize: 13,
                color: hasError
                    ? AppColors.red.withValues(alpha: 0.70)
                    : AppColors.ctext.withValues(alpha: 0.55))),
        items: _customers.map((c) {
          final name = '${c.firstName} ${c.lastName}'.trim();
          return DropdownMenuItem(
            value: c,
            child: Text(name.isEmpty ? c.companyName : name,
                style: const TextStyle(color: AppColors.cdark, fontSize: 14)),
          );
        }).toList(),
        onChanged: (val) {
          setState(() {
            _selectedCustomer = val;
            if (_errClient != null) _errClient = null;
          });
        },
        decoration: _dropdownDecoration('Client', Icons.person,
            isRequired: true, hasError: hasError),
      ),
    );
  }

  // ── ITEMS SECTION ─────────────────────────────────────────────────────────
  Widget _itemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Products',
                style: TextStyle(
                    color: AppColors.ctext,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            GestureDetector(
              onTap: () {
                setState(() {
                  _itemRows.add(_ItemRow());
                  if (_errItems != null) _errItems = null;
                });
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: AppColors.cxl,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cborder)),
                child: const Icon(Icons.add, color: AppColors.c1, size: 18),
              ),
            ),
          ],
        ),
        if (_errItems != null) ...[
          const SizedBox(height: 4),
          _errorRow(_errItems!),
        ],
        const SizedBox(height: 10),
        if (_itemRows.isEmpty)
          Container(
            height: 90,
            width: double.infinity,
            decoration: BoxDecoration(
                color: AppColors.cxl,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cborder)),
            child: const Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.shopping_cart_outlined,
                    color: AppColors.c1, size: 26),
                SizedBox(height: 8),
                Text('No products added',
                    style: TextStyle(
                        color: AppColors.ctext,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text('Tap + to add items',
                    style: TextStyle(color: AppColors.ctext, fontSize: 11)),
              ]),
            ),
          )
        else
          ..._itemRows.asMap().entries.map(
                (e) => _itemCard(e.key, e.value),
              ),
      ],
    );
  }

  Widget _itemCard(int index, _ItemRow row) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cxl,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cborder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.cborder)),
                child: Center(
                  child: Text('${index + 1}',
                      style: const TextStyle(
                          color: AppColors.c1,
                          fontSize: 11,
                          fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 8),
              Text('Item ${index + 1}',
                  style: const TextStyle(
                      color: AppColors.cdark,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  row.dispose();
                  setState(() => _itemRows.removeAt(index));
                },
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.remove_rounded,
                      size: 14, color: AppColors.red),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<ProductModel>(
            initialValue: row.selectedProduct,
            isExpanded: true,
            dropdownColor: AppColors.white,
            icon: const SizedBox.shrink(),
            style: const TextStyle(fontSize: 13, color: AppColors.cdark),
            hint: const Text('Select product',
                style: TextStyle(color: AppColors.ctext, fontSize: 12)),
            items: _products.map((p) {
              return DropdownMenuItem(
                value: p,
                child: Text(p.productName,
                    style:
                        const TextStyle(color: AppColors.cdark, fontSize: 13)),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                row.selectedProduct = val;
                if (val != null) {
                  row.unitPriceCtrl.text = val.unitPrice;
                  row.sgstCtrl.text = val.sgst;
                  row.cgstCtrl.text = val.cgst;
                }
              });
            },
            decoration:
                _dropdownDecoration('Product', Icons.inventory_2_outlined),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: _fieldInline(row.quantityCtrl, 'Quantity', Icons.numbers,
                  keyboardType: TextInputType.number),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _fieldInline(
                  row.unitPriceCtrl, 'Unit Price', Icons.currency_rupee_rounded,
                  keyboardType: TextInputType.number),
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: _fieldInline(row.sgstCtrl, 'SGST %', Icons.percent,
                  keyboardType: TextInputType.number),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _fieldInline(row.cgstCtrl, 'CGST %', Icons.percent,
                  keyboardType: TextInputType.number),
            ),
          ]),
        ],
      ),
    );
  }

  // ── STUDENT FIELDS ────────────────────────────────────────────────────────
  List<Widget> _studentFields() {
    return [
      Consumer<InternshipViewmodel>(
        builder: (context, internVm, _) {
          if (internVm.getStudentsLoader || internVm.getCoursesLoader) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(color: AppColors.c1),
            );
          }

          // Re-resolve by id against the live list each build. Dropdown
          // `value` must be `==` to one of the objects in `items`; if the
          // provider list is rebuilt with new instances after our initial
          // match, the stale object reference would otherwise render blank.
          final resolvedStudent = _selectedStudent == null
              ? null
              : _firstOrNull(
                  internVm.studentList, (s) => s.id == _selectedStudent!.id);
          final resolvedCourse = _selectedCourse == null
              ? null
              : _firstOrNull(
                  internVm.courseList, (c) => c.id == _selectedCourse!.id);

          return Column(
            children: [
              _dropdownWrap(
                error: _errStudent,
                child: DropdownButtonFormField<StudentModel>(
                  initialValue: resolvedStudent,
                  isExpanded: true,
                  dropdownColor: AppColors.white,
                  icon: const SizedBox.shrink(),
                  hint: Text('Select Student',
                      style: TextStyle(
                          fontSize: 13,
                          color: _errStudent != null
                              ? AppColors.red.withValues(alpha: 0.70)
                              : AppColors.ctext.withValues(alpha: 0.55))),
                  items: internVm.studentList.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(s.fullName,
                              style: const TextStyle(
                                  color: AppColors.cdark,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          Text('${s.studentId} · ${s.centerName}',
                              style: const TextStyle(
                                  color: AppColors.ctext, fontSize: 10)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() {
                    _selectedStudent = val;
                    if (_errStudent != null) _errStudent = null;
                  }),
                  decoration: _dropdownDecoration(
                      'Student', Icons.person_rounded,
                      isRequired: true, hasError: _errStudent != null),
                ),
              ),
              _dropdownWrap(
                error: _errCourse,
                child: DropdownButtonFormField<InternshipCourseModel>(
                  initialValue: resolvedCourse,
                  isExpanded: true,
                  dropdownColor: AppColors.white,
                  icon: const SizedBox.shrink(),
                  hint: Text('Select Course',
                      style: TextStyle(
                          fontSize: 13,
                          color: _errCourse != null
                              ? AppColors.red.withValues(alpha: 0.70)
                              : AppColors.ctext.withValues(alpha: 0.55))),
                  items: internVm.courseList.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(c.title,
                              style: const TextStyle(
                                  color: AppColors.cdark,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          Text(
                              '₹${c.totalFee}  ·  GST ${c.totalTaxPercentage}%',
                              style: const TextStyle(
                                  color: AppColors.ctext, fontSize: 10)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: _onCourseSelected,
                  decoration: _dropdownDecoration(
                      'Course', Icons.menu_book_rounded,
                      isRequired: true, hasError: _errCourse != null),
                ),
              ),
            ],
          );
        },
      ),
      _field(_feeCtrl, 'Fee Amount', Icons.currency_rupee_rounded,
          isRequired: true,
          keyboardType: TextInputType.number,
          error: _errFee, onChanged: (_) {
        if (_errFee != null) setState(() => _errFee = null);
      }),
      Row(children: [
        Expanded(
          child: _fieldInline(_sgstCtrl, 'SGST %', Icons.percent,
              keyboardType: TextInputType.number),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _fieldInline(_cgstCtrl, 'CGST %', Icons.percent,
              keyboardType: TextInputType.number),
        ),
      ]),
      const SizedBox(height: 12),
      _field(_descriptionCtrl, 'Description', Icons.notes_outlined,
          maxLines: 2),
    ];
  }

  // ── TERMS SECTION ──────────────────────────────────────────────────────────
  Widget _termsSection() {
    return _dropdownWrap(
      child: TextField(
        key: ValueKey(_selectedTerms?.titleId),
        controller: TextEditingController(text: _selectedTerms?.title ?? ''),
        readOnly: true,
        style: const TextStyle(fontSize: 14, color: AppColors.ctext),
        decoration: _inputDecoration(
          'Terms & Conditions (optional)',
          Icons.article,
          customSuffix: _termsLoading
              ? const Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.c1),
                  ),
                )
              : const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 20, color: AppColors.c1),
        ),
        onTap: _termsLoading ? null : _showTermsBottomSheet,
      ),
    );
  }

  void _showTermsBottomSheet() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        decoration: BoxDecoration(
            color: AppColors.cxl,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: AppColors.cborder, width: 1.5)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text('Terms & Conditions',
                style: TextStyle(
                    color: AppColors.cdark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
            const Divider(color: AppColors.cborder),
            // None option
            ListTile(
              leading:
                  const Icon(Icons.block, color: AppColors.ctext, size: 18),
              title: const Text('None',
                  style: TextStyle(color: AppColors.ctext, fontSize: 14)),
              onTap: () {
                setState(() => _selectedTerms = null);
                Navigator.pop(ctx);
              },
            ),
            if (_termsTitleList.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No terms available',
                    style: TextStyle(color: AppColors.ctext, fontSize: 13)),
              )
            else
              ..._termsTitleList.map(
                (t) => ListTile(
                  leading: const Icon(Icons.article_outlined,
                      color: AppColors.c1, size: 18),
                  title: Text(t.title,
                      style: const TextStyle(
                          color: AppColors.cdark,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  trailing: _selectedTerms?.titleId == t.titleId
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppColors.c1, size: 18)
                      : null,
                  onTap: () {
                    setState(() => _selectedTerms = t);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── REMARK ────────────────────────────────────────────────────────────────
  Widget _remarkSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _remarkCtrl,
        maxLines: 4,
        cursorColor: AppColors.c1,
        style: const TextStyle(fontSize: 14, color: AppColors.ctext),
        decoration: _inputDecoration('Remark', Icons.notes),
      ),
    );
  }

  // ── SAVE BAR ──────────────────────────────────────────────────────────────
  Widget _buildSaveBar(InvoiceViewmodel vm) {
    final isLoading = vm.createInvoiceLoader || vm.editInvoiceLoader;
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
                  color: AppColors.c1.withValues(alpha: 0.30),
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
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                          widget.isEdit
                              ? Icons.check_rounded
                              : Icons.save_outlined,
                          color: AppColors.white,
                          size: 18),
                      const SizedBox(width: 8),
                      Text(widget.isEdit ? 'Save Changes' : 'Save Invoice',
                          style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ── DECORATION HELPERS ────────────────────────────────────────────────────
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
      labelStyle: TextStyle(
          fontSize: 13,
          color: hasError ? AppColors.red : AppColors.ctext.withValues(alpha: 0.75)),
      prefixIcon:
          Icon(icon, size: 18, color: hasError ? AppColors.red : AppColors.c1),
      suffixIcon: customSuffix ??
          (isRequired
              ? const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.circle, size: 6, color: AppColors.red),
                )
              : null),
      suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      filled: true,
      fillColor: !isEnabled
          ? AppColors.cxl.withValues(alpha: 0.5)
          : hasError
              ? AppColors.red.withValues(alpha: 0.04)
              : AppColors.cxl,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
            color:
                hasError ? AppColors.red.withValues(alpha: 0.60) : AppColors.cborder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
            color:
                hasError ? AppColors.red.withValues(alpha: 0.60) : AppColors.cborder),
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
      labelStyle: TextStyle(
          fontSize: 13,
          color: hasError ? AppColors.red : AppColors.ctext.withValues(alpha: 0.75)),
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
      fillColor: hasError ? AppColors.red.withValues(alpha: 0.04) : AppColors.cxl,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
            color:
                hasError ? AppColors.red.withValues(alpha: 0.60) : AppColors.cborder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
            color:
                hasError ? AppColors.red.withValues(alpha: 0.60) : AppColors.cborder),
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

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isRequired = false,
    bool isEnabled = true,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? error,
    void Function(String)? onChanged,
    VoidCallback? onTap,
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
            readOnly: readOnly,
            keyboardType: keyboardType,
            maxLines: maxLines,
            cursorColor: AppColors.c1,
            onChanged: onChanged,
            onTap: onTap,
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

  Widget _fieldInline(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13, color: AppColors.cdark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.ctext),
        prefixIcon: Icon(icon, size: 15, color: AppColors.c1),
        filled: true,
        fillColor: AppColors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cborder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cborder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.c1, width: 1.5),
        ),
      ),
    );
  }
}

// ── ITEM ROW HELPER ───────────────────────────────────────────────────────────
class _ItemRow {
  ProductModel? selectedProduct;
  final TextEditingController quantityCtrl = TextEditingController();
  final TextEditingController unitPriceCtrl = TextEditingController();
  final TextEditingController sgstCtrl = TextEditingController();
  final TextEditingController cgstCtrl = TextEditingController();

  void dispose() {
    quantityCtrl.dispose();
    unitPriceCtrl.dispose();
    sgstCtrl.dispose();
    cgstCtrl.dispose();
  }
}
