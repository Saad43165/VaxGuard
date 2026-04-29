import 'package:hive/hive.dart';

part 'vaccine_record.g.dart';

@HiveType(typeId: 0)
class VaccineRecord {
  @HiveField(0)
  final String vaccineName;

  @HiveField(1)
  final DateTime vaccinationDate;

  @HiveField(2)
  final String lotNumber;

  VaccineRecord({required this.vaccineName, required this.vaccinationDate, required this.lotNumber});
}