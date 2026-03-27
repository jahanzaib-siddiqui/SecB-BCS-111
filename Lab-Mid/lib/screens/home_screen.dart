import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../app_theme.dart';
import '../widgets/task_tile.dart';
import '../services/export_service.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';
import 'task_detail_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _searchVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    Future.microtask(
        () => Provider.of<TaskProvider>(context, listen: false).fetchTasks());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final isDark = provider.isDarkMode;
    final stats = provider.getStatistics();

    return Scaffold(
      appBar: AppBar(
        title: _searchVisible
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                  filled: false,
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                ),
                onChanged: (q) => provider.setSearchQuery(q),
              )
            : const Text('Task Manager'),
        actions: [
          IconButton(
            icon: Icon(_searchVisible ? Icons.close : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _searchVisible = !_searchVisible;
                if (!_searchVisible) {
                  _searchController.clear();
                  provider.setSearchQuery('');
                }
              });
            },
          ),
          // Priority filter
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter by Priority',
            itemBuilder: (_) => ['All', 'High', 'Medium', 'Low']
                .map((p) => PopupMenuItem(value: p, child: Text(p)))
                .toList(),
            onSelected: (p) => provider.setFilterPriority(p),
          ),
          // Export menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'csv', child: Text('📄 Export CSV')),
              const PopupMenuItem(value: 'pdf', child: Text('📋 Export PDF')),
              const PopupMenuItem(value: 'share', child: Text('📤 Share as Text')),
              const PopupMenuItem(value: 'stats', child: Text('📊 Statistics')),
            ],
            onSelected: (action) async {
              final tasks = provider.allTasks;
              switch (action) {
                case 'csv':
                  final path = await ExportService.exportCSV(tasks);
                  if (mounted && path != null) {
                    _showSnack('CSV saved: $path');
                  }
                  break;
                case 'pdf':
                  final path = await ExportService.exportPDF(tasks);
                  if (mounted && path != null) {
                    _showSnack('PDF saved: $path');
                  }
                  break;
                case 'share':
                  await ExportService.shareAsText(tasks);
                  break;
                case 'stats':
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const StatisticsScreen()),
                    );
                  }
                  break;
              }
            },
          ),
          // Dark mode toggle
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () => provider.toggleTheme(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            _buildTab('Today', stats['today'] as int, AppTheme.primaryColor),
            _buildTab('Upcoming', (stats['pending'] as int) - (stats['today'] as int), AppTheme.accentColor),
            _buildTab('Completed', stats['completed'] as int, AppTheme.successColor),
            _buildTab('Repeated', provider.getRepeatedTasks().length, AppTheme.secondaryColor),
          ],
        ),
      ),

      body: Column(
        children: [
          // Stats summary card
          _buildStatsCard(stats, isDark),

          // Task lists
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(provider.getTodayTasks(), provider, emptyMsg: '🎉 No tasks for today!'),
                _buildTaskList(provider.getUpcomingTasks(), provider, emptyMsg: '✨ No upcoming tasks'),
                _buildTaskList(provider.getCompletedTasks(), provider, emptyMsg: '📭 No completed tasks yet'),
                _buildTaskList(provider.getRepeatedTasks(), provider, emptyMsg: '🔁 No repeated tasks'),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
          if (mounted) provider.fetchTasks();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task'),
      ),
    );
  }

  Tab _buildTab(String label, int count, Color color) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700, color: color),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stats, bool isDark) {
    final rate = stats['completionRate'] as double;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall Progress',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${(rate * 100).toStringAsFixed(0)}% Complete',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: _statPill('${stats['total']}', 'Total', Colors.white.withOpacity(0.2)),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _statPill('${stats['highPriority']}', 'Urgent', AppTheme.errorColor.withOpacity(0.7)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: rate),
              duration: const Duration(milliseconds: 600),
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _quickStat('✅ Done', '${stats['completed']}'),
              _quickStat('⏳ Pending', '${stats['pending']}'),
              _quickStat('📅 Today', '${stats['today']}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statPill(String value, String label, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16)),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,),
        ],
      ),
    );
  }

  Widget _quickStat(String label, String value) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(width: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11)),
      ],
    );
  }

  Widget _buildTaskList(List<Task> tasks, TaskProvider provider,
      {String emptyMsg = 'No tasks'}) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(emptyMsg,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 100),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskTile(
          task: task,
          onDelete: () => provider.deleteTask(task.id!),
          onEdit: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EditTaskScreen(task: task)),
            );
            if (mounted) provider.fetchTasks();
          },
          onComplete: () => provider.toggleComplete(task),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
            );
          },
        );
      },
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontSize: 13)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}