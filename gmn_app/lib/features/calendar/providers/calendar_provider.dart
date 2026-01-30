import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../data/calendar_repository.dart';
import '../data/models/calendar_event.dart';

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepository(apiClient: ref.watch(apiClientProvider));
});

// Selected date
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// Calendar items
final calendarItemsProvider = FutureProvider.autoDispose<List<CalendarItem>>((
  ref,
) async {
  final repository = ref.watch(calendarRepositoryProvider);
  return repository.getCalendarItems();
});

// Items for selected date
final selectedDateItemsProvider = Provider.autoDispose<List<CalendarItem>>((
  ref,
) {
  final itemsAsync = ref.watch(calendarItemsProvider);
  final selectedDate = ref.watch(selectedDateProvider);

  return itemsAsync.when(
    data: (items) {
      return items.where((item) {
        return item.dateTime.year == selectedDate.year &&
            item.dateTime.month == selectedDate.month &&
            item.dateTime.day == selectedDate.day;
      }).toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Items grouped by date
final itemsByDateProvider =
    Provider.autoDispose<Map<DateTime, List<CalendarItem>>>((ref) {
      final itemsAsync = ref.watch(calendarItemsProvider);

      return itemsAsync.when(
        data: (items) {
          final Map<DateTime, List<CalendarItem>> grouped = {};
          for (final item in items) {
            final date = DateTime(
              item.dateTime.year,
              item.dateTime.month,
              item.dateTime.day,
            );
            grouped.putIfAbsent(date, () => []).add(item);
          }
          return grouped;
        },
        loading: () => {},
        error: (_, __) => {},
      );
    });

// Overdue items
final overdueItemsProvider = Provider.autoDispose<List<CalendarItem>>((ref) {
  final itemsAsync = ref.watch(calendarItemsProvider);

  return itemsAsync.when(
    data: (items) {
      return items.where((item) => item.isOverdue).toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Calendar operations notifier
class CalendarNotifier extends StateNotifier<AsyncValue<void>> {
  final CalendarRepository _repository;
  final Ref _ref;

  CalendarNotifier(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  Future<CalendarEvent?> create(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final event = await _repository.createEvent(data);
      _ref.invalidate(calendarItemsProvider);
      state = const AsyncValue.data(null);
      return event;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<CalendarEvent?> update(String id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final event = await _repository.updateEvent(id, data);
      _ref.invalidate(calendarItemsProvider);
      state = const AsyncValue.data(null);
      return event;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> delete(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteEvent(id);
      _ref.invalidate(calendarItemsProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> toggleComplete(String id, bool isCompleted) async {
    state = const AsyncValue.loading();
    try {
      await _repository.toggleComplete(id, isCompleted);
      _ref.invalidate(calendarItemsProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final calendarNotifierProvider =
    StateNotifierProvider<CalendarNotifier, AsyncValue<void>>((ref) {
      return CalendarNotifier(ref.watch(calendarRepositoryProvider), ref);
    });
