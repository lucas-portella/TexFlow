import 'package:flutter/material.dart';
import 'package:texflow/models/status.dart';
import 'package:texflow/shared/status_helpers.dart';

class StatusBadge extends StatelessWidget {
  final Status status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final cor = statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusLabel(status),
        style: TextStyle(fontSize: 12, color: cor, fontWeight: FontWeight.w600),
      ),
    );
  }
}
