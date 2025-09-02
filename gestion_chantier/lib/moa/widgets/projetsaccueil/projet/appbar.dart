import 'package:flutter/material.dart';
import 'package:gestion_chantier/moa/utils/HexColor.dart';

class CustomProjectAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? textColor;
  final double? elevation;
  final bool automaticallyImplyLeading;

  const CustomProjectAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.textColor,
    this.elevation,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? HexColor('#1A365D'),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        bottom: 15,
      ),
      child: Row(
        children: [
          if (automaticallyImplyLeading)
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: textColor ?? Colors.white,
                size: 24,
              ),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            ),
          if (automaticallyImplyLeading) const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + 25, // Hauteur standard + padding
  );
}
