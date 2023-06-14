# flutter_in_app_debugger

A library that supports debugging in the app or on the web via a remote server (in development).

Current functions:
- Network inspector.
- Log view

## Installation Instructions

Use this package as a library by depending on it

Run this command:

- With Flutter:

```dart
$ flutter pub flutter_in_app_debugger
```

This will add a line like this to your package's pubspec.yaml (and run an implicit dart pub get):

```dart
dependencies:
  debug_logger: ^{lastest version}
```

Alternatively, your editor might support flutter pub get. Check the docs for your editor to learn more.

Lastly:

Import it like so:

```dart
import 'package:flutter_in_app_debugger/home/overlay_view.dart';
```
