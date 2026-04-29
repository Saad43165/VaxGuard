import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/vaccine_record.dart';
import 'package:intl/intl.dart';

class VaccineCard extends StatelessWidget {
  final VaccineRecord record;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkComplete;

  const VaccineCard({
    Key? key,
    required this.record,
    this.onTap,
    this.onDelete,
    this.onMarkComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(context),
            _buildBody(context),
            if (onMarkComplete != null || onDelete != null) _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: record.isCompleted
            ? AppTheme.successGradient
            : AppTheme.primaryGradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Text('💉', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.vaccineName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (record.doseNumber != null)
                  Text(
                    record.doseNumber!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        record.isCompleted ? 'Done ✓' : 'Pending',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoRow(
            '📅',
            'Vaccination Date',
            DateFormat('MMMM d, yyyy').format(record.vaccinationDate),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('🔢', 'Lot Number', record.lotNumber),
          if (record.clinicName != null && record.clinicName!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow('🏥', 'Clinic', record.clinicName!),
          ],
          if (record.administeredBy != null &&
              record.administeredBy!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow('👨‍⚕️', 'Administered By', record.administeredBy!),
          ],
          if (record.nextDoseDate != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              '⏰',
              'Next Dose',
              DateFormat('MMMM d, yyyy').format(record.nextDoseDate!),
              isHighlighted: true,
            ),
          ],
          if (record.notes != null && record.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow('📝', 'Notes', record.notes!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String emoji,
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isHighlighted ? AppTheme.accentOrange : AppTheme.textDark,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.divider),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (onMarkComplete != null && !record.isCompleted)
            TextButton.icon(
              onPressed: onMarkComplete,
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: const Text('Mark Complete', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.accentGreen,
              ),
            ),
          if (onDelete != null)
            TextButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Delete', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.accentRed,
              ),
            ),
        ],
      ),
    );
  }
}
