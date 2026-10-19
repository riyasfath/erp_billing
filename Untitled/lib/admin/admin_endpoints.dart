/// Every admin endpoint confirmed via Hoppscotch so far. Same backend
/// host as the customer app (93.127.167.39:8060), different route
/// prefixes (/admin/...).
class AdminEndpoints {
  AdminEndpoints._();

  static const String _base = 'http://93.127.167.39:8060';

  static String get login => '$_base/api/accounts/admin-login/';

  static String get dashboardStats => '$_base/api/orders/admin/dashboard/stats/';

  static String get products => '$_base/api/products/admin/products/';
  static String productDetail(int id) => '$_base/api/products/admin/products/$id/';
  static String addSize(int id) => '$_base/api/products/admin/products/$id/add-size/';
  static String changeStatus(int id) => '$_base/api/products/admin/products/$id/change-status/';
  static String toggleFeatured(int id) => '$_base/api/products/admin/products/$id/toggle-featured/';
  static String uploadImages(int id) => '$_base/api/products/admin/products/$id/upload-images/';
  static String deleteImage(int productId) => '$_base/api/products/admin/products/$productId/delete-image/';

  static String reviewUpdateStatus(int reviewId) => '$_base/api/products/admin/reviews/$reviewId/update-status/';
  static String reviewReply(int reviewId) => '$_base/api/products/admin/reviews/$reviewId/reply/';

  // ---------------------------------------------------------------------
  // Orders
  // ---------------------------------------------------------------------
  static String get ordersAll => '$_base/api/orders/admin/all/';
  static String orderDetail(int id) => '$_base/api/orders/admin/$id/';
  static String orderUpdate(int id) => '$_base/api/orders/admin/$id/update/';

  // ---------------------------------------------------------------------
  // Returns
  // ---------------------------------------------------------------------
  static String get returnsAll => '$_base/api/orders/admin/returns/';
  static String returnDetail(int id) => '$_base/api/orders/admin/return/$id/';
  static String returnProcess(int id) => '$_base/api/orders/admin/return/$id/process/';

  // ---------------------------------------------------------------------
  // Payments & exports
  // ---------------------------------------------------------------------
  static String get paymentsAll => '$_base/api/orders/admin/payments/';
  static String get exportOrders => '$_base/api/orders/admin/export/orders/';
  static String get exportPayments => '$_base/api/orders/admin/export/payments/';

  // ---------------------------------------------------------------------
  // Employees
  // ---------------------------------------------------------------------
  static String get employees => '$_base/api/accounts/admin/employees/';
  static String employeeDetail(int id) => '$_base/api/accounts/admin/employees/$id/';

  // ---------------------------------------------------------------------
  // Customers
  // ---------------------------------------------------------------------
  static String get customers => '$_base/api/accounts/admin/customers/';
  static String customerDetail(int id) => '$_base/api/accounts/admin/customers/$id/';

  // ---------------------------------------------------------------------
  // Support tickets
  // ---------------------------------------------------------------------
  static String get supportStats => '$_base/api/orders/admin/support/stats/';
  static String get supportTickets => '$_base/api/orders/admin/support/tickets/';
  static String supportTicketDetail(int id) => '$_base/api/orders/admin/support/ticket/$id/';

  // ---------------------------------------------------------------------
  // Notifications — NOT under /admin/, same shared endpoint as the
  // customer app; the backend returns admin-relevant notifications
  // when hit with the admin's own token.
  // ---------------------------------------------------------------------
  static String get notifications => '$_base/api/notifications/';
  static String get notificationsUnreadCount => '$_base/api/notifications/unread-count/';
  static String notificationRead(int id) => '$_base/api/notifications/$id/read/';
  static String get notificationsReadAll => '$_base/api/notifications/read-all/';
}