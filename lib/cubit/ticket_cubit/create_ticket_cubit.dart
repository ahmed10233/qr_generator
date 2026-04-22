import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'create_ticket_state.dart';

class CreateTicketCubit extends Cubit<CreateTicketState> {
  CreateTicketCubit() : super(CreateTicketState.initial());

  static DateTime _calcToDate(DateTime date, int stationCount) {
    return date.add(Duration(minutes: stationCount * 30));
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

  void increment() {
    final newCount = state.stationCount + 1;
    emit(
      state.copyWith(
        stationCount: newCount,
        toDate: _calcToDate(state.date, newCount),
      ),
    );
  }

  void decrement() {
    if (state.stationCount > 1) {
      final newCount = state.stationCount - 1;
      emit(
        state.copyWith(
          stationCount: newCount,
          toDate: _calcToDate(state.date, newCount),
        ),
      );
    }
  }

  void changeStation(String station) {
    emit(state.copyWith(station: station));
  }

  void updateDate(DateTime date, bool isFrom) {
    if (isFrom == true) {
      emit(
        state.copyWith(
          date: date,
          toDate: _calcToDate(date, state.stationCount),
          ticketId: _generateTicketId(date),
        ),
      );
    } else {
      emit(state.copyWith(toDate: date));
    }
  }
}
