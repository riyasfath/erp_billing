import 'package:erp_academy/core/app_colors.dart';
import 'package:erp_academy/core/utils/coming_soon.dart';
import 'package:erp_academy/core/utils/currency_format.dart';
import 'package:erp_academy/core/utils/date_format.dart';
import 'package:erp_academy/core/utils/text_format.dart';
import 'package:erp_academy/models/student_model.dart';
import 'package:erp_academy/models/student_profile_model.dart';
import 'package:erp_academy/services/student_service.dart';
import 'package:erp_academy/widgets/status_chip.dart';
import 'package:erp_academy/widgets/student_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/student_profile_viewmodel.dart';
import '../../../viewmodels/student_viewmodel.dart';

const _purple = Color(0xFF6D28D9);
const _indigo = Color(0xFF4F46E5);
const _purpleSoft = Color(0xFFF3EEFF);
const _blue = Color(0xFF2563EB);
const _green = Color(0xFF16A34A);
const _red = Color(0xFFDC2626);
const _amber = Color(0xFFD97706);
const _border = Color(0xFFE9EAF0);
const _bg = Color(0xFFF8F9FC);

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key, required this.student});

  final StudentListItem student;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (ctx) =>
            StudentProfileViewModel(ctx.read<StudentService>(), student),
        child: const _Body(),
      );
}

class _KV {
  const _KV(this.label, this.value, {this.color});
  final String label;
  final String value;
  final Color? color;
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentProfileViewModel>();
    final s = vm.student;

    return Scaffold(
      backgroundColor: _bg,
      body: RefreshIndicator(
        onRefresh: vm.load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back,
                    size: 20, color: Colors.black87),
                label: const Text('Back to Students',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4)),
              ),
            ),
            const SizedBox(height: 6),
            _Hero(student: s),
            const SizedBox(height: 14),
            _actions(context),
            const SizedBox(height: 22),
            const _SectionTitle('Enrolled Courses', Icons.menu_book_outlined),
            const SizedBox(height: 10),
            _enrollments(vm),
            const SizedBox(height: 22),
            const _SectionTitle('Personal Information', Icons.person_outline),
            const SizedBox(height: 10),
            _personal(s),
            const SizedBox(height: 22),
            const _SectionTitle(
                'Admission Payment', Icons.receipt_long_outlined),
            const SizedBox(height: 10),
            _admission(s),
          ],
        ),
      ),
    );
  }

  // ---------------- Quick actions ----------------
  Widget _actions(BuildContext context) => Row(children: [
        Expanded(
          child: _ActionTile(
            icon: Icons.edit_outlined,
            label: 'Edit',
            color: _blue,
            onTap: () => showComingSoon(context, 'Edit Student'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionTile(
            icon: Icons.key_outlined,
            label: 'Credentials',
            color: _purple,
            onTap: () => _openCredentials(context),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionTile(
            icon: Icons.receipt_long_outlined,
            label: 'Receipt',
            color: _green,
            onTap: () => showComingSoon(context, 'Create Receipt'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionTile(
            icon: Icons.delete_outline,
            label: 'Delete',
            color: _red,
            onTap: () => showComingSoon(context, 'Delete Student'),
          ),
        ),
      ]);

  void _openCredentials(BuildContext context) {
    final vm = context.read<StudentProfileViewModel>();
    vm.clearCredentialsError();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => ChangeNotifierProvider.value(
        value: vm,
        child: const _CredentialsSheet(),
      ),
    );
  }

  // ---------------- Enrollments ----------------
  Widget _enrollments(StudentProfileViewModel vm) {
    if (vm.loading && vm.profile == null) {
      return const _StateCard(child: CircularProgressIndicator());
    }
    if (vm.error != null && vm.profile == null) {
      return _StateCard(
        child: Column(children: [
          const Icon(Icons.cloud_off, size: 36, color: AppColors.muted),
          const SizedBox(height: 8),
          Text(vm.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted)),
          TextButton(onPressed: vm.load, child: const Text('Retry')),
        ]),
      );
    }
    final list = vm.profile?.courses ?? const <StudentEnrollment>[];
    if (list.isEmpty) {
      return const _StateCard(
        child: Column(children: [
          Icon(Icons.menu_book_outlined, size: 36, color: AppColors.muted),
          SizedBox(height: 8),
          Text('Not enrolled in any course yet.',
              style: TextStyle(color: AppColors.muted)),
        ]),
      );
    }
    return Column(
      children: list
          .map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _EnrollmentCard(enrollment: e),
              ))
          .toList(),
    );
  }

  // ---------------- Personal ----------------
  Widget _personal(StudentListItem s) {
    final rows = <(IconData, String, String)>[
      (Icons.badge_outlined, 'Student ID', TextFormat.orDash(s.studentCode)),
      (Icons.person_outline, 'Full Name', TextFormat.orDash(s.fullName)),
      (Icons.wc, 'Gender', TextFormat.pretty(s.gender)),
      (Icons.cake_outlined, 'Date of Birth', AppDate.format(s.dateOfBirth)),
      (Icons.phone_outlined, 'Phone', TextFormat.orDash(s.phone)),
      (Icons.alternate_email, 'Login Email', TextFormat.orDash(s.loginEmail)),
      (Icons.mail_outline, 'Personal Email', TextFormat.orDash(s.email)),
      (Icons.location_city_outlined, 'Center',
          TextFormat.orDash(s.centerName)),
      (Icons.support_agent, 'Counsellor', TextFormat.orDash(s.counsellorName)),
      (Icons.event_outlined, 'Start Date', AppDate.format(s.startDate)),
      (Icons.home_outlined, 'Address', TextFormat.orDash(s.address)),
    ];

    return Container(
      decoration: _box(),
      child: Column(
        children: List.generate(rows.length, (i) {
          final r = rows[i];
          return Column(children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                          color: _purpleSoft,
                          borderRadius: BorderRadius.circular(9)),
                      child: Icon(r.$1, size: 16, color: _purple),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.$2,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.muted)),
                            const SizedBox(height: 2),
                            Text(r.$3,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700)),
                          ]),
                    ),
                  ]),
            ),
            if (i != rows.length - 1)
              const Divider(height: 1, indent: 58, color: _border),
          ]);
        }),
      ),
    );
  }

  // ---------------- Admission payment ----------------
  Widget _admission(StudentListItem s) {
    if (!s.hasEnrollment) {
      return const _StateCard(
        child: Column(children: [
          Icon(Icons.receipt_long_outlined, size: 36, color: AppColors.muted),
          SizedBox(height: 8),
          Text('No admission payment recorded.',
              style: TextStyle(color: AppColors.muted)),
        ]),
      );
    }
    final installments = s.customInstallments ?? s.installmentCount;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _box(),
      child: _KVGrid(items: [
        _KV('Payment Plan', TextFormat.pretty(s.paymentPlanType)),
        _KV('Installments', installments == null ? '—' : '$installments'),
        _KV('Advance Paid', CurrencyFormat.inr(s.advanceAmount),
            color: _green),
        _KV('Payment Method', TextFormat.pretty(s.paymentMethod)),
        _KV('Transaction ID', TextFormat.orDash(s.transactionId)),
        _KV('Payment Date', AppDate.format(s.paymentDate)),
        _KV('Discount', CurrencyFormat.inr(s.discountAmount), color: _amber),
        _KV('Discount Reason', TextFormat.pretty(s.discountReason)),
      ]),
    );
  }
}

// =====================================================================
// Hero header
// =====================================================================
class _Hero extends StatelessWidget {
  const _Hero({required this.student});
  final StudentListItem student;

  @override
  Widget build(BuildContext context) {
    final s = student;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_purple, _indigo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: _purple.withOpacity(.25),
              blurRadius: 18,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: StudentAvatar(
                name: s.fullName, imageUrl: s.profileImage, size: 66),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.fullName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(s.studentCode,
                      style: TextStyle(
                          color: Colors.white.withOpacity(.8),
                          fontSize: 13,
                          letterSpacing: .5,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  StatusChip(s.status, small: true),
                ]),
          ),
        ]),
        const SizedBox(height: 16),
        _line(Icons.phone_outlined, TextFormat.orDash(s.phone)),
        const SizedBox(height: 6),
        _line(Icons.mail_outline, TextFormat.orDash(s.loginEmail)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            _stat('Course', s.hasCourse ? s.courseTitle : '—'),
            _divider(),
            _stat('Batch', s.batchNumber ?? '—'),
            _divider(),
            _stat('Center', s.centerName.isEmpty ? '—' : s.centerName),
          ]),
        ),
      ]),
    );
  }

  Widget _line(IconData icon, String text) => Row(children: [
        Icon(icon, size: 15, color: Colors.white70),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
      ]);

  Widget _stat(String label, String value) => Expanded(
        child: Column(children: [
          Text(label.toUpperCase(),
              style: TextStyle(
                  color: Colors.white.withOpacity(.7),
                  fontSize: 9.5,
                  letterSpacing: .8,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800)),
          ),
        ]),
      );

  Widget _divider() => Container(
      width: 1, height: 30, color: Colors.white.withOpacity(.25));
}

// =====================================================================
// Enrollment card (course + payment)
// =====================================================================
class _EnrollmentCard extends StatelessWidget {
  const _EnrollmentCard({required this.enrollment});
  final StudentEnrollment enrollment;

  @override
  Widget build(BuildContext context) {
    final e = enrollment;
    final payable = e.discountedFee > 0 ? e.discountedFee : e.totalFee;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: _box(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 6,
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_purple, _indigo])),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: _purpleSoft,
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.menu_book_outlined,
                    color: _purple, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(TextFormat.orDash(e.courseName),
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Wrap(spacing: 6, runSpacing: 6, children: [
                        if (e.batchNumber != null)
                          _miniTag(Icons.groups_outlined, e.batchNumber!),
                        if (e.courseDuration != null)
                          _miniTag(Icons.timelapse, e.courseDuration!),
                      ]),
                    ]),
              ),
              StatusChip(e.courseStatus, small: true),
            ]),
            const SizedBox(height: 16),
            _KVGrid(items: [
              _KV('Registration', AppDate.format(e.registrationDate)),
              _KV('Enrollment', AppDate.format(e.enrollmentDate)),
              _KV('Course Start', AppDate.format(e.courseStartingDate)),
              _KV('Class End', AppDate.format(e.classEndDate)),
              _KV('Center', TextFormat.orDash(e.center)),
              _KV('Counsellor', TextFormat.orDash(e.counsellorName)),
            ]),
            const SizedBox(height: 4),
            const Text('INSTRUCTORS',
                style: TextStyle(
                    fontSize: 10,
                    letterSpacing: .8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted)),
            const SizedBox(height: 6),
            if (e.instructors.isEmpty)
              const Text('No instructors assigned',
                  style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.muted))
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: e.instructors
                    .map((f) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                              color: _purpleSoft,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(f.name,
                              style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: _purple)),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 16),

            // -------- Payment block --------
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: _bg, borderRadius: BorderRadius.circular(14)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.account_balance_wallet_outlined,
                          size: 18, color: _purple),
                      const SizedBox(width: 8),
                      const Text('Payment Summary',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800)),
                      const Spacer(),
                      StatusChip(e.paymentStatus, small: true),
                    ]),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: e.paidProgress,
                        minHeight: 9,
                        backgroundColor: const Color(0xFFE5E7EB),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(_green),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                        '${CurrencyFormat.inr(e.paidAmount)} paid of ${CurrencyFormat.inr(payable)} '
                        '(${(e.paidProgress * 100).round()}%)',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.muted)),
                    const SizedBox(height: 14),
                    _KVGrid(items: [
                      _KV('Total Fee', CurrencyFormat.inr(e.totalFee)),
                      _KV('Discount', CurrencyFormat.inr(e.discountAmount),
                          color: _amber),
                      _KV('Payable', CurrencyFormat.inr(payable),
                          color: _purple),
                      _KV('Advance', CurrencyFormat.inr(e.advanceAmount)),
                      _KV('Paid', CurrencyFormat.inr(e.paidAmount),
                          color: _green),
                      _KV('Pending', CurrencyFormat.inr(e.pendingAmount),
                          color: e.pendingAmount > 0 ? _red : _green),
                    ]),
                    _KVGrid(items: [
                      _KV('Plan Type', TextFormat.pretty(e.paymentPlanType)),
                      _KV(
                          'Custom Installments',
                          e.customInstallments == null
                              ? '—'
                              : '${e.customInstallments}'),
                    ]),
                    if (e.installments.isNotEmpty) ...[
                      const Text('UPCOMING INSTALLMENTS',
                          style: TextStyle(
                              fontSize: 10,
                              letterSpacing: .8,
                              fontWeight: FontWeight.w700,
                              color: AppColors.muted)),
                      const SizedBox(height: 8),
                      ...e.installments.map((p) => _installmentTile(p)),
                    ],
                  ]),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _installmentTile(StudentPayment p) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: _purpleSoft,
            child: Text('${p.installment}',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _purple)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Installment ${p.installment}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                  Text('Paid ${CurrencyFormat.inr(p.paid)}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.muted)),
                ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(CurrencyFormat.inr(p.amount),
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            StatusChip(p.status, small: true),
          ]),
        ]),
      );

  Widget _miniTag(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: AppColors.muted),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700)),
        ]),
      );
}

// =====================================================================
// Credentials bottom sheet  (PATCH /students/{id}/credentials/)
// =====================================================================
class _CredentialsSheet extends StatefulWidget {
  const _CredentialsSheet();

  @override
  State<_CredentialsSheet> createState() => _CredentialsSheetState();
}

class _CredentialsSheetState extends State<_CredentialsSheet> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _email;
  final _pw = TextEditingController();
  final _confirm = TextEditingController();
  bool _hidePw = true;
  bool _hideConfirm = true;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(
        text: context.read<StudentProfileViewModel>().student.loginEmail);
  }

  @override
  void dispose() {
    _email.dispose();
    _pw.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_form.currentState?.validate() ?? false)) return;

    final vm = context.read<StudentProfileViewModel>();
    final students = context.read<StudentViewModel>();
    final messenger = ScaffoldMessenger.of(context);

    final ok = await vm.updateCredentials(
      email: _email.text,
      password: _pw.text,
      confirmPassword: _confirm.text,
    );
    if (!mounted || !ok) return;

    Navigator.of(context).pop();
    messenger.showSnackBar(const SnackBar(
      content: Text('Login credentials updated'),
      behavior: SnackBarBehavior.floating,
    ));
    students.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentProfileViewModel>();

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(height: 18),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: _purpleSoft,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.key_outlined, color: _purple),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Update Login Credentials',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w800)),
                          Text(vm.student.fullName,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.muted)),
                        ]),
                  ),
                ]),
                const SizedBox(height: 20),
                _label('LOGIN EMAIL'),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  enabled: !vm.savingCredentials,
                  validator: vm.validateEmail,
                  onChanged: (_) => vm.clearCredentialsError(),
                  decoration: _dec(Icons.alternate_email),
                ),
                const SizedBox(height: 14),
                _label('NEW PASSWORD'),
                TextFormField(
                  controller: _pw,
                  obscureText: _hidePw,
                  enabled: !vm.savingCredentials,
                  validator: vm.validatePassword,
                  onChanged: (_) => vm.clearCredentialsError(),
                  decoration: _dec(
                    Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                          _hidePw
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20),
                      onPressed: () => setState(() => _hidePw = !_hidePw),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _label('CONFIRM PASSWORD'),
                TextFormField(
                  controller: _confirm,
                  obscureText: _hideConfirm,
                  enabled: !vm.savingCredentials,
                  validator: (v) => vm.validateConfirm(v, _pw.text),
                  onChanged: (_) => vm.clearCredentialsError(),
                  onFieldSubmitted: (_) => _submit(),
                  decoration: _dec(
                    Icons.lock_reset_outlined,
                    suffix: IconButton(
                      icon: Icon(
                          _hideConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20),
                      onPressed: () =>
                          setState(() => _hideConfirm = !_hideConfirm),
                    ),
                  ),
                ),
                if (vm.credentialsError != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 14),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _red.withOpacity(.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _red.withOpacity(.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline, size: 18, color: _red),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(vm.credentialsError!,
                              style: const TextStyle(
                                  fontSize: 13, color: _red))),
                    ]),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: vm.savingCredentials ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _purple.withOpacity(.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: vm.savingCredentials
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Update Credentials',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t,
            style: const TextStyle(
                fontSize: 11,
                letterSpacing: .8,
                fontWeight: FontWeight.w700,
                color: AppColors.muted)),
      );

  InputDecoration _dec(IconData icon, {Widget? suffix}) => InputDecoration(
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffix,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _purple)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _red)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _red)),
      );
}

// =====================================================================
// Shared bits
// =====================================================================
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, this.icon);
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 18, color: _purple),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      ]);
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: _box(),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withOpacity(.1), shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 6),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11.5, fontWeight: FontWeight.w700)),
          ]),
        ),
      );
}

class _KVGrid extends StatelessWidget {
  const _KVGrid({required this.items});
  final List<_KV> items;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _cell(items[i])),
          const SizedBox(width: 12),
          Expanded(
              child: i + 1 < items.length
                  ? _cell(items[i + 1])
                  : const SizedBox()),
        ]),
      ));
    }
    return Column(children: rows);
  }

  Widget _cell(_KV kv) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(kv.label.toUpperCase(),
            style: const TextStyle(
                fontSize: 10,
                letterSpacing: .7,
                fontWeight: FontWeight.w700,
                color: AppColors.muted)),
        const SizedBox(height: 3),
        Text(kv.value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: kv.color ?? Colors.black87)),
      ]);
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        decoration: _box(),
        child: Center(child: child),
      );
}

BoxDecoration _box() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _border),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(.03), blurRadius: 10)
      ],
    );