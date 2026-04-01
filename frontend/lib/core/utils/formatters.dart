import 'package:intl/intl.dart';

/// Formatting helpers for currency, dates, and display strings.
class Formatters {
  Formatters._();

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 0,
  );

  static final _currencyFormatDecimal = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 2,
  );

  /// Formats price as Indian rupee: "₹149" or "₹149.50".
  static String price(double amount) {
    return amount == amount.truncateToDouble()
        ? _currencyFormat.format(amount)
        : _currencyFormatDecimal.format(amount);
  }

  /// Formats date: "12 Jan 2026".
  static String date(DateTime dt) => DateFormat('d MMM y').format(dt);

  /// Formats time: "9:30 AM".
  static String time(DateTime dt) => DateFormat('h:mm a').format(dt);

  /// Formats datetime: "12 Jan 2026, 9:30 AM".
  static String dateTime(DateTime dt) =>
      DateFormat('d MMM y, h:mm a').format(dt);

  /// Formats relative time: "2 min ago", "3 hours ago", "Yesterday".
  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return date(dt);
  }

  /// Formats a discount percentage: "25% OFF".
  static String discountPercent(double original, double current) {
    final percent = ((original - current) / original * 100).round();
    return '$percent% OFF';
  }

  /// Formats count with 99+ cap for badges.
  static String badgeCount(int count) {
    if (count <= 0) return '';
    if (count > 99) return '99+';
    return count.toString();
  }

  /// Formats order id: "Order #GB1234567890".
  static String orderId(String id) => 'Order #$id';
}
