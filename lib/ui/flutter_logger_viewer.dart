// ignore_for_file: no_logic_in_create_state

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_logger/flutter_logger.dart';
import 'package:share_plus/share_plus.dart';

/// Page with all logs for a specific tag
class FlutterLoggerViewer extends StatefulWidget {
  /// Page with all logs for a specific tag
  const FlutterLoggerViewer({
    super.key,
    required this.logTag,
  });

  /// Log tag (file) to look logs for
  final String logTag;

  @override
  State<FlutterLoggerViewer> createState() => _FlutterLoggerViewerState(
        logTag: logTag,
      );
}

class _FlutterLoggerViewerState extends State<FlutterLoggerViewer> {
  final String logTag;
  late Future<File> getLogFuture;

  _FlutterLoggerViewerState({
    required this.logTag,
  }) {
    getLogFuture = FlutterLogger.fileForTag(logTag);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBackButton(context),
                    Text(
                      'Logs: $logTag',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildRemoveButton(),
                        const SizedBox(width: 8.0),
                        _buildShareButton(),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: Container(
                  color: const Color(0xFFF9F9FB),
                  child: FutureBuilder(
                    future: getLogFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const CircularProgressIndicator();
                      } else {
                        if (snapshot.hasError) {
                          return const Column(
                            children: [],
                          );
                        }

                        List<String> logs = [];
                        try {
                          logs = snapshot.data!.readAsLinesSync();
                          // ignore: empty_catches
                        } catch (e) {}
                        logs.sort((a, b) => b.compareTo(a));

                        return ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.only(
                            left: 16.0,
                            top: 16.0,
                            right: 16.0,
                            bottom:
                                16.0 + MediaQuery.of(context).padding.bottom,
                          ),
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            final log = logs[index];
                            return Text(
                              log,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.black,
                                    fontSize: 14.0,
                                    letterSpacing: -0.28,
                                  ),
                              textAlign: TextAlign.start,
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(
                              height: 2.0,
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildButtonContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFF2F2F4),
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: child,
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(),
      child: _buildButtonContainer(
        child: const Row(
          children: [
            SizedBox(
              width: 24.0,
              height: 24.0,
              child: Icon(
                Icons.arrow_back_ios_outlined,
                size: 24.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return InkWell(
      onTap: () async {
        final file = await FlutterLogger.fileForTag(logTag);
        Share.shareXFiles([XFile(file.path)]);
      },
      child: _buildButtonContainer(
        child: const Row(
          children: [
            SizedBox(
              width: 24.0,
              height: 24.0,
              child: Icon(
                Icons.share,
                size: 24.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoveButton() {
    return InkWell(
      onTap: () {
        FlutterLogger.deleteLogsForTag(logTag);
        setState(() {
          getLogFuture = FlutterLogger.fileForTag(logTag);
        });
      },
      child: _buildButtonContainer(
        child: const Row(
          children: [
            SizedBox(
              width: 24.0,
              height: 24.0,
              child: Icon(
                Icons.delete_outline,
                size: 24.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
