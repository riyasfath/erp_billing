import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokakbilling/models/data-models/customer_model.dart';
import 'package:pokakbilling/viewmodels/customer_viewmodel.dart';
import 'package:pokakbilling/viewmodels/customer_type_viewmodel.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/client_contract_viewmodel.dart';
import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
import 'package:pokakbilling/views/Screens/customer/contract/contract_details.dart';
import 'package:pokakbilling/views/Screens/customer/contract/view_contract.dart';
import 'package:provider/provider.dart';

class CreateNewCustomer extends StatelessWidget {
  final bool isEdit;
  final CustomerModel? customer;

  const CreateNewCustomer({super.key, required this.isEdit, this.customer});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CustomerTypeViewmodel(),
      builder: (context, _) =>
          _CreateNewCustomerBody(isEdit: isEdit, customer: customer),
    );
  }
}

class _CreateNewCustomerBody extends StatefulWidget {
  final bool isEdit;
  final CustomerModel? customer;

  const _CreateNewCustomerBody({required this.isEdit, this.customer});

  @override
  State<_CreateNewCustomerBody> createState() => _CreateNewCustomerState();
}

class _CreateNewCustomerState extends State<_CreateNewCustomerBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  late TextEditingController firstNameTextController;
  late TextEditingController lastNameTextController;
  late TextEditingController companyNameTextController;
  late TextEditingController addressTextController;
  late TextEditingController emailIdTextController;
  late TextEditingController phoneTextController;
  late TextEditingController mobileTextController;
  late TextEditingController countryTextController;
  late TextEditingController stateTextController;
  late TextEditingController salesPersonTextController;

  // ── Manual field errors (only set on button click) ────────────────────────
  String? _errContactType;
  String? _errFirstName;
  String? _errLastName;
  String? _errCountry;
  String? _errState;
  String? _errEmail;
  String? _errPhone;
  String? _errMobile;
  String? _errSalesPerson;

  // ── Duplicate flags (set by real-time duplicate check) ───────────────────
  bool _emailDuplicate = false;
  bool _mobileDuplicate = false;
  bool _phoneDuplicate = false;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();

    firstNameTextController =
        TextEditingController(text: widget.customer?.firstName ?? '');
    lastNameTextController =
        TextEditingController(text: widget.customer?.lastName ?? '');
    companyNameTextController =
        TextEditingController(text: widget.customer?.companyName ?? '');
    addressTextController =
        TextEditingController(text: widget.customer?.address ?? '');
    emailIdTextController =
        TextEditingController(text: widget.customer?.email ?? '');
    phoneTextController =
        TextEditingController(text: widget.customer?.phoneNumber ?? '');
    mobileTextController =
        TextEditingController(text: widget.customer?.mobileNumber ?? '');
    countryTextController =
        TextEditingController(text: widget.customer?.country ?? '');
    stateTextController =
        TextEditingController(text: widget.customer?.state ?? '');
    salesPersonTextController =
        TextEditingController(text: widget.customer?.salesPersonName ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final contractVM = Provider.of<ContractViewmodel>(context, listen: false);
      final salesVM = Provider.of<SalesPersonViewmodel>(context, listen: false);
      final typeVM = Provider.of<CustomerTypeViewmodel>(context, listen: false);

      contractVM.clearSelectedContract();
      await typeVM.getCustomerTypes();

      if (salesVM.salesPersonList.isEmpty) {
        await salesVM.getAllSalesPerson();
      }

      if (!mounted) return;

      if (widget.isEdit && widget.customer != null) {
        if (widget.customer!.contractId != null) {
          contractVM.selectContract(
            widget.customer!.contractId!,
            widget.customer!.contractName ?? '',
          );
        }
        salesVM.updateSelectedSalesPersonId(widget.customer!.salesPersonId);
        final existingId = widget.customer!.customerTypeId;
        if (existingId != null) typeVM.selectTypeById(existingId);
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    firstNameTextController.dispose();
    lastNameTextController.dispose();
    companyNameTextController.dispose();
    addressTextController.dispose();
    emailIdTextController.dispose();
    phoneTextController.dispose();
    mobileTextController.dispose();
    countryTextController.dispose();
    stateTextController.dispose();
    salesPersonTextController.dispose();
    super.dispose();
  }

  // ── Duplicate checkers ────────────────────────────────────────────────────

  /// Returns true if the [value] already exists in [customerList],
  /// ignoring the current customer when in edit mode.
  bool _isEmailDuplicate(String value, List<CustomerModel> customerList) {
    if (value.trim().isEmpty) return false;
    final normalised = value.trim().toLowerCase();
    return customerList.any((c) {
      // Skip self when editing
      if (widget.isEdit && c.customerId == widget.customer?.customerId) {
        return false;
      }
      return (c.email ?? '').trim().toLowerCase() == normalised;
    });
  }

  bool _isMobileDuplicate(String value, List<CustomerModel> customerList) {
    if (value.trim().isEmpty) return false;
    return customerList.any((c) {
      if (widget.isEdit && c.customerId == widget.customer?.customerId) {
        return false;
      }
      return (c.mobileNumber ?? '').trim() == value.trim();
    });
  }

  bool _isPhoneDuplicate(String value, List<CustomerModel> customerList) {
    if (value.trim().isEmpty) return false;
    return customerList.any((c) {
      if (widget.isEdit && c.customerId == widget.customer?.customerId) {
        return false;
      }
      return (c.phoneNumber ?? '').trim() == value.trim();
    });
  }

  // ── Whether the save button should be blocked ─────────────────────────────
  bool get _hasDuplicates =>
      _emailDuplicate || _mobileDuplicate || _phoneDuplicate;

  // ── Validators ────────────────────────────────────────────────────────────

  String? _validateFirstName(String v) {
    if (v.trim().isEmpty) return 'First name is required';
    if (v.trim().length < 2) return 'Must be at least 2 characters';
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(v.trim())) {
      return 'Only letters, spaces, hyphens and apostrophes allowed';
    }
    return null;
  }

  String? _validateLastName(String v) {
    if (v.trim().isEmpty) return 'Last name is required';
    if (v.trim().length < 2) return 'Must be at least 2 characters';
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(v.trim())) {
      return 'Only letters, spaces, hyphens and apostrophes allowed';
    }
    return null;
  }

  String? _validateEmail(String v) {
    if (v.trim().isEmpty) return null; // Optional field

    final hasAt = v.trim().contains('@');
    final parts = v.trim().split('@');
    final hasLocalPart = hasAt && parts[0].isNotEmpty;
    final hasDomain = hasAt && parts.length == 2 && parts[1].isNotEmpty;

    if (!hasLocalPart || !hasDomain) return 'Enter a valid email address';

    if (!parts[1].toLowerCase().endsWith('.com')) {
      return 'Only .com email addresses are accepted';
    }

    final domainWithoutCom =
        parts[1].substring(0, parts[1].toLowerCase().lastIndexOf('.com'));

    if (domainWithoutCom.isEmpty) return 'Enter a valid email address';

    return null;
  }

  String? _validatePhone(String v) {
    if (v.isEmpty) return null; // optional
    if (v.length != 10) return 'Phone number must be exactly 10 digits';
    return null;
  }

  String? _validateMobile(String v) {
    if (v.isEmpty) return 'Mobile number is required';
    if (v.length != 10) return 'Mobile number must be exactly 10 digits';
    return null;
  }

  String? _validateCountry(String v) {
    if (v.trim().isEmpty) return 'Country is required';
    if (!RegExp(r"^[a-zA-Z\s\-]+$").hasMatch(v.trim())) {
      return 'Enter a valid country name';
    }
    return null;
  }

  String? _validateState(String v) {
    if (v.trim().isEmpty) return 'State is required';
    if (!RegExp(r"^[a-zA-Z\s\-]+$").hasMatch(v.trim())) {
      return 'Enter a valid state name';
    }
    return null;
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  void _handleSubmit(
    CustomerViewmodel customerVM,
    SalesPersonViewmodel salesVM,
    ContractViewmodel contractVM,
    CustomerTypeViewmodel typeVM,
  ) {
    // Block if duplicates are present (safety net, button should already be disabled)
    if (_hasDuplicates) return;

    final typeErr = (typeVM.selectedTypeName == null ||
            typeVM.selectedTypeName!.trim().isEmpty)
        ? 'Contact type is required'
        : null;
    final firstErr = _validateFirstName(firstNameTextController.text);
    final lastErr = _validateLastName(lastNameTextController.text);
    final countryErr = _validateCountry(countryTextController.text);
    final stateErr = _validateState(stateTextController.text);
    final emailErr = _validateEmail(emailIdTextController.text);
    final phoneErr = _validatePhone(phoneTextController.text);
    final mobileErr = _validateMobile(mobileTextController.text);
    final salesErr = (salesVM.selectedSalesPersonId == 0 ||
            salesVM.selectedSalesPersonId == null)
        ? 'Sales person is required'
        : null;

    setState(() {
      _errContactType = typeErr;
      _errFirstName = firstErr;
      _errLastName = lastErr;
      _errCountry = countryErr;
      _errState = stateErr;
      _errEmail = emailErr;
      _errPhone = phoneErr;
      _errMobile = mobileErr;
      _errSalesPerson = salesErr;
    });

    if (typeErr != null ||
        firstErr != null ||
        lastErr != null ||
        countryErr != null ||
        stateErr != null ||
        emailErr != null ||
        phoneErr != null ||
        mobileErr != null ||
        salesErr != null) return;

    final typeId = typeVM.selectedTypeId;
    if (widget.isEdit) {
      customerVM.editCustomer(
        widget.customer?.customerId,
        typeId,
        firstNameTextController.text.trim(),
        lastNameTextController.text.trim(),
        companyNameTextController.text.trim(),
        emailIdTextController.text.trim(),
        phoneTextController.text.trim(),
        mobileTextController.text.trim(),
        addressTextController.text.trim(),
        stateTextController.text.trim(),
        countryTextController.text.trim(),
        salesVM.selectedSalesPersonId,
        contractVM.selectedContractId,
        context,
      );
    } else {
      customerVM.createCustomer(
        typeId,
        firstNameTextController.text.trim(),
        lastNameTextController.text.trim(),
        companyNameTextController.text.trim(),
        emailIdTextController.text.trim(),
        phoneTextController.text.trim(),
        mobileTextController.text.trim(),
        addressTextController.text.trim(),
        stateTextController.text.trim(),
        countryTextController.text.trim(),
        salesVM.selectedSalesPersonId,
        contractVM.selectedContractId,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerViewModel = Provider.of<CustomerViewmodel>(context);
    final salesPersonViewmodel = Provider.of<SalesPersonViewmodel>(context);
    final contractViewmodel = context.read<ContractViewmodel>();
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.white,
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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      children: [
                        _buildSection(
                          icon: Icons.person_outline_rounded,
                          title: 'Client Information',
                          children: [
                            _buildContactTypeDropdown(),
                            _field(
                              firstNameTextController,
                              'First Name',
                              Icons.badge_outlined,
                              isRequired: true,
                              error: _errFirstName,
                              onChanged: (_) {
                                if (_errFirstName != null) {
                                  setState(() => _errFirstName = null);
                                }
                              },
                            ),
                            _field(
                              lastNameTextController,
                              'Last Name',
                              Icons.badge_outlined,
                              isRequired: true,
                              error: _errLastName,
                              onChanged: (_) {
                                if (_errLastName != null) {
                                  setState(() => _errLastName = null);
                                }
                              },
                            ),
                            _field(
                              companyNameTextController,
                              'Company Name',
                              Icons.business_outlined,
                            ),
                            _field(
                              countryTextController,
                              'Country',
                              Icons.flag_outlined,
                              isRequired: true,
                              error: _errCountry,
                              onChanged: (_) {
                                if (_errCountry != null) {
                                  setState(() => _errCountry = null);
                                }
                              },
                            ),
                            _field(
                              stateTextController,
                              'State',
                              Icons.location_city_outlined,
                              isRequired: true,
                              error: _errState,
                              onChanged: (_) {
                                if (_errState != null) {
                                  setState(() => _errState = null);
                                }
                              },
                            ),
                            _field(
                              addressTextController,
                              'Address',
                              Icons.home_outlined,
                            ),
                            // ── Email with duplicate check ────────────────
                            Consumer<CustomerViewmodel>(
                              builder: (context, customerVM, _) {
                                return _field(
                                  emailIdTextController,
                                  'Email',
                                  Icons.email_outlined,
                                  // isRequired: true,
                                  keyboardType: TextInputType.emailAddress,
                                  error: _emailDuplicate
                                      ? 'This email is already registered'
                                      : _errEmail,
                                  isDuplicate: _emailDuplicate,
                                  onChanged: (v) {
                                    // Clear format error
                                    if (_errEmail != null) {
                                      setState(() => _errEmail = null);
                                    }
                                    // Real-time duplicate check
                                    final isDup = _isEmailDuplicate(
                                        v, customerVM.customerList);
                                    if (isDup != _emailDuplicate) {
                                      setState(() => _emailDuplicate = isDup);
                                    }
                                  },
                                );
                              },
                            ),
                            // ── Phone with duplicate check ────────────────
                            Consumer<CustomerViewmodel>(
                              builder: (context, customerVM, _) {
                                return _field(
                                  phoneTextController,
                                  'Phone',
                                  Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  error: _phoneDuplicate
                                      ? 'This phone number is already registered'
                                      : _errPhone,
                                  isDuplicate: _phoneDuplicate,
                                  onChanged: (v) {
                                    if (_errPhone != null) {
                                      setState(() => _errPhone = null);
                                    }
                                    if (v.length == 10 || v.isEmpty) {
                                      final isDup = _isPhoneDuplicate(
                                          v, customerVM.customerList);
                                      if (isDup != _phoneDuplicate) {
                                        setState(() => _phoneDuplicate = isDup);
                                      }
                                    } else if (_phoneDuplicate) {
                                      setState(() => _phoneDuplicate = false);
                                    }
                                  },
                                );
                              },
                            ),
                            // ── Mobile with duplicate check ───────────────
                            Consumer<CustomerViewmodel>(
                              builder: (context, customerVM, _) {
                                return _field(
                                  mobileTextController,
                                  'Mobile',
                                  Icons.smartphone_outlined,
                                  isRequired: true,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  error: _mobileDuplicate
                                      ? 'This mobile number is already registered'
                                      : _errMobile,
                                  isDuplicate: _mobileDuplicate,
                                  onChanged: (v) {
                                    if (_errMobile != null) {
                                      setState(() => _errMobile = null);
                                    }
                                    if (v.length == 10 || v.isEmpty) {
                                      final isDup = _isMobileDuplicate(
                                          v, customerVM.customerList);
                                      if (isDup != _mobileDuplicate) {
                                        setState(
                                            () => _mobileDuplicate = isDup);
                                      }
                                    } else if (_mobileDuplicate) {
                                      setState(() => _mobileDuplicate = false);
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildSection(
                          icon: Icons.people_outline_rounded,
                          title: 'Sales Person',
                          children: [
                            _buildSalesPersonDropdown(salesPersonViewmodel),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildSection(
                          icon: Icons.description_outlined,
                          title: 'Client Contract',
                          trailing: _contractAddBtn(context),
                          children: [_buildContractSection(context)],
                        ),

                        // ── Duplicate warning banner ──────────────────────
                        if (_hasDuplicates) ...[
                          const SizedBox(height: 14),
                          _buildDuplicateBanner(),
                        ],

                        const SizedBox(height: 20),
                        Consumer<CustomerTypeViewmodel>(
                          builder: (context, typeVM, _) => _buildSaveBar(
                            customerViewModel,
                            salesPersonViewmodel,
                            contractViewmodel,
                            typeVM,
                          ),
                        ),
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

  // ── Duplicate warning banner ──────────────────────────────────────────────
  Widget _buildDuplicateBanner() {
    final List<String> conflicts = [];
    if (_emailDuplicate) conflicts.add('email');
    if (_mobileDuplicate) conflicts.add('mobile number');
    if (_phoneDuplicate) conflicts.add('phone number');

    final conflictText = conflicts.join(', ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.red.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.red.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.red, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Duplicate entry detected',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.red,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'A client with the same $conflictText already exists. '
                  'Please use a different value to proceed.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.red.withOpacity(0.85),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, double sw, double topPad) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPad + 12,
        bottom: 28,
        left: sw * 0.03,
        right: sw * 0.04,
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
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.cxl,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cborder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.c3,
                size: 15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEdit ? 'Edit Client' : 'New Client',
                style: const TextStyle(
                  color: AppColors.cdark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                widget.isEdit
                    ? 'Update client details'
                    : 'Fill in the details below',
                style: const TextStyle(color: AppColors.ctext, fontSize: 12),
              ),
            ],
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
    Widget? trailing,
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
            color: AppColors.c1.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
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
                  border: Border.all(color: AppColors.cborder),
                ),
                child: Icon(icon, color: AppColors.c1, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cdark,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const Divider(height: 20, thickness: 1, color: AppColors.cborder),
          ...children,
        ],
      ),
    );
  }

  // ── Text field ────────────────────────────────────────────────────────────
  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isRequired = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? error,
    bool isDuplicate = false,
    void Function(String)? onChanged,
  }) {
    final hasError = error != null && error.isNotEmpty;

    // Duplicate fields get an amber tint instead of the standard red
    final Color errorColor =
        isDuplicate ? Colors.orange.shade700 : AppColors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            cursorColor: AppColors.c1,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14, color: AppColors.cdark),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                fontSize: 13,
                color: hasError
                    ? AppColors.red
                    : AppColors.ctext.withOpacity(0.75),
              ),
              prefixIcon: Icon(
                icon,
                size: 18,
                color: hasError ? errorColor : AppColors.c1,
              ),
              suffixIcon: isRequired
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(Icons.circle, size: 6, color: AppColors.red),
                    )
                  : null,
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 32, minHeight: 32),
              filled: true,
              fillColor:
                  hasError ? errorColor.withOpacity(0.04) : AppColors.cxl,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: hasError
                      ? errorColor.withOpacity(0.60)
                      : AppColors.cborder,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: hasError
                      ? errorColor.withOpacity(0.60)
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
                  color: hasError ? errorColor : AppColors.c1,
                  width: 1.5,
                ),
              ),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    isDuplicate
                        ? Icons.people_alt_outlined
                        : Icons.error_outline_rounded,
                    size: 13,
                    color: errorColor,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      error,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: errorColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Dropdown with error below ─────────────────────────────────────────────
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
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 13, color: AppColors.red),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      error,
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
            ),
        ],
      ),
    );
  }

  // ── Shared dropdown decoration ────────────────────────────────────────────
  InputDecoration _dropdownDecoration(
    String label,
    IconData icon, {
    bool isRequired = false,
    bool hasError = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: label,
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
    );
  }

  // ── Contact Type dropdown ─────────────────────────────────────────────────
  Widget _buildContactTypeDropdown() {
    final hasError = _errContactType != null && _errContactType!.isNotEmpty;

    return Consumer<CustomerTypeViewmodel>(
      builder: (context, typeVM, _) {
        if (typeVM.loading) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: SizedBox(
              height: 50,
              child: Center(
                child: CircularProgressIndicator(
                    color: AppColors.c1, strokeWidth: 2),
              ),
            ),
          );
        }

        return _dropdownWithError(
          error: _errContactType,
          dropdown: DropdownButtonFormField<String>(
            value: (typeVM.selectedTypeName?.isNotEmpty == true)
                ? typeVM.selectedTypeName
                : null,
            isExpanded: true,
            dropdownColor: AppColors.white,
            icon: const SizedBox.shrink(),
            style: const TextStyle(
                fontSize: 14,
                color: AppColors.cdark,
                fontWeight: FontWeight.w500),
            hint: Text(
              'Contact Type',
              style: TextStyle(
                fontSize: 13,
                color: hasError
                    ? AppColors.red
                    : AppColors.ctext.withOpacity(0.55),
              ),
            ),
            items: typeVM.customerTypeList.map((t) {
              return DropdownMenuItem(
                value: t.name,
                child: Text(t.name,
                    style:
                        const TextStyle(color: AppColors.cdark, fontSize: 14)),
              );
            }).toList(),
            onChanged: (v) {
              if (v == null) return;
              typeVM.selectTypeByName(v);
              if (_errContactType != null) {
                setState(() => _errContactType = null);
              }
            },
            decoration: _dropdownDecoration(
              'Contact Type',
              Icons.category_outlined,
              isRequired: true,
              hasError: hasError,
            ),
          ),
        );
      },
    );
  }

  // ── Sales Person dropdown ─────────────────────────────────────────────────
  Widget _buildSalesPersonDropdown(SalesPersonViewmodel provider) {
    final hasError = _errSalesPerson != null && _errSalesPerson!.isNotEmpty;

    if (provider.getSalesPersonLoading) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: SizedBox(
          height: 50,
          child: Center(
            child:
                CircularProgressIndicator(color: AppColors.c1, strokeWidth: 2),
          ),
        ),
      );
    }

    if (provider.salesPersonList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 16, color: AppColors.c1),
            SizedBox(width: 6),
            Text('No sales persons available',
                style: TextStyle(color: AppColors.ctext, fontSize: 13)),
          ],
        ),
      );
    }

    final Map<String, int> nameToId = {};
    for (final sp in provider.salesPersonList) {
      final name = sp.fullName.trim();
      if (name.isNotEmpty) nameToId[name] = sp.salesPersonId;
    }

    String? selectedName;
    if (provider.selectedSalesPersonId != 0) {
      try {
        final match = provider.salesPersonList.firstWhere(
          (sp) => sp.salesPersonId == provider.selectedSalesPersonId,
        );
        selectedName =
            match.fullName.trim().isEmpty ? null : match.fullName.trim();
      } catch (_) {
        selectedName = null;
      }
    }

    final items = nameToId.keys.toList();

    return _dropdownWithError(
      error: _errSalesPerson,
      dropdown: DropdownButtonFormField<String>(
        value: items.contains(selectedName) ? selectedName : null,
        isExpanded: true,
        dropdownColor: AppColors.white,
        icon: const SizedBox.shrink(),
        style: const TextStyle(
            fontSize: 14, color: AppColors.cdark, fontWeight: FontWeight.w500),
        hint: Text(
          'Select Sales Person',
          style: TextStyle(
            fontSize: 13,
            color: hasError ? AppColors.red : AppColors.ctext.withOpacity(0.55),
          ),
        ),
        items: items.map((name) {
          return DropdownMenuItem(
            value: name,
            child: Text(name,
                style: const TextStyle(color: AppColors.cdark, fontSize: 14)),
          );
        }).toList(),
        onChanged: (v) {
          if (v == null) return;
          final id = nameToId[v];
          if (id == null) return;
          provider.updateSelectedSalesPersonId(id);
          provider.selectSalesPerson(v);
          salesPersonTextController.text = v;
          if (_errSalesPerson != null) {
            setState(() => _errSalesPerson = null);
          }
        },
        decoration: _dropdownDecoration(
          'Sales Person',
          Icons.person_outline_rounded,
          isRequired: true,
          hasError: hasError,
        ),
      ),
    );
  }

  // ── Contract add button ───────────────────────────────────────────────────
  Widget _contractAddBtn(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final contractVM = context.read<ContractViewmodel>();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: contractVM,
              child: const ContractDetailsPage(),
            ),
          ),
        );
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.add_rounded, color: AppColors.c1, size: 18),
      ),
    );
  }

  // ── Contract section ──────────────────────────────────────────────────────
  Widget _buildContractSection(BuildContext context) {
    return Consumer<ContractViewmodel>(
      builder: (context, vm, _) {
        if (vm.loading) {
          return const Center(
            child:
                CircularProgressIndicator(color: AppColors.c1, strokeWidth: 2),
          );
        }
        if (vm.contractList.isEmpty) {
          return const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: AppColors.c1),
              SizedBox(width: 6),
              Text('No contract added yet',
                  style: TextStyle(
                      color: AppColors.cdark,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ],
          );
        }
        if (vm.contractList.length == 1 && vm.selectedContractId == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final c = vm.contractList.first;
            vm.selectContract(c.id!, c.name!);
          });
        }
        return Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                dropdownColor: AppColors.white,
                style: const TextStyle(color: AppColors.cdark, fontSize: 13),
                value: vm.contractList.any((c) => c.id == vm.selectedContractId)
                    ? vm.selectedContractId
                    : null,
                hint: const Text('Select Contract',
                    style: TextStyle(fontSize: 13, color: AppColors.ctext)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.cxl,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.cborder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.cborder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AppColors.c1, width: 1.5),
                  ),
                ),
                items: vm.contractList
                    .map((contract) => DropdownMenuItem<int>(
                          value: contract.id,
                          child: Text(contract.name,
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.ctext)),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  final selected =
                      vm.contractList.firstWhere((c) => c.id == value);
                  vm.selectContract(selected.id!, selected.name!);
                },
              ),
            ),
            if (vm.selectedContractId != null) ...[
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  if (vm.selectedContractId == null) return;
                  final customerId =
                      context.read<CustomerViewmodel>().selectedCustomerId;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewContractDetailsScreen(
                        contractId: vm.selectedContractId!,
                        customerId: customerId,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.c1,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cborder),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.c1.withOpacity(0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text('View',
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  // ── Save / Edit bottom bar ────────────────────────────────────────────────
  Widget _buildSaveBar(
    CustomerViewmodel customerViewModel,
    SalesPersonViewmodel salesPersonViewmodel,
    ContractViewmodel contractViewmodel,
    CustomerTypeViewmodel typeVM,
  ) {
    final isLoading =
        customerViewModel.editLoading || customerViewModel.createLoading;

    // Disable the button when duplicates exist OR when a request is in progress
    final isDisabled = isLoading || _hasDuplicates;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDisabled ? AppColors.c1.withOpacity(0.45) : AppColors.c1,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                    color: AppColors.c1.withOpacity(0.30),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: isDisabled
              ? null
              : () => _handleSubmit(
                    customerViewModel,
                    salesPersonViewmodel,
                    contractViewmodel,
                    typeVM,
                  ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
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
                      _hasDuplicates
                          ? Icons.block_rounded
                          : (widget.isEdit
                              ? Icons.check_rounded
                              : Icons.person_add_outlined),
                      color: AppColors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _hasDuplicates
                          ? 'Duplicate Entry — Cannot Save'
                          : (widget.isEdit ? 'Save Changes' : 'Save Client'),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
