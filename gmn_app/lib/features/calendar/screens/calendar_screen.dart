import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_spinner.dart';
import '../../../core/widgets/error_message.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/calendar_provider.dart';
import '../data/models/calendar_event.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final itemsAsync = ref.watch(calendarItemsProvider);
    final itemsByDate = ref.watch(itemsByDateProvider);
    final selectedItems = ref.watch(selectedDateItemsProvider);
    final overdueItems = ref.watch(overdueItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          if (overdueItems.isNotEmpty)
            Badge(
              label: Text(overdueItems.length.toString()),
              child: IconButton(
                icon: const Icon(Icons.warning_amber),
                onPressed: () => _showOverdueSheet(overdueItems),
              ),
            ),
        ],
      ),
      body: itemsAsync.when(
        data: (_) => Column(
          children: [
            // Calendar
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(selectedDate, day),
              eventLoader: (day) {
                final date = DateTime(day.year, day.month, day.day);
                return itemsByDate[date] ?? [];
              },
              onDaySelected: (selectedDay, focusedDay) {
                ref.read(selectedDateProvider.notifier).state = selectedDay;
                setState(() => _focusedDay = focusedDay);
              },
              onFormatChanged: (format) {
                setState(() => _calendarFormat = format);
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(77),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
              ),
            ),
            const Divider(height: 1),

            // Selected day events
            Expanded(
              child: selectedItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 48,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No events on ${Formatters.date(selectedDate)}',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: selectedItems.length,
                      itemBuilder: (context, index) {
                        return _CalendarItemCard(
                          item: selectedItems[index],
                          onTap: () => _handleItemTap(selectedItems[index]),
                          onToggleComplete: selectedItems[index].type == 'event'
                              ? () => _toggleComplete(selectedItems[index])
                              : null,
                        );
                      },
                    ),
            ),
          ],
        ),
        loading: () => PageLoader(),
        error: (error, stack) => ErrorMessage(
          message: error.toString(),
          onRetry: () => ref.invalidate(calendarItemsProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEventDialog(null),
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
      ),
    );
  }

  void _handleItemTap(CalendarItem item) {
    if (item.type == 'work_order') {
      context.go('/work-orders/${item.id}');
    } else {
      _showEventDialog(item.id);
    }
  }

  void _toggleComplete(CalendarItem item) async {
    await ref
        .read(calendarNotifierProvider.notifier)
        .toggleComplete(item.id, !item.isCompleted);
  }

  void _showOverdueSheet(List<CalendarItem> items) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: AppColors.error),
                  const SizedBox(width: 12),
                  Text(
                    'Overdue Items (${items.length})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _CalendarItemCard(
                    item: items[index],
                    onTap: () {
                      Navigator.pop(context);
                      _handleItemTap(items[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDialog(String? eventId) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDateTime = ref.read(selectedDateProvider);
    String priority = 'normal';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(eventId != null ? 'Edit Event' : 'New Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date & Time'),
                  subtitle: Text(Formatters.dateTime(selectedDateTime)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDateTime,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                      );
                      if (time != null) {
                        setDialogState(() {
                          selectedDateTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: AppConstants.priorities.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.getPriorityColor(p),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(Formatters.capitalize(p)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => priority = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            if (eventId != null)
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final confirmed = await ConfirmDialog.show(
                    context: this.context,
                    title: 'Delete Event',
                    message: 'Are you sure you want to delete this event?',
                    confirmLabel: 'Delete',
                    isDestructive: true,
                  );
                  if (confirmed == true) {
                    await ref
                        .read(calendarNotifierProvider.notifier)
                        .delete(eventId);
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) return;

                final data = {
                  'title': titleController.text,
                  'description': descriptionController.text.isNotEmpty
                      ? descriptionController.text
                      : null,
                  'dateTime': selectedDateTime.toIso8601String(),
                  'priority': priority,
                };

                final notifier = ref.read(calendarNotifierProvider.notifier);
                if (eventId != null) {
                  await notifier.update(eventId, data);
                } else {
                  await notifier.create(data);
                }

                if (mounted) Navigator.pop(context);
              },
              child: Text(eventId != null ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarItemCard extends StatelessWidget {
  final CalendarItem item;
  final VoidCallback onTap;
  final VoidCallback? onToggleComplete;

  const _CalendarItemCard({
    required this.item,
    required this.onTap,
    this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = AppColors.getPriorityColor(item.priority);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CustomCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: item.isOverdue ? AppColors.error : priorityColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            if (onToggleComplete != null)
              Checkbox(
                value: item.isCompleted,
                onChanged: (_) => onToggleComplete?.call(),
                activeColor: AppColors.success,
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        item.type == 'work_order'
                            ? Icons.work_outline
                            : Icons.event,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.title,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: item.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (item.subtitle != null)
                    Text(
                      item.subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.time(item.dateTime),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (item.isOverdue)
                  const Text(
                    'OVERDUE',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
