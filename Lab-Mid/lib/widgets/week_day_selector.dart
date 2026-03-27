import 'package:flutter/material.dart';
import '../app_theme.dart';

class WeekDaySelector extends StatefulWidget {
  final List<String> selectedDays;
  final ValueChanged<List<String>> onChanged;

  const WeekDaySelector({
    super.key,
    required this.selectedDays,
    required this.onChanged,
  });

  @override
  State<WeekDaySelector> createState() => _WeekDaySelectorState();
}

class _WeekDaySelectorState extends State<WeekDaySelector> {
  static const List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedDays);
  }

  void _toggle(String day) {
    setState(() {
      if (_selected.contains(day)) {
        _selected.remove(day);
      } else {
        _selected.add(day);
      }
    });
    widget.onChanged(List.from(_selected));
  }

  void _selectAll() {
    setState(() {
      _selected = List.from(_days);
    });
    widget.onChanged(List.from(_selected));
  }

  void _clearAll() {
    setState(() {
      _selected.clear();
    });
    widget.onChanged([]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Repeat Days',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: _selectAll,
                  child: Text(
                    'All Week',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _clearAll,
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _days.map((day) {
            final isSelected = _selected.contains(day);
            final isWeekend = day == 'Sat' || day == 'Sun';
            return GestureDetector(
              onTap: () => _toggle(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : (isWeekend
                          ? AppTheme.errorColor.withOpacity(0.08)
                          : Colors.grey.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    day.substring(0, 1),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : (isWeekend
                              ? AppTheme.errorColor
                              : Colors.grey.shade600),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
