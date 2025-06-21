import 'package:demo_agenda/models/appointment.dart';
import 'package:demo_agenda/services/appointment_service.dart';
import 'package:flutter/material.dart';

class AppointmentProvider with ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();
  List<Appointment> _appointments = [];

  List<Appointment> get appointments => _appointments;

  AppointmentProvider() {
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    _appointments = await _appointmentService.getAllAppointments();
    notifyListeners();
  }

  Future<Map<String, dynamic>> addAppointment(Appointment appointment) async {
    final result = await _appointmentService.insertAppointment(appointment);

    if (result['success']) {
      _appointments.add(appointment.copyWith(id: result['id']));
      notifyListeners();
    }

    return result;
  }

  Future<Map<String, dynamic>> updateAppointment(
      Appointment appointment) async {
    final result = await _appointmentService.updateAppointment(appointment);

    if (result['success']) {
      final index = _appointments.indexWhere((app) => app.id == appointment.id);
      if (index != -1) {
        _appointments[index] = appointment;
        notifyListeners();
      }
    }

    return result;
  }

  Future<void> deleteAppointment(int id) async {
    await _appointmentService.deleteAppointment(id);
    _appointments.removeWhere((app) => app.id == id);
    notifyListeners();
  }

  List<Appointment> getAppointmentsForPatient(int patientId) {
    return _appointments
        .where((appointment) => appointment.patientId == patientId)
        .toList();
  }

  List<Appointment> getAppointmentsForDate(DateTime date) {
    return _appointments
        .where(
          (appointment) =>
              appointment.startTime.year == date.year &&
              appointment.startTime.month == date.month &&
              appointment.startTime.day == date.day,
        )
        .toList();
  }

  List<Appointment> getFilteredAppointments(String status) {
    return _appointments
        .where((appointment) => appointment.status == status)
        .toList();
  }
}
