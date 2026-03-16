import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/task_card.dart';
import '../../widgets/skeleton_loader.dart';
import '../../utils/helpers.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _filters = [
    'All',
    'Pending',
    'In Progress',
    'Completed',
    'Payment Received',
    'Cancelled'
  ];
  int _currentNavIndex = 0;

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

  void _onNavTap(int index) {
    setState(() => _currentNavIndex = index);
    if (index == 1) {
      context.push('/manager/team');
    } else if (index == 2) {
      context.push('/manager/activity');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.surfaceColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Manager',
              style: TextStyle(
                fontSize: sw(context, 22),
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                color: AppConstants.primaryColor,
              ),
            ),
            Text(
              'Good morning, Manager',
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
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, _) {
          return Column(
            children: [
              // Summary Section
              Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          _summaryCard(
                            'Total Tasks',
                            taskProvider.totalTasks,
                            const LinearGradient(
                                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
                            Icons.task_alt_rounded,
                            context,
                          ),
                          const SizedBox(width: 12),
                          _summaryCard(
                            'Pending',
                            taskProvider.pendingTasks,
                            const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                            Icons.pending_actions_rounded,
                            context,
                          ),
                          const SizedBox(width: 12),
                          _summaryCard(
                            'In Progress',
                            taskProvider.inProgressTasks,
                            const LinearGradient(
                                colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
                            Icons.sync_rounded,
                            context,
                          ),
                          const SizedBox(width: 12),
                          _summaryCard(
                            'Completed',
                            taskProvider.completedTasks,
                            const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF059669)]),
                            Icons.check_circle_rounded,
                            context,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Filter tabs
              Container(
                color: Colors.white,
                width: double.infinity,
                alignment: Alignment.centerLeft,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: AppConstants.primaryColor,
                  unselectedLabelColor: AppConstants.textSecondary,
                  indicatorColor: AppConstants.primaryColor,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 14),
                  tabs: _filters.map((f) => Tab(text: f)).toList(),
                ),
              ),

              const Divider(
                  height: 1, thickness: 1, color: AppConstants.dividerColor),

              // Task list
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _filters.map((filter) {
                    if (taskProvider.isLoading) {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: 5,
                        itemBuilder: (context, index) =>
                            const TaskCardSkeleton(),
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
                                color:
                                    AppConstants.dividerColor.withOpacity(0.3),
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
                              'No tasks found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              filter == 'All'
                                  ? 'Get started by creating your first task!'
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
                        padding: EdgeInsets.only(top: 12, bottom: 100),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          return TaskCard(
                            task: filteredTasks[index],
                            showLastHandler: true,
                            onTap: () {
                              context.push(
                                '/manager/task/${filteredTasks[index].id}',
                              );
                            },
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/manager/create-task'),
        backgroundColor: const Color(0xFF4F46E5),
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        label: const Text(
          "New Task",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: _onNavTap,
        backgroundColor: Colors.white,
        elevation: 10,
        height: 70,
        indicatorColor: AppConstants.primaryColor.withOpacity(0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.splitscreen_rounded),
            selectedIcon: Icon(Icons.splitscreen_rounded,
                color: AppConstants.primaryColor),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.supervised_user_circle_outlined),
            selectedIcon: Icon(Icons.supervised_user_circle_rounded,
                color: AppConstants.primaryColor),
            label: 'Team',
          ),
          NavigationDestination(
            icon: Icon(Icons.speed_outlined),
            selectedIcon:
                Icon(Icons.speed_rounded, color: AppConstants.primaryColor),
            label: 'Activity',
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, int count, Gradient gradient, IconData icon,
      BuildContext context) {
    return Container(
      width: 140,
      height: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 6),
            color: (gradient as LinearGradient).colors.first.withOpacity(0.35),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const Spacer(),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }
}
