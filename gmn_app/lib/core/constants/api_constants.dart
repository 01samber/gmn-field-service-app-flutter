class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:3001/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:3001/api'; // iOS simulator
  // static const String baseUrl = 'https://your-domain.com/api'; // Production

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';

  // Work Orders endpoints
  static const String workOrders = '/work-orders';

  // Technicians endpoints
  static const String technicians = '/technicians';

  // Proposals endpoints
  static const String proposals = '/proposals';

  // Costs endpoints
  static const String costs = '/costs';

  // Files endpoints
  static const String files = '/files';

  // Calendar endpoints
  static const String calendar = '/calendar';

  // Dashboard endpoints
  static const String dashboardStats = '/dashboard/stats';
}
