import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'status_badge.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final bool showLastHandler;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.showLastHandler = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: sw(context, 16), vertical: sh(context, 8)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstants.textPrimary.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Indicator Bar
              Container(
                width: sw(context, 5),
                color: AppConstants.getStatusColor(task.status),
              ),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: sw(context, 17),
                                    fontWeight: FontWeight.bold,
                                    color: AppConstants.textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              StatusBadge(status: task.status),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded,
                                  size: 16, color: AppConstants.textSecondary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  task.location,
                                  style: TextStyle(
                                    fontSize: sw(context, 13),
                                    color: AppConstants.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.person_rounded,
                                  size: 16, color: AppConstants.textSecondary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  task.contactName,
                                  style: TextStyle(
                                    fontSize: sw(context, 13),
                                    color: AppConstants.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (task.assignedToName != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.assignment_ind_rounded,
                                    size: 16,
                                    color: AppConstants.textSecondary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Assigned: ${task.assignedToName}',
                                    style: TextStyle(
                                      fontSize: sw(context, 13),
                                      color: AppConstants.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (task.deadlineAt != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.watch_later_rounded,
                                    size: 16,
                                    color: AppConstants.cancelledColor),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Deadline: ${Helpers.formatDateTime(task.deadlineAt!)}',
                                    style: TextStyle(
                                      fontSize: sw(context, 12),
                                      color: AppConstants.cancelledColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (showLastHandler) ...[
                            const SizedBox(height: 16),
                            if (task.status == 'In Progress' ||
                                task.status == 'Completed')
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.person_pin_rounded,
                                    size: 15,
                                    color: Color(0xFF4F46E5),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Picked up by ${task.lastChangedByName ?? 'Unknown'}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF4F46E5),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                            else if (task.status == 'Pending')
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.group_outlined,
                                    size: 15,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    task.assignedToName == null
                                        ? 'Awaiting assignment'
                                        : 'Assigned and waiting to start',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
