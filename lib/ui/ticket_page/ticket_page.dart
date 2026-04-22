import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_generate/cubit/ticket_cubit/create_ticket_cubit.dart';
import 'package:qr_generate/cubit/ticket_cubit/create_ticket_state.dart';
import 'package:qr_generate/widgets/custom_widget/date_widget.dart';
import 'package:qr_generate/widgets/ticket_widgets/counter_widget.dart';
import 'package:qr_generate/widgets/custom_widget/custom_app_bar.dart';
import 'package:qr_generate/widgets/ticket_widgets/stations_widget.dart';
import 'package:qr_generate/widgets/ticket_widgets/ticket_details.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class CreateTicketPage extends StatelessWidget {
  const CreateTicketPage({super.key});

  static const _stations = [
    "2085 - أكاديمية الرشطة",
    "2087 - طريق السويس",
    "2088 - عدلي منصور",
    "2089 - السلام",
    "2090 - الفريق ابراهيم العرابي",
    "2091 - مؤسسة الزكاة",
    "2092 - القلج",
    "2093 - المرج",
    "2094 - الخصوص",
    "2095 - مسطرد",
    "2096 - بهتيم",
    "2097 - شبا بنها",
    "2098 - العقيد احمد عبدالرحيم",
    "2099 - اسكندرية الزراعي",
    "2100 - باسوس",
    "2101 - الوراق",
    "2102 - شبرا مصر",
    "2103 - إمبابة",
    "2104 - محور احمد عرابي",
    "2105 - ارض اللواء",
    "2106 - الباجيل",
    "2107 - محور 26 يوليو",
    "2108 - المعتمدية",
    "2109 - زنين",
    "2110 - صفط اللبن",
    "2111 - منشأة البكاري",
    "2112 - مسجد المدينة",
    "2113 - الملك فيصل",
    "2114 - الهرم",
    "2115 - ترسا",
    "2116 - المريوطية",
    "2117 - الطالبية",
    "2118 - العمرانية",
    "2119 - البحر الاعظم",
    "2120 - الزهراء",
    "2121 - الإمامين",
    "2122 - شارع الجزائر",
    "2123 - الأوتوستراد",
    "2124 - المقطم",
    "2125 - كارفور المعادي",
    "2126 - النساجون الشرقيون",
    "2127 - طريق السخنة",
    "2128 - الجولف",
    "2129 - المشير طنطاوي",
    "2130 - المتحف المصري الكبير",
    "2131 - مدخل أكتوبر",
    "2132 - تقاطع الفيوم",
    "2133 - المنصورية",
  ];
  static const accentColor = Color(0xFF4F8EF7);
  static const surfaceBg = Color(0xFF111827);
  static const String _keyValue = "gUdeENpYlayCon56lgAzlVDtUBrvAndF";

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

  static final ScreenshotController _screenshotController =
      ScreenshotController();
  Future<void> _shareTicket() async {
    final image = await _screenshotController.capture(pixelRatio: 3.0);
    if (image == null) return;

    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/ticket.png').writeAsBytes(image);

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: 'تذكرتي'),
    );
  }

  // ─── Build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateTicketCubit(),
      child: Scaffold(
        backgroundColor: surfaceBg,
        appBar: const CustomAppBar(),
        body: BlocBuilder<CreateTicketCubit, CreateTicketState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    const SizedBox(height: 14),
                    _buildDateTimeCard(context, state),
                    const SizedBox(height: 14),
                    _buildTicketId(state),
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
              ),
            );
          },
        ),
      ),
    );
  }

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
        ],
      ),
    );
  }

  Widget _buildTicketId(
    CreateTicketState state,

    // BuildContext context,
    // TextEditingController controller,
  ) {
    return SectionCard(
      icon: Icons.title_sharp,
      title: "رقم التذكرة",
      child: Text(
        state.ticketId,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),

      // TextField(
      //   controller: controller,
      //   keyboardType: TextInputType.number,
      //   style: TextStyle(color: Colors.white),
      //   onChanged: (con) {
      //     context.read<CreateTicketCubit>().changeTicketId(controller);
      //   },
    );
  }

  Widget _buildStationCard(BuildContext context, CreateTicketState state) {
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
              color: accentColor,
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

  Widget buildQR(String keyValue) {
    return QrImageView(
      data: keyValue,
      version: QrVersions.auto,
      size: 180,
      backgroundColor: Colors.white,
    );
  }

  Widget _buildTicketCard(CreateTicketState state) {
    return Screenshot(
      controller: _screenshotController,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 8, 38, 93),
                    Color.fromARGB(255, 9, 115, 228),
                    Color.fromARGB(255, 141, 125, 219),
                  ],
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
                    child: buildQR(
                      CreateTicketCubit.buildEncryptedQrPayload(
                        ticketId: state.ticketId,
                        stationCount: state.stationCount,
                        sourceStationId: CreateTicketCubit.parseStationId(
                          state.station,
                        ),
                        destinationStationId:
                            CreateTicketCubit.parseStationId(state.station) +
                            state.stationCount,
                      ),
                    ),
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
                          value: state.ticketId,
                        ),
                        const _InfoDivider(),
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
                          value:
                              state.station?.split(' - ').last ?? "اختر المحطة",
                        ),
                        const _InfoDivider(),
                        TicketDetailsRow(
                          label: "عدد المحطات المسموح بها",
                          value: "${state.stationCount}",
                        ),
                        const _InfoDivider(),
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
            onPressed: () {
              _shareTicket();
            },
            icon: const Icon(Icons.share_rounded, size: 18),
            label: const Text("SHARE"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
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
