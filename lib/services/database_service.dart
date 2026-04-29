import 'package:hive_flutter/hive_flutter.dart';
import '../models/vaccine_record.dart';
import '../utils/app_constants.dart';

class DatabaseService {
  static DatabaseService? _instance;
  late Box<VaccineRecord> _vaccineBox;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  Future<void> initialize() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(VaccineRecordAdapter());
    }
    _vaccineBox = await Hive.openBox<VaccineRecord>(AppConstants.vaccineBox);
  }

  // Create
  Future<void> addVaccineRecord(VaccineRecord record) async {
    await _vaccineBox.put(record.id, record);
  }

  // Read
  List<VaccineRecord> getAllVaccineRecords() {
    return _vaccineBox.values.toList()
      ..sort((a, b) => b.vaccinationDate.compareTo(a.vaccinationDate));
  }

  VaccineRecord? getVaccineRecord(String id) {
    return _vaccineBox.get(id);
  }

  List<VaccineRecord> getCompletedVaccines() {
    return _vaccineBox.values
        .where((record) => record.isCompleted)
        .toList()
      ..sort((a, b) => b.vaccinationDate.compareTo(a.vaccinationDate));
  }

  List<VaccineRecord> getUpcomingVaccines() {
    final now = DateTime.now();
    return _vaccineBox.values
        .where((record) =>
            record.nextDoseDate != null &&
            record.nextDoseDate!.isAfter(now))
        .toList()
      ..sort((a, b) => a.nextDoseDate!.compareTo(b.nextDoseDate!));
  }

  List<VaccineRecord> getVaccinesByName(String name) {
    return _vaccineBox.values
        .where((record) =>
            record.vaccineName.toLowerCase().contains(name.toLowerCase()))
        .toList();
  }

  // Update
  Future<void> updateVaccineRecord(VaccineRecord record) async {
    await _vaccineBox.put(record.id, record);
  }

  Future<void> markVaccineComplete(String id) async {
    final record = _vaccineBox.get(id);
    if (record != null) {
      record.isCompleted = true;
      await record.save();
    }
  }

  // Delete
  Future<void> deleteVaccineRecord(String id) async {
    await _vaccineBox.delete(id);
  }

  Future<void> deleteAllRecords() async {
    await _vaccineBox.clear();
  }

  // Statistics
  int get totalVaccines => _vaccineBox.length;
  int get completedVaccines =>
      _vaccineBox.values.where((r) => r.isCompleted).length;
  int get pendingVaccines =>
      _vaccineBox.values.where((r) => !r.isCompleted).length;

  double get completionPercentage {
    if (totalVaccines == 0) return 0;
    return (completedVaccines / totalVaccines) * 100;
  }

  Map<String, int> getVaccinesByMonth() {
    final Map<String, int> monthlyData = {};
    for (final record in _vaccineBox.values) {
      final key =
          '${record.vaccinationDate.year}-${record.vaccinationDate.month.toString().padLeft(2, '0')}';
      monthlyData[key] = (monthlyData[key] ?? 0) + 1;
    }
    return monthlyData;
  }

  // Stream for reactive updates
  Stream<BoxEvent> watchVaccineRecords() {
    return _vaccineBox.watch();
  }

  Future<void> close() async {
    await _vaccineBox.close();
  }
}
