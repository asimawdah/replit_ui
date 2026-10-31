import 'dart:math' as math;

import 'package:replit_ui/replit_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/layout/breakpoints.dart';
import '../../domain/models/playground_item.dart';
import '../demos/demo_registry.dart';
import '../widgets/code_panel.dart';
import '../widgets/sidebar.dart';
import '../widgets/stage.dart';
import '../widgets/top_bar.dart';

/// The playground's single screen: top bar over sidebar + canvas + code
/// panel. Owns the panel state and the per-item variant memory; the component
/// on the stage comes from the route, and the theme lives with the app so
/// the whole MaterialApp flips.
class PlaygroundShell extends StatefulWidget {
  const PlaygroundShell({
    super.key,
    required this.item,
    required this.onSelect,
    required this.onThemeModeChanged,
  });

  /// The component on the stage — the route's `:component`. The shell
  /// reads it, the router owns it: picking a row navigates, and
  /// navigating (the browser's back button included) restages.
  final PlaygroundItem item;

  /// Selection intent; the app turns it into a route change.
  final ValueChanged<PlaygroundItem> onSelect;

  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<PlaygroundShell> createState() => _PlaygroundShellState();
}

class _PlaygroundShellState extends State<PlaygroundShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _codeOpen = true;

  /// The chosen variant per item; items absent fall back to their first.
  final Map<PlaygroundItem, String> _variants = {};

  String? get _variant {
    final variants = variantsFor(widget.item);
    if (variants.isEmpty) return null;
    return _variants[widget.item] ?? variants.first.$1;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final mobile = width < PlaygroundBreakpoints.mobile;
        final tablet =
            width >= PlaygroundBreakpoints.mobile &&
            width < PlaygroundBreakpoints.desktop;
        final showInlineCode = width >= PlaygroundBreakpoints.inlineCode;
        final drawerWidth = math.min(320.0, width * 0.88).toDouble();

        return Scaffold(
          key: _scaffoldKey,
          drawer: mobile
              ? Drawer(
                  width: drawerWidth,
                  child: SafeArea(
                    child: Sidebar(
                      selected: widget.item,
                      width: drawerWidth,
                      onSelect: (item) {
                        Navigator.of(context).pop();
                        widget.onSelect(item);
                      },
                    ),
                  ),
                )
              : null,
          bottomNavigationBar: mobile
              ? _MobileActions(
                  onBrowse: () => _scaffoldKey.currentState?.openDrawer(),
                  onShowCode: _showCodeSheet,
                )
              : null,
          body: SafeArea(
            top: true,
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TopBar(
                  mobile: mobile,
                  onThemeModeChanged: widget.onThemeModeChanged,
                  codeOpen: showInlineCode && _codeOpen,
                  onToggleCode: showInlineCode
                      ? () => setState(() => _codeOpen = !_codeOpen)
                      : _showCodeDialog,
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (tablet)
                        Sidebar(
                          selected: widget.item,
                          compact: true,
                          onSelect: widget.onSelect,
                        )
                      else if (!mobile)
                        Sidebar(
                          selected: widget.item,
                          onSelect: widget.onSelect,
                        ),
                      Expanded(
                        child: Stage(
                          item: widget.item,
                          variant: _variant,
                          onVariantChanged: (id) =>
                              setState(() => _variants[widget.item] = id),
                        ),
                      ),
                      if (showInlineCode)
                        CodePanel(
                          open: _codeOpen,
                          item: widget.item,
                          variant: _variant,
                          onClose: () => setState(() => _codeOpen = false),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showCodeSheet() async {
    final height = MediaQuery.sizeOf(context).height;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: height * 0.82,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          child: CodePanel(
            compact: true,
            open: true,
            item: widget.item,
            variant: _variant,
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  Future<void> _showCodeDialog() async {
    final size = MediaQuery.sizeOf(context);
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: math.min(720.0, size.width - 48).toDouble(),
          height: size.height * 0.84,
          child: CodePanel(
            compact: true,
            open: true,
            item: widget.item,
            variant: _variant,
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}

class _MobileActions extends StatelessWidget {
  const _MobileActions({required this.onBrowse, required this.onShowCode});

  final VoidCallback onBrowse;
  final VoidCallback onShowCode;

  @override
  Widget build(BuildContext context) {
    final colors = context.replitColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceBright,
        border: Border(top: BorderSide(color: colors.outline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              _MobileAction(
                icon: Icons.grid_view_rounded,
                label: 'Browse',
                onTap: onBrowse,
              ),
              _MobileAction(
                icon: Icons.code_rounded,
                label: 'Code',
                onTap: onShowCode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileAction extends StatelessWidget {
  const _MobileAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.replitColors;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: colors.onSurfaceVariant),
            const SizedBox(height: 3),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
