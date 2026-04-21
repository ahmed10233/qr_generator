import 'package:flutter/material.dart';

class CreateTicketState {
  final int stationCount;
  final TextEditingController ticketId;
  final String station;
  final DateTime date;
  final DateTime toDate;

  const CreateTicketState({
    required this.stationCount,

    required this.station,

    required this.date,

    required this.toDate,
    required this.ticketId,
  });

  factory CreateTicketState.initial() {
    return CreateTicketState(
      stationCount: 1,

      station: "2099 - اسكندرية الزراعي",

      date: DateTime.now(),

      toDate: DateTime.now(),
      ticketId: TextEditingController(),
    );
  }

  CreateTicketState copyWith({
    int? stationCount,
    String? station,
    DateTime? date,
    DateTime? toDate,
    TextEditingController? ticketId,
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
