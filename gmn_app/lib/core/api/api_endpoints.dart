class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';

  // Work Orders
  static const String workOrders = '/work-orders';
  static String workOrder(String id) => '/work-orders/$id';

  // Technicians
  static const String technicians = '/technicians';
  static String technician(String id) => '/technicians/$id';
  static const String technicianTrades = '/technicians/meta/trades';

  // Proposals
  static const String proposals = '/proposals';
  static String proposal(String id) => '/proposals/$id';

  // Costs
  static const String costs = '/costs';
  static String cost(String id) => '/costs/$id';

  // Files
  static const String files = '/files';
  static String file(String id) => '/files/$id';

  // Calendar
  static const String calendar = '/calendar';
  static String calendarEvent(String id) => '/calendar/$id';

  // Dashboard
  static const String dashboardStats = '/dashboard/stats';
}
