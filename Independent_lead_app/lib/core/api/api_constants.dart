import 'package:pokakbilling/core/config.dart';

class ApiConstants {
  static String serverUrl = ApiConfig.serverUrl;

  // Authentication
  static String signupEndPoint = '$serverUrl/accounts/signup/';
  static String verifyOtpEndPoint = '$serverUrl/accounts/verify-otp/';
  static String getStartedEndPoint = '$serverUrl/accounts/getting-started/';
  static String loginEndPoint = '$serverUrl/auth/login/';

  // Home
  static String userSettingsEndPoint = '$serverUrl/accounts/usersettings/';
  static String homePageEndPoint = '$serverUrl/accounts/homepage/';
  static String helpLinksEndPoint = '$serverUrl/accounts/help-links/';

  // Sale Orders
  static String createSaleOrdersEndPoint = '$serverUrl/accounts/sales-orders/';
  static String getSaleOrdersEndPoint = '$serverUrl/accounts/get-sales-orders/';
  static String leadActivityManualEndpoint =
      '$serverUrl/activities/lead/manual/';

  // Invoice Order
  static String createInvoiceOrdersEndPoint =
      '$serverUrl/accounts/invoice-orders/';
  static String getInvoiceOrdersEndPoint =
      '$serverUrl/accounts/get-invoice-orders/';

  // Delivery Orders
  static String createDeliveryOrdersEndPoint =
      '$serverUrl/accounts/delivery-orders/';
  static String getDeliveryOrdersEndPoint =
      '$serverUrl/accounts/get-delivery-orders/';

  // Suppliers
  static String createSuppliersEndPoint = '$serverUrl/accounts/suppliers/';
  static String getSuppliersEndPoint = '$serverUrl/accounts/get-suppliers/';

  // Purchase
  static String createPurchaseEndPoint = '$serverUrl/accounts/create-purchase/';
  static String listPurchaseEndPoint = '$serverUrl/accounts/list-purchase/';

  // Delivery Challan
  static String createDeliveryChallanEndPoint =
      '$serverUrl/accounts/create-delivery-challan/';
  static String listDeliveryChallanEndPoint =
      '$serverUrl/accounts/list-delivery-challans/';
  static String updatedDeliveryChallanIdEndPoint(int deliveryChallanId) =>
      '$serverUrl/accounts/update-delivery-challan/$deliveryChallanId/';

  // Sales person
  static String salesPersonEndPoint = '$serverUrl/sales-persons/';
  static String salesPersonByIdEndpoint(int salesPersonId) =>
      '$serverUrl/sales-persons/$salesPersonId/';

  // Country state
  static String countriesEndpoint = '$serverUrl/accounts/countries/';
  static String statesEndpoint(String country) =>
      '$serverUrl/accounts/states?country=$country';

  // Product
  static String addProductEndPoint = '$serverUrl/products/';
  static String getProductEndPoint = '$serverUrl/products/';
  static String productByIdEndPoint(int productId) =>
      '$serverUrl/products/$productId/';

  // Customer / Client
  static String createCustomerEndpoint = '$serverUrl/clients/';
  static String getCustomerEndpoint = '$serverUrl/clients/';
  static String customerByIdEndpoint(int customerId) =>
      '$serverUrl/clients/$customerId/';
  static String customerTypesEndpoint = '$serverUrl/clients/customer-types/';

  // Client Contract
  static String clientContractEndpoint = '$serverUrl/clients/contracts/';
  static String getClientContractEndpoint = '$serverUrl/clients/contracts/';
  static String clientContractByIdEndpoint(int id) =>
      '$serverUrl/clients/contracts/$id/';

  // Quotation
  static String quotationEndPoint = '$serverUrl/quotations/';
  static String quotationByIdEndPoint(int quotationId) =>
      '$serverUrl/quotations/$quotationId/';
  static String deleteQuotationProductEndPoint(
          int quotationId, int productId) =>
      '$serverUrl/quotations/$quotationId/$productId/';
  static String quotationByIdAndProductEndPoint(
          int quotationId, int productId) =>
      '$serverUrl/quotations/$quotationId/$productId/';
  static String deleteQuotationItemsEndPoint(
          int quotationId, int productTabId) =>
      '$serverUrl/quotations/$quotationId/$productTabId/';

  // Leads
  static String leadsEndpoint = '$serverUrl/leads/';
  static String leadByIdEndpoint(int id) => '$serverUrl/leads/$id/';
  static String assignedLeadsEndpoint = '$serverUrl/leads/assigned/';
  static String searchLeadByNameEndpoint(String name) =>
      '$serverUrl/leads/?search=$name';
  static String leadTimelineEndpoint(int id) =>
      '$serverUrl/leads/$id/timeline/';
  static String leadStatsEndpoint(int id) => '$serverUrl/leads/$id/stats/';
  static String leadCommunicationsEndpoint(int id) =>
      '$serverUrl/leads/$id/communications/';
  static String leadDetailedEndpoint(int id) =>
      '$serverUrl/leads/$id/detailed/';

  // Follow-ups
  static String followupsEndpoint = '$serverUrl/follow-ups/';
  static String followupByIdEndpoint(int id) => '$serverUrl/follow-ups/$id/';
  static String followupsStatsEndpoint = '$serverUrl/follow-ups/stats/';

  // Meetings
  static String meetingsEndpoint = '$serverUrl/meetings/';
  static String meetingByIdEndpoint(int id) => '$serverUrl/meetings/$id/';
  static String meetingsStatsEndpoint = '$serverUrl/meetings/stats/';

  // Reminders
  static String remindersEndpoint = '$serverUrl/reminders/';
  static String reminderByIdEndpoint(int id) => '$serverUrl/reminders/$id/';
  static String remindersStatsEndpoint = '$serverUrl/reminders/stats/';

  // Activities
  static String activitiesEndpoint = '$serverUrl/activities/';
  static String activityByIdEndpoint(int id) => '$serverUrl/activities/$id/';
  static String activitiesStatsEndpoint = '$serverUrl/activities/stats/';
  static String activityEndPoint = '$serverUrl/activities/';

  // Terms & Conditions
  static String termsEndpoint = '$serverUrl/settings/terms/';
  static String termsByIdEndPoint(int id) => '$serverUrl/settings/terms/$id/';
  static String termsPointsEndpoint = '$serverUrl/accounts/terms-points/';
  static String termsPointByIdEndPoint(int id) =>
      '$serverUrl/accounts/terms-points/$id/';
  static String termsPointByTermsIdEndPoint(int termsId) =>
      '$serverUrl/accounts/terms-points/$termsId/terms/';

  // Invoice
  static String createInvoiceEndpoint = '$serverUrl/invoices/';
  static String getInvoiceEndpoint = '$serverUrl/invoices/';
  static String invoiceByIdEndpoint(int id) => '$serverUrl/invoices/$id/';
  static String deleteInvoiceEndpoint(int id) => '$serverUrl/invoices/$id/';
  static String invoiceEndpoint = '$serverUrl/accounts/invoice-orders/';

  // Bank Account
  static String bankAccountEndPoint = '$serverUrl/accounts/bank-accounts/';

  // PDF
  static String getQuotationPdfEndpoint(int id) =>
      '$serverUrl/accounts/print-quotations/$id/';
  static String getSalesorderPdfEndpoint(int id) =>
      '$serverUrl/accounts/print-sales-orders/$id/';
  static String getdeliveryPdfEndpoint(int id) =>
      '$serverUrl/accounts/print-delivery-orders/$id/';
  static String getReceiptPdfEndpoint(int id) =>
      '$serverUrl/accounts/print-receipts/$id/';

  // Communications
  static String communicationsEndpoint = '$serverUrl/communications/';
  static String communicationsHistoryEndpoint(int leadId) =>
      '$serverUrl/communications/history/?lead_id=$leadId';
  static String logCallEndpoint = '$serverUrl/communications/log_call/';
  static String logWhatsappEndpoint = '$serverUrl/communications/log_whatsapp/';
  static String logEmailEndpoint = '$serverUrl/communications/log_email/';
  static String communicationsStatsEndpoint =
      '$serverUrl/communications/stats/';

  // Category
  static String categoryEndpoint = '$serverUrl/accounts/category/';
  static String categoryByIdEndpoint(int categoryId) =>
      '$serverUrl/accounts/category/$categoryId/';

  // Unit
  static String unitEndpoint = '$serverUrl/accounts/units/';
  static String unitByIdEndpoint(int unitId) =>
      '$serverUrl/accounts/units/$unitId/';

  // Notes
  static String notesEndpoint = '$serverUrl/notes/';

  // Team Member
  static String teamMemberEndpoint = '$serverUrl/project_management/members/';
  static String teamMemberByIdEndpoint(int id) =>
      '$serverUrl/project_management/members/$id/';
  static String searchByNameEndpoint(String name) =>
      '$serverUrl/project_management/members/search/?name=$name/';

  // Stack
  static String stackEndpoint = '$serverUrl/project_management/stack/';
  static String stackByIdEndpoint(int id) =>
      '$serverUrl/project_management/stack/$id/';

  // Project
  static String projectEndpoint = '$serverUrl/project_management/';
  static String projectByIdEndpoint(int id) =>
      '$serverUrl/project_management/$id/';
  static String projectTeamMemberEndpoint =
      '$serverUrl/project_management/project_members/';

  // Task Management
  static String projectMembersEndpoint(int projectId) =>
      '$serverUrl/project_management/$projectId/members/';
  static String projectMembersByIdEndpoint(int projectMemberId) =>
      '$serverUrl/project_management/task/$projectMemberId/project_members/';
  static String taskManagementEndPoint = '$serverUrl/project_management/task/';
  static String taskByMembersEndPoint(int memberId) =>
      '$serverUrl/project_management/task/$memberId/members/';
  static String taskManagementByIdEndPoint(int id) =>
      '$serverUrl/project_management/task/$id/';

  // Sales Order
  static String salesOrderEndpoint = '$serverUrl/accounts/sales-orders/';
  static String salesOrderByIdEndPoint(int id) =>
      '$serverUrl/accounts/sales-orders/$id/';
  static String editsalesOrderByIdEndPoint(int id) =>
      '$serverUrl/accounts/sales-orders/$id/';
  static String deleteSalesOrderItemsEndPoint(
          int salesOrderId, int productTabId) =>
      '$serverUrl/accounts/sales-orders/$salesOrderId/$productTabId/';
  static String generateNumberEndPoint(String type) =>
      Uri.parse('$serverUrl/accounts/orders/generate-number/')
          .replace(queryParameters: {'type': type}).toString();

  // Delivery
  static String salesOrderByClientIdEndPoint(int clientId) =>
      '$serverUrl/accounts/sales-orders/not-delivered/$clientId/';
  static String itemsBySalesOrderIdEndPoint(int id) =>
      '$serverUrl/accounts/sales-orders/$id/items/';
  static String deliveryEndpoint = '$serverUrl/accounts/delivery-orders/';
  static String deliveryByIdEndpoint(int id) =>
      '$serverUrl/accounts/delivery-orders/$id/';

  // Contract
  static String contractEndpoint = '$serverUrl/accounts/contracts/';
  static String contractByIdEndPoint(int id) =>
      '$serverUrl/accounts/contracts/$id/';
  static String contractSectionEndPoint(int contractId) =>
      '$serverUrl/accounts/contracts/$contractId/sections/';
  static String contractSectionByIdEndPoint(int contractId, int sectionId) =>
      '$serverUrl/accounts/contracts/$contractId/sections/$sectionId/';
  static String contractSectionPointEndPoint(int contractId, int sectionId) =>
      '$serverUrl/accounts/contracts/$contractId/sections/$sectionId/points/';
  static String contractSectionPointByIdEndPoint(
          int contractId, int sectionId, int pointId) =>
      '$serverUrl/accounts/contracts/$contractId/sections/$sectionId/points/$pointId/';
  static String contractInfoEndPoint(int id) =>
      '$serverUrl/accounts/contracts/$id/detail/';

  // Profile
  static String profileEndpoint = '$serverUrl/auth/profile/';
  static String meEndpoint = '$serverUrl/accounts/profile/';

  // Supplier
  static String supplierEndPoint = '$serverUrl/accounts/suppliers/';
  static String supplierByIdEndpoint(int id) =>
      '$serverUrl/accounts/suppliers/$id/';

  // Purchase Order
  static String purchaseOrderEndPoint = '$serverUrl/accounts/purchase-orders/';
  static String purchaseOrderByIdEndpoint(int id) =>
      '$serverUrl/accounts/purchase-orders/$id/';

  // Material Receive
  static String materialReceiveEndPoint =
      '$serverUrl/accounts/material-receive/';
  static String materialReceiveByIdEndpoint(int id) =>
      '$serverUrl/accounts/material-receive/$id/';

  // Receipt
  static String receiptEndpoint = '$serverUrl/accounts/receipts/';
  static String receiptByIdEndpoint(int id) =>
      '$serverUrl/accounts/receipts/$id/';

  // User access
  static String userAccessEndpoint = '$serverUrl/accounts/create-staff/';
  static String userAccessModulesEndpoint = '$serverUrl/accounts/user/modules/';

  // Location
  static String locationEndpoint = '$serverUrl/leads/location/';

  // Leads Meta
  static String sourceEndpoint = '$serverUrl/leads/source/';
  static String sourceByIdEndpoint(int id) => '$serverUrl/leads/source/$id/';
  static String categoryListEndpoint = '$serverUrl/leads/category/';

  // Marketing Reports
  static String marketingReportEndpoint = '$serverUrl/leads/marketing-report/';
  static String marketingReportByIdEndpoint(int id) =>
      '$serverUrl/leads/marketing-report/$id/';
  static String marketingReportSearchEndpoint(
          {String? fromDate, String? toDate}) =>
      Uri.parse('$serverUrl/leads/marketing-report/').replace(queryParameters: {
        if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
        if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
      }).toString();

  // Chat
  static String chatUsersEndpoint = '$serverUrl/chat/users/';
  static String chatChatsEndpoint = '$serverUrl/chat/chats/';
  static String chatMessages(int roomId) => '$serverUrl/chat/messages/$roomId/';
  static String chatConversationsEndpoint = '$serverUrl/chat/conversations/';
  static String chatConversationByIdEndpoint(int id) =>
      '$serverUrl/chat/conversations/$id/';
  static String chatConversationMessagesEndpoint(int id) =>
      '$serverUrl/chat/conversations/$id/messages/';
  static String chatAddMemberEndpoint(int id) =>
      '$serverUrl/chat/conversations/$id/add_member/';
  static String chatRemoveMemberEndpoint(int id) =>
      '$serverUrl/chat/conversations/$id/remove_member/';
  static String chatPinEndpoint(int id) =>
      '$serverUrl/chat/conversations/$id/pin/';
  static String chatMuteEndpoint(int id) =>
      '$serverUrl/chat/conversations/$id/mute/';

  // Organiser
  static String organiserEndpoint = '$serverUrl/organiser/';
  static String organiserByIdEndpoint(int id) => '$serverUrl/organiser/$id/';
  static String organiserStatsEndpoint = '$serverUrl/organiser/stats/';
  static String organiserMarkDoneEndpoint(int id) =>
      '$serverUrl/organiser/$id/mark_done/';

  // Call Activity
  static String callActivityDashboardEndpoint =
      '$serverUrl/call-activity/dashboard/';
  static String callActivityScheduleTaskEndpoint =
      '$serverUrl/call-activities/schedule-task/';
  static String callActivityTodayTasksEndpoint =
      '$serverUrl/call-activities/today-tasks/';
  static String callActivityHistoryEndpoint =
      '$serverUrl/call-activity/call-history/';
  static String callActivityFollowUpEndpoint =
      '$serverUrl/call-activities/follow-up/';
  static String callActivityPerformanceSummaryEndpoint =
      '$serverUrl/call-activity/performance-summary/';
  static String callRecordingsEndpoint = '$serverUrl/call-recordings/';
  static String addCallLogEndpoint = '$serverUrl/add-call-logs/';
  static String callActivityStartNewCallEndpoint =
      '$serverUrl/call-activity/start-new_call/';
  static String callActivityCallDetailsEndpoint(int leadId) =>
      '$serverUrl/call-activity/call-details/$leadId/';
  static String callActivityTwilioTokenEndpoint =
      '$serverUrl/call-activity/token/';
  static String callActivitySipCredentialsEndpoint =
      '$serverUrl/call-activity/sip-credentials/';
  static String callActivityTokenEndpoint = '$serverUrl/call-activity/token/';
    // ── Staff Dashboard ─────────────────────────────────────────────
  static String staffDashboardEndpoint = '$serverUrl/staff/dashboard/';

  // ── AI Follow-ups (Email / WhatsApp generator) ──────────────────
  static String aiFollowupsEndpoint = '$serverUrl/ai-followups/';
  static String aiFollowupGenerateEndpoint = '$serverUrl/ai-followups/generate/';
  static String aiFollowupByIdEndpoint(int id) =>
      '$serverUrl/ai-followups/$id/';
  static String aiFollowupUpdateMessageEndpoint(int id) =>
      '$serverUrl/ai-followups/$id/update_message/';
  static String aiFollowupSendActionEndpoint(int id) =>
      '$serverUrl/ai-followups/$id/send_action/';
}
