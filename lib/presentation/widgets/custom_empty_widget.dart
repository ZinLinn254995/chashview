import 'package:flutter/material.dart';

// ---------------------------------------------
// 1. CUSTOM EMPTY WIDGET DEFINITION (Previous Code)
// ---------------------------------------------

/// Screen အနေအထားပေါ်မူတည်ပြီး ပြသပုံစံကို ခွဲခြားသတ်မှတ်ခြင်း
enum EmptyStateType {
  fullScreen, // Screen အပြည့်ပြမည့်နေရာများ (ဥပမာ - Page တစ်ခုလုံး Data မရှိခါ)
  section,    // အစိတ်အပိုင်းတစ်ခုအနေဖြင့်ပြမည့်နေရာများ (ဥပမာ - List အတိုလေးများ)
  mini        // အလွန်သေးငယ်သောနေရာများ
}

class CustomEmptyWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final String? imageAssetPath;
  final String? buttonText;
  final VoidCallback? onPressed;
  final EmptyStateType type;
  final Color? iconColor;

  const CustomEmptyWidget({
    super.key,
    required this.message,
    this.title = 'No Data',
    this.icon,
    this.imageAssetPath,
    this.buttonText,
    this.onPressed,
    this.type = EmptyStateType.fullScreen,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    // Screen Type အလိုက် Size များကို သတ်မှတ်ခြင်း
    final double iconSize = _getIconSize();
    final double titleSize = _getTitleSize(context);
    final double messageSize = _getMessageSize(context);
    final double spacing = type == EmptyStateType.mini ? 8.0 : 16.0;

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Image သို့မဟုတ် Icon ပြသခြင်း
                  if (imageAssetPath != null)
                    Image.asset(
                      imageAssetPath!,
                      width: iconSize * 1.5,
                      height: iconSize * 1.5,
                      fit: BoxFit.contain,
                    )
                  else
                    Icon(
                      icon ?? Icons.inbox_outlined,
                      size: iconSize,
                      color: iconColor ?? Theme.of(context).disabledColor.withValues(alpha: 0.5),
                    ),

                  SizedBox(height: spacing),

                  // 2. Title ပြသခြင်း (Mini type တွင် မပြပါ)
                  if (type != EmptyStateType.mini) ...[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                  ],

                  // 3. Description Message
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: messageSize,
                      color: Theme.of(context).hintColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // 4. Action Button (Retry button စသည်)
                  if (onPressed != null && buttonText != null) ...[
                    SizedBox(height: spacing * 1.5),
                    type == EmptyStateType.mini
                        ? IconButton(
                      onPressed: onPressed,
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: buttonText,
                    )
                        : ElevatedButton.icon(
                      onPressed: onPressed,
                      icon: const Icon(Icons.add_circle_outline),
                      label: Text(buttonText!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper methods to get dynamic sizes
  double _getIconSize() {
    switch (type) {
      case EmptyStateType.fullScreen:
        return 100.0;
      case EmptyStateType.section:
        return 60.0;
      case EmptyStateType.mini:
        return 30.0;
    }
  }

  double _getTitleSize(BuildContext context) {
    switch (type) {
      case EmptyStateType.fullScreen:
        return 22.0;
      case EmptyStateType.section:
        return 18.0;
      case EmptyStateType.mini:
        return 14.0;
    }
  }

  double _getMessageSize(BuildContext context) {
    switch (type) {
      case EmptyStateType.fullScreen:
        return 16.0;
      case EmptyStateType.section:
        return 14.0;
      case EmptyStateType.mini:
        return 12.0;
    }
  }
}
