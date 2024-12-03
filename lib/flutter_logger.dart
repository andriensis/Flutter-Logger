import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_logger/ui/flutter_logger_tags_list.dart';
import 'package:file_logger/ui/flutter_logger_viewer.dart';
import 'package:path_provider/path_provider.dart';

/// Flutter Logger
class FlutterLogger {
  static int _maxFileSizeMb = 2;

  /// Set up Flutter Logger
  /// [maxFileSizeMb] asgas
  static init({
    /// Maximum size (in MB) of logs file / when exceeded file will be cleaned up until the file is half of the set size
    /// Default value is 2MB. If file exceeds 2MB older logs will be deleted until the file is ~ 1MB
    int maxFileSizeMb = 2,
  }) {
    _maxFileSizeMb = maxFileSizeMb;
  }

  static Future<String> get _localPath async {
    Directory directory;

    if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = (await getExternalStorageDirectory())!;
    }
    return directory.path;
  }

  static Future<File> _localFile(String tag) async {
    final path = await _localPath;
    return File('$path/file-logger-$tag.txt');
  }

  /// Log a [logMessage] to a log [tag] file
  static void log({
    /// Log tag (file name) where to store the log message
    required String tag,
    required String logMessage,
  }) async {
    debugPrint(
      '[$tag] $logMessage',
    );

    var file = await _localFile(tag);
    final timestamp = DateTime.now().toIso8601String();

    file.writeAsString(
      '$timestamp: $logMessage\n',
      mode: FileMode.append,
    );

    int sizeInBytes = file.lengthSync();
    double sizeInMb = sizeInBytes / (1024 * 1024);
    if (sizeInMb > _maxFileSizeMb) {
      while (sizeInMb > _maxFileSizeMb / 2) {
        final fileContent = file.readAsLinesSync();
        final cleanedUpContent = fileContent.sublist(fileContent.length ~/ 10);
        file.writeAsStringSync(cleanedUpContent.join('\n'),
            mode: FileMode.write);

        file = await _localFile(tag);
        sizeInBytes = file.lengthSync();
        sizeInMb = sizeInBytes / (1024 * 1024);
      }
    }
  }

  /// Get file reference to log tag (file)
  static Future<File> fileForTag(String tag) => _localFile(tag);

  /// Clean up logs for a specific tag (file)
  static deleteLogsForTag(String tag) async {
    final file = await _localFile(tag);
    await file.writeAsString('', mode: FileMode.write);
  }

  /// Retrieves a list of all the log tags (files) created on the log directory
  static Future<List<String>> getLogTags() async {
    List<String> tagsList = [];
    final files = Directory('${await _localPath}/').listSync();
    for (FileSystemEntity file in files) {
      final fileName = file.uri.pathSegments.last;
      if (fileName.startsWith('file-logger-') && fileName.endsWith('.txt')) {
        tagsList.add(
            fileName.replaceAll('.txt', '').replaceAll('file-logger-', ''));
      }
    }
    return Future(() => tagsList);
  }

  /// Display a page showing logs for a tag (file)
  static viewFileForTag(String tag, BuildContext context) async {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (buildContext, animation, secondaryAnimation) {
        return FlutterLoggerViewer(logTag: tag);
      },
    );
  }

  /// Display a page showing all available log tags (files)
  static viewLogTagsPage(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (buildContext, animation, secondaryAnimation) {
        return const FlutterLoggerTagsList();
      },
    );
  }
}
