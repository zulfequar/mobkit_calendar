import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'mobkit_calendar/controller/mobkit_calendar_controller.dart';
import 'mobkit_calendar/mobkit_calendar_widget.dart';
import 'mobkit_calendar/model/configs/calendar_config_model.dart';
import 'mobkit_calendar/model/mobkit_calendar_appointment_model.dart';

/// It allows you to use MobkitCalendar on your screen with a few parameters.
class MobkitCalendarWidget extends StatefulWidget {
  final DateTime? minDate;
  final MobkitCalendarConfigModel? config;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime) onSelectionChange;
  final Function(MobkitCalendarAppointmentModel model)? eventTap;

  /// [slotDateTime] is the [DateTime] object for the tapped slot.
  ///
  /// [slotLocation] is the location of the time slot within an even.
  ///
  /// [model] is the appointment model of the event which has occupied the
  /// tapped slot time. It's value is null if there is no such event.
  ///
  /// The type of [slotLocation] is [String]?.
  /// The type of [model] is [MobkitCalendarAppointmentModel]?
  /// <br> <br>
  /// It has four possible values:
  /// * 'event_start': If the tapped slot is a start time of an event.
  /// * 'event_end': If the tapped slot is an end time of an event.
  /// * 'within_event': If the tapped slot is between the start and end time of
  /// an event.
  /// * null: If the tapped slot is not booked in any event.
  final void Function(DateTime slotDateTime, String? slotLocation, MobkitCalendarAppointmentModel? model)? onSlotTap;

  /// List of currently selected slots. Typically, start and end time slots of
  /// an event.
  final List<DateTime> selectedSlots;

  /// A string representing a time slot in hh:mm format before which all the time slots in day view should be disabled.
  final String? disableSlotsBefore;

  /// A string representing a time slot in hh:mm format after which all the time slots in day view should be disabled.
  final String? disableSlotsAfter;

  /// A list of strings representing time slots where each string is in hh:mm format and for each string the time slot in day view should be disabled.
  final List<String> disabledSlots;

  /// Color for the disabled slots.
  final Color? disabledSlotsColor;
  final double? timeSlotsListInitialScrollOffset;
  final Function(DateTime datetime)? onDateChanged;
  final MobkitCalendarController? mobkitCalendarController;
  final Widget Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime)? onPopupWidget;
  final Widget Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime)? headerWidget;
  final Widget Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime)? titleWidget;
  final Widget Function(MobkitCalendarAppointmentModel list, DateTime datetime)? agendaWidget;
  final Widget Function(Map<DateTime, List<MobkitCalendarAppointmentModel>>)? weeklyViewWidget;
  final Function(DateTime datetime)? dateRangeChanged;

  const MobkitCalendarWidget({
    super.key,
    this.config,
    required this.onSelectionChange,
    this.eventTap,
    this.onSlotTap,
    this.selectedSlots = const [],
    this.disableSlotsBefore,
    this.disableSlotsAfter,
    this.disabledSlots = const [],
    this.disabledSlotsColor,
    this.timeSlotsListInitialScrollOffset,
    this.minDate,
    this.onPopupWidget,
    this.headerWidget,
    this.titleWidget,
    this.agendaWidget,
    this.onDateChanged,
    this.weeklyViewWidget,
    this.dateRangeChanged,
    required this.mobkitCalendarController,
  });

  @override
  State<MobkitCalendarWidget> createState() => _MobkitCalendarWidgetState();
}

class _MobkitCalendarWidgetState extends State<MobkitCalendarWidget> {
  late MobkitCalendarController mobkitCalendarController;

  @override
  void initState() {
    mobkitCalendarController = widget.mobkitCalendarController ?? MobkitCalendarController();
    initializeDateFormatting();
    super.initState();
    assert((widget.minDate ?? DateTime.utc(0, 0, 0)).isBefore(mobkitCalendarController.calendarDate), "Minimum Date cannot be greater than Calendar Date.");
  }

  late final ValueNotifier<List<DateTime>> selectedDates = ValueNotifier<List<DateTime>>(List<DateTime>.from([]));

  @override
  Widget build(BuildContext context) {
    return mobkitCalendarController.isLoadData
        ? MobkitCalendarView(
            config: widget.config,
            mobkitCalendarController: mobkitCalendarController,
            minDate: widget.minDate,
            onSelectionChange: widget.onSelectionChange,
            eventTap: widget.eventTap,
            onSlotTap: widget.onSlotTap,
            selectedSlots: widget.selectedSlots,
            disableSlotsBefore: widget.disableSlotsBefore,
            disableSlotsAfter: widget.disableSlotsAfter,
            disabledSlots: widget.disabledSlots,
            disabledSlotsColor: widget.disabledSlotsColor,
            timeSlotsListInitialScrollOffset: widget.timeSlotsListInitialScrollOffset,
            onPopupWidget: widget.onPopupWidget,
            headerWidget: widget.headerWidget,
            titleWidget: widget.titleWidget,
            agendaWidget: widget.agendaWidget,
            onDateChanged: widget.onDateChanged,
            weeklyViewWidget: widget.weeklyViewWidget,
            dateRangeChanged: widget.dateRangeChanged,
          )
        : const Center(child: CircularProgressIndicator());
  }
}
