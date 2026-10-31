/// The package's own file-drop detection, where the platform has any.
///
/// Only the web does. The Flutter SDK carries no OS file-drop support in
/// the framework or the engine on any target, so the desktop and mobile
/// implementation is the stub: it registers nothing and reports nothing,
/// and hosts that want drop there keep driving `ReplitChatView.dropActive`
/// themselves from a plugin of their choosing.
library;

export 'replit_file_drop_stub.dart'
    if (dart.library.js_interop) 'replit_file_drop_web.dart';
