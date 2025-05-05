import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

class LoggingService {
  static final Logger _logger = Logger();
  static File? _logFile;
  static StreamController<String> _logStreamController = StreamController.broadcast();

  static Stream<String> get logStream => _logStreamController.stream;

  static Future<void> initialize() async {
    try {
      // For iOS, use the Documents directory which can be made visible via File Sharing
      final directory = await getApplicationDocumentsDirectory();
      _logFile = File('${directory.path}/app_logs.txt');

      // For Android, you could use external storage if needed
      // final directory = await getExternalStorageDirectory();

      _logger.i('Logs stored at: ${_logFile?.path}');
    } catch (e) {
      _logger.e('Failed to initialize logging: $e');
    }
  }

  static void log(String message, {Level level = Level.info}) {
    final timestamp = DateTime.now().toIso8601String();
    final formattedMessage = '[$timestamp] $level: $message\n';

    _logger.log(level, message);
    _logStreamController.add(formattedMessage);
    _logFile?.writeAsString(formattedMessage, mode: FileMode.append);
  }

  static Future<String?> getLogs() async {
    try {
      return await _logFile?.readAsString();
    } catch (e) {
      log('Error reading logs: $e', level: Level.error);
      return null;
    }
  }
}