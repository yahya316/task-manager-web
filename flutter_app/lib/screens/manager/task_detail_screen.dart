import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/task_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/activity_log_tile.dart';

class ManagerTaskDetailScreen extends StatefulWidget {
  final String taskId;

  const ManagerTaskDetailScreen({super.key, required this.taskId});

  @override
  State<ManagerTaskDetailScreen> createState() =>
      _ManagerTaskDetailScreenState();
}

class _ManagerTaskDetailScreenState extends State<ManagerTaskDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTask(widget.taskId);
    });
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Task'),
        content: const Text(
            'Are you sure you want to delete this task? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success =
          await context.read<TaskProvider>().deleteTask(widget.taskId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task deleted',
                style: TextStyle(fontSize: sw(context, 14))),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(sw(context, 16)),
            padding: EdgeInsets.symmetric(
                horizontal: sw(context, 16), vertical: sh(context, 12)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(sw(context, 10))),
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.surfaceColor,
      appBar: AppBar(
        title: Text(
          'Task Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.edit_rounded,
                  size: 20, color: AppConstants.primaryColor),
            ),
            onPressed: () {
              context.push('/manager/edit-task/${widget.taskId}');
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.accentRose.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_rounded,
                  size: 20, color: AppConstants.cancelledColor),
            ),
            onPressed: _deleteTask,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, _) {
          if (taskProvider.isLoading && taskProvider.selectedTask == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final task = taskProvider.selectedTask;
          if (task == null) {
            return const Center(child: Text('Task not found'));
          }

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Info Section
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.textPrimary.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
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
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: AppConstants.textPrimary,
                                  letterSpacing: -1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            StatusBadge(status: task.status),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _infoItem(Icons.location_on_rounded, 'Location',
                            task.location, AppConstants.inProgressColor),
                        if (task.assignedToName != null)
                          _infoItem(
                            Icons.assignment_ind_rounded,
                            'Assigned To',
                            task.assignedToName!,
                            AppConstants.primaryColor,
                          ),
                        if (task.deadlineAt != null)
                          _infoItem(
                            Icons.watch_later_rounded,
                            'Deadline',
                            Helpers.formatDateTime(task.deadlineAt!),
                            AppConstants.cancelledColor,
                          ),
                        _infoItem(Icons.person_rounded, 'Contact Name',
                            task.contactName, AppConstants.primaryColor),
                        _infoItem(
                          Icons.phone_rounded,
                          'Phone Number',
                          task.contactPhone,
                          AppConstants.accentTeal,
                          onTap: () => _launchPhone(task.contactPhone),
                        ),
                        _infoItem(
                            Icons.event_available_rounded,
                            'Created At',
                            Helpers.formatDateTime(task.createdAt),
                            AppConstants.textSecondary),
                        const Divider(
                            height: 48,
                            thickness: 1,
                            color: AppConstants.dividerColor),
                        Text(
                          'DESCRIPTION',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppConstants.textTertiary,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          task.description,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: AppConstants.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (task.status == 'Completed' &&
                            task.paymentReceived != null) ...[
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: task.paymentReceived!
                                  ? AppConstants.completedColor.withOpacity(0.1)
                                  : AppConstants.pendingColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  task.paymentReceived!
                                      ? Icons.check_circle_rounded
                                      : Icons.pending_actions_rounded,
                                  size: 18,
                                  color: task.paymentReceived!
                                      ? AppConstants.completedColor
                                      : AppConstants.pendingColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    task.paymentReceived!
                                        ? 'Payment status: Received'
                                        : 'Payment status: Not received',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: task.paymentReceived!
                                          ? AppConstants.completedColor
                                          : AppConstants.pendingColor,
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

                  // Metadata section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        if (task.createdByName != null)
                          Expanded(
                            child: _miniMetaCard('Creator', task.createdByName!,
                                Icons.admin_panel_settings_rounded),
                          ),
                        if (task.lastChangedByName != null &&
                            task.createdByName != null)
                          const SizedBox(width: 12),
                        if (task.lastChangedByName != null)
                          Expanded(
                            child: _miniMetaCard(
                                'Last Handler',
                                task.lastChangedByName!,
                                Icons.assignment_ind_rounded),
                          ),
                      ],
                    ),
                  ),

                  // Activity Log Section
                  if (task.activityLog.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.history_rounded,
                                size: 18, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Activity History',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppConstants.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppConstants.dividerColor),
                      ),
                      child: Column(
                        children: List.generate(
                          task.activityLog.length,
                          (index) {
                            final reversedIndex =
                                task.activityLog.length - 1 - index;
                            return ActivityLogTile(
                              log: task.activityLog[reversedIndex],
                              isLast: index == task.activityLog.length - 1,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value, Color color,
      {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppConstants.textTertiary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                onTap == null
                    ? Text(
                        value,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimary,
                        ),
                      )
                    : InkWell(
                        onTap: onTap,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                            decoration: TextDecoration.underline,
                            decorationColor:
                                AppConstants.primaryColor.withOpacity(0.3),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniMetaCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConstants.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppConstants.textSecondary),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
                fontSize: 11,
                color: AppConstants.textSecondary,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppConstants.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
