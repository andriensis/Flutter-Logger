import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_logger/flutter_logger.dart';

/// Page with all available log tags
class FlutterLoggerTagsList extends StatelessWidget {
  /// Page with all available log tags
  const FlutterLoggerTagsList({super.key});

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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildBackButton(context),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: Container(
                  color: const Color(0xFFF9F9FB),
                  child: FutureBuilder(
                    future: FlutterLogger.getLogTags(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const CircularProgressIndicator();
                      } else {
                        if (snapshot.hasError) {
                          return const Column(
                            children: [],
                          );
                        }

                        final data = snapshot.data ?? [];

                        return ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.only(
                            left: 16.0,
                            top: 16.0,
                            right: 16.0,
                            bottom:
                                16.0 + MediaQuery.of(context).padding.bottom,
                          ),
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final item = data[index];
                            return InkWell(
                              onTap: () => FlutterLogger.viewFileForTag(
                                item,
                                context,
                              ),
                              child: Container(
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
                                child: Text(
                                  item,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(
                              height: 8.0,
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
}
