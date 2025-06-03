import 'package:flutter/material.dart';

class PickDateButton extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDatePicked;

  const PickDateButton({
    super.key,
    required this.selectedDate,
    required this.onDatePicked,
  });

  @override
  Widget build(BuildContext context) {
    final label =
        selectedDate != null
            ? '${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}'
            : 'Pick Date';

    return Tooltip(
      message: 'Pick a date for the event',
      child: ElevatedButton.icon(
        icon: const Icon(Icons.calendar_today_outlined),
        label: Text(label, style: const TextStyle(fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            onDatePicked(picked);
          }
        },
      ),
    );
  }
}

class PickTimeButton extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay> onTimePicked;
  final TimeOfDay initialTime;

  const PickTimeButton({
    super.key,
    required this.selectedTime,
    required this.onTimePicked,
    this.initialTime = const TimeOfDay(hour: 12, minute: 0),
  });

  @override
  Widget build(BuildContext context) {
    final label =
        selectedTime != null ? selectedTime!.format(context) : 'Pick Time';

    return Tooltip(
      message: 'Pick a time for the event',
      child: ElevatedButton.icon(
        icon: const Icon(Icons.access_time_outlined),
        label: Text(label, style: const TextStyle(fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: initialTime,
          );
          if (picked != null) {
            onTimePicked(picked);
          }
        },
      ),
    );
  }
}
