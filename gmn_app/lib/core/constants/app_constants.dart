class AppConstants {
  AppConstants._();

  // API Configuration
  static const String baseUrl = 'http://10.0.2.2:3001/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:3001/api'; // iOS simulator

  // Storage Keys
  static const String tokenKey = 'gmn_token';
  static const String userKey = 'gmn_user';

  // Pagination
  static const int defaultPageSize = 20;

  // Work Order Statuses
  static const List<String> workOrderStatuses = [
    'waiting',
    'in_progress',
    'completed',
    'invoiced',
    'paid',
  ];

  // Cost Statuses
  static const List<String> costStatuses = ['requested', 'approved', 'paid'];

  // Proposal Statuses
  static const List<String> proposalStatuses = [
    'draft',
    'sent',
    'approved',
    'rejected',
  ];

  // Trades
  static const List<String> trades = [
    'HVAC',
    'Plumbing',
    'Electrical',
    'Appliance',
    'Locksmith',
    'General',
  ];

  // Priorities
  static const List<String> priorities = ['low', 'normal', 'high', 'urgent'];

  // User Roles
  static const List<String> userRoles = [
    'dispatcher',
    'team_leader',
    'account_manager',
    'admin',
  ];

  // Default Values
  static const double defaultCostMultiplier = 1.35;
  static const double defaultTaxRate = 0.0825; // 8.25%
  static const double defaultTechRating = 5.0;
}
