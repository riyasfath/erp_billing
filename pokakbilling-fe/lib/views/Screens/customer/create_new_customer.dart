import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:pokakbilling/models/data-models/customer_model.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/viewmodels/customer_viewmodel.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
import 'package:provider/provider.dart';

class CreateNewCustomer extends StatelessWidget {
  final bool isEdit;
  final CustomerModel? customer;

  const CreateNewCustomer({super.key, required this.isEdit, this.customer});

  @override
  Widget build(BuildContext context) {
    return _CreateNewCustomerBody(isEdit: isEdit, customer: customer);
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

  String _selectedModuleType = 'client';
  LeadModel? _selectedLead;

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
  late TextEditingController gstNumberTextController;

  // ── Manual field errors (only set on button click) ────────────────────────
  String? _errModuleType;
  String? _errLead;
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

    _selectedModuleType = widget.customer?.moduleType ?? 'client';

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
        TextEditingController(text: widget.customer?.phone ?? '');
    mobileTextController =
        TextEditingController(text: widget.customer?.mobile ?? '');
    countryTextController =
        TextEditingController(text: widget.customer?.country ?? '');
    stateTextController =
        TextEditingController(text: widget.customer?.state ?? '');
    salesPersonTextController =
        TextEditingController(text: widget.customer?.salesPersonName ?? '');
    gstNumberTextController =
        TextEditingController(text: widget.customer?.gstNumber ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final salesVM = Provider.of<SalesPersonViewmodel>(context, listen: false);
      final leadVM = Provider.of<LeadViewmodel>(context, listen: false);

      if (salesVM.salesPersonList.isEmpty) {
        await salesVM.getAllSalesPerson();
      }

      if (!mounted) return;

      if (widget.isEdit && widget.customer != null) {
        salesVM.updateSelectedSalesPersonId(widget.customer!.salesPersonId);

        if (widget.customer!.moduleType == 'lead' &&
            widget.customer!.leadId != null &&
            leadVM.leadList.isNotEmpty) {
          LeadModel? match;
          for (final l in leadVM.leadList) {
            if (l.leadId == widget.customer!.leadId) {
              match = l;
              break;
            }
          }
          if (mounted && match != null) {
            setState(() => _selectedLead = match);
          }
        }
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
    gstNumberTextController.dispose();
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
      return c.email.trim().toLowerCase() == normalised;
    });
  }

  bool _isMobileDuplicate(String value, List<CustomerModel> customerList) {
    if (value.trim().isEmpty) return false;
    return customerList.any((c) {
      if (widget.isEdit && c.customerId == widget.customer?.customerId) {
        return false;
      }
      return c.mobile.trim() == value.trim();
    });
  }

  bool _isPhoneDuplicate(String value, List<CustomerModel> customerList) {
    if (value.trim().isEmpty) return false;
    return customerList.any((c) {
      if (widget.isEdit && c.customerId == widget.customer?.customerId) {
        return false;
      }
      return c.phone.trim() == value.trim();
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

  String? _validateLead() {
    if (_selectedModuleType == 'lead' && _selectedLead == null) {
      return 'Please choose a lead to link with this customer';
    }
    return null;
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  void _handleSubmit(
    CustomerViewmodel customerVM,
    SalesPersonViewmodel salesVM,
  ) {
    // Block if duplicates are present (safety net, button should already be disabled)
    if (_hasDuplicates) return;

    final leadErr = _validateLead();
    final firstErr = _validateFirstName(firstNameTextController.text);
    final lastErr = _validateLastName(lastNameTextController.text);
    final countryErr = _validateCountry(countryTextController.text);
    final stateErr = _validateState(stateTextController.text);
    final emailErr = _validateEmail(emailIdTextController.text);
    final phoneErr = _validatePhone(phoneTextController.text);
    final mobileErr = _validateMobile(mobileTextController.text);
    final salesErr = (salesVM.selectedSalesPersonId == 0)
        ? 'Sales person is required'
        : null;

    setState(() {
      _errModuleType = null;
      _errLead = leadErr;
      _errFirstName = firstErr;
      _errLastName = lastErr;
      _errCountry = countryErr;
      _errState = stateErr;
      _errEmail = emailErr;
      _errPhone = phoneErr;
      _errMobile = mobileErr;
      _errSalesPerson = salesErr;
    });

    if (leadErr != null ||
        firstErr != null ||
        lastErr != null ||
        countryErr != null ||
        stateErr != null ||
        emailErr != null ||
        phoneErr != null ||
        mobileErr != null ||
        salesErr != null) {
      return;
    }

    final leadId = _selectedModuleType == 'lead' ? _selectedLead?.leadId : null;

    if (widget.isEdit) {
      customerVM.editCustomer(
        customerId: widget.customer!.customerId,
        moduleType: _selectedModuleType,
        firstName: firstNameTextController.text.trim(),
        lastName: lastNameTextController.text.trim(),
        companyName: companyNameTextController.text.trim(),
        country: countryTextController.text.trim(),
        state: stateTextController.text.trim(),
        address: addressTextController.text.trim(),
        email: emailIdTextController.text.trim(),
        phone: phoneTextController.text.trim(),
        mobile: mobileTextController.text.trim(),
        salesPersonId: salesVM.selectedSalesPersonId,
        gstNumber: gstNumberTextController.text.trim(),
        leadId: leadId,
        context: context,
      );
    } else {
      customerVM.createCustomer(
        moduleType: _selectedModuleType,
        firstName: firstNameTextController.text.trim(),
        lastName: lastNameTextController.text.trim(),
        companyName: companyNameTextController.text.trim(),
        country: countryTextController.text.trim(),
        state: stateTextController.text.trim(),
        address: addressTextController.text.trim(),
        email: emailIdTextController.text.trim(),
        phone: phoneTextController.text.trim(),
        mobile: mobileTextController.text.trim(),
        salesPersonId: salesVM.selectedSalesPersonId,
        gstNumber: gstNumberTextController.text.trim(),
        leadId: leadId,
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerViewModel = Provider.of<CustomerViewmodel>(context);
    final salesPersonViewmodel = Provider.of<SalesPersonViewmodel>(context);
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    final tenDigits = [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(10),
    ];

    return Scaffold(
      backgroundColor: ErpColors.pageBg,
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
                    padding: EdgeInsets.fromLTRB(sw * 0.04, 18, sw * 0.04,
                        MediaQuery.of(context).padding.bottom + 28),
                    child: Column(
                      children: [
                        // ── Module type ───────────────────────────────────
                        ErpFadeIn(
                          index: 0,
                          child: _buildSection(
                            icon: Icons.category_rounded,
                            color: ErpColors.cyan,
                            title: 'Module Type',
                            subtitle: 'Is this a client or a lead?',
                            children: [_buildModuleTypeToggle()],
                          ),
                        ),

                        // ── Linked lead ───────────────────────────────────
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          child: _selectedModuleType == 'lead'
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 14),
                                  child: _buildSection(
                                    icon: Icons.trending_up_rounded,
                                    color: ErpColors.violet,
                                    title: 'Select Lead',
                                    subtitle:
                                        'Link this customer to an existing lead',
                                    children: [_buildLeadDropdown()],
                                  ),
                                )
                              : const SizedBox(width: double.infinity),
                        ),
                        const SizedBox(height: 14),

                        // ── Personal details ──────────────────────────────
                        ErpFadeIn(
                          index: 1,
                          child: _buildSection(
                            icon: Icons.person_rounded,
                            color: ErpColors.blue,
                            title: 'Client Information',
                            subtitle: 'Name, company and GST',
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _field(
                                      firstNameTextController,
                                      'First Name',
                                      Icons.badge_rounded,
                                      hint: 'First name',
                                      isRequired: true,
                                      error: _errFirstName,
                                      onChanged: (_) {
                                        if (_errFirstName != null) {
                                          setState(() => _errFirstName = null);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _field(
                                      lastNameTextController,
                                      'Last Name',
                                      Icons.badge_rounded,
                                      hint: 'Last name',
                                      isRequired: true,
                                      error: _errLastName,
                                      onChanged: (_) {
                                        if (_errLastName != null) {
                                          setState(() => _errLastName = null);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              _field(
                                companyNameTextController,
                                'Company Name',
                                Icons.business_rounded,
                                hint: 'e.g. Pokak Technologies',
                                isOptional: true,
                              ),
                              _field(
                                gstNumberTextController,
                                'GST Number',
                                Icons.receipt_long_rounded,
                                hint: 'e.g. 32ABCDE1234F1Z5',
                                isOptional: true,
                                bottomGap: 0,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── Location ──────────────────────────────────────
                        ErpFadeIn(
                          index: 2,
                          child: _buildSection(
                            icon: Icons.location_on_rounded,
                            color: ErpColors.orange,
                            title: 'Location',
                            subtitle: 'Country, state and address',
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _field(
                                      countryTextController,
                                      'Country',
                                      Icons.flag_rounded,
                                      hint: 'India',
                                      color: ErpColors.orange,
                                      isRequired: true,
                                      error: _errCountry,
                                      onChanged: (_) {
                                        if (_errCountry != null) {
                                          setState(() => _errCountry = null);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _field(
                                      stateTextController,
                                      'State',
                                      Icons.location_city_rounded,
                                      hint: 'Kerala',
                                      color: ErpColors.orange,
                                      isRequired: true,
                                      error: _errState,
                                      onChanged: (_) {
                                        if (_errState != null) {
                                          setState(() => _errState = null);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              _field(
                                addressTextController,
                                'Address',
                                Icons.home_rounded,
                                hint: 'Building, street, city, PIN',
                                color: ErpColors.orange,
                                isOptional: true,
                                maxLines: 3,
                                bottomGap: 0,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── Contact ───────────────────────────────────────
                        ErpFadeIn(
                          index: 3,
                          child: _buildSection(
                            icon: Icons.contact_phone_rounded,
                            color: ErpColors.violet,
                            title: 'Contact Details',
                            subtitle: 'Checked for duplicates as you type',
                            children: [
                              // ── Email with duplicate check ────────────
                              Consumer<CustomerViewmodel>(
                                builder: (context, customerVM, _) {
                                  return _field(
                                    emailIdTextController,
                                    'Email',
                                    Icons.email_rounded,
                                    hint: 'name@company.com',
                                    color: ErpColors.violet,
                                    isOptional: true,
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
                              // ── Phone with duplicate check ────────────
                              Consumer<CustomerViewmodel>(
                                builder: (context, customerVM, _) {
                                  return _field(
                                    phoneTextController,
                                    'Phone',
                                    Icons.phone_rounded,
                                    hint: '10-digit landline / alt. number',
                                    color: ErpColors.violet,
                                    isOptional: true,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: tenDigits,
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
                                          setState(
                                              () => _phoneDuplicate = isDup);
                                        }
                                      } else if (_phoneDuplicate) {
                                        setState(
                                            () => _phoneDuplicate = false);
                                      }
                                    },
                                  );
                                },
                              ),
                              // ── Mobile with duplicate check ───────────
                              Consumer<CustomerViewmodel>(
                                builder: (context, customerVM, _) {
                                  return _field(
                                    mobileTextController,
                                    'Mobile',
                                    Icons.smartphone_rounded,
                                    hint: '10-digit mobile number',
                                    color: ErpColors.violet,
                                    isRequired: true,
                                    bottomGap: 0,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: tenDigits,
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
                                        setState(
                                            () => _mobileDuplicate = false);
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── Sales person ──────────────────────────────────
                        ErpFadeIn(
                          index: 4,
                          child: _buildSection(
                            icon: Icons.support_agent_rounded,
                            color: ErpColors.green,
                            title: 'Sales Person',
                            subtitle: 'Who handles this customer?',
                            children: [
                              _buildSalesPersonDropdown(salesPersonViewmodel),
                            ],
                          ),
                        ),

                        // ── Duplicate warning banner ──────────────────────
                        if (_hasDuplicates) ...[
                          const SizedBox(height: 14),
                          _buildDuplicateBanner(),
                        ],

                        const SizedBox(height: 22),
                        _buildSaveBar(
                          customerViewModel,
                          salesPersonViewmodel,
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

  // ── Module type toggle ────────────────────────────────────────────────────
  Widget _buildModuleTypeToggle() {
    const options = [
      ErpChoice('Client', Icons.verified_user_rounded, ErpColors.green),
      ErpChoice('Lead', Icons.trending_up_rounded, ErpColors.violet),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ErpChoiceGrid(
          columns: 2,
          options: options,
          selected: _selectedModuleType == 'lead' ? 'Lead' : 'Client',
          onSelect: (label) => setState(() {
            _selectedModuleType = label == 'Lead' ? 'lead' : 'client';
            _selectedLead = null;
            _errLead = null;
          }),
        ),
        if (_errModuleType != null) ErpErrorText(_errModuleType!),
      ],
    );
  }

  // ── Lead dropdown ──────────────────────────────────────────────────────────
  Widget _buildLeadDropdown() {
    final hasError = _errLead != null && _errLead!.isNotEmpty;

    return Consumer<LeadViewmodel>(
      builder: (context, leadVM, _) {
        if (leadVM.getLeadLoader) {
          return _statusBox(
            const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: ErpColors.violet, strokeWidth: 2),
              ),
            ),
          );
        }

        if (leadVM.leadList.isEmpty) {
          return _statusBox(
            const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 18, color: ErpColors.violet),
                SizedBox(width: 8),
                Text('No leads available',
                    style: TextStyle(
                        color: ErpColors.slate,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5)),
              ],
            ),
          );
        }

        return _dropdownWithError(
          label: 'Linked Lead',
          isRequired: true,
          error: _errLead,
          dropdown: DropdownButtonFormField<int>(
            initialValue:
                leadVM.leadList.any((l) => l.leadId == _selectedLead?.leadId)
                    ? _selectedLead?.leadId
                    : null,
            isExpanded: true,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(16),
            icon: _dropIcon(hasError, ErpColors.violet),
            style: const TextStyle(
                fontSize: 14.5,
                color: ErpColors.ink,
                fontWeight: FontWeight.w600),
            hint: Text(
              'Choose a lead',
              style: TextStyle(
                fontSize: 13.5,
                color: hasError
                    ? ErpColors.red.withValues(alpha: 0.7)
                    : ErpColors.slate.withValues(alpha: 0.7),
              ),
            ),
            items: leadVM.leadList.map((l) {
              final name = l.name.isNotEmpty ? l.name : 'Lead #${l.leadId}';
              final company = (l.company != null && l.company!.isNotEmpty)
                  ? ' · ${l.company}'
                  : '';
              return DropdownMenuItem(
                value: l.leadId,
                child: Text('$name$company',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: ErpColors.ink,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
              );
            }).toList(),
            onChanged: (id) {
              if (id == null) return;
              setState(() {
                _selectedLead = leadVM.leadList.firstWhere(
                  (l) => l.leadId == id,
                );
                _errLead = null;
              });
            },
            decoration: erpInputDecoration(
              hint: '',
              icon: Icons.trending_up_rounded,
              hasError: hasError,
              color: ErpColors.violet,
            ),
          ),
        );
      },
    );
  }

  Widget _statusBox(Widget child) => Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: ErpColors.pageBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ErpColors.line),
        ),
        child: child,
      );

  Widget _dropIcon(bool hasError, Color color) => Container(
        width: 26,
        height: 26,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: (hasError ? ErpColors.red : color).withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.keyboard_arrow_down_rounded,
            color: hasError ? ErpColors.red : ErpColors.shade(color, 0.15),
            size: 19),
      );

  // ── Duplicate warning banner ──────────────────────────────────────────────
  Widget _buildDuplicateBanner() {
    final List<String> conflicts = [];
    if (_emailDuplicate) conflicts.add('email');
    if (_mobileDuplicate) conflicts.add('mobile number');
    if (_phoneDuplicate) conflicts.add('phone number');

    final conflictText = conflicts.join(', ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ErpColors.amber.withValues(alpha: 0.14),
            ErpColors.amber.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ErpColors.amber.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ErpGradientTile(
              icon: Icons.warning_amber_rounded,
              color: ErpColors.amber,
              size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Duplicate entry detected',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: ErpColors.shade(ErpColors.amber, 0.35),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'A customer with the same $conflictText already exists. '
                  'Please use a different value to proceed.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: ErpColors.shade(ErpColors.amber, 0.45),
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
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 24,
            top: topPad + 6,
            child: Transform.rotate(
              angle: -0.25,
              child: Icon(
                  widget.isEdit
                      ? Icons.manage_accounts_rounded
                      : Icons.person_add_alt_1_rounded,
                  size: 86,
                  color: Colors.white.withValues(alpha: 0.13)),
            ),
          ),
          Positioned(
            left: -26,
            bottom: -34,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: topPad + 12,
              bottom: 26,
              left: sw * 0.045,
              right: sw * 0.045,
            ),
            child: Row(
              children: [
                ErpPressable(
                  onTap: () => Navigator.pop(context),
                  child: const ErpGlassCircle(
                      icon: Icons.arrow_back_ios_new_rounded, iconSize: 19),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isEdit ? 'Edit Customer' : 'New Customer',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.isEdit
                            ? 'Update customer details'
                            : 'Fill in the details below',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section card ──────────────────────────────────────────────────────────
  Widget _buildSection({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ErpColors.line),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ErpGradientTile(icon: icon, color: color, size: 40),
              const SizedBox(width: 11),
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
                    Text(
                      subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: ErpColors.slate),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, thickness: 1, color: ErpColors.line),
          ),
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
    String? hint,
    bool isRequired = false,
    bool isOptional = false,
    Color color = ErpColors.blue,
    int maxLines = 1,
    double bottomGap = 14,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? error,
    bool isDuplicate = false,
    void Function(String)? onChanged,
  }) {
    final hasError = error != null && error.isNotEmpty;

    // Duplicates are shown in amber instead of the standard red
    InputDecoration decoration = erpInputDecoration(
      hint: hint ?? 'Enter ${label.toLowerCase()}',
      icon: icon,
      hasError: hasError && !isDuplicate,
      color: isDuplicate ? ErpColors.amber : color,
    );
    if (isDuplicate) {
      OutlineInputBorder b(double w) => OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: ErpColors.amber.withValues(alpha: w == 1 ? 0.7 : 1),
                width: w),
          );
      decoration = decoration.copyWith(
        fillColor: ErpColors.amber.withValues(alpha: 0.06),
        enabledBorder: b(1),
        focusedBorder: b(1.6),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: bottomGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ErpFieldLabel(label, isRequired: isRequired, isOptional: isOptional),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            cursorColor: color,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            minLines: 1,
            maxLines: maxLines,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: hasError && !isDuplicate ? ErpColors.red : ErpColors.ink,
            ),
            decoration: decoration,
          ),
          if (hasError)
            isDuplicate ? _duplicateText(error) : ErpErrorText(error),
        ],
      ),
    );
  }

  Widget _duplicateText(String msg) {
    final c = ErpColors.shade(ErpColors.amber, 0.3);
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(children: [
        Icon(Icons.people_alt_rounded, size: 14, color: c),
        const SizedBox(width: 4),
        Flexible(
          child: Text(msg,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: c,
                  height: 1.4)),
        ),
      ]),
    );
  }

  // ── Dropdown with label + error ───────────────────────────────────────────
  Widget _dropdownWithError({
    required String label,
    required Widget dropdown,
    bool isRequired = false,
    String? error,
  }) {
    final hasError = error != null && error.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ErpFieldLabel(label, isRequired: isRequired),
        dropdown,
        if (hasError) ErpErrorText(error),
      ],
    );
  }

  // ── Sales Person dropdown ─────────────────────────────────────────────────
  Widget _buildSalesPersonDropdown(SalesPersonViewmodel provider) {
    final hasError = _errSalesPerson != null && _errSalesPerson!.isNotEmpty;

    if (provider.getSalesPersonLoading) {
      return _statusBox(
        const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child:
                CircularProgressIndicator(color: ErpColors.green, strokeWidth: 2),
          ),
        ),
      );
    }

    if (provider.salesPersonList.isEmpty) {
      return _statusBox(
        const Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 18, color: ErpColors.green),
            SizedBox(width: 8),
            Text('No sales persons available',
                style: TextStyle(
                    color: ErpColors.slate,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5)),
          ],
        ),
      );
    }

    final Map<String, int> nameToId = {};
    for (final sp in provider.salesPersonList) {
      final name = "${sp.firstName} ${sp.lastName}".trim();
      if (name.isNotEmpty) nameToId[name] = sp.salesPersonId;
    }

    String? selectedName;
    if (provider.selectedSalesPersonId != 0) {
      try {
        final match = provider.salesPersonList.firstWhere(
          (sp) => sp.salesPersonId == provider.selectedSalesPersonId,
        );
        final name = "${match.firstName} ${match.lastName}".trim();
        selectedName = name.isEmpty ? null : name;
      } catch (_) {
        selectedName = null;
      }
    }

    final items = nameToId.keys.toList();

    return _dropdownWithError(
      label: 'Sales Person',
      isRequired: true,
      error: _errSalesPerson,
      dropdown: DropdownButtonFormField<String>(
        initialValue: items.contains(selectedName) ? selectedName : null,
        isExpanded: true,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(16),
        icon: _dropIcon(hasError, ErpColors.green),
        style: const TextStyle(
            fontSize: 14.5, color: ErpColors.ink, fontWeight: FontWeight.w600),
        hint: Text(
          'Select sales person',
          style: TextStyle(
            fontSize: 13.5,
            color: hasError
                ? ErpColors.red.withValues(alpha: 0.7)
                : ErpColors.slate.withValues(alpha: 0.7),
          ),
        ),
        items: items.map((name) {
          return DropdownMenuItem(
            value: name,
            child: Text(name,
                style: const TextStyle(
                    color: ErpColors.ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          );
        }).toList(),
        onChanged: (v) {
          if (v == null) return;
          final id = nameToId[v];
          if (id == null) return;
          provider.updateSelectedSalesPersonId(id);
          salesPersonTextController.text = v;
          if (_errSalesPerson != null) {
            setState(() => _errSalesPerson = null);
          }
        },
        decoration: erpInputDecoration(
          hint: '',
          icon: Icons.support_agent_rounded,
          hasError: hasError,
          color: ErpColors.green,
        ),
      ),
    );
  }

  // ── Save / Edit buttons ───────────────────────────────────────────────────
  Widget _buildSaveBar(
    CustomerViewmodel customerViewModel,
    SalesPersonViewmodel salesPersonViewmodel,
  ) {
    final isLoading =
        customerViewModel.editLoading || customerViewModel.createLoading;

    return Column(
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _hasDuplicates ? 0.65 : 1,
          child: ErpPrimaryButton(
            text: _hasDuplicates
                ? 'Duplicate Entry — Cannot Save'
                : (widget.isEdit ? 'Save Changes' : 'Save Customer'),
            icon: _hasDuplicates
                ? Icons.block_rounded
                : (widget.isEdit
                    ? Icons.check_rounded
                    : Icons.person_add_alt_1_rounded),
            color: _hasDuplicates ? ErpColors.amber : null,
            loading: isLoading,
            // Disabled while a request runs or duplicates exist
            onTap: _hasDuplicates
                ? null
                : () => _handleSubmit(
                      customerViewModel,
                      salesPersonViewmodel,
                    ),
          ),
        ),
        const SizedBox(height: 12),
        ErpSecondaryButton(
          text: 'Cancel',
          onTap: isLoading ? null : () => Navigator.pop(context),
        ),
      ],
    );
  }
}