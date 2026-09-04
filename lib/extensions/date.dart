import 'dart:math';

extension Format on DateTime {
  /// format date as [day]$[delimeter]$[month]$[delimeter]$[year]
  String format([String delimeter = '/', bool invert = false]) {
    var date = toLocal();
    int year = date.year;
    int month = date.month;
    int day = date.day;
    if (invert) {
      return '$year$delimeter${month > 9 ? '' : '0'}$month$delimeter${day > 9 ? '' : '0'}$day';
    }
    return '${day > 9 ? '' : '0'}$day$delimeter${month > 9 ? '' : '0'}$month$delimeter$year';
  }

  String get readableFormat {
    var date = toLocal();
    int year = date.year;
    String month = monthNames[max(min(date.month - 1, 13), 0)];
    int day = date.day;
    return '$month $day $year';
  }

  String get readableFormatMin {
    var date = toLocal();
    // int year = date.year;
    String month = monthNamesMin[max(min(date.month - 1, 13), 0)];
    int day = date.day;
    return '$month $day';
  }

  String get readableFormatNoYear {
    var date = toLocal();
    String month = monthNames[max(min(date.month - 1, 13), 0)];
    int day = date.day;
    return '$month $day';
  }

  /// show Month in full text, show day and time, if date is today,
  /// tommorow or yesterday, it returns the string respectively
  String get readableFormatRefined {
    var now = DateTime.now();
    var midNightToday = DateTime(now.year, now.month, now.day);
    var midNightYesterday = midNightToday.subtract(const Duration(days: 1));
    var midNightTomorrow = midNightToday.add(const Duration(days: 1));
    var twoDaysFromNow = midNightToday.add(const Duration(days: 2));
    var date = this;
    // if (date == null) return '';
    if (date.year != now.year) return date.readableFormat;
    if (date.year == midNightTomorrow.year &&
        date.month == midNightTomorrow.month &&
        date.day == midNightTomorrow.day) return 'Tomorrow';
    if (date.isAfter(twoDaysFromNow)) return date.readableFormat;
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    if (date.year == midNightYesterday.year &&
        date.month == midNightYesterday.month &&
        date.day == midNightYesterday.day) {
      return 'Yesterday';
    }
    return date.readableFormat;
  }

  // bool isToday(DateTime date) {
  //   var _d = DateTime(date.year, date.month, date.day);
  // }

  /// show Month in full text, show day and time, if date is today,
  /// tommorow or yesterday, it returns the string respectively
  String get readableFormatRefinedMin {
    var now = DateTime.now();
    var date = this;
    // if (date == null) return '';
    if (date.year != now.year) return date.readableFormat;
    if (date.difference(now).inDays > 1) return date.readableFormatMin;
    if (date.difference(now).inDays == 1) return 'Tommorow';
    if (date.difference(now).inDays == 0 && date.day == now.day) {
      return date.time;
    } //?? 'Today';
    if (date.difference(now).inDays == 0 && date.day > now.day) {
      return 'Tommorow';
    }
    if (date.difference(now).inDays == 0 && date.day < now.day) {
      return 'Yesterday';
    }
    if (date.difference(now).inDays == -1) return 'Yesterday';
    return date.readableFormatMin;
  }

  /// show Month in full text, show day and time, if date is today,
  /// tommorow or yesterday, it returns the string respectively
  String get readableFormatRefinedNoYear {
    var now = DateTime.now();
    var date = this;
    // if (date == null) return '';
    if (date.year != now.year) return date.readableFormatNoYear;
    if (date.difference(now).inDays > 1) return date.readableFormatNoYear;
    if (date.difference(now).inDays == 1) return 'Tommorow';
    if (date.difference(now).inDays == 0 && date.day == now.day) {
      return 'Today';
    }
    if (date.difference(now).inDays == 0 && date.day > now.day) {
      return 'Tommorow';
    }
    if (date.difference(now).inDays == 0 && date.day < now.day) {
      return 'Yesterday';
    }
    if (date.difference(now).inDays == -1) return 'Yesterday';
    return date.readableFormat;
  }

  String get formatWithTime {
    var date = toLocal();
    int year = date.year;
    String month = monthNames[max(min(this.month - 1, 13), 0)];
    int day = date.day;
    int hour = date.hour;
    int minute = this.minute;
    return '$month $day, $year at ${_formatTime(hour, minute)}';
  }

  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      int diff = difference.inDays ~/ 7;

      return diff > 1 ? '$diff weeks ago' : '$diff week ago';
    } else if (difference.inDays < 365) {
      int diff = difference.inDays ~/ 30;

      return diff > 1 ? '$diff months ago' : '$diff month ago';
    } else {
      int diff = difference.inDays ~/ 365;

      return diff > 1 ? '$diff years ago' : '$diff year ago';
    }
  }

  String _formatTime(int hour, int min) {
    String m = '$min';
    if (min < 10) m = '0$min';
    if (hour < 10) {
      return '0$hour:$min AM';
    } else if (hour < 13) {
      if (hour == 12 && min == 0) return '$hour:00 NOON';
      if (hour == 12) return '$hour:$min PM';
      return '$hour:$min AM';
    } else {
      return '${hour - 12}:$m PM';
    }
  }

  String get time {
    var date = toLocal();
    int hour = date.hour;
    int minute = this.minute;
    return _formatTime(hour, minute);
  }
}

const List<String> monthNames = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> monthNamesMin = <String>[
  'Jan',
  'Feb',
  'March',
  'April',
  'May',
  'June',
  'July',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
