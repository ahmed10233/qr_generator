import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_generate/cubit/ticket_cubit/create_ticket_cubit.dart';
import 'package:qr_generate/cubit/ticket_cubit/create_ticket_state.dart';
import 'package:qr_generate/widgets/ticket_widgets/stations_widget.dart';

class CustomDropMenu extends StatelessWidget {
  const CustomDropMenu({super.key, required this.state, required this.station});
  final CreateTicketState state;

  final List<String> station;
  @override
  Widget build(BuildContext context) {
    return SectionCard(
      icon: Icons.train_rounded,
      title: "محطة البدء",
      child: Theme(
        data: Theme.of(context).copyWith(canvasColor: const Color(0xFF242B3D)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            hint: Center(
              child: const Text(
                "اختر المحطة",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            isExpanded: true,
            value: state.station,
            dropdownColor: const Color(0xFF242B3D),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF4F8EF7),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 15),
            items: station.map((stationName) {
              return DropdownMenuItem(
                alignment: AlignmentGeometry.center,
                value: stationName,
                child: Text(
                  stationName,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (selectedNewStation) {
              if (selectedNewStation != null) {
                context.read<CreateTicketCubit>().changeStation(
                  selectedNewStation,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
