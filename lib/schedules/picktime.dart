import 'package:flutter/material.dart';

class PickTimeButton extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay> onTimePicked;

  const PickTimeButton({
    super.key,
    required this.selectedTime,
    required this.onTimePicked,
  });

  @override
  Widget build(BuildContext context) {
    final label =
        selectedTime != null ? selectedTime!.format(context) : 'Pick Time';

    return ElevatedButton.icon(
      icon: const Icon(Icons.access_time_outlined),
      label: Text(label, style: const TextStyle(fontSize: 14)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 3,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null) {
          onTimePicked(picked);
        }
      },
    );
  }
}
