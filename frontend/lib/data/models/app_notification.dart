class AppNotification {
  final int id;
  final String title;
  final String message;
  final String type;
  final int? referenceId;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id:json['id'] as int,
    title: json['title']  as String,
    message: json['message'] as String,
    type: json['type']  as String,
    referenceId: json['referenceId'] as int?,
    isRead:  json['isRead']  as bool,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    title:  title,
    message: message,
    type: type,
    referenceId: referenceId,
    isRead:isRead ?? this.isRead,
    createdAt: createdAt,
  );
}