import 'package:demo_agenda/models/appointment.dart';
import 'package:demo_agenda/utils/database_helper.dart';

class AppointmentService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<bool> hasTimeConflict(DateTime startTime, DateTime endTime,
      [int? excludeAppointmentId]) async {
    // Consultar todas las citas que podrían tener conflicto
    final List<Map<String, dynamic>> maps = await _dbHelper.query(
      'appointments',
      where: excludeAppointmentId != null
          ? '((startTime < ? AND endTime > ?) OR (startTime < ? AND endTime > ?) OR (startTime >= ? AND endTime <= ?)) AND id != ?'
          : '(startTime < ? AND endTime > ?) OR (startTime < ? AND endTime > ?) OR (startTime >= ? AND endTime <= ?)',
      whereArgs: excludeAppointmentId != null
          ? [
              endTime.toIso8601String(),
              startTime.toIso8601String(),
              endTime.toIso8601String(),
              startTime.toIso8601String(),
              startTime.toIso8601String(),
              endTime.toIso8601String(),
              excludeAppointmentId,
            ]
          : [
              endTime.toIso8601String(),
              startTime.toIso8601String(),
              endTime.toIso8601String(),
              startTime.toIso8601String(),
              startTime.toIso8601String(),
              endTime.toIso8601String(),
            ],
    );

    return maps.isNotEmpty;
  }

  Future<Map<String, dynamic>> insertAppointment(
      Appointment appointment) async {
    // Verificar si hay conflicto de horario
    bool hasConflict =
        await hasTimeConflict(appointment.startTime, appointment.endTime);

    if (hasConflict) {
      return {
        'success': false,
        'message': 'Ya existe una cita programada para este horario.',
        'id': null
      };
    }

    try {
      final id = await _dbHelper.insert('appointments', appointment.toMap());
      return {
        'success': true,
        'message': 'Cita agendada exitosamente',
        'id': id
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al agendar la cita: ${e.toString()}',
        'id': null
      };
    }
  }

  Future<Map<String, dynamic>> updateAppointment(
      Appointment appointment) async {
    if (appointment.id == null) {
      return {
        'success': false,
        'message': 'Error: ID de cita no válido',
        'rowsAffected': 0
      };
    }

    // Verificar si hay conflicto de horario, excluyendo la cita actual
    bool hasConflict = await hasTimeConflict(
        appointment.startTime, appointment.endTime, appointment.id);

    if (hasConflict) {
      return {
        'success': false,
        'message': 'Ya existe una cita programada para este horario.',
        'rowsAffected': 0
      };
    }

    try {
      final rowsAffected = await _dbHelper.update(
        'appointments',
        appointment.toMap(),
        'id = ?',
        [appointment.id],
      );

      return {
        'success': true,
        'message': 'Cita actualizada exitosamente',
        'rowsAffected': rowsAffected
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al actualizar la cita: ${e.toString()}',
        'rowsAffected': 0
      };
    }
  }

  Future<Appointment?> getAppointmentById(int id) async {
    final List<Map<String, dynamic>> maps = await _dbHelper.query(
      'appointments',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Appointment.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Appointment>> getAllAppointments() async {
    final List<Map<String, dynamic>> maps =
        await _dbHelper.queryAll('appointments');
    return List.generate(maps.length, (i) {
      return Appointment.fromMap(maps[i]);
    });
  }

  Future<List<Appointment>> getAppointmentsForPatient(int patientId) async {
    final List<Map<String, dynamic>> maps = await _dbHelper.query(
      'appointments',
      where: 'patientId = ?',
      whereArgs: [patientId],
      orderBy: 'startTime ASC',
    );
    return List.generate(maps.length, (i) {
      return Appointment.fromMap(maps[i]);
    });
  }

  Future<int> deleteAppointment(int id) async {
    return await _dbHelper.delete(
      'appointments',
      'id = ?',
      [id],
    );
  }
}
