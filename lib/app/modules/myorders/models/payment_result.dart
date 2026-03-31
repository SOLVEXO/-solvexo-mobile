class PaymentResult {
  final String? id;
  final String? status;
  final String? updateTime;
  final String? emailAddress;

  PaymentResult({this.id, this.status, this.updateTime, this.emailAddress});

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      id: json['id'] as String?,
      status: json['status'] as String?,
      updateTime: json['updateTime'] as String?,
      emailAddress: json['emailAddress'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'updateTime': updateTime,
      'emailAddress': emailAddress,
    };
  }
}
