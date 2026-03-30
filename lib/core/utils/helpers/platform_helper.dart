import 'package:flutter/foundation.dart';

bool get isWeb => kIsWeb;

bool get isAndroid =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

bool get isMacOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

bool get isLinux => !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;

bool get isWindows =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

bool get isFuchsia =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.fuchsia;

bool get isDesktop => isMacOS || isLinux || isWindows;

bool get isMobile => isAndroid || isIOS;
