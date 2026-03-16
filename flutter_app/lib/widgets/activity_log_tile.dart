import 'package:flutter/material.dart';
import '../models/activity_log_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class ActivityLogTile extends StatelessWidget {
  final ActivityLogModel log;
  final bool showTaskTitle;
  final bool isLast;

  const ActivityLogTile({
    super.key,
    required this.log,
    this.showTaskTitle = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final toColor = AppConstants.getStatusColor(log.toStatus);

    return IntrinsicHeight(
      child: Padding(
        padding: EdgeInsets.only(left: sw(context, 16)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            SizedBox(
              width: sw(context, 32),
              child: Column(
                children: [
                  Container(
                    width: sw(context, 10),
                    height: sw(context, 10),
                    decoration: BoxDecoration(
                      color: toColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: toColor.withOpacity(0.3),
                        width: sw(context, 3),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: sw(context, 2),
                        color: AppConstants.dividerColor,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: sw(context, 8)),
            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: sh(context, 12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showTaskTitle && log.taskTitle != null) ...[
                    Text(
                      log.taskTitle!,
                      style: TextStyle(
                        fontSize: sw(context, 14),
                        fontWeight: FontWeight.w600,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                    SizedBox(height: sh(context, 4)),
                  ],
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: sw(context, 13),
                        color: AppConstants.textSecondary,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: log.changedByName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppConstants.textPrimary,
                          ),
                        ),
                        const TextSpan(text: ' changed status from '),
                        TextSpan(
                          text: log.fromStatus,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppConstants.getStatusColor(log.fromStatus),
                          ),
                        ),
                        const TextSpan(text: ' → '),
                        TextSpan(
                          text: log.toStatus,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: toColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: sh(context, 4)),
                  Text(
                    Helpers.formatDateTime(log.timestamp),
                    style: TextStyle(
                      fontSize: sw(context, 11),
                      color: AppConstants.textSecondary.withOpacity(0.7),
                    ),
                  ),
                  if (log.note.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.format_quote_rounded,
                            size: 14,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              log.note,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF94A3B8),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
