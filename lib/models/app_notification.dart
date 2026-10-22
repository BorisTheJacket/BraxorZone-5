class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  // 'welcome', 'booking', 'achievement', 'tier'
  final String iconType;
  // 'tasks', 'profile', 'offers', 'booking', or null for no navigation
  final String? action;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.iconType,
    this.isRead = false,
    this.action,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        body: body,
        timestamp: timestamp,
        iconType: iconType,
        isRead: isRead ?? this.isRead,
        action: action,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
        'iconType': iconType,
        'action': action,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        isRead: json['isRead'] as bool? ?? false,
        iconType: json['iconType'] as String? ?? 'welcome',
        action: json['action'] as String?,
      );
}
