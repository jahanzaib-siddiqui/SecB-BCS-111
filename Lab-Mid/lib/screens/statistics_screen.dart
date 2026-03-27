import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../app_theme.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final stats = provider.getStatistics();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final total = stats['total'] as int;
    final completed = stats['completed'] as int;
    final pending = stats['pending'] as int;
    final today = stats['today'] as int;
    final highPriority = stats['highPriority'] as int;
    final rate = stats['completionRate'] as double;

    // Priority breakdown
    final high = provider.allTasks.where((t) => t.priority == 'High').length;
    final medium = provider.allTasks.where((t) => t.priority == 'Medium').length;
    final low = provider.allTasks.where((t) => t.priority == 'Low').length;

    final repeated = provider.getRepeatedTasks().length;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overview card
          _gradientCard(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Overall Completion',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text('${(rate * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: rate),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    builder: (_, val, __) => LinearProgressIndicator(
                      value: val,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _wStat('Total', '$total'),
                    _wStat('Done', '$completed'),
                    _wStat('Pending', '$pending'),
                    _wStat('Today', '$today'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Stats grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _statCard('✅ Completed', '$completed', AppTheme.successColor, isDark),
              _statCard('⏳ Pending', '$pending', AppTheme.warningColor, isDark),
              _statCard('🔥 Urgent', '$highPriority', AppTheme.errorColor, isDark),
              _statCard('🔁 Repeated', '$repeated', AppTheme.accentColor, isDark),
            ],
          ),

          const SizedBox(height: 20),

          // Priority breakdown
          _sectionTitle('Priority Breakdown'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1F2E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _priorityBar('High', high, total, AppTheme.errorColor),
                const SizedBox(height: 14),
                _priorityBar('Medium', medium, total, AppTheme.warningColor),
                const SizedBox(height: 14),
                _priorityBar('Low', low, total, AppTheme.successColor),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Completion donut (simple visual)
          _sectionTitle('Completion Summary'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1F2E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: total == 0
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No tasks added yet',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  )
                : Column(
                    children: [
                      // Stacked bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          children: [
                            if (completed > 0)
                              Flexible(
                                flex: completed,
                                child: Container(
                                  height: 20,
                                  color: AppTheme.successColor,
                                ),
                              ),
                            if (pending > 0)
                              Flexible(
                                flex: pending,
                                child: Container(
                                  height: 20,
                                  color: AppTheme.warningColor.withOpacity(0.7),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _legend(AppTheme.successColor, 'Completed ($completed)'),
                          const SizedBox(width: 20),
                          _legend(AppTheme.warningColor, 'Pending ($pending)'),
                        ],
                      ),
                    ],
                  ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _gradientCard({required Gradient gradient, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _wStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _statCard(String title, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(title,
              style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _priorityBar(String label, int value, int total, Color color) {
    final frac = total == 0 ? 0.0 : value / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text('$value tasks',
                style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: frac),
            duration: const Duration(milliseconds: 800),
            builder: (_, val, __) => LinearProgressIndicator(
              value: val,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));
  }

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
