import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import 'models/calendar_event.dart';

class CalendarRepository {
  final ApiClient _apiClient;

  CalendarRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<CalendarItem>> getCalendarItems() async {
    final response = await _apiClient.get(ApiConstants.calendar);
    
    final List<CalendarItem> items = [];
    
    if (response.data is Map) {
      // Events
      if (response.data['events'] is List) {
        for (final json in response.data['events']) {
          items.add(CalendarItem.fromEvent(CalendarEvent.fromJson(json)));
        }
      }
      // Work Orders with ETAs
      if (response.data['workOrders'] is List) {
        for (final json in response.data['workOrders']) {
          if (json['etaAt'] != null) {
            items.add(CalendarItem.fromWorkOrder(json));
          }
        }
      }
    } else if (response.data is List) {
      for (final json in response.data) {
        items.add(CalendarItem.fromEvent(CalendarEvent.fromJson(json)));
      }
    }
    
    return items;
  }

  Future<CalendarEvent> getEvent(String id) async {
    final response = await _apiClient.get('${ApiConstants.calendar}/$id');
    return CalendarEvent.fromJson(response.data);
  }

  Future<CalendarEvent> createEvent(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiConstants.calendar,
      data: data,
    );
    return CalendarEvent.fromJson(response.data);
  }

  Future<CalendarEvent> updateEvent(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.patch(
      '${ApiConstants.calendar}/$id',
      data: data,
    );
    return CalendarEvent.fromJson(response.data);
  }

  Future<void> deleteEvent(String id) async {
    await _apiClient.delete('${ApiConstants.calendar}/$id');
  }

  Future<CalendarEvent> toggleComplete(String id, bool isCompleted) async {
    return updateEvent(id, {'isCompleted': isCompleted});
  }
}
