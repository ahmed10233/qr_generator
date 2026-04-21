import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_generate/cubit/ticket_cubit/create_ticket_cubit.dart';
import 'package:qr_generate/cubit/ticket_cubit/create_ticket_state.dart';
import 'package:qr_generate/widgets/custom_widget/date_widget.dart';
import 'package:qr_generate/widgets/ticket_widgets/counter_widget.dart';
import 'package:qr_generate/widgets/ticket_widgets/stations_widget.dart';
import 'package:qr_generate/widgets/ticket_widgets/ticket_details.dart';

class CreateTicketPage extends StatelessWidget {
  const CreateTicketPage({super.key});

  // ─── Constants ──────────────────────────────────────────
  static const _stations = [
    "2099 - اسكندرية الزراعي",
    "القاهرة",
    "رمسيس",
    "طنطا",
    "المنصورة",
    "دمياط",
    "بورسعيد",
  ];

  static const _accentColor = Color(0xFF4F8EF7);
  static const _surfaceBg = Color(0xFF111827);
  static const String _keyValue =
      "gUdeENpYlayCon56lgAzlVDtUBrvAndFhQwv4EXj9i7Aw3KghzW//cLHzDHQnpLilAbczr2avHsCuFyo38e2qcVdX/Iqn/5y";

  // ─── Helpers ──────────────────────────────────────────────
  String _formatDate(DateTime dt) =>
      "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";

  String _formatTime(DateTime dt) =>
      "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";

  Future<void> pickDateTime(BuildContext context, bool isFrom) async {
    final cubit = context.read<CreateTicketCubit>();
    final state = cubit.state;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: state.date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null || !context.mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(state.date),
    );

    if (pickedTime == null || !context.mounted) return;

    final newDate = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    cubit.updateDate(newDate, isFrom);
  }

  // ─── Build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    TextEditingController ticketIdController = TextEditingController();
    return BlocProvider(
      create: (context) => CreateTicketCubit(),
      child: Scaffold(
        backgroundColor: _surfaceBg,
        appBar: _buildAppBar(context),
        body: BlocBuilder<CreateTicketCubit, CreateTicketState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Column(
                children: [
                  const SizedBox(height: 14),
                  _buildDateTimeCard(context, state),
                  const SizedBox(height: 14),
                  _buildTicketId(context, ticketIdController),
                  const SizedBox(height: 14),
                  _buildStationCard(context, state),
                  const SizedBox(height: 14),
                  _buildCounterCard(context, state),
                  const SizedBox(height: 14),
                  _buildKeyCard(),
                  const SizedBox(height: 24),
                  const SizedBox(height: 16),
                  _buildTicketCard(state),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _surfaceBg,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white70,
          size: 20,
        ),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: const Text(
        "إنشاء تذكرة جديدة",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 17,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 2,
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
    );
  }

  // ─── Date & Time Card ─────────────────────────────────────
  Widget _buildDateTimeCard(BuildContext context, CreateTicketState state) {
    return SectionCard(
      icon: Icons.event_rounded,
      title: "التاريخ والوقت",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text("تبداء من", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: DateContainer(
                  icon: Icons.calendar_today_rounded,
                  label:
                      "${_formatDate(state.date)} ${_formatTime(state.date)}",
                  onTap: () => pickDateTime(context, true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text("تنتهي عند", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: DateContainer(
                  icon: Icons.calendar_today_rounded,
                  label:
                      "${_formatDate(state.toDate)} ${_formatTime(state.toDate)}",
                  onTap: () => pickDateTime(context, false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Station Card ─────────────────────────────────────────
  Widget _buildStationCard(BuildContext context, CreateTicketState state) {
    return SectionCard(
      icon: Icons.train_rounded,
      title: "محطة البدء",
      child: Theme(
        data: Theme.of(context).copyWith(canvasColor: const Color(0xFF242B3D)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: state.station,
            dropdownColor: const Color(0xFF242B3D),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _accentColor,
            ),
            style: const TextStyle(color: Colors.white, fontSize: 15),
            items: _stations.map((stationName) {
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

  // ─── Counter Card ─────────────────────────────────────────
  Widget _buildCounterCard(BuildContext context, CreateTicketState state) {
    return SectionCard(
      icon: Icons.confirmation_number_rounded,
      title: "عدد المحطات",
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                CounterButton(
                  icon: Icons.remove_rounded,
                  onTap: () => context.read<CreateTicketCubit>().decrement(),
                  enabled: state.stationCount > 1,
                ),
                Container(
                  width: 44,
                  alignment: Alignment.center,
                  child: Text(
                    "${state.stationCount}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                CounterButton(
                  icon: Icons.add_rounded,
                  onTap: () => context.read<CreateTicketCubit>().increment(),
                  enabled: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Key Card ─────────────────────────────────────────────
  Widget _buildKeyCard() {
    return SectionCard(
      icon: Icons.vpn_key_rounded,
      title: "Key",
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: const Text(
          _keyValue,
          style: TextStyle(fontSize: 11, color: Color(0xFF7DD3FC), height: 1.5),
        ),
      ),
    );
  }

  Widget _buildTicketId(
    BuildContext context,
    TextEditingController controller,
  ) {
    return SectionCard(
      icon: Icons.title_sharp,
      title: "رقم التذكرة",
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(color: Colors.white),
        onChanged: (con) {
          context.read<CreateTicketCubit>().changeTicketId(controller);
        },
      ),
    );
  }

  Widget buildQR(String keyValue) {
    return QrImageView(
      data: keyValue,
      version: QrVersions.auto,
      size: 180,
      backgroundColor: Colors.white,
    );
  }

  // ─── Ticket Card ──────────────────────────────────────────
  Widget _buildTicketCard(CreateTicketState state) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1D3A6E), Color(0xFF1A5494)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.train_rounded,
                    color: Colors.white54,
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "وزارة النقل",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "تتمنى لكم رحلة سعيدة",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1.5,
                      ),
                    ),
                    child: buildQR(_keyValue),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "امسح للتحقق من التذكرة",
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Column(
                      children: [
                        TicketDetailsRow(
                          label: "رقم التذكرة",
                          value:
                              "TKT-${state.stationCount.toString().padLeft(4, '0')}",
                        ),
                        const _InfoDivider(),
                        TicketDetailsRow(
                          label: "تاريخ الإصدار",
                          value:
                              "${_formatDate(state.date)}  ${_formatTime(state.date)}",
                        ),
                        const _InfoDivider(),
                        TicketDetailsRow(
                          label: "صالحة حتى",
                          value:
                              "${_formatDate(state.toDate)}  ${_formatTime(state.toDate)}",
                        ),
                        const _InfoDivider(),
                        TicketDetailsRow(
                          label: "المحطة",
                          value: state.station.split(' - ').last,
                        ),
                        const _InfoDivider(),
                        TicketDetailsRow(
                          label: "عدد المحطات المسموح بها",
                          value: "${state.stationCount}",
                        ),
                        const _InfoDivider(),
                        TicketDetailsRow(
                          label: "رقم التذكرة",
                          value: state.ticketId.text,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Action Buttons ───────────────────────────────────────
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              foregroundColor: Colors.white70,
            ),
            onPressed: () {},
            icon: const Icon(Icons.share_rounded, size: 18),
            label: const Text("SHARE"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {},
            icon: const Icon(Icons.data_object_rounded, size: 18),
            label: const Text("DECODE PAYLOAD"),
          ),
        ),
      ],
    );
  }
}

class _InfoDivider extends StatelessWidget {
  const _InfoDivider();
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: Color(0xFFF3F4F6));
  }
}
