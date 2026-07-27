import 'package:flutter/material.dart';
import '../../data/models/clinic_details_model.dart'; // تأكدي من المسار لديكِ

class SpecializationsTableWidget extends StatelessWidget {
  final List<SpecializationItem> specializations;

  const SpecializationsTableWidget({super.key, required this.specializations});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تخصصات العيادة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          if (specializations.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('لا توجد تخصصات مسجلة لهذه العيادة')),
            )
          else
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        '#',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'اسم التخصص',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'عدد الأطباء',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ...specializations.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final item = entry.value;
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text('$index'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(item.name ?? 'غير محدد'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text('${item.doctorsCount}'),
                      ),
                    ],
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }
}
