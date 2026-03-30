import 'package:flutter/foundation.dart';

/// Web stub for dart:io Platform
class Platform {
  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  static bool get isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isMacOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
  static bool get isLinux =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
  static bool get isWindows =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  static bool get isFuchsia =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.fuchsia;
}

/// Web stub for dart:io Directory
class Directory {
  final String path;
  Directory(this.path);
  bool existsSync() => false;
  void createSync({bool recursive = false}) {}
  List<dynamic> listSync({bool recursive = false}) => [];
}

/// Web stub for dart:io File
class File {
  final String path;
  File(this.path);
  bool existsSync() => false;
  Future<File> writeAsBytes(List<int> bytes) async => this;
  Uint8List readAsBytesSync() => Uint8List(0);
  Future<File> create({bool recursive = false}) async => this;
  Future<void> delete({bool recursive = false}) async {}
}
