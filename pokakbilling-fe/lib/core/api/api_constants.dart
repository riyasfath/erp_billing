  // // // lib/core/api/api_constants.dart

  import 'package:pokakbilling/core/config.dart';

  class ApiConstants {
    static String serverUrl = ApiConfig.serverUrl;

    // Authentication
    static String signupEndPoint = '$serverUrl/accounts/signup/';
    static String verifyOtpEndPoint = '$serverUrl/accounts/verify-otp/';
    static String getStartedEndPoint = '$serverUrl/accounts/getting-started/';
    static String loginEndPoint = '$serverUrl/accounts/token/';

    // Home
    static String userSettingsEndPoint = '$serverUrl/accounts/usersettings/';
    static String homePageEndPoint = '$serverUrl/accounts/homepage/';
    static String helpLinksEndPoint = '$serverUrl/accounts/help-links/';

    // Sale Orders
    static String createSaleOrdersEndPoint = '$serverUrl/accounts/sales-orders/';
    static String getSaleOrdersEndPoint = '$serverUrl/accounts/get-sales-orders/';

    // Invoice Order
    static String createInvoiceOrdersEndPoint = '$serverUrl/accounts/invoice/';
    static String getInvoiceOrdersEndPoint = '$serverUrl/accounts/invoice/';

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

    // Product
    static String addProductEndPoint = '$serverUrl/accounts/products/';
    static String getProductEndPoint = '$serverUrl/accounts/products/';
    static String productByIdEndPoint(int productId) =>
        '$serverUrl/accounts/products/$productId/';

    // Sales person
    static String salesPersonEndPoint = '$serverUrl/accounts/salespersons/';
    static String salesPersonByIdEndpoint(int salesPersonId) =>
        '$serverUrl/accounts/salespersons/$salesPersonId/';

    // Country state
    static String countriesEndpoint = '$serverUrl/accounts/countries/';
    static String statesEndpoint(String country) =>
        '$serverUrl/accounts/states?country=$country';

    // Customer
    static String createCustomerEndpoint = '$serverUrl/accounts/customers/';
    static String getCustomerEndpoint = '$serverUrl/accounts/customers/';
    static String customerByIdEndpoint(int customerId) =>
        '$serverUrl/accounts/customers/$customerId/';

    // Category
    static String categoryEndpoint = '$serverUrl/accounts/category/';
    static String categoryByIdEndpoint(int categoryId) =>
        '$serverUrl/accounts/category/$categoryId/';

    // Unit
    static String unitEndpoint = '$serverUrl/accounts/units/';
    static String unitByIdEndpoint(int unitId) =>
        '$serverUrl/accounts/units/$unitId/';

    // Quotations
    static String quotationEndPoint = '$serverUrl/accounts/quotations/';
    static String quotationByIdEndPoint(int quotationId) =>
        '$serverUrl/accounts/quotations/$quotationId/';
    static String deleteQuotationProductEndPoint(
            int quotationId, int productId) =>
        '$serverUrl/accounts/quotations/$quotationId/$productId/';
    static String quotationByIdAndProductEndPoint(
            int quotationId, int productId) =>
        '$serverUrl/accounts/quotations/$quotationId/$productId/';
    static String deleteQuotationItemsEndPoint(
            int quotationId, int productTabId) =>
        '$serverUrl/accounts/quotations/$quotationId/$productTabId/';

    static String bankAccountEndPoint = '$serverUrl/accounts/bank-accounts/';

    // pdf
    static String getQuotationPdfEndpoint(int id) =>
        '$serverUrl/accounts/print-quotations/$id/';
    static String getSalesorderPdfEndpoint(int id) =>
        '$serverUrl/accounts/print-sales-orders/$id/';
    static String getdeliveryPdfEndpoint(int id) =>
        '$serverUrl/accounts/print-delivery-orders/$id/';
    static String getReceiptPdfEndpoint(int id) =>
        '$serverUrl/accounts/print-receipts/$id/';

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

    // Client contract
    static String clientContractEndpoint =
        '$serverUrl/project_management/client_contract/';
    static String clientContractByIdEndpoint(int id) =>
        '$serverUrl/project_management/client_contract/$id/';

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

    // Terms & Conditions
    static String termsEndpoint = '$serverUrl/accounts/terms/';
    static String termsByIdEndPoint(int id) => '$serverUrl/accounts/terms/$id/';
    static String termsPointsEndpoint = '$serverUrl/accounts/terms-points/';
    static String termsPointByIdEndPoint(int id) =>
        '$serverUrl/accounts/terms-points/$id/';
    static String termsPointByTermsIdEndPoint(int termsId) =>
        '$serverUrl/accounts/terms-points/$termsId/terms/';

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
    static String profileEndpoint = '$serverUrl/accounts/profile/';

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

    // Invoice
    static String invoiceEndpoint = '$serverUrl/accounts/invoice/';
    static String invoiceByIdEndpoint(int id) =>
        '$serverUrl/accounts/invoice/$id/';

    // Receipt
    static String receiptEndpoint = '$serverUrl/accounts/receipts/';
    static String receiptByIdEndpoint(int id) =>
        '$serverUrl/accounts/receipts/$id/';

    // // User access
    // static String userAccessEndpoint = '$serverUrl/accounts/create-staff/';

    // // CHANGED: was '$serverUrl/accounts/user/modules/'
    // // now points at the endpoint that returns the full modules+submodules tree
    // static String userAccessModulesEndpoint =
    //     '$serverUrl/accounts/user/modules/all/';
  // User access
    static String userAccessEndpoint = '$serverUrl/accounts/create-staff/';
    static String userAccessModulesEndpoint = '$serverUrl/accounts/user/modules/';
    // NEW: full modules+submodules permission tree (the API you shared first)
    static String userAccessModulesAllEndpoint =
        '$serverUrl/accounts/user/modules/all/';
    // Location
    static String locationEndpoint = '$serverUrl/leads/location/';

    // Leads Meta
    static String sourceEndpoint = '$serverUrl/leads/source/';
    static String sourceByIdEndpoint(int id) => '$serverUrl/leads/source/$id/';
    static String categoryListEndpoint = "$serverUrl/leads/category/";

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

    // Chats
    static String chatUsersEndpoint = '$serverUrl/chat/users/';
    static String chatChatsEndpoint = '$serverUrl/chat/chats/';
    static String chatMessages(int roomId) => '$serverUrl/chat/messages/$roomId/';

    // Leads (staff-scoped endpoints)
    static String leadEndpoint = '$serverUrl/leads/staff/';
    static String leadByIdEndpoint(int id) => '$serverUrl/leads/staff/$id/';
    static String searchLeadByNameEndpoint(String name) =>
        '$serverUrl/leads/staff/search/?name=$name';
    static String searchLeadByDate({
      required String fromDate,
      required String toDate,
    }) =>
        '$serverUrl/leads/staff/search/?from_date=$fromDate&to_date=$toDate';

    // Followups (staff-scoped)
    static String followupsEndpoint = '$serverUrl/leads/staff/followups/';
    static String followupByIdEndpoint(int id) =>
        '$serverUrl/leads/staff/followups/$id/';
    static String followupsByLeadIdEndpoint(int leadId) =>
        '$serverUrl/leads/staff/$leadId/followup/';

    // Meetings
    static String meetingEndpoint = '$serverUrl/leads/meeting/';
    static String meetingByIdEndpoint(int id) => '$serverUrl/leads/meeting/$id/';
    static String meetingsByLeadIdEndpoint(int leadId) =>
        '$serverUrl/leads/staff/$leadId/meeting/';

    // Reminders
    static String staffRemindersEndpoint = '$serverUrl/leads/staff/reminders/';
    static String remindersByLeadIdEndpoint(int leadId) =>
        '$serverUrl/leads/staff/$leadId/reminders/';

    // Activity manual endpoint
    static String leadActivityManual = '$serverUrl/leads/activity/manual/';

    // Admin login
    static String adminLoginEndPoint = '$serverUrl/accounts/admin/token/';

    // ── Internship ─────────────────────────────────────────────────────────────

    
      // ── Internship ─────────────────────────────────────────────────────────────
    static String internshipStudentsEndpoint = '$serverUrl/internship/students/';
    static String internshipCourseEndpoint = '$serverUrl/internship/course/';

    // ── Academy reports ────────────────────────────────────────────────────────
    static String academyRegistrationsEndpoint =
        '$serverUrl/internship/report/registrations/';
    static String academyAdmissionsEndpoint =
        '$serverUrl/internship/report/admissions/';
    static String academyPaymentsEndpoint =
        '$serverUrl/internship/report/payments/';
    static String academySummaryEndpoint =
        '$serverUrl/internship/report/admissions/summary/';
    static String academyCounsellorConversionEndpoint(int id) =>
        '$serverUrl/internship/report/counsellors/$id/conversion/';

            static String academyProceedToHrEndpoint(int counsellorId) =>
        '$serverUrl/internship/report/counsellors/$counsellorId/proceed-to-hr/';
    static String academyHrSubmissionsEndpoint =
        '$serverUrl/internship/report/hr/counsellor-submissions/';
    static String academyHrSubmissionByIdEndpoint(int id) =>
        '$serverUrl/internship/report/hr/counsellor-submissions/$id/';
    static String academyHrActionEndpoint(int id) =>
        '$serverUrl/internship/report/hr/counsellor-submissions/$id/action/';

        static String academicDashboardStaffEndpoint =
    '$serverUrl/leads/academic-dashboard/staff/';
  }
