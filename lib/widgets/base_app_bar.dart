import 'package:material_ui/material_ui.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final double? leadingWidth;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final double? appBarHeight;

  const BaseAppBar({
    this.title,
    this.leading,
    this.leadingWidth,
    this.actions = const [],
    this.bottom,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.appBarHeight,
    super.key,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    (appBarHeight ?? kToolbarHeight) + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      leading: leading,
      leadingWidth: leadingWidth,
      actions: actions,
      bottom: bottom,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }
}
