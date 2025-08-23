import 'package:flutter/material.dart';

class AdvancePayment {
  final String id;
  final String laborId;
  final String laborName;
  final String laborPhone;
  final String laborRole;
  final double amount;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final String? receiptImagePath;
  final double remainingSalary;
  final double totalSalary;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdByEmail;

  AdvancePayment({
    required this.id,
    required this.laborId,
    required this.laborName,
    required this.laborPhone,
    required this.laborRole,
    required this.amount,
    required this.description,
    required this.date,
    required this.time,
    this.receiptImagePath,
    required this.remainingSalary,
    required this.totalSalary,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.createdByEmail,
  });

  AdvancePayment copyWith({
    String? id,
    String? laborId,
    String? laborName,
    String? laborPhone,
    String? laborRole,
    double? amount,
    String? description,
    DateTime? date,
    TimeOfDay? time,
    String? receiptImagePath,
    double? remainingSalary,
    double? totalSalary,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdByEmail,
  }) {
    return AdvancePayment(
      id: id ?? this.id,
      laborId: laborId ?? this.laborId,
      laborName: laborName ?? this.laborName,
      laborPhone: laborPhone ?? this.laborPhone,
      laborRole: laborRole ?? this.laborRole,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      remainingSalary: remainingSalary ?? this.remainingSalary,
      totalSalary: totalSalary ?? this.totalSalary,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdByEmail: createdByEmail ?? this.createdByEmail,
    );
  }

  // Formatted properties
  String get formattedAmount => 'PKR ${amount.toStringAsFixed(2)}';

  String get timeText => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  String get dateTimeText => '${date.day}/${date.month}/${date.year} at $timeText';

  String get formattedDate => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  bool get hasReceipt => receiptImagePath != null && receiptImagePath!.isNotEmpty;

  double get advancePercentage => totalSalary > 0 ? (amount / totalSalary * 100) : 0;

  // Status and display properties
  Color get statusColor {
    if (remainingSalary <= 0) return Colors.red;
    if (advancePercentage >= 80) return Colors.orange;
    if (advancePercentage >= 50) return Colors.yellow[700]!;
    return Colors.green;
  }

  String get statusText {
    if (remainingSalary <= 0) return 'Salary Exhausted';
    if (advancePercentage >= 80) return 'High Advance';
    if (advancePercentage >= 50) return 'Medium Advance';
    return 'Low Advance';
  }

  String get displayName => '$laborName - ${formattedAmount}';

  DateTime get paymentDateTime {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    return difference <= 7;
  }

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String get relativeDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(recordDate).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference < 365) {
      final months = (difference / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (difference / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }

  String get laborInitials {
    final nameParts = laborName.split(' ');
    String initials = '';
    for (final part in nameParts) {
      if (part.isNotEmpty) {
        initials += part[0].toUpperCase();
      }
    }
    return initials.isNotEmpty ? initials : laborName.substring(0, 2).toUpperCase();
  }

  String get paymentSummary {
    final summary = description.length > 50 ? '${description.substring(0, 47)}...' : description;
    return '$summary - $formattedAmount';
  }

  int get paymentAgeDays {
    return DateTime.now().difference(date).inDays;
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'labor_id': laborId,
      'labor_name': laborName,
      'labor_phone': laborPhone,
      'labor_role': laborRole,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'time': timeText,
      'receipt_image_path': receiptImagePath,
      'remaining_salary': remainingSalary,
      'total_salary': totalSalary,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by_email': createdByEmail,
    };
  }

  // Create from JSON API response
  factory AdvancePayment.fromJson(Map<String, dynamic> json) {
    // Parse time string (HH:MM or HH:MM:SS format)
    TimeOfDay parseTime(String timeStr) {
      try {
        if (timeStr.isEmpty) return TimeOfDay(hour: 0, minute: 0);
        final parts = timeStr.split(':');
        if (parts.length < 2 || parts.length > 3) return TimeOfDay(hour: 0, minute: 0);
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        return TimeOfDay(hour: hour, minute: minute);
      } catch (e) {
        return TimeOfDay(hour: 0, minute: 0);
      }
    }

    // Handle null values safely
    String safeString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    double safeDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    DateTime safeDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return AdvancePayment(
      id: safeString(json['id']),
      laborId: safeString(json['labor_id'] ?? ''),
      laborName: safeString(json['labor_name'] ?? ''),
      laborPhone: safeString(json['labor_phone'] ?? ''),
      laborRole: safeString(json['labor_role'] ?? ''),
      amount: safeDouble(json['amount']),
      description: safeString(json['description'] ?? ''),
      date: safeDateTime(json['date']),
      time: parseTime(safeString(json['time'] ?? '00:00')),
      receiptImagePath: json['receipt_image_path'] != null ? safeString(json['receipt_image_path']) : null,
      remainingSalary: safeDouble(json['remaining_salary']),
      totalSalary: safeDouble(json['total_salary']),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: safeDateTime(json['created_at']),
      updatedAt: safeDateTime(json['updated_at'] ?? json['created_at']),
      createdByEmail: json['created_by_email'] != null ? safeString(json['created_by_email']) : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdvancePayment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AdvancePayment(id: $id, laborName: $laborName, amount: $amount, date: $date)';
  }
}

// Labor model for dropdown selection (updated for API)
class Labor {
  final String id;
  final String name;
  final String phone;
  final String role;
  final double monthlySalary;
  final double totalAdvancesTaken;
  final bool isActive;

  Labor({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.monthlySalary,
    required this.totalAdvancesTaken,
    this.isActive = true,
  });

  double get remainingSalary => monthlySalary - totalAdvancesTaken;

  String get displayName => '$name - $role';

  String get formattedSalary => 'PKR ${monthlySalary.toStringAsFixed(0)}';

  String get formattedRemainingSalary => 'PKR ${remainingSalary.toStringAsFixed(0)}';

  factory Labor.fromJson(Map<String, dynamic> json) {
    return Labor(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone_number']?.toString() ?? json['phone']?.toString() ?? '',
      role: json['designation']?.toString() ?? json['role']?.toString() ?? '',
      monthlySalary: (json['salary'] as num?)?.toDouble() ?? 0.0,
      totalAdvancesTaken: (json['total_advances_taken'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role,
      'monthly_salary': monthlySalary,
      'total_advances_taken': totalAdvancesTaken,
      'is_active': isActive,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Labor && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Labor(id: $id, name: $name, role: $role, salary: $monthlySalary)';
  }
}