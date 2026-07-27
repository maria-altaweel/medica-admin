class DashboardHomeResponse {
  final bool success;
  final DashboardHomeData data;

  DashboardHomeResponse({required this.success, required this.data});

  factory DashboardHomeResponse.fromJson(Map<String, dynamic> json) {
    return DashboardHomeResponse(
      success: json['success'] ?? false,
      data: DashboardHomeData.fromJson(json['data'] ?? {}),
    );
  }
}

class DashboardHomeData {
  final DashboardCounts counts;
  final TodayAppointments todayAppointments;
  final double monthlyRevenue;
  final num revenueChangePercentage;
  final DoctorAttendance doctorAttendance;
  final List<TopSpecialization> topSpecializations;
  final List<ClinicOverview> clinicsOverview;

  DashboardHomeData({
    required this.counts,
    required this.todayAppointments,
    required this.monthlyRevenue,
    required this.revenueChangePercentage,
    required this.doctorAttendance,
    required this.topSpecializations,
    required this.clinicsOverview,
  });

  factory DashboardHomeData.fromJson(Map<String, dynamic> json) {
    return DashboardHomeData(
      counts: DashboardCounts.fromJson(json['counts'] ?? {}),
      todayAppointments: TodayAppointments.fromJson(
        json['today_appointments'] ?? {},
      ),
      monthlyRevenue: (json['monthly_revenue'] ?? 0).toDouble(),
      revenueChangePercentage: json['revenue_change_percentage'] ?? 0,
      doctorAttendance: DoctorAttendance.fromJson(
        json['doctor_attendance'] ?? {},
      ),
      topSpecializations: (json['top_specializations'] as List? ?? [])
          .map((e) => TopSpecialization.fromJson(e))
          .toList(),
      clinicsOverview: (json['clinics_overview'] as List? ?? [])
          .map((e) => ClinicOverview.fromJson(e))
          .toList(),
    );
  }
}

class DashboardCounts {
  final int clinics;
  final int doctors;
  final int patients;
  final int secretaries;

  DashboardCounts({
    required this.clinics,
    required this.doctors,
    required this.patients,
    required this.secretaries,
  });

  factory DashboardCounts.fromJson(Map<String, dynamic> json) {
    return DashboardCounts(
      clinics: json['clinics'] ?? 0,
      doctors: json['doctors'] ?? 0,
      patients: json['patients'] ?? 0,
      secretaries: json['secretaries'] ?? 0,
    );
  }
}

class TodayAppointments {
  final int total;
  final Map<String, dynamic> byStatus;

  TodayAppointments({required this.total, required this.byStatus});

  factory TodayAppointments.fromJson(Map<String, dynamic> json) {
    return TodayAppointments(
      total: json['total'] ?? 0,
      byStatus: json['by_status'] ?? {},
    );
  }
}

class DoctorAttendance {
  final num rate;
  final int presentCount;
  final int absentCount;
  final int totalCount;

  DoctorAttendance({
    required this.rate,
    required this.presentCount,
    required this.absentCount,
    required this.totalCount,
  });

  factory DoctorAttendance.fromJson(Map<String, dynamic> json) {
    return DoctorAttendance(
      rate: json['rate'] ?? 0,
      presentCount: json['present_count'] ?? 0,
      absentCount: json['absent_count'] ?? 0,
      totalCount: json['total_count'] ?? 0,
    );
  }
}

class TopSpecialization {
  final int id;
  final String name;
  final int appointmentsCount;

  TopSpecialization({
    required this.id,
    required this.name,
    required this.appointmentsCount,
  });

  factory TopSpecialization.fromJson(Map<String, dynamic> json) {
    return TopSpecialization(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      appointmentsCount: json['appointments_count'] ?? 0,
    );
  }
}

class ClinicOverview {
  final int id;
  final String name;
  final int patientsCount;
  final int doctorsCount;
  final int secretariesCount;
  final Map<String, dynamic> todayAppointments;
  final double todayRevenue;
  final double monthlyRevenue;

  ClinicOverview({
    required this.id,
    required this.name,
    required this.patientsCount,
    required this.doctorsCount,
    required this.secretariesCount,
    required this.todayAppointments,
    required this.todayRevenue,
    required this.monthlyRevenue,
  });
  factory ClinicOverview.fromJson(Map<String, dynamic> json) {
    return ClinicOverview(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      patientsCount: json['patients_count'] ?? 0,
      doctorsCount: json['doctors_count'] ?? 0,
      secretariesCount: json['secretaries_count'] ?? 0,
      todayAppointments: json['today_appointments'] ?? {},
      todayRevenue: (json['today_revenue'] ?? 0).toDouble(),
      monthlyRevenue: (json['monthly_revenue'] ?? 0).toDouble(),
    );
  }
}
