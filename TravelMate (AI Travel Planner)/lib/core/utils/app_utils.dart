import 'package:intl/intl.dart';

class AppUtils {
  // ─── Currency Formatting ──────────────────────────────────────────────────────
  static String formatCurrency(double amount, {String symbol = 'PKR'}) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '$symbol ${formatter.format(amount)}';
  }

  // ─── Date Formatting ──────────────────────────────────────────────────────────
  static String formatDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('d MMM').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('d MMM yyyy, h:mm a').format(date);
  }

  static int calculateDays(DateTime start, DateTime end) {
    return end.difference(start).inDays + 1;
  }

  // ─── Budget Per Day ────────────────────────────────────────────────────────────
  static double budgetPerDay(double total, DateTime start, DateTime end) {
    final days = calculateDays(start, end);
    return days > 0 ? total / days : total;
  }

  // ─── Percentage ────────────────────────────────────────────────────────────────
  static String formatPercent(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  // ─── String Utils ─────────────────────────────────────────────────────────────
  static String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // ─── Validation ───────────────────────────────────────────────────────────────
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!re.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    return null;
  }

  // ─── Rating Display ────────────────────────────────────────────────────────────
  static String ratingToStars(double rating) {
    final full = rating.floor();
    final hasHalf = (rating - full) >= 0.5;
    return '${'★' * full}${hasHalf ? '½' : ''}${'☆' * (5 - full - (hasHalf ? 1 : 0))}';
  }
}
