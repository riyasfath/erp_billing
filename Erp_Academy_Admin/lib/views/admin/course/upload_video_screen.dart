import 'package:erp_academy/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/upload_video_viewmodel.dart';

class UploadVideoScreen extends StatefulWidget {
  const UploadVideoScreen({super.key});
  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  static const _fieldBg = Color(0xFFF1F3FC);

  final _title =
      TextEditingController(text: 'Advanced Distributed Systems Architecture');
  final _subtitle = TextEditingController(
      text: 'Master consensus, cloud native fault tolerance, and more');
  final _module = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {})); // update 43/80 counter
  }

  @override
  void dispose() {
    _title.dispose();
    _subtitle.dispose();
    _module.dispose();
    super.dispose();
  }

  Future<void> _run(bool upload) async {
    final vm = context.read<UploadVideoViewModel>();
    final ok = upload
        ? await vm.upload(_title.text, _subtitle.text, _module.text)
        : await vm.saveDraft(_title.text, _subtitle.text, _module.text);
    if (!mounted || !ok) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(upload ? 'Video uploaded' : 'Draft saved')));
    if (upload) Navigator.pop(context);
  }

  InputDecoration _dec() => InputDecoration(
        filled: true,
        fillColor: _fieldBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
      );

  Widget _label(String t, {bool required = false, String? trailing}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text.rich(TextSpan(
              text: t,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              children: [
                if (required)
                  const TextSpan(
                      text: ' *', style: TextStyle(color: AppColors.red))
              ])),
          if (trailing != null)
            Text(trailing,
                style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UploadVideoViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.chevron_left, size: 24),
                    Text('Courses',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ]),
                ),
                const SizedBox(height: 24),
                const Text('Upload video',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                      color: const Color(0xFFEFF1FE),
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                          color: Color(0xFFDDE3FA), shape: BoxShape.circle),
                      child: const Icon(Icons.videocam_outlined,
                          color: AppColors.primary),
                    ),
                    const SizedBox(height: 12),
                    const Text('Upload Video',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    const Text('Drag and drop or tap to browse media',
                        style: TextStyle(fontSize: 13, color: AppColors.text)),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () {}, // later: file picker
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6))),
                      child: const Text('Choose Video Preview',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ]),
                ),
                const SizedBox(height: 32),
                const Text('BASIC INFORMATION',
                    style: TextStyle(fontSize: 14, letterSpacing: .8)),
                const SizedBox(height: 18),
                _label('Course Title',
                    required: true, trailing: '${_title.text.length}/80'),
                TextField(
                  controller: _title,
                  inputFormatters: [LengthLimitingTextInputFormatter(80)],
                  decoration: _dec(),
                ),
                const SizedBox(height: 20),
                _label('Catalog Subtitle'),
                TextField(controller: _subtitle, decoration: _dec()),
                const SizedBox(height: 20),
                _label('Module'),
                TextField(
                    controller: _module,
                    keyboardType: TextInputType.number,
                    decoration: _dec()),
                const SizedBox(height: 20),
                _label('Academic Domain'),
                DropdownButtonFormField<String>(
                  value: vm.selectedDomain,
                  items: vm.domains
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: vm.setDomain,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  decoration: _dec(),
                ),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(children: [
              Expanded(
                flex: 4,
                child: ElevatedButton.icon(
                  onPressed: vm.busy ? null : () => _run(false),
                  icon: const Icon(Icons.bookmark_border, size: 18),
                  label: const Text('Save Draft'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEDEFF2),
                      foregroundColor: AppColors.text,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 6,
                child: ElevatedButton(
                  onPressed: vm.busy ? null : () => _run(true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B1220),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: vm.busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Text('Upload'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 18),
                            ]),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}