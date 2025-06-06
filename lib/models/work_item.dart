class WorkItem {
  final int? id;
  final String title;
  final String description;
  final String userId;
  final String userName;
  final String
  type; // Type of work item: 'leave', 'overtime', 'business_trip', etc.
  final String status; // 'pending', 'approved', 'rejected'
  final String requestedDate;
  final String? approvedDate;
  final String? approvedBy;

  WorkItem({
    this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.userName,
    required this.type,
    required this.status,
    required this.requestedDate,
    this.approvedDate,
    this.approvedBy,
  });

  // Convert WorkItem to a Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'userName': userName,
      'type': type,
      'status': status,
      'requestedDate': requestedDate,
      'approvedDate': approvedDate,
      'approvedBy': approvedBy,
    };
  }

  // Create a WorkItem from a database Map
  factory WorkItem.fromMap(Map<String, dynamic> map) {
    return WorkItem(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      userId: map['userId'],
      userName: map['userName'],
      type: map['type'],
      status: map['status'],
      requestedDate: map['requestedDate'],
      approvedDate: map['approvedDate'],
      approvedBy: map['approvedBy'],
    );
  }

  // Create a copy of this WorkItem with updated fields
  WorkItem copyWith({
    int? id,
    String? title,
    String? description,
    String? userId,
    String? userName,
    String? type,
    String? status,
    String? requestedDate,
    String? approvedDate,
    String? approvedBy,
  }) {
    return WorkItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      type: type ?? this.type,
      status: status ?? this.status,
      requestedDate: requestedDate ?? this.requestedDate,
      approvedDate: approvedDate ?? this.approvedDate,
      approvedBy: approvedBy ?? this.approvedBy,
    );
  }
}
