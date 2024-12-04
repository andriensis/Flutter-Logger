# Flutter Logger

This package lets you store logs on the user device and view them without having to build a custom UI for that.
You can also mark logs with a ```tag``` to view them in different pages.

## How to use?
**1:** Add this to your package's pubspec.yaml file:
```yaml
dependencies:
  file_logger: LATEST_VERSION
```

**2:** Install packages from the command line:
```bash
$ flutter packages get
```

**3:** Import the package and start using it
```dart
import 'package:file_logger/flutter_logger.dart';

FlutterLogger.log(tag: 'network', logMessage: 'network is down!'); // log a message
FlutterLogger.log(tag: 'bluetooth', logMessage: 'bluetooth enabled'); // log a message

FlutterLogger.viewLogTagsPage(context); // show the log tags page
FlutterLogger.viewFileForTag('network', context); // show the network tag logs page
```

<img src="https://github.com/andriensis/Flutter-Logger/blob/main/doc/log-tags.png?raw=true" alt="Log tags page" width="200"/>
<img src="https://github.com/andriensis/Flutter-Logger/blob/main/doc/log-page.png?raw=true" alt="Logs page showing logs for tealium tag" width="200"/>