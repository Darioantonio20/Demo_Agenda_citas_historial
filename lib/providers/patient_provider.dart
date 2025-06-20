import 'package:demo_agenda/models/patient.dart';
import 'package:demo_agenda/services/patient_service.dart';
import 'package:flutter/material.dart';

class PatientProvider with ChangeNotifier {
  final PatientService _patientService = PatientService();
  List<Patient> _patients = [];

  List<Patient> get patients => _patients;

  PatientProvider() {
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    _patients = await _patientService.getAllPatients();
    notifyListeners();
  }

  Future<void> addPatient(Patient patient) async {
    final existingPatient =
        await _patientService.getPatientByPhoneNumber(patient.phoneNumber);
    if (existingPatient != null) {
      throw Exception('Ya existe un paciente con este número de teléfono.');
    }
    final newId = await _patientService.insertPatient(patient);
    _patients.add(patient.copyWith(id: newId));
    notifyListeners();
  }

  Future<void> updatePatient(Patient patient) async {
    await _patientService.updatePatient(patient);
    await _loadPatients();
  }

  Future<void> deletePatient(int id) async {
    await _patientService.deletePatient(id);
    await _loadPatients();
  }

  Patient? getPatientById(int id) {
    try {
      return _patients.firstWhere((patient) => patient.id == id);
    } catch (e) {
      return null;
    }
  }
}
