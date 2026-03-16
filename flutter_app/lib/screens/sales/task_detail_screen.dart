import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/activity_log_tile.dart';

class SalesTaskDetailScreen extends StatefulWidget {
  final String taskId;

  const SalesTaskDetailScreen({super.key, required this.taskId});

  @override
  State<SalesTaskDetailScreen> createState() => _SalesTaskDetailScreenState();
}

class _SalesTaskDetailScreenState extends State<SalesTaskDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTask(widget.taskId);
    });
  }

  void _showChangeStatusSheet(TaskModel task) {
    final noteController = TextEditingController();
    String? selectedStatus;
    bool paymentReceived = false;

    // Determine available statuses
    List<String> availableStatuses = [];
    if (task.status == 'Pending') {
      availableStatuses = ['In Progress'];
    } else if (task.status == 'In Progress') {
      availableStatuses = ['Completed', 'Pending'];
    }

    if (availableStatuses.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppConstants.dividerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Update Task Status',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppConstants.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Move task from ${task.status} to:',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppConstants.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                ...availableStatuses.map((status) {
                  final isSelected = selectedStatus == status;
                  final color = AppConstants.getStatusColor(status);
                  return GestureDetector(
                    onTap: () {
                      setModalState(() => selectedStatus = status);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.08)
                            : AppConstants.surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? color : AppConstants.dividerColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? color : color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              AppConstants.getStatusIcon(status),
                              color: isSelected ? Colors.white : color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color:
                                  isSelected ? color : AppConstants.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            Icon(Icons.check_circle_rounded,
                                color: color, size: 24),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                if (selectedStatus == 'Completed') ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: CheckboxListTile(
                      value: paymentReceived,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppConstants.completedColor,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text(
                        'Payment received',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppConstants.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        paymentReceived
                            ? 'Checked = customer payment collected'
                            : 'Unchecked = payment not received yet',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppConstants.textSecondary,
                        ),
                      ),
                      onChanged: (value) {
                        setModalState(() => paymentReceived = value ?? false);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'ADD A NOTE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppConstants.textTertiary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'What happened during this stage?',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: AppConstants.textSecondary.withOpacity(0.4),
                    ),
                    filled: true,
                    fillColor: AppConstants.surfaceColor,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: AppConstants.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: AppConstants.primaryColor, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      if (selectedStatus != null)
                        BoxShadow(
                          color: AppConstants.primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: selectedStatus == null
                        ? null
                        : () async {
                            Navigator.pop(ctx);
                            final taskProvider = context.read<TaskProvider>();
                            final success = await taskProvider.changeStatus(
                              widget.taskId,
                              selectedStatus!,
                              note: noteController.text.trim(),
                              paymentReceived: selectedStatus == 'Completed'
                                  ? paymentReceived
                                  : null,
                            );
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Task updated to $selectedStatus',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white)),
                                  backgroundColor: AppConstants.getStatusColor(
                                      selectedStatus!),
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.all(16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppConstants.dividerColor,
                      disabledForegroundColor: AppConstants.textTertiary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'CONFIRM UPDATE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _markPaymentReceived() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Mark Payment Received'),
        content: const Text(
          'Confirm that payment has now been received for this completed task.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final taskProvider = context.read<TaskProvider>();
    final success = await taskProvider.updatePaymentStatus(
      widget.taskId,
      true,
      note: 'Payment received after completion',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Payment status updated to received'
              : (taskProvider.error ?? 'Failed to update payment status'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor:
            success ? AppConstants.completedColor : Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.surfaceColor,
      appBar: AppBar(
        title: const Text(
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
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Consumer<TaskProvider>(
          builder: (context, taskProvider, _) {
            if (taskProvider.isLoading && taskProvider.selectedTask == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final task = taskProvider.selectedTask;
            if (task == null) {
              return const Center(child: Text('Task not found'));
            }

            final canChangeStatus =
                task.status == 'Pending' || task.status == 'In Progress';

            return SingleChildScrollView(
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
                        const Divider(
                            height: 48,
                            thickness: 1,
                            color: AppConstants.dividerColor),
                        Text(
                          'DESCRIPTION',
                          style: TextStyle(
                            fontSize: 10,
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

                  // Change Status Button
                  if (canChangeStatus)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              AppConstants.primaryColor,
                              AppConstants.accentIndigo
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppConstants.primaryColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => _showChangeStatusSheet(task),
                          icon: const Icon(Icons.bolt_rounded,
                              size: 20, color: Colors.white),
                          label: const Text(
                            'UPDATE STATUS',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (task.status == 'Completed' &&
                      task.paymentReceived == false)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: AppConstants.completedColor,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppConstants.completedColor.withOpacity(0.28),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _markPaymentReceived,
                          icon: const Icon(Icons.payments_rounded,
                              size: 20, color: Colors.white),
                          label: const Text(
                            'MARK PAYMENT RECEIVED',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Metadata section (Creator/Handler info)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        if (task.createdByName != null)
                          Expanded(
                            child: _miniMetaCard(
                                'Assigned By',
                                task.createdByName!,
                                Icons.admin_panel_settings_rounded),
                          ),
                        if (task.lastChangedByName != null &&
                            task.createdByName != null)
                          const SizedBox(width: 12),
                        if (task.lastChangedByName != null)
                          Expanded(
                            child: _miniMetaCard('Last Update',
                                task.lastChangedByName!, Icons.update_rounded),
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
                              color: AppConstants.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.history_rounded,
                                size: 18, color: AppConstants.primaryColor),
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
            );
          },
        ),
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
