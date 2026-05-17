class WalletModel {
  final String id;
  final String userId;
  final double balance;
  final String currency;
  final DateTime updatedAt;

  const WalletModel({
    required this.id,
    required this.userId,
    required this.balance,
    required this.currency,
    required this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'VND',
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class TransactionModel {
  final String id;
  final String type;
  final double amount;
  final String currency;
  final String status;
  final String? description;
  final String? referenceId;
  final String? referenceType;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    this.description,
    this.referenceId,
    this.referenceType,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'VND',
      status: json['status'] as String,
      description: json['description'] as String?,
      referenceId: json['referenceId'] as String?,
      referenceType: json['referenceType'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  bool get isCredit => type == 'credit' || type == 'topup' || type == 'refund';
}

class PromoModel {
  final String id;
  final String code;
  final String description;
  final String discountType;
  final double discountValue;
  final double? maxDiscount;
  final double? minOrderAmount;
  final DateTime expiresAt;

  const PromoModel({
    required this.id,
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    this.maxDiscount,
    this.minOrderAmount,
    required this.expiresAt,
  });

  factory PromoModel.fromJson(Map<String, dynamic> json) {
    return PromoModel(
      id: json['id'] as String,
      code: json['code'] as String,
      description: json['description'] as String? ?? '',
      discountType: json['discountType'] as String,
      discountValue: (json['discountValue'] as num).toDouble(),
      maxDiscount: (json['maxDiscount'] as num?)?.toDouble(),
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble(),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  String get displayDiscount {
    if (discountType == 'percentage') {
      return '${discountValue.toInt()}%';
    }
    return '${discountValue.toInt()}đ';
  }
}
