import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sevenup_mobile/data/api_repository.dart';

/// Unread counts from `POST /api/notifications/counts`, driving the header bell.
class NotificationState extends Equatable {
  final int messages;
  final int communications;
  final int announcements;
  final int total;
  final bool loaded;

  const NotificationState({
    this.messages = 0,
    this.communications = 0,
    this.announcements = 0,
    this.total = 0,
    this.loaded = false,
  });

  @override
  List<Object?> get props =>
      [messages, communications, announcements, total, loaded];
}

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(const NotificationState());

  final _repository = ApiRepository();
  DateTime? _lastLoaded;

  static int _n(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

  /// Refresh only if the last successful fetch is older than [maxAge] — used by
  /// the header bell so navigating between screens doesn't spam the endpoint.
  Future<void> loadIfStale({
    Duration maxAge = const Duration(seconds: 45),
  }) async {
    if (_lastLoaded != null &&
        DateTime.now().difference(_lastLoaded!) < maxAge) {
      return;
    }
    return load();
  }

  Future<void> load() async {
    final res = await _repository.getNotificationCounts();
    final raw = res.body;
    if (raw == null) return;
    final messages = _n(raw['messages']);
    final communications = _n(raw['communications']);
    final announcements = _n(raw['announcements']);
    final total = raw['total'] != null
        ? _n(raw['total'])
        : messages + communications + announcements;
    _lastLoaded = DateTime.now();
    emit(NotificationState(
      messages: messages,
      communications: communications,
      announcements: announcements,
      total: total,
      loaded: true,
    ));
  }

  /// Reset on logout so a new user doesn't briefly see the previous counts.
  void clear() {
    _lastLoaded = null;
    emit(const NotificationState());
  }
}
