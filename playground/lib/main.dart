import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:material_ui/material_ui.dart';

import 'playground_app.dart';
import 'src/features/playground/playground.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // `?embed=` boots the chrome-less single-demo mode the docs site
  // iframes. It shows no code panel, so the grammar load is skipped for a
  // faster first paint. On non-web platforms Uri.base has no query — the
  // full playground always boots.
  final embed = EmbedRequest.fromUri(Uri.base);
  if (embed != null) {
    runApp(EmbedApp(request: embed));
    return;
  }
  // Path URLs for the components: /playground/composer, not a hash route.
  // It goes *after* the embed branch on purpose — the docs iframe
  // /playground/index.html?embed=…, and under this strategy that reads as
  // the route name "/index.html", which the embed's plain Navigator can't
  // build. The embed returns above, so it never sees one. Off the web this
  // call is a documented no-op.
  usePathUrlStrategy();
  runApp(const PlaygroundApp());
}
