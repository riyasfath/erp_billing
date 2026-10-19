import 'package:flutter/material.dart';
import 'package:ecommerce_app/app_colors.dart';

class _LanguageOption {
  final String name;
  final String flag; // emoji flag, no asset needed
  const _LanguageOption(this.name, this.flag);
}

const List<_LanguageOption> _mostUsed = [
  _LanguageOption('English', '🇬🇧'),
  _LanguageOption('Japan', '🇯🇵'),
  _LanguageOption('Indonesian', '🇮🇩'),
];

const List<_LanguageOption> _otherLanguages = [
  _LanguageOption('Spain', '🇪🇸'),
  _LanguageOption('Germany', '🇩🇪'),
  _LanguageOption('Arabic', '🇸🇦'),
  _LanguageOption('Rusian', '🇷🇺'),
  _LanguageOption('Turkish', '🇹🇷'),
  _LanguageOption('Italian', '🇮🇹'),
];

/// "Select Language" screen — search field, Most Used + Other
/// Languages radio lists, and a success dialog on change.
class SelectLanguageScreen extends StatefulWidget {
  const SelectLanguageScreen({super.key});

  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  String _selected = 'English';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectLanguage(String language) {
    setState(() => _selected = language);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: AppColors.success.withOpacity(0.12), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: AppColors.success, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Change Language Success',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                "Your language successfully changed, let's go !",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text('Back to settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.bgLight,
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 18, color: AppColors.iconGrey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Select language here',
                              hintStyle: TextStyle(color: AppColors.hintGrey, fontSize: 13),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Most Used', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textGrey)),
                  const SizedBox(height: 8),
                  ..._mostUsed.map((lang) => _languageTile(lang)),
                  const SizedBox(height: 14),
                  const Text('Other Languages', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textGrey)),
                  const SizedBox(height: 8),
                  ..._otherLanguages.map((lang) => _languageTile(lang)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          const Text('Select Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _languageTile(_LanguageOption lang) {
    final bool selected = lang.name == _selected;
    return GestureDetector(
      onTap: () => _selectLanguage(lang.name),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primaryBlue : AppColors.borderGrey),
        ),
        child: Row(
          children: [
            Text(lang.flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(lang.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18,
              color: selected ? AppColors.primaryBlue : AppColors.borderGrey,
            ),
          ],
        ),
      ),
    );
  }
}