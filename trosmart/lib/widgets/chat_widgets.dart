import 'package:flutter/material.dart';
import '../shared/app_theme.dart';

/// Chat bubble widget for both sent and received messages.
class ChatBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isSent;

  /// For admin chat detail: sent = purple bubble, received = dark bubble.
  /// For user chat: sent = purple bubble, received = white bubble.
  final Color? backgroundColor;
  final Color? textColor;

  const ChatBubble({
    super.key,
    required this.message,
    required this.time,
    this.isSent = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ??
        (isSent
            ? AppTheme.deepPurple.withValues(alpha: 0.80)
            : AppTheme.bgDarkCard);
    final msgColor = textColor ?? Colors.white;

    return Column(
      crossAxisAlignment:
          isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: ShapeDecoration(
            color: bgColor,
            shape: RoundedRectangleBorder(
              side: isSent
                  ? BorderSide.none
                  : BorderSide(
                      width: 1,
                      color: AppTheme.bgGray100,
                    ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isSent ? 16 : 4),
                topRight: Radius.circular(isSent ? 4 : 16),
                bottomLeft: const Radius.circular(16),
                bottomRight: const Radius.circular(16),
              ),
            ),
            shadows: AppTheme.cardShadow,
          ),
          child: Text(
            message,
            style: AppTheme.bodyLg.copyWith(color: msgColor),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 4,
            left: isSent ? 0 : 4,
            right: isSent ? 4 : 0,
          ),
          child: Text(time, style: AppTheme.timestamp),
        ),
      ],
    );
  }
}

/// Chat input bar with text field and send button.
class ChatInputBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final VoidCallback? onSend;

  const ChatInputBar({
    super.key,
    this.controller,
    this.hintText = 'Nhập tin nhắn...',
    this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: const BoxDecoration(color: AppTheme.bgWhite),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Text input
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 52),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: ShapeDecoration(
                color: AppTheme.bgDark,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: controller,
                style: AppTheme.bodyLg.copyWith(color: Colors.white),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: AppTheme.bodyLg.copyWith(color: AppTheme.textHint),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Send button
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 52,
              height: 52,
              decoration: ShapeDecoration(
                color: AppTheme.deepPurple.withValues(alpha: 0.80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
                shadows: [
                  BoxShadow(
                    color: AppTheme.accentTeal.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chat list item showing avatar (initials), name, last message, and time.
class ChatListItem extends StatelessWidget {
  final String initials;
  final String name;
  final String lastMessage;
  final String time;
  final bool isUnread;
  final VoidCallback? onTap;

  const ChatListItem({
    super.key,
    required this.initials,
    required this.name,
    required this.lastMessage,
    this.time = '',
    this.isUnread = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: ShapeDecoration(
                color: AppTheme.primaryPurple.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: AppTheme.titleMd.copyWith(color: AppTheme.deepPurple),
              ),
            ),
            const SizedBox(width: 12),
            // Name & message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTheme.titleMd.copyWith(
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lastMessage,
                    style: isUnread
                        ? AppTheme.bodySm.copyWith(
                            color: AppTheme.deepPurple,
                            fontWeight: FontWeight.w700,
                          )
                        : AppTheme.bodySm,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Time
            if (time.isNotEmpty)
              Text(time, style: AppTheme.timestamp),
          ],
        ),
      ),
    );
  }
}
