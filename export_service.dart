import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../features/tasks/domain/task_models.dart';

class ExportService {
  const ExportService();

  Future<File> exportCsv(List<Task> tasks) async {
    final rows = <List<dynamic>>[
      <String>[
        'Title',
        'Description',
        'Due Date',
        'Reminder',
        'Priority',
        'Completed',
        'Repeat',
        'Subtasks',
      ],
      ...tasks.map(
        (task) => <dynamic>[
          task.title,
          task.description,
          DateFormat('yyyy-MM-dd HH:mm').format(task.dueDate),
          task.reminderAt == null
              ? ''
              : DateFormat('yyyy-MM-dd HH:mm').format(task.reminderAt!),
          task.priority.name,
          task.isCompleted ? 'Yes' : 'No',
          task.repeatRule.label,
          task.subtasks.map((subtask) => subtask.title).join(' | '),
        ],
      ),
    ];

    final csv = const CsvEncoder().convert(rows);
    return _writeExportFile(
      _buildExportFileName('tasks', 'csv'),
      Uint8List.fromList(csv.codeUnits),
    );
  }

  Future<File> exportPdf(List<Task> tasks) async {
    final document = pw.Document();
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    document.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(
          margin: pw.EdgeInsets.all(32),
        ),
        build: (context) {
          return <pw.Widget>[
            pw.Text(
              'Todo',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 26,
                color: PdfColor.fromHex('#24389C'),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Task export generated on ${dateFormat.format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 24),
            ...tasks.map(
              (task) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 16),
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F3F3F6'),
                  borderRadius: pw.BorderRadius.circular(16),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Text(
                      task.title,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(task.description),
                    pw.SizedBox(height: 8),
                    pw.Text('Due: ${dateFormat.format(task.dueDate)}'),
                    pw.Text('Repeat: ${task.repeatRule.label}'),
                    pw.Text(
                      'Progress: ${task.progress.completed}/${task.progress.total}',
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
      ),
    );
    return _writeExportFile(
      _buildExportFileName('tasks', 'pdf'),
      await document.save(),
    );
  }

  Future<void> shareByEmail(List<Task> tasks) async {
    final csvFile = await exportCsv(tasks);
    final pdfFile = await exportPdf(tasks);
    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[
          XFile(csvFile.path),
          XFile(pdfFile.path),
        ],
        subject: 'Todo export',
        text: 'Attached are the latest task exports from Todo.',
      ),
    );
  }

  Future<OpenResult> openFile(File file) {
    return OpenFilex.open(file.path);
  }

  String _buildExportFileName(String baseName, String extension) {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return '$baseName-$timestamp.$extension';
  }

  Future<File> _writeExportFile(String name, List<int> bytes) async {
    final directory = await _getExportDirectory();
    final file = File(path.join(directory.path, name));
    return file.writeAsBytes(bytes, flush: true);
  }

  Future<Directory> _getExportDirectory() async {
    final downloadsDirectory = await getDownloadsDirectory();
    if (downloadsDirectory != null) {
      await downloadsDirectory.create(recursive: true);
      return downloadsDirectory;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    await documentsDirectory.create(recursive: true);
    return documentsDirectory;
  }
}
