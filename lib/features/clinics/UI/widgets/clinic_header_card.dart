import 'package:flutter/material.dart';
import '../../data/models/clinic_details_model.dart'; // تأكدي من مسار الموديل لديكِ

class ClinicHeaderCard extends StatelessWidget {
  final ClinicData clinicData;

  const ClinicHeaderCard({super.key, required this.clinicData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              size: 40,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clinicData.name ?? 'بدون اسم',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 24,
                  runSpacing: 8,
                  children: [
                    _buildInfoItem(
                      Icons.location_on_outlined,
                      clinicData.address ?? 'غير محدد',
                    ),
                    _buildInfoItem(
                      Icons.phone_outlined,
                      clinicData.phone ?? 'غير محدد',
                    ),
                    _buildInfoItem(
                      Icons.email_outlined,
                      clinicData.email ?? 'غير محدد',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
      ],
    );
  }
}
