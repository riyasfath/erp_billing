import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/viewmodels/login_viewmodel.dart';
import 'package:pokakbilling/viewmodels/access_viewmodel.dart';
import 'package:pokakbilling/viewmodels/customer_viewmodel.dart';
import 'package:pokakbilling/viewmodels/customer_type_viewmodel.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/viewmodels/meeting_viewmodel.dart';
import 'package:pokakbilling/viewmodels/reminder/reminder_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/followup_viewmodel.dart';
import 'package:pokakbilling/viewmodels/profile_viewmodel.dart';
import 'package:pokakbilling/viewmodels/invoice_viewmodel.dart';
import 'package:pokakbilling/viewmodels/expense_viewmodel.dart';
import 'package:pokakbilling/viewmodels/product_viewmodel.dart';
import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
import 'package:pokakbilling/viewmodels/sales_order_viewmodel.dart';
import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
import 'package:pokakbilling/viewmodels/supplier_viewmodel.dart';
import 'package:pokakbilling/viewmodels/user_access_viewmodel.dart';
import 'package:pokakbilling/viewmodels/global_viewmodel.dart';
import 'package:pokakbilling/viewmodels/project_management/task_management_viewmodel.dart';
import 'package:pokakbilling/viewmodels/project_management/team_member_viewmodel.dart';
import 'package:pokakbilling/viewmodels/client_contract_viewmodel.dart';
import 'package:pokakbilling/viewmodels/activity/all_activityviewmodel.dart';
import 'package:pokakbilling/viewmodels/chat_viewmodel.dart';
import 'package:pokakbilling/views/splashScreen/splash_Screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SessionService
//
// HOW IT WORKS:
//  1. DioClient sees a 401/403 response in its interceptor.
//  2. It calls SessionService.instance.handleSessionExpired().
//  3. SessionService:
//       a) Blocks duplicate triggers with _isHandling flag
//       b) Resets all ViewModels → clears stale data
//       c) Shows the session-expired dialog (user must tap Sign In Again)
//       d) On tap → clears token + navigates to SplashScreen (full stack wipe)
// ─────────────────────────────────────────────────────────────────────────────
class SessionService {
  SessionService._();
  static final SessionService instance = SessionService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool _isHandling = false;

  Future<void> handleSessionExpired() async {
    if (_isHandling) return;
    _isHandling = true;

    try {
      final context = navigatorKey.currentContext;
      if (context == null) return;

      // Step 1 — wipe stale data from every ViewModel
      _resetAllViewModels(context);

      // Step 2 — show dialog (pushed as a page so it sits above everything)
      await navigatorKey.currentState?.push(
        PageRouteBuilder(
          opaque: false,
          barrierDismissible: false,
          barrierColor: Colors.black.withOpacity(0.55),
          pageBuilder: (ctx, _, __) => const _SessionExpiredDialog(),
          transitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (ctx, a1, a2, child) {
            final curved =
                CurvedAnimation(parent: a1, curve: Curves.easeOutBack);
            return ScaleTransition(
              scale: Tween<double>(begin: 0.75, end: 1.0).animate(curved),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(a1),
                child: child,
              ),
            );
          },
        ),
      );

      // Step 3 — after dialog resolves, push SplashScreen and wipe stack
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (route) => false,
      );
    } finally {
      // Reset flag after a small delay so rapid 401s don't re-trigger
      await Future.delayed(const Duration(seconds: 3));
      _isHandling = false;
    }
  }

  // ── Reset every ViewModel that holds user-specific data ──────────────────
  void _resetAllViewModels(BuildContext context) {
    _safe(() => _vm<LoginViewModel>(context)?.clearUserData());
    _safe(() => _vm<AccessViewModel>(context)?.reset());
    _safe(() => _vm<CustomerViewmodel>(context)?.reset());
    _safe(() => _vm<CustomerTypeViewmodel>(context)?.reset());
    _safe(() => _vm<LeadViewmodel>(context)?.reset());
    _safe(() => _vm<MeetingViewmodel>(context)?.reset());
    _safe(() => _vm<ReminderViewmodel>(context)?.reset());
    _safe(() => _vm<FollowupViewmodel>(context)?.reset());
    _safe(() => _vm<ProfileViewmodel>(context)?.reset());
    _safe(() => _vm<InvoiceViewModel>(context)?.reset());
    _safe(() => _vm<ExpenseViewmodel>(context)?.reset());
    _safe(() => _vm<ProductViewModel>(context)?.reset());
    _safe(() => _vm<QuotationViewmodel>(context)?.reset());
    _safe(() => _vm<SalesOrderViewmodel>(context)?.reset());
    _safe(() => _vm<SalesPersonViewmodel>(context)?.reset());
    _safe(() => _vm<SupplierViewmodel>(context)?.reset());
    _safe(() => _vm<UserAccessViewmodel>(context)?.reset());
    _safe(() => _vm<GlobalViewmodel>(context)?.reset());
    _safe(() => _vm<TaskManagementViewmodel>(context)?.reset());
    _safe(() => _vm<TeamMemberViewmodel>(context)?.reset());
    _safe(() => _vm<ContractViewmodel>(context)?.reset());
    _safe(() => _vm<AllActivityViewModel>(context)?.reset());
    _safe(() => _vm<ChatViewModel>(context)?.reset());
  }

  T? _vm<T>(BuildContext context) {
    try {
      return Provider.of<T>(context, listen: false) as T;
    } catch (_) {
      return null;
    }
  }

  void _safe(void Function() fn) {
    try {
      fn();
    } catch (_) {}
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SessionExpiredDialog
// Matches your app's existing navy/cyan color style from LoginScreen
// ─────────────────────────────────────────────────────────────────────────────
class _SessionExpiredDialog extends StatelessWidget {
  const _SessionExpiredDialog();

  static const Color _navy = Color(0xFF0D1B2A); // replace with AppColors.navy
  static const Color _cyan = Color(0xFF00BCD4); // replace with AppColors.cyan
  static const Color _white = Colors.white;
  static const Color _red = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.14),
              blurRadius: 32,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Top red accent bar ───────────────────────────────────────
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_red, Color(0xFFFCA5A5)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Icon ────────────────────────────────────────────────
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _red.withOpacity(0.08),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: _red.withOpacity(0.25), width: 1.5),
                    ),
                    child: const Icon(Icons.lock_clock_outlined,
                        color: _red, size: 28),
                  ),
                  const SizedBox(height: 16),

                  // ── Title ───────────────────────────────────────────────
                  const Text(
                    'Session Expired',
                    style: TextStyle(
                      color: _navy,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Subtitle ────────────────────────────────────────────
                  Text(
                    'Your session has expired due to inactivity.\nPlease sign in again to continue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _navy.withOpacity(0.50),
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Divider(
                      color: _navy.withOpacity(0.08),
                      height: 1,
                      thickness: 0.5),
                  const SizedBox(height: 20),

                  // ── Sign In Again button ─────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_cyan, _navy],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: _cyan.withOpacity(0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        // Tapping pops the dialog → SessionService then
                        // navigates to SplashScreen
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login_rounded, color: _white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'SIGN IN AGAIN',
                              style: TextStyle(
                                color: _white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
