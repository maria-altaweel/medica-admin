class SalaryPayoutModel {
  final int id;
  final ClinicModel clinic;
  final DoctorModel doctor;
  final SalaryFinancialsModel financials;
  final SalaryAuditModel? audit;
  final SalaryBreakdownModel? breakdown;
  final List<SalaryPaymentModel>? payments;

  SalaryPayoutModel({
    required this.id,
    required this.clinic,
    required this.doctor,
    required this.financials,
    this.audit,
    this.breakdown,
    this.payments,
  });

  factory SalaryPayoutModel.fromJson(Map<String, dynamic> json) {
    return SalaryPayoutModel(
      id: json['id'] ?? 0,
      // إذا كانت غير موجودة برد الاعتماد، ضع لها قيمة افتراضية حتى لا يحدث الانهيار
      clinic: json['clinic'] != null
          ? ClinicModel.fromJson(json['clinic'])
          : ClinicModel(id: 0, name: ''),
      doctor: json['doctor'] != null
          ? DoctorModel.fromJson(json['doctor'])
          : DoctorModel(id: 0, name: ''),
      financials: SalaryFinancialsModel.fromJson(
        json['financials'] ?? json['salary'] ?? json,
      ),
      // باقي الحقول...
      audit: json['audit'] != null
          ? SalaryAuditModel.fromJson(json['audit'])
          : null,
      breakdown: json['breakdown'] != null
          ? SalaryBreakdownModel.fromJson(json['breakdown'])
          : null,
      payments: json['payments'] != null
          ? (json['payments'] as List)
                .map((p) => SalaryPaymentModel.fromJson(p))
                .toList()
          : null,
    );
  }
}

class ClinicModel {
  final int id;
  final String name;

  ClinicModel({required this.id, required this.name});

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(id: json['id'], name: json['name']);
  }
}

class DoctorModel {
  final int id;
  final String name;
  final String? specialization;

  DoctorModel({required this.id, required this.name, this.specialization});

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'],
      name: json['name'] ?? '',
      specialization: json['specialization'],
    );
  }
}

class SalaryFinancialsModel {
  final String? periodStart;
  final String? periodEnd;
  final int? appointments;
  final num? revenue;
  final num salaryPercentage;
  final num doctorShare;
  final num? clinicShare;
  final String status;

  SalaryFinancialsModel({
    this.periodStart,
    this.periodEnd,
    this.appointments,
    this.revenue,
    required this.salaryPercentage,
    required this.doctorShare,
    this.clinicShare,
    required this.status,
  });

  factory SalaryFinancialsModel.fromJson(Map<String, dynamic> json) {
    num? parseNum(dynamic value) {
      if (value == null) return null;
      if (value is num) return value;
      return num.tryParse(value.toString());
    }

    return SalaryFinancialsModel(
      periodStart: json['period_start'],
      periodEnd: json['period_end'],
      appointments: json['appointments'],
      revenue: parseNum(
        json['revenue'] ??
            json['total_revenue'] ??
            json['total'] ??
            json['income'] ??
            json['gross'],
      ),
      salaryPercentage:
          parseNum(json['salary_percentage'] ?? json['percentage']) ?? 0,
      doctorShare: parseNum(json['doctor_share']) ?? 0,
      clinicShare: parseNum(json['clinic_share']),
      status: json['status'] ?? 'pending',
    );
  }
}

class SalaryAuditModel {
  final String? approvedBy;
  final String? approvedAt;
  final String? deliveredBy;
  final String? deliveredAt;

  SalaryAuditModel({
    this.approvedBy,
    this.approvedAt,
    this.deliveredBy,
    this.deliveredAt,
  });

  factory SalaryAuditModel.fromJson(Map<String, dynamic> json) {
    return SalaryAuditModel(
      approvedBy: json['approved_by'],
      approvedAt: json['approved_at'],
      deliveredBy: json['delivered_by'],
      deliveredAt: json['delivered_at'],
    );
  }
}

class SalaryBreakdownModel {
  final num cash;
  final num points;
  final num onlinePayment;
  final num creditCard;

  SalaryBreakdownModel({
    required this.cash,
    required this.points,
    required this.onlinePayment,
    required this.creditCard,
  });

  factory SalaryBreakdownModel.fromJson(Map<String, dynamic> json) {
    num parseNum(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value;
      return num.tryParse(value.toString()) ?? 0;
    }

    return SalaryBreakdownModel(
      cash: parseNum(json['cash']),
      points: parseNum(json['points']),
      onlinePayment: parseNum(json['online_payment']),
      creditCard: parseNum(json['credit_card']),
    );
  }
}

class SalaryPaymentModel {
  final int id;
  final ClinicModel patient;
  final num amount;
  final String paymentMethod;
  final String? paidAt;

  SalaryPaymentModel({
    required this.id,
    required this.patient,
    required this.amount,
    required this.paymentMethod,
    this.paidAt,
  });

  factory SalaryPaymentModel.fromJson(Map<String, dynamic> json) {
    num parseNum(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value;
      return num.tryParse(value.toString()) ?? 0;
    }

    return SalaryPaymentModel(
      id: json['id'],
      patient: ClinicModel.fromJson(json['patient']),
      amount: parseNum(json['amount']),
      paymentMethod: json['payment_method'],
      paidAt: json['paid_at'],
    );
  }
}
