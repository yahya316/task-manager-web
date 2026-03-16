import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/activity_log_tile.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadActivity();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.surfaceColor,
      appBar: AppBar(
        title: Text('Activity Feed', style: TextStyle(fontSize: sw(context, 20), fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: sw(context, 24)),
            onPressed: () => context.read<TaskProvider>().loadActivity(),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<TaskProvider>(
          builder: (context, taskProvider, _) {
          if (taskProvider.isLoading && taskProvider.activityFeed.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (taskProvider.activityFeed.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timeline_outlined,
                    size: sw(context, 64),
                    color: AppConstants.textSecondary.withOpacity(0.3),
                  ),
                  SizedBox(height: sh(context, 16)),
                  Text(
                    'No activity yet',
                    style: TextStyle(
                      fontSize: sw(context, 16),
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textSecondary,
                    ),
                  ),
                  SizedBox(height: sh(context, 8)),
                  Text(
                    'Activity will appear here when tasks are updated',
                    style: TextStyle(
                      fontSize: sw(context, 13),
                      color: AppConstants.textSecondary.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => taskProvider.loadActivity(),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: sw(context, 16), vertical: 8),
              itemCount: taskProvider.activityFeed.length,
              itemBuilder: (context, index) {
                final log = taskProvider.activityFeed[index];
                
                bool showDateHeader = false;
                if (index == 0) {
                  showDateHeader = true;
                } else {
                  final prevLog = taskProvider.activityFeed[index - 1];
                  final date1 = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
                  final date2 = DateTime(prevLog.timestamp.year, prevLog.timestamp.month, prevLog.timestamp.day);
                  if (date1 != date2) {
                    showDateHeader = true;
                  }
                }

                return Column(
                  children: [
                    if (showDateHeader) _buildDateSeparator(_getDateLabel(log.timestamp)),
                    Container(
                      margin: const EdgeInsets.only(bottom: 2),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ActivityLogTile(
                        log: log,
                        showTaskTitle: true,
                        isLast: index == taskProvider.activityFeed.length - 1,
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
      ),
    );
  }

  Widget _buildDateSeparator(String dateLabel) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              dateLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
        ],
      ),
    );
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) return 'Today';
    if (itemDate == yesterday) return 'Yesterday';

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }
}
