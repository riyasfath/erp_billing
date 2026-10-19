import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/login_viewmodel.dart';
import 'package:pokakbilling/viewmodels/profile_viewmodel.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _dobController;
  late TextEditingController _addressController;
  String _genderValue = 'Male';

  String? _selectedImagePath;
  String _existingImageUrl = '';
  bool _isUpdating = false;
  bool _hasChanges = false;

  // ── Validation regex patterns ─────────────────────────────────────────
  static final RegExp _nameRegex = RegExp(r'^[a-zA-Z\s]+$');
  static final RegExp _phoneRegex = RegExp(r'^[6-9][0-9]{9}$');
  static final RegExp _addressRegex = RegExp(r"^[a-zA-Z0-9\s,./#\-]+$");

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final profileVm = Provider.of<ProfileViewmodel>(context, listen: false);

    String firstName = '';
    String lastName = '';
    String phoneNumber = '';
    String gender = 'Male';
    String dob = '';
    String address = '';
    String profilePicture = '';

    if (profileVm.profileList.isNotEmpty) {
      final u = profileVm.profileList.first;
      firstName = u.firstName;
      lastName = u.lastName;
      phoneNumber = u.phoneNumber;
      gender = u.gender.isNotEmpty ? u.gender : 'Male';
      dob = u.dob;
      address = u.address;
      profilePicture = u.profilePicture;
    }

    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _phoneNumberController = TextEditingController(text: phoneNumber);
    _genderValue = gender;
    _dobController = TextEditingController(text: dob);
    _addressController = TextEditingController(text: address);
    _existingImageUrl = profilePicture;

    _firstNameController.addListener(_checkChanges);
    _lastNameController.addListener(_checkChanges);
    _phoneNumberController.addListener(_checkChanges);
    _dobController.addListener(_checkChanges);
    _addressController.addListener(_checkChanges);
  }

  void _checkChanges() {
    setState(() => _hasChanges = true);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Profile Photo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cdark,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _bottomSheetOption(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(ctx);
                      _openGallery();
                    },
                  ),
                  _bottomSheetOption(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(ctx);
                      _openGallery();
                    },
                  ),
                  if (_selectedImagePath != null ||
                      _existingImageUrl.isNotEmpty)
                    _bottomSheetOption(
                      icon: Icons.delete_outline,
                      label: 'Remove',
                      color: Colors.red,
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _selectedImagePath = null;
                          _existingImageUrl = '';
                          _hasChanges = true;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomSheetOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? AppColors.c1;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: c.withOpacity(.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: c, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openGallery() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();

    if (!ps.hasAccess) {
      _showPermissionDenied();
      return;
    }

    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
      ),
    );

    if (albums.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No images found in gallery')),
      );
      return;
    }

    final List<AssetEntity> assets = await albums.first.getAssetListPaged(
      page: 0,
      size: 80,
    );

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Select Photo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.cdark,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: assets.length,
                itemBuilder: (_, index) {
                  return GestureDetector(
                    onTap: () async {
                      final File? file = await assets[index].file;
                      if (file != null) {
                        setState(() {
                          _selectedImagePath = file.path;
                          _hasChanges = true;
                        });
                      }
                      Navigator.pop(ctx);
                    },
                    child: _GalleryThumbWidget(asset: assets[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPermissionDenied() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            const Text('Permission denied. Please allow access in settings.'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: () => PhotoManager.openSetting(),
        ),
      ),
    );
  }

  Future<void> _selectGender() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Select Gender',
          style: TextStyle(
            color: AppColors.cdark,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Male', 'Female', 'Other'].map((g) {
            return RadioListTile<String>(
              title: Text(g),
              value: g,
              groupValue: _genderValue,
              activeColor: AppColors.c1,
              onChanged: (val) => Navigator.pop(ctx, val),
            );
          }).toList(),
        ),
      ),
    );

    if (selected != null && selected != _genderValue) {
      setState(() {
        _genderValue = selected;
        _hasChanges = true;
      });
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    DateTime initialDate;
    if (_dobController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(_dobController.text);
      } catch (_) {
        initialDate = DateTime(now.year - 18, now.month, now.day);
      }
    } else {
      initialDate = DateTime(now.year - 18, now.month, now.day);
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 1, now.month, now.day),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.c1,
            onPrimary: AppColors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No changes made'),
          backgroundColor: AppColors.c1.withOpacity(.8),
        ),
      );
      return;
    }

    setState(() => _isUpdating = true);

    final profileVm = Provider.of<ProfileViewmodel>(context, listen: false);

    final success = await profileVm.updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      gender: _genderValue,
      dob: _dobController.text.trim(),
      address: _addressController.text.trim(),
      imagePath: _selectedImagePath,
    );

    setState(() => _isUpdating = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.arrow_back_outlined,
                color: AppColors.cdark, size: 24),
          ),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.cdark,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          _isUpdating
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : InkWell(
                  onTap: _hasChanges ? _saveProfile : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: _hasChanges
                            ? AppColors.c1
                            : AppColors.ctext.withOpacity(.4),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildProfileImageSection(),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Basic Info'),
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _firstNameController,
                      label: 'First Name',
                      icon: Icons.badge_outlined,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z\s]')),
                        LengthLimitingTextInputFormatter(30),
                      ],
                      validator: (val) {
                        final v = val?.trim() ?? '';
                        if (v.isEmpty) return 'First name is required';
                        if (!_nameRegex.hasMatch(v)) {
                          return 'Only letters are allowed';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      icon: Icons.badge_outlined,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z\s]')),
                        LengthLimitingTextInputFormatter(30),
                      ],
                      validator: (val) {
                        final v = val?.trim() ?? '';
                        if (v.isEmpty) return 'Last name is required';
                        if (!_nameRegex.hasMatch(v)) {
                          return 'Only letters are allowed';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDisabledField(
                      label: 'Email',
                      value: Provider.of<LoginViewModel>(context, listen: false)
                              .loggedInEmail ??
                          '',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 24),
                    _sectionLabel('Contact & Personal'),
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _phoneNumberController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (val) {
                        final v = val?.trim() ?? '';
                        if (v.isEmpty) {
                          // remove this block if phone should be required
                          return null;
                        }
                        if (v.length != 10) {
                          return 'Phone number must be exactly 10 digits';
                        }
                        if (!_phoneRegex.hasMatch(v)) {
                          return 'Enter a valid number starting with 6-9';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildGenderSelector(),
                    const SizedBox(height: 16),
                    _buildDateSelector(),
                    const SizedBox(height: 24),
                    _sectionLabel('Address'),
                    const SizedBox(height: 12),
                    _buildAddressField(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.ctext.withOpacity(.5),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.c1.withOpacity(.3), width: 3),
          ),
          child: ClipOval(
            child: _selectedImagePath != null
                // newly picked local image
                ? Image.file(
                    File(_selectedImagePath!),
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  )
                : _existingImageUrl.isNotEmpty
                    // existing image from server
                    ? Image.network(
                        _existingImageUrl,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _avatarPlaceholder(),
                      )
                    : _avatarPlaceholder(),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: InkWell(
            onTap: _pickImage,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.c1,
                border: Border.all(color: AppColors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt,
                  size: 18, color: AppColors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      color: AppColors.cdark,
      child:
          Icon(Icons.person, size: 50, color: AppColors.white.withOpacity(.7)),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cborder.withOpacity(.6)),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        textCapitalization: TextCapitalization.words,
        style: const TextStyle(
            color: AppColors.cdark, fontSize: 15, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: AppColors.ctext.withOpacity(.5),
              fontSize: 13,
              fontWeight: FontWeight.w600),
          prefixIcon: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.c1.withOpacity(.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.c1),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDisabledField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cborder.withOpacity(.4)),
      ),
      child: TextFormField(
        readOnly: true,
        enabled: false,
        initialValue: value,
        style: TextStyle(
            color: AppColors.ctext.withOpacity(.5),
            fontSize: 15,
            fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: AppColors.ctext.withOpacity(.4),
              fontSize: 13,
              fontWeight: FontWeight.w600),
          prefixIcon: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.cborder.withOpacity(.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.ctext.withOpacity(.4)),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cborder.withOpacity(.6)),
      ),
      child: InkWell(
        onTap: _selectGender,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppColors.c1.withOpacity(.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.wc_outlined, size: 18, color: AppColors.c1),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gender',
                      style: TextStyle(
                          color: AppColors.ctext.withOpacity(.5),
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _genderValue,
                      style: const TextStyle(
                          color: AppColors.cdark,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_drop_down,
                  color: AppColors.ctext.withOpacity(.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cborder.withOpacity(.6)),
      ),
      child: InkWell(
        onTap: _selectDate,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppColors.c1.withOpacity(.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.calendar_today_outlined,
                    size: 18, color: AppColors.c1),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date of Birth',
                      style: TextStyle(
                          color: AppColors.ctext.withOpacity(.5),
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _dobController.text.isEmpty
                          ? 'Select date'
                          : _dobController.text,
                      style: TextStyle(
                        color: _dobController.text.isEmpty
                            ? AppColors.ctext.withOpacity(.4)
                            : AppColors.cdark,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_drop_down,
                  color: AppColors.ctext.withOpacity(.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cborder.withOpacity(.6)),
      ),
      child: TextFormField(
        controller: _addressController,
        maxLines: 3,
        maxLength: 150,
        textCapitalization: TextCapitalization.sentences,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9\s,./#\-]")),
        ],
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (val) {
          final v = val?.trim() ?? '';
          if (v.isEmpty) return null; // address is optional
          if (!_addressRegex.hasMatch(v)) {
            return 'Special characters are not allowed';
          }
          return null;
        },
        style: const TextStyle(
            color: AppColors.cdark, fontSize: 15, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: 'Address (Optional)',
          labelStyle: TextStyle(
              color: AppColors.ctext.withOpacity(.5),
              fontSize: 13,
              fontWeight: FontWeight.w600),
          prefixIcon: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.c1.withOpacity(.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.home_outlined, size: 18, color: AppColors.c1),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          counterText: '',
        ),
      ),
    );
  }
}

// ── Gallery Thumbnail Widget ──────────────────────────────────────────────────
class _GalleryThumbWidget extends StatefulWidget {
  final AssetEntity asset;
  const _GalleryThumbWidget({required this.asset});

  @override
  State<_GalleryThumbWidget> createState() => _GalleryThumbWidgetState();
}

class _GalleryThumbWidgetState extends State<_GalleryThumbWidget> {
  Uint8List? _thumb;

  @override
  void initState() {
    super.initState();
    _loadThumb();
  }

  Future<void> _loadThumb() async {
    final bytes = await widget.asset.thumbnailDataWithSize(
      const ThumbnailSize(200, 200),
    );
    if (mounted) setState(() => _thumb = bytes);
  }

  @override
  Widget build(BuildContext context) {
    if (_thumb == null) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 1)),
      );
    }
    return Image.memory(_thumb!, fit: BoxFit.cover);
  }
}
