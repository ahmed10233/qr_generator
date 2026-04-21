import 'package:flutter_bloc/flutter_bloc.dart';

import 'create_ticket_state.dart';

class CreateTicketCubit extends Cubit<CreateTicketState> {
  CreateTicketCubit() : super(CreateTicketState.initial());

  void increment() {
    emit(state.copyWith(stationCount: state.stationCount + 1));
  }

  void decrement() {
    if (state.stationCount > 1) {
      emit(state.copyWith(stationCount: state.stationCount - 1));
    }
  }

  void changeStation(String station) {
    emit(state.copyWith(station: station));
  }

  void updateDate(DateTime date, bool isFrom) {
    if (isFrom == true) {
      emit(state.copyWith(date: date));
    } else {
      emit(state.copyWith(toDate: date));
    }
  }
}
