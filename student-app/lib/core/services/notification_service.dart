import 'package:flutter/foundation.dart';

enum NotificationTopic {
  announcements,
  classReminders,
  feeReminders,
  assignments,
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationTopic topic;
  final DateTime timestamp;
  final Map<String, dynamic>? payload;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.topic,
    required this.timestamp,
    this.payload,
    this.isRead = false,
  });
}

class NotificationService {
  static bool _isInitialized = false;
  static final List<AppNotification> _inMemoryNotifications = [];
  static final Set<String> _subscribedTopics = {};

  static bool get isInitialized => _isInitialized;
  static List<AppNotification> get notifications =>
      List.unmodifiable(_inMemoryNotifications);

  /// Initialize notification client & permissions
  static Future<void> initialize() async {
    _isInitialized = true;

    // Default subscriptions for students
    await subscribeToTopic(NotificationTopic.announcements);
    await subscribeToTopic(NotificationTopic.classReminders);
    await subscribeToTopic(NotificationTopic.feeReminders);
    await subscribeToTopic(NotificationTopic.assignments);

    if (kDebugMode) {
      print('Modular Notification Service initialized.');
    }
  }

  /// Subscribe to topic channel
  static Future<bool> subscribeToTopic(NotificationTopic topic) async {
    final topicName = topic.name;
    _subscribedTopics.add(topicName);
    if (kDebugMode) {
      print('Subscribed to notification topic: $topicName');
    }
    return true;
  }

  /// Unsubscribe from topic channel
  static Future<bool> unsubscribeFromTopic(NotificationTopic topic) async {
    _subscribedTopics.remove(topic.name);
    return true;
  }

  /// Check if subscribed
  static bool isSubscribed(NotificationTopic topic) {
    return _subscribedTopics.contains(topic.name);
  }

  /// Post local/in-app notification
  static void postNotification({
    required String title,
    required String body,
    required NotificationTopic topic,
    Map<String, dynamic>? payload,
  }) {
    final notification = AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      topic: topic,
      timestamp: DateTime.now(),
      payload: payload,
    );
    _inMemoryNotifications.insert(0, notification);
  }

  /// Clear all notifications
  static void clearAll() {
    _inMemoryNotifications.clear();
  }
}
