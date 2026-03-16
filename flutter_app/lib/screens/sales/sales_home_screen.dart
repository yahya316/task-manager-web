import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/task_card.dart';
import '../../widgets/skeleton_loader.dart';
import '../../utils/helpers.dart';
import 'package:go_router/go_router.dart';

class SalesHomeScreen extends StatefulWidget {
  const SalesHomeScreen({super.key});

  @override
  State<SalesHomeScreen> createState() => _SalesHomeScreenState();
}

class _SalesHomeScreenState extends State<SalesHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _filters = [
    'All',
    'Pending',
    'In Progress',
    'Completed',
    'Payment Received',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppConstants.surfaceColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Tasks',
              style: TextStyle(
                fontSize: sw(context, 22),
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                color: AppConstants.primaryColor,
              ),
            ),
            Text(
              'Hello, ${user?.name ?? 'Team Member'}',
              style: TextStyle(
                fontSize: sw(context, 12),
                color: AppConstants.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.surfaceColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.refresh_rounded,
                  size: 20, color: AppConstants.textPrimary),
            ),
            onPressed: () => context.read<TaskProvider>().loadTasks(),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.accentRose.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded,
                  size: 20, color: AppConstants.cancelledColor),
            ),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (mounted) context.go('/login');
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            width: double.infinity,
            child: TabBar(
              controller: _tabController,
              labelColor: AppConstants.primaryColor,
              unselectedLabelColor: AppConstants.textSecondary,
              indicatorColor: AppConstants.primaryColor,
              indicatorWeight: 3,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle:
                  TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              tabs: _filters.map((f) => Tab(text: f)).toList(),
            ),
          ),
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, _) {
          return TabBarView(
            controller: _tabController,
            children: _filters.map((filter) {
              if (taskProvider.isLoading) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: 5,
                  itemBuilder: (context, index) => const TaskCardSkeleton(),
                );
              }

              final filteredTasks = filter == 'All'
                  ? taskProvider.tasks
                  : filter == 'Payment Received'
                      ? taskProvider.tasks
                          .where((t) => t.paymentReceived == true)
                          .toList()
                      : taskProvider.tasks
                          .where((t) => t.status == filter)
                          .toList();

              if (filteredTasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppConstants.dividerColor.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: AppConstants.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No tasks assigned',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        filter == 'All'
                            ? 'You don\'t have any tasks at the moment.'
                            : filter == 'Payment Received'
                                ? 'No completed tasks with payment received yet.'
                                : 'No tasks currently marked as $filter.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppConstants.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => taskProvider.loadTasks(),
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 12, bottom: 24),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    return TaskCard(
                      task: filteredTasks[index],
                      onTap: () {
                        context.push('/sales/task/${filteredTasks[index].id}');
                      },
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
