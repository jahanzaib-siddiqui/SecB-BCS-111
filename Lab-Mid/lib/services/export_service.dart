import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/task.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class ExportService {
  // ── CSV Export ─────────────────────────────────────────────────────────────
  static Future<String?> exportCSV(List<Task> tasks) async {
    try {
      final List<List<String>> data = [
        ['#', 'Title', 'Description', 'Date', 'Time', 'Priority', 'Status', 'Repeat', 'Progress', 'Subtasks'],
        ...tasks.asMap().entries.map((e) {
          final i = e.key + 1;
          final t = e.value;
          final subtaskList = t.subtasks.asMap().entries.map(
            (s) => '${s.value}(${t.subtaskStatus.length > s.key && t.subtaskStatus[s.key] == 1 ? "✓" : "○"})',
          ).join('; ');
          return [
            '$i',
            t.title,
            t.description,
            t.date,
            t.time,
            t.priority,
            t.isCompleted == 1 ? 'Completed' : 'Pending',
            t.repeat,
            '${(t.getProgress() * 100).toStringAsFixed(0)}%',
            subtaskList,
          ];
        }),
      ];

      final csv = const ListToCsvConverter().convert(data);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/tasks_export.csv');
      await file.writeAsString(csv);
      return file.path;
    } catch (e) {
      debugPrint('exportCSV error: $e');
      return null;
    }
  }

  // ── PDF Export ─────────────────────────────────────────────────────────────
  static Future<String?> exportPDF(List<Task> tasks) async {
    try {
      final pdf = pw.Document();
      final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
      final completed = tasks.where((t) => t.isCompleted == 1).length;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('📋 Task Manager Report',
                      style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                  pw.Text(now, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Total: ${tasks.length}  |  Completed: $completed  |  Pending: ${tasks.length - completed}',
                style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
              ),
              pw.Divider(color: PdfColors.indigo800, thickness: 2),
              pw.SizedBox(height: 8),
            ],
          ),
          build: (context) => tasks.asMap().entries.map((entry) {
            final t = entry.value;
            final progress = t.getProgress();
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  left: pw.BorderSide(
                    color: t.priority == 'High'
                        ? PdfColors.red
                        : t.priority == 'Medium'
                            ? PdfColors.orange
                            : PdfColors.green,
                    width: 4,
                  ),
                ),
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Text(t.title,
                            style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                decoration: t.isCompleted == 1
                                    ? pw.TextDecoration.lineThrough
                                    : null)),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: pw.BoxDecoration(
                          color: t.isCompleted == 1 ? PdfColors.green100 : PdfColors.orange100,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        ),
                        child: pw.Text(
                          t.isCompleted == 1 ? '✓ Done' : '○ Pending',
                          style: pw.TextStyle(
                              fontSize: 10,
                              color: t.isCompleted == 1 ? PdfColors.green800 : PdfColors.orange800,
                              fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  if (t.description.isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(t.description,
                        style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
                  ],
                  pw.SizedBox(height: 4),
                  pw.Row(children: [
                    pw.Text('📅 ${t.date}',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                    if (t.time.isNotEmpty) ...[
                      pw.SizedBox(width: 12),
                      pw.Text('⏰ ${t.time}',
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                    ],
                    pw.SizedBox(width: 12),
                    pw.Text('⚡ ${t.priority}',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                    if (t.repeat != 'None') ...[
                      pw.SizedBox(width: 12),
                      pw.Text('🔁 ${t.repeat}',
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                    ],
                  ]),
                  if (t.subtasks.isNotEmpty) ...[
                    pw.SizedBox(height: 6),
                    pw.Text('Progress: ${(progress * 100).toStringAsFixed(0)}%  (${t.subtaskStatus.where((s) => s == 1).length}/${t.subtasks.length} subtasks)',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    pw.SizedBox(height: 4),
                    pw.LinearProgressIndicator(value: progress, backgroundColor: PdfColors.grey300),
                    pw.SizedBox(height: 4),
                    ...t.subtasks.asMap().entries.map((s) => pw.Text(
                          '  ${t.subtaskStatus.length > s.key && t.subtaskStatus[s.key] == 1 ? "☑" : "☐"} ${s.value}',
                          style: const pw.TextStyle(fontSize: 10),
                        )),
                  ],
                ],
              ),
            );
          }).toList(),
          footer: (context) => pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Task Manager App', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
              pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
            ],
          ),
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/tasks_export.pdf');
      await file.writeAsBytes(await pdf.save());
      return file.path;
    } catch (e) {
      debugPrint('exportPDF error: $e');
      return null;
    }
  }

  // ── Share via Email / System Share ────────────────────────────────────────
  static Future<void> shareCSV(List<Task> tasks) async {
    final path = await exportCSV(tasks);
    if (path != null) {
      await Share.shareXFiles([XFile(path)], text: 'My Task List exported from Task Manager');
    }
  }

  static Future<void> sharePDF(List<Task> tasks) async {
    final path = await exportPDF(tasks);
    if (path != null) {
      await Share.shareXFiles([XFile(path)], text: 'My Task Report from Task Manager');
    }
  }

  /// Share tasks as plain text (works as email body)
  static Future<void> shareAsText(List<Task> tasks) async {
    final buffer = StringBuffer();
    buffer.writeln('📋 My Task List\n');
    for (final t in tasks) {
      final status = t.isCompleted == 1 ? '✅' : '⬜';
      buffer.writeln('$status ${t.title}');
      if (t.description.isNotEmpty) buffer.writeln('   ${t.description}');
      buffer.writeln('   📅 ${t.date}${t.time.isNotEmpty ? " ⏰ ${t.time}" : ""}  ⚡ ${t.priority}');
      if (t.subtasks.isNotEmpty) {
        buffer.writeln('   Progress: ${(t.getProgress() * 100).toStringAsFixed(0)}%');
      }
      buffer.writeln();
    }
    await Share.share(buffer.toString(), subject: 'My Task List - Task Manager App');
  }
}