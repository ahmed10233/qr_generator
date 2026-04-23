import 'dart:math';

class CreateTicketState {
  final int stationCount;
  final String ticketId;
  final String? station;
  final DateTime date;
  final DateTime toDate;

  const CreateTicketState({
    required this.stationCount,
    required this.station,
    required this.date,
    required this.ticketId,
    required this.toDate,
  });

  factory CreateTicketState.initial() {
    final now = DateTime.now();
    return CreateTicketState(
      stationCount: 1,
      station: null,
      date: now,
      ticketId: _generateTicketId(now),
      toDate: now.add(const Duration(minutes: 30)),
    );
  }
  static String _generateTicketId(DateTime dt) {
    final datePart = [
      dt.year.toString().substring(2),
      dt.month.toString().padLeft(2, '0'),
      dt.day.toString().padLeft(2, '0'),
      dt.hour.toString().padLeft(2, '0'),
      dt.minute.toString().padLeft(2, '0'),
    ].join();

    final randomPart = List.generate(8, (_) => Random().nextInt(10)).join();

    return '$datePart$randomPart';
  }

  CreateTicketState copyWith({
    int? stationCount,
    String? station,
    DateTime? date,
    DateTime? toDate,
    String? ticketId,
  }) {
    return CreateTicketState(
      stationCount: stationCount ?? this.stationCount,
      station: station ?? this.station,
      date: date ?? this.date,
      toDate: toDate ?? this.toDate,
      ticketId: ticketId ?? this.ticketId,
    );
  }
}
