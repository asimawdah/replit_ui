import 'package:material_ui/material_ui.dart';

import '../styles/replit_menu_style.dart';
import '../theme/replit_theme.dart';
import 'replit_circle_button.dart';
import 'replit_menu_core.dart';

// The bottom-sheet presentation of the selector menus.
// Not exported from the package barrel.

/// Matches the anchored menus' feel; the sheet is the same surface.
const Duration _pageTransition = Duration(milliseconds: 180);

const double _navHeight = 56;
const double _navIconSize = 20;

/// The design's sheet metrics: 24px top corners, the nav bar inset 12 and
/// nudged 4 off the corner, 48 under the last row.
const Radius _sheetCornerRadius = Radius.circular(24);
const double _navInset = 12;
const double _navTopInset = 4;
const double _bottomPadding = 48;

/// The rendered width of the leading nav button — derived, not a spec
/// value, so resizing the icon or the disc keeps the title centered.
const double _navBalanceWidth =
    _navIconSize + 2 * ReplitCircleButton.defaultPadding;

/// One screen of a menu sheet: the root list, or a pushed submenu page.
///
/// [children] is a builder rather than a list so rows are created under the
/// [ReplitMenuSheetScope], letting them close the sheet or push a deeper page,
/// and so a pushed page re-renders when the host's state changes behind it.
class ReplitMenuSheetPage {
  const ReplitMenuSheetPage({this.title, required this.children});

  /// Centered in the sheet's nav bar. Null leaves only the close button.
  final String? title;

  final List<Widget> Function(BuildContext context) children;
}

/// Opens [root] as a modal bottom sheet styled like the anchored menus.
///
/// Rides material_ui's modal-sheet route, which itself requires its
/// [MaterialLocalizations]: a host not built on [MaterialApp] must list
/// `DefaultMaterialLocalizations.delegate` in its `localizationsDelegates`
/// for the phone presentation — localized apps get it through
/// `GlobalMaterialLocalizations.delegates`, which since the material_ui
/// move also bundles the widgets and Cupertino delegates. Nothing else in
/// the package needs it.
Future<void> showReplitMenuSheet({
  required BuildContext context,
  required ReplitMenuSheetPage root,
  ReplitMenuStyle? style,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: replitMenuBackground(context, style),
    barrierColor: style?.barrierColor,
    // The sheet is the raised card again: top corners at the card radius,
    // edged in the palette's firm hairline.
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: style?.sheetRadius ?? _sheetCornerRadius,
      ),
      side: BorderSide(color: replitMenuBorderColor(context, style)),
    ),
    clipBehavior: Clip.antiAlias,
    useSafeArea: true,
    builder: (context) => _ReplitMenuSheet(root: root, style: style),
  );
}

/// Lets rows built inside the sheet dismiss it or push a deeper page —
/// the sheet counterpart of the `MenuController` an anchored row reaches
/// through its context.
class ReplitMenuSheetScope extends InheritedWidget {
  const ReplitMenuSheetScope({
    super.key,
    required this.close,
    required this.push,
    required super.child,
  });

  /// Pops the whole sheet.
  final VoidCallback close;

  /// Pushes a deeper page, e.g. the effort list.
  final ValueChanged<ReplitMenuSheetPage> push;

  static ReplitMenuSheetScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ReplitMenuSheetScope>();

  @override
  bool updateShouldNotify(ReplitMenuSheetScope oldWidget) =>
      close != oldWidget.close || push != oldWidget.push;
}

class _ReplitMenuSheet extends StatefulWidget {
  const _ReplitMenuSheet({required this.root, this.style});

  final ReplitMenuSheetPage root;
  final ReplitMenuStyle? style;

  @override
  State<_ReplitMenuSheet> createState() => _ReplitMenuSheetState();
}

class _ReplitMenuSheetState extends State<_ReplitMenuSheet> {
  late final List<ReplitMenuSheetPage> _stack = [widget.root];

  void close() => Navigator.of(context).pop();

  void push(ReplitMenuSheetPage page) => setState(() => _stack.add(page));

  void _pop() => setState(() => _stack.removeLast());

  @override
  Widget build(BuildContext context) {
    final colors = context.replitColors;
    final page = _stack.last;
    final atRoot = _stack.length == 1;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : _pageTransition;
    // Not MaterialLocalizations.of: like the preview's close button, a
    // missing tooltip must not be the one thing that throws.
    final localizations = Localizations.of<MaterialLocalizations>(
      context,
      MaterialLocalizations,
    );

    final navBar = SizedBox(
      height: _navHeight,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: _navInset,
          end: _navInset,
          top: _navTopInset,
        ),
        child: Row(
          children: [
            ReplitCircleButton(
              icon: atRoot ? Icons.close : Icons.arrow_back,
              background: Colors.transparent,
              foreground: colors.onSurfaceVariant,
              iconSize: _navIconSize,
              tooltip: atRoot
                  ? localizations?.closeButtonTooltip
                  : localizations?.backButtonTooltip,
              onTap: atRoot ? close : _pop,
            ),
            Expanded(
              child: page.title == null
                  ? const SizedBox.shrink()
                  : Text(
                      page.title!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.replitTypography.labelLargeEmphasised
                          .copyWith(color: colors.onSurface),
                    ),
            ),
            // Balances the leading button so the title stays centered.
            const SizedBox(width: _navBalanceWidth),
          ],
        ),
      ),
    );

    // Back gestures pop the pushed page before they dismiss the sheet.
    return PopScope(
      canPop: atRoot,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _pop();
      },
      child: ReplitMenuSheetScope(
        close: close,
        push: push,
        child: AnimatedSize(
          duration: duration,
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: duration,
            // A Builder rather than this State's context: the children
            // builder must see a context *below* the scope, or the rows'
            // ReplitMenuSheetScope.maybeOf would come back null and pushing
            // a page from them would silently do nothing.
            child: Builder(
              key: ValueKey(_stack.length),
              builder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  navBar,
                  ...page.children(context),
                  const SizedBox(height: _bottomPadding),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
