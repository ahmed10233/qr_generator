import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'create_ticket_state.dart';

class CreateTicketCubit extends Cubit<CreateTicketState> {
  CreateTicketCubit() : super(CreateTicketState.initial());

  static const String _keyValue = "gUdeENpYlayCon56lgAzlVDtUBrvAndF";

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

  static DateTime _calcToDate(DateTime date, int stationCount) {
    return date.add(Duration(minutes: stationCount * 30));
  }

  static int parseStationId(String? station) {
    if (station == null) return 0;
    return int.tryParse(station.split(' - ').first.trim()) ?? 0;
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
    if (isFrom) {
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

  static String buildEncryptedQrPayload({
    required String ticketId,
    required int stationCount,
    required int sourceStationId,
    required int destinationStationId,
  }) {
    final buffer = ByteData(14);
    final ticketNumber = int.tryParse(ticketId) ?? 0;
    buffer.setUint64(0, ticketNumber, Endian.little);
    buffer.setUint16(8, stationCount, Endian.little);
    buffer.setUint16(10, sourceStationId, Endian.little);
    buffer.setUint16(12, destinationStationId, Endian.little);

    final payload = buffer.buffer.asUint8List();
    final aesKey = enc.Key.fromUtf8(_keyValue);
    final iv = enc.IV.fromSecureRandom(16);

    final encrypter = enc.Encrypter(
      enc.AES(aesKey, mode: enc.AESMode.cbc, padding: 'PKCS7'),
    );

    final encrypted = encrypter.encryptBytes(payload, iv: iv);

    final result = Uint8List(16 + encrypted.bytes.length);
    result.setRange(0, 16, iv.bytes);
    result.setRange(16, result.length, encrypted.bytes);

    return base64Encode(result);
  }
}
