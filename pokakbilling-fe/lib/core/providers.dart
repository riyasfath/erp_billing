// // lib/providers.dart

import 'package:pokakbilling/appthemes/themeNotifier.dart';
import 'package:pokakbilling/viewmodels/academy/academy_hr_viewmodel.dart';
import 'package:pokakbilling/viewmodels/academy/academy_viewmodel.dart';
import 'package:pokakbilling/viewmodels/academy/form_submission_viewmodel.dart';
import 'package:pokakbilling/viewmodels/activity_leads/activity_viewmodel.dart';
import 'package:pokakbilling/viewmodels/admin/lead_viewmodelAdmin.dart';
import 'package:pokakbilling/viewmodels/course_viewmodel.dart';
import 'package:pokakbilling/viewmodels/internship_viewmodel.dart';
import 'package:pokakbilling/viewmodels/reminder/reminder_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/followup_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
import 'package:pokakbilling/viewmodels/staff_lead/staff_lead_viewmodel.dart' hide LeadViewmodel;
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:pokakbilling/viewmodels/access_viewmodel.dart';
import 'package:pokakbilling/viewmodels/auth_viewmodel.dart';
import 'package:pokakbilling/viewmodels/chat_users_viewmodel.dart';
import 'package:pokakbilling/viewmodels/chat_viewmodel.dart';
import 'package:pokakbilling/viewmodels/material_receive_viewmodel.dart';
import 'package:pokakbilling/viewmodels/purchase_viewmodel.dart';
import 'package:pokakbilling/viewmodels/receipt_viewmodel.dart';
import 'package:pokakbilling/viewmodels/bottom_state.dart';
import 'package:pokakbilling/viewmodels/setup/category_viewmodel.dart';
import 'package:pokakbilling/viewmodels/delivery_viewmodel.dart';
import 'package:pokakbilling/viewmodels/global_viewmodel.dart';
import 'package:pokakbilling/viewmodels/profile_viewmodel.dart';
import 'package:pokakbilling/viewmodels/project_management/client_contract_viewmodel.dart';
import 'package:pokakbilling/viewmodels/country_state_viewmodel.dart';
import 'package:pokakbilling/viewmodels/customer_viewmodel.dart';
import 'package:pokakbilling/viewmodels/expense_viewmodel.dart';
import 'package:pokakbilling/viewmodels/invoice_viewmodel.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/viewmodels/login_viewmodel.dart';
import 'package:pokakbilling/viewmodels/meeting_viewmodel.dart';
import 'package:pokakbilling/viewmodels/pdf_viewmodel.dart';
import 'package:pokakbilling/viewmodels/product_viewmodel.dart';
import 'package:pokakbilling/viewmodels/project_management/project_viewmodel.dart';
import 'package:pokakbilling/viewmodels/project_management/stack_viewmodel.dart';
import 'package:pokakbilling/viewmodels/project_management/task_management_viewmodel.dart';
import 'package:pokakbilling/viewmodels/project_management/team_member_viewmodel.dart';
import 'package:pokakbilling/viewmodels/quotation/quotation_viewmodel.dart';
import 'package:pokakbilling/viewmodels/quotation/textfield_viewmodel.dart';
import 'package:pokakbilling/viewmodels/sales_order_viewmodel.dart';
import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
import 'package:pokakbilling/viewmodels/sales_state.dart';
import 'package:pokakbilling/viewmodels/settings_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/contract_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/terms&condition_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/unit_viewmodel.dart';
import 'package:pokakbilling/viewmodels/user_access_viewmodel.dart';
import 'package:pokakbilling/viewmodels/supplier_viewmodel.dart';
import 'package:pokakbilling/viewmodels/user_log_state.dart';
import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => AccessViewModel()),
  ChangeNotifierProvider(create: (_) => CustomerViewmodel()),
  ChangeNotifierProvider(create: (_) => SaleModel()),
  ChangeNotifierProvider(create: (_) => UserLoginProvider()),
  ChangeNotifierProvider(create: (_) => BottomNavProvider()),
  ChangeNotifierProvider(create: (_) => SettingsViewmodel()),
  ChangeNotifierProvider(create: (_) => AuthViewModel()),
  ChangeNotifierProvider(create: (_) => ProductViewModel()),
  ChangeNotifierProvider(create: (_) => QuotationViewmodel()),
  ChangeNotifierProvider(create: (_) => SalesPersonViewmodel()),
  ChangeNotifierProvider(create: (_) => InvoiceViewmodel()),
  ChangeNotifierProvider(create: (_) => ExpenseViewmodel()),
  ChangeNotifierProvider(create: (_) => LoginViewModel()),
  ChangeNotifierProvider(create: (_) => CountryStateProvider()),
  ChangeNotifierProvider(create: (_) => CategoryViewmodel()),
  ChangeNotifierProvider(create: (_) => UnitViewmodel()),
  ChangeNotifierProvider(create: (_) => TextfieldViewmodel()),
  ChangeNotifierProvider(create: (_) => PdfViewmodel()),
  ChangeNotifierProvider(create: (_) => LeadViewmodel()),
  ChangeNotifierProvider(create: (_) => MeetingViewmodel()),
  ChangeNotifierProvider(create: (_) => ReminderViewmodel()),
  ChangeNotifierProvider(create: (_) => TeamMemberViewmodel()),
  ChangeNotifierProvider(create: (_) => StackViewmodel()),
  ChangeNotifierProvider(create: (_) => ProjectViewmodel()),
  ChangeNotifierProvider(create: (_) => ClientContractViewmodel()),
  ChangeNotifierProvider(create: (_) => TaskManagementViewmodel()),
  ChangeNotifierProvider(create: (_) => TermsViewmodel()),
  ChangeNotifierProvider(create: (_) => SalesOrderViewmodel()),
  ChangeNotifierProvider(create: (_) => GlobalViewmodel()),
  ChangeNotifierProvider(create: (_) => DeliveryViewmodel()),
  ChangeNotifierProvider(create: (_) => ProfileViewmodel()),
  ChangeNotifierProvider(create: (_) => ContractViewmodel()),
  ChangeNotifierProvider(create: (_) => SupplierViewmodel()),
  ChangeNotifierProvider(create: (_) => PurchaseViewmodel()),
  ChangeNotifierProvider(create: (_) => MaterialReceiveViewmodel()),
  ChangeNotifierProvider(create: (_) => ReceiptViewmodel()),
  ChangeNotifierProvider(create: (_) => UserAccessViewmodel()),
  ChangeNotifierProvider(create: (_) => LocationViewmodel()),
  ChangeNotifierProvider(create: (_) => ChatUsersViewModel()),
  ChangeNotifierProvider(create: (_) => ChatInboxViewModel()),
  ChangeNotifierProvider(create: (_) => FollowupViewmodel()),
  ChangeNotifierProvider(create: (_) => SourceViewmodel()),
  ChangeNotifierProvider(create: (_) => ActivityScreenViewmodel()),
  ChangeNotifierProvider(create: (_) => ThemeNotifier()),
  ChangeNotifierProvider(create: (_) => AdminLeadViewmodel()),

  // ✅ Internship — students & courses
  ChangeNotifierProvider(create: (_) => InternshipViewmodel()),
  ChangeNotifierProvider(create: (_) => CourseViewmodel()),
  ChangeNotifierProvider(create: (_) => FormSubmissionViewmodel()),
    ChangeNotifierProvider(create: (_) => AcademyViewmodel()),
      ChangeNotifierProvider(create: (_) => AcademyHrViewmodel()),
      ChangeNotifierProvider(create: (_) => StaffLeadViewmodel()),
];
