import 'package:flutter/material.dart';
import 'package:mobkit_calendar/src/mobkit_calendar/calendar_agenda_bar.dart';
import 'package:mobkit_calendar/src/mobkit_calendar/calendar_date_bar.dart';
import 'package:mobkit_calendar/src/mobkit_calendar/controller/mobkit_calendar_controller.dart';
import 'package:mobkit_calendar/src/mobkit_calendar/model/configs/calendar_config_model.dart';
import 'package:mobkit_calendar/src/mobkit_calendar/utils/date_utils.dart';
import 'package:mobkit_calendar/src/extensions/date_extensions.dart';
import 'calendar_month_selection_bar.dart';
import 'calendar_weekdays_bar.dart';
import 'calendar_year_selection_bar.dart';
import 'enum/mobkit_calendar_view_type_enum.dart';
import 'model/mobkit_calendar_appointment_model.dart';
import '../calendar.dart';

/// Creates a [MobkitCalendarWidget] widget, which used to scheduling and managing events.
class MobkitCalendarView extends StatelessWidget {
  const MobkitCalendarView({
    Key? key,
    required this.mobkitCalendarController,
    required this.config,
    this.minDate,
    this.onSelectionChange,
    this.eventTap,
    this.onSlotTap,
    this.selectedSlots = const [],
    this.disableSlotsBefore,
    this.disableSlotsAfter,
    this.disabledSlots = const [],
    this.disabledSlotsColor,
    this.timeSlotsListInitialScrollOffset,
    this.onPopupWidget,
    this.headerWidget,
    this.titleWidget,
    this.agendaWidget,
    this.onDateChanged,
    this.weeklyViewWidget,
    this.dateRangeChanged,
  }) : super(key: key);
  final MobkitCalendarController mobkitCalendarController;
  final MobkitCalendarConfigModel? config;
  final DateTime? minDate;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime)? onSelectionChange;
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
  final Widget Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime)? onPopupWidget;
  final Widget Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime)? headerWidget;
  final Widget Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime)? titleWidget;
  final Widget Function(MobkitCalendarAppointmentModel list, DateTime datetime)? agendaWidget;
  final Function(DateTime datetime)? onDateChanged;
  final Widget Function(Map<DateTime, List<MobkitCalendarAppointmentModel>>)? weeklyViewWidget;
  final Function(DateTime datetime)? dateRangeChanged;

  /// Returns whether there is an intersection between two specified dates.
  bool? isIntersect(
    DateTime firstStartDate,
    DateTime firstEndDate,
    DateTime secondStartDate,
    DateTime secondEndDate,
  ) {
    return (secondStartDate.isBetween(firstStartDate, firstEndDate.add(const Duration(minutes: -1))) ?? false) ||
        (secondEndDate.add(const Duration(minutes: -1)).isBetween(firstStartDate, firstEndDate.add(const Duration(minutes: -1))) ?? false) ||
        (firstStartDate.isBetween(secondStartDate, secondEndDate.add(const Duration(minutes: -1))) ?? false) ||
        (firstEndDate.add(const Duration(minutes: -1)).isBetween(secondStartDate, secondEndDate.add(const Duration(minutes: -1))) ?? false);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    int maxGroupCount = 0;
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: mobkitCalendarController.mobkitCalendarViewType == MobkitCalendarViewType.agenda
          ? [
              Expanded(
                child: CalendarAgendaBar(
                  mobkitCalendarController: mobkitCalendarController,
                  config: config,
                  titleWidget: titleWidget,
                  agendaWidget: agendaWidget,
                  dateRangeChanged: dateRangeChanged,
                  eventTap: eventTap,
                  onDateChanged: onDateChanged,
                ),
              ),
            ]
          : [
              ListenableBuilder(
                  listenable: mobkitCalendarController,
                  builder: (BuildContext context, Widget? widget) {
                    return ((config?.topBarConfig.isVisibleTitleWidget ?? false))
                        ? titleWidget?.call(
                              findCustomModel(mobkitCalendarController.appointments, mobkitCalendarController.calendarDate),
                              mobkitCalendarController.calendarDate,
                            ) ??
                            Container()
                        : Container();
                  }),
              config?.topBarConfig.isVisibleMonthBar == true || config?.topBarConfig.isVisibleYearBar == true
                  ? SizedBox(
                      height: 30,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            config?.topBarConfig.isVisibleMonthBar == true
                                ? CalendarMonthSelectionBar(
                                    mobkitCalendarController,
                                    onSelectionChange,
                                    config,
                                  )
                                : Container(),
                            config?.topBarConfig.isVisibleMonthBar == true
                                ? const SizedBox(
                                    width: 10,
                                  )
                                : Container(),
                            config?.topBarConfig.isVisibleYearBar == true ? CalendarYearSelectionBar(mobkitCalendarController, onSelectionChange, config) : Container(),
                          ],
                        ),
                      ),
                    )
                  : Container(),
              config?.topBarConfig.isVisibleMonthBar == true || config?.topBarConfig.isVisibleYearBar == true
                  ? const SizedBox(
                      height: 15,
                    )
                  : Container(),
              config?.topBarConfig.isVisibleWeekDaysBar == true
                  ? SizedBox(
                      height: 30,
                      child: CalendarWeekDaysBar(
                        config: config,
                        customCalendarModel: mobkitCalendarController.appointments,
                        mobkitCalendarController: mobkitCalendarController,
                      ),
                    )
                  : Container(),
              config?.topBarConfig.isVisibleWeekDaysBar == true
                  ? const SizedBox(
                      height: 10,
                    )
                  : Container(),
              mobkitCalendarController.mobkitCalendarViewType == MobkitCalendarViewType.daily
                  ? SizedBox(
                      height: config?.dailyTopWidgetSize,
                      child: CalendarDateSelectionBar(
                        minDate: minDate,
                        onSelectionChange: onSelectionChange,
                        mobkitCalendarController: mobkitCalendarController,
                        config: config,
                        onPopupWidget: onPopupWidget,
                        headerWidget: headerWidget,
                        onDateChanged: onDateChanged,
                        weeklyViewWidget: weeklyViewWidget,
                      ),
                    )
                  : Expanded(
                      child: CalendarDateSelectionBar(
                        minDate: minDate,
                        onSelectionChange: onSelectionChange,
                        mobkitCalendarController: mobkitCalendarController,
                        config: config,
                        onPopupWidget: onPopupWidget,
                        headerWidget: headerWidget,
                        onDateChanged: onDateChanged,
                        weeklyViewWidget: weeklyViewWidget,
                      ),
                    ),
              mobkitCalendarController.mobkitCalendarViewType == MobkitCalendarViewType.daily ? mobkitCalendarDailyDataList(maxGroupCount, width) : Container(),
            ],
    );
  }

  // Modify the height of the event widget with a positive or a negative value.
  final double heightModifier = 85;

  ListenableBuilder mobkitCalendarDailyDataList(int maxGroupCount, double width) {
    return ListenableBuilder(
      listenable: mobkitCalendarController,
      builder: (BuildContext context, Widget? widget) {
        DateTime newDate = mobkitCalendarController.selectedDate ?? DateTime.now();
        List<MobkitCalendarAppointmentModel> modelList = mobkitCalendarController.appointments.where((element) {
          var item = !element.isAllDay &&
              ((DateTime(newDate.year, newDate.month, newDate.day).isBetween(element.appointmentStartDate, element.appointmentEndDate) ?? false) ||
                  (DateTime(newDate.year, newDate.month, newDate.day).isSameDay(element.appointmentStartDate)) ||
                  DateTime(newDate.year, newDate.month, newDate.day).isSameDay(element.appointmentEndDate.add(const Duration(minutes: -1))));
          return item;
        }).toList();
        List<MobkitCalendarAppointmentModel> allDayList = mobkitCalendarController.appointments
            .where((element) => ((DateTime(newDate.year, newDate.month, newDate.day).isBetween(element.appointmentStartDate, element.appointmentEndDate) ?? false) || DateTime(newDate.year, newDate.month, newDate.day).isSameDay(element.appointmentStartDate)) && element.isAllDay)
            .toList();
        modelList.sort((a, b) => a.appointmentStartDate.compareTo(b.appointmentStartDate));
        if (modelList.isNotEmpty) {
          for (var item in modelList) {
            if (modelList.indexOf(item) == 0) {
              item.index = 0;
              maxGroupCount = 1;
            } else {
              var indexOfData = 0;
              List<int> groupIndex = [];
              for (int i = 0; i < modelList.indexOf(item); i++) {
                if (isIntersect(item.appointmentStartDate, item.appointmentEndDate, modelList[i].appointmentStartDate, modelList[i].appointmentEndDate) ?? false) {
                  groupIndex.add((modelList[i].index ?? 0));
                  while (groupIndex.contains(indexOfData)) {
                    ++indexOfData;
                  }
                }
              }
              item.index = indexOfData;
              maxGroupCount = indexOfData + 1 > maxGroupCount ? indexOfData + 1 : maxGroupCount;
            }
          }
        }
        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              allDayList.isNotEmpty
                  ?
                  // All day event widgets
                  Padding(
                      padding: config?.dailyItemsConfigModel.allDayMargin ?? const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Text(
                            config?.dailyItemsConfigModel.allDayText ?? "All Day",
                            style: config?.dailyItemsConfigModel.allDayTextStyle ?? const TextStyle(color: Colors.black, fontSize: 14),
                          ),
                          SizedBox(
                            width: config?.dailyItemsConfigModel.space ?? 2,
                          ),
                          Expanded(
                            child: Row(
                              children: allDayList
                                  .map(
                                    (item) => Expanded(
                                      child: GestureDetector(
                                        onTap: () => eventTap?.call(item),
                                        child: Container(
                                          padding: config?.dailyItemsConfigModel.allDayFrameStyle?.padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: item.color ?? config?.dailyItemsConfigModel.allDayFrameStyle?.color,
                                            border: config?.dailyItemsConfigModel.allDayFrameStyle?.border,
                                            borderRadius: config?.dailyItemsConfigModel.allDayFrameStyle?.borderRadius,
                                          ),
                                          child: Text(
                                            item.title ?? "",
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: config?.dailyItemsConfigModel.allDayFrameStyle?.textStyle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              // Event widgets with time slots
              Expanded(
                child: SingleChildScrollView(
                  key: const PageStorageKey('daily_view_slots'),
                  controller: ScrollController(initialScrollOffset: timeSlotsListInitialScrollOffset ?? 0.0),
                  child: Stack(
                    children: List<Widget>.generate(
                      modelList.length,
                      (i) {
                        return Positioned(
                          top: 4 + topPositioned(modelList, i, newDate),
                          left: leftPositioned(modelList, i, width, maxGroupCount),
                          width: widthPositioned(width, maxGroupCount),
                          height: heightPositioned(modelList, i, newDate),
                          child: GestureDetector(
                            onTap: () => eventTap?.call(modelList[i]),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 1.5),
                              child: Container(
                                padding: config?.dailyItemsConfigModel.itemFrameStyle?.padding,
                                decoration: BoxDecoration(color: modelList[i].color?.withOpacity(0.8), borderRadius: config?.dailyItemsConfigModel.itemFrameStyle?.borderRadius ?? const BorderRadius.all(Radius.circular(1)), border: config?.dailyItemsConfigModel.itemFrameStyle?.border),
                                child: Align(
                                  alignment: config?.dailyItemsConfigModel.itemFrameStyle?.alignment ?? Alignment.topCenter,
                                  child: Text(
                                    modelList[i].title ?? "",
                                    style: config?.dailyItemsConfigModel.itemFrameStyle?.textStyle ?? const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )..insert(
                        0,
                        // Time slots widget
                        Column(
                          children: List<Widget>.generate(
                            24,
                            (slotHour) {
                              String timeDisableBefore = disableSlotsBefore ?? '';
                              String timeDisableAfter = disableSlotsAfter ?? '';
                              Color disabledSlotColor = disabledSlotsColor ?? config?.dailyItemsConfigModel.hourTextStyle?.color?.withOpacity(0.2) ?? const Color(0xFFDAEDF1);

                              // Evaluation for disabledSlots
                              bool isSlotDisabled = disabledSlots.contains('$slotHour:00') || disabledSlots.contains('${slotHour.toString().padLeft(2, '0')}:00');

                              // Evaluation for disableSlotsBefore
                              if (!isSlotDisabled && timeDisableBefore.contains(':')) {
                                int hourDisableBefore = int.parse(timeDisableBefore.split(':')[0]);
                                int minuteDisableBefore = int.parse(timeDisableBefore.split(':')[1]);
                                isSlotDisabled = slotHour < hourDisableBefore || (slotHour == hourDisableBefore && 0 < minuteDisableBefore);
                              }
                              // Evaluation for disableSlotsAfter
                              if (!isSlotDisabled && timeDisableAfter.contains(':')) {
                                isSlotDisabled = slotHour > int.parse(timeDisableAfter.split(':')[0]);
                              }

                              return Container(
                                alignment: Alignment.topCenter,
                                height: 80 + heightModifier,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12, right: 12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: isSlotDisabled
                                            ? null
                                            : () {
                                                DateTime slotDtTm = DateTime(newDate.year, newDate.month, newDate.day, slotHour, 0);
                                                String? slotLocation;
                                                MobkitCalendarAppointmentModel? model;
                                                for (int modelIndex = 0; modelIndex < modelList.length; modelIndex++) {
                                                  if (slotDtTm == modelList[modelIndex].appointmentStartDate) {
                                                    slotLocation = 'event_start';
                                                    model = modelList[modelIndex];
                                                    break;
                                                  } else if (slotDtTm == modelList[modelIndex].appointmentEndDate) {
                                                    slotLocation = 'event_end';
                                                    model = modelList[modelIndex];
                                                    break;
                                                  } else if (slotDtTm.isBetween(modelList[modelIndex].appointmentStartDate.add(const Duration(minutes: 1)), modelList[modelIndex].appointmentEndDate.subtract(const Duration(minutes: 1))) ?? false) {
                                                    slotLocation = 'within_event';
                                                    model = modelList[modelIndex];
                                                    break;
                                                  }
                                                }
                                                return onSlotTap?.call(slotDtTm, slotLocation, model);
                                              },
                                        child: Container(
                                          padding: const EdgeInsets.only(bottom: 15),
                                          decoration: BoxDecoration(color: selectedSlots.contains(DateTime(newDate.year, newDate.month, newDate.day, slotHour, 0)) ? (config?.cellConfig.selectedStyle?.color?.withOpacity(0.3) ?? Colors.blue[100]) : null, borderRadius: BorderRadius.circular(5)),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${slotHour.toString().padLeft(2, '0')}:00',
                                                style: isSlotDisabled
                                                    ? config?.dailyItemsConfigModel.hourTextStyle?.copyWith(color: disabledSlotColor) ??
                                                        TextStyle(
                                                          color: disabledSlotColor,
                                                          fontSize: 18,
                                                        )
                                                    : config?.dailyItemsConfigModel.hourTextStyle ??
                                                        const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 18,
                                                        ),
                                              ),
                                              Container(
                                                width: width * 0.8,
                                                color: isSlotDisabled ? disabledSlotColor : Theme.of(context).dividerColor,
                                                height: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      ...List.generate(3, (i) {
                                        int slotMinute = (i + 1) * 15;

                                        // Evaluation for disabledSlots
                                        isSlotDisabled = disabledSlots.contains('$slotHour:$slotMinute') || disabledSlots.contains('${slotHour.toString().padLeft(2, '0')}:$slotMinute');

                                        // Evaluation for disableSlotsBefore
                                        if (!isSlotDisabled && timeDisableBefore.contains(':')) {
                                          int hourDisableBefore = int.parse(timeDisableBefore.split(':')[0]);
                                          int minuteDisableBefore = int.parse(timeDisableBefore.split(':')[1]);
                                          isSlotDisabled = slotHour < hourDisableBefore || (slotHour == hourDisableBefore && slotMinute < minuteDisableBefore);
                                        }
                                        // Evaluation for disableSlotsAfter
                                        if (!isSlotDisabled && timeDisableAfter.contains(':')) {
                                          int hourDisableAfter = int.parse(timeDisableAfter.split(':')[0]);
                                          int minuteDisableAfter = int.parse(timeDisableAfter.split(':')[1]);
                                          isSlotDisabled = slotHour > hourDisableAfter || (slotHour == hourDisableAfter && slotMinute > minuteDisableAfter);
                                        }
                                        return InkWell(
                                          onTap: isSlotDisabled
                                              ? null
                                              : () {
                                                  DateTime slotDtTm = DateTime(newDate.year, newDate.month, newDate.day, slotHour, slotMinute);
                                                  String? slotLocation;
                                                  MobkitCalendarAppointmentModel? model;
                                                  for (int modelIndex = 0; modelIndex < modelList.length; modelIndex++) {
                                                    if (slotDtTm == modelList[modelIndex].appointmentStartDate) {
                                                      slotLocation = 'event_start';
                                                      model = modelList[modelIndex];
                                                      break;
                                                    } else if (slotDtTm == modelList[modelIndex].appointmentEndDate) {
                                                      slotLocation = 'event_end';
                                                      model = modelList[modelIndex];
                                                      break;
                                                    } else if (slotDtTm.isBetween(modelList[modelIndex].appointmentStartDate.add(const Duration(minutes: 1)), modelList[modelIndex].appointmentEndDate.subtract(const Duration(minutes: 1))) ?? false) {
                                                      slotLocation = 'within_event';
                                                      model = modelList[modelIndex];
                                                      break;
                                                    }
                                                  }
                                                  return onSlotTap?.call(slotDtTm, slotLocation, model);
                                                },
                                          child: Container(
                                            padding: const EdgeInsets.only(bottom: 15),
                                            decoration: BoxDecoration(
                                              color: selectedSlots.contains(DateTime(newDate.year, newDate.month, newDate.day, slotHour, slotMinute)) ? (config?.cellConfig.selectedStyle?.color?.withOpacity(0.3) ?? Colors.blue[100]) : null,
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '${slotHour.toString().padLeft(2, '0')}:$slotMinute',
                                                  style: isSlotDisabled
                                                      ? config?.dailyItemsConfigModel.hourTextStyle?.copyWith(color: disabledSlotColor) ??
                                                          TextStyle(
                                                            color: disabledSlotColor,
                                                            fontSize: 18,
                                                          )
                                                      : config?.dailyItemsConfigModel.hourTextStyle ??
                                                          const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 18,
                                                          ),
                                                ),
                                                Container(
                                                  width: width * 0.8,
                                                  color: isSlotDisabled ? disabledSlotColor : Theme.of(context).dividerColor.withOpacity(0.3),
                                                  height: 1,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double heightPositioned(List<MobkitCalendarAppointmentModel> modelList, int i, DateTime newDate) {
    return (!modelList[i].appointmentEndDate.isSameDay(newDate) && !modelList[i].appointmentStartDate.isSameDay(newDate))
        ? 24 * (80 + heightModifier)
        : (!modelList[i].appointmentStartDate.isSameDay(newDate) && modelList[i].appointmentEndDate.isSameDay(newDate))
            ? ((80 + heightModifier) * (modelList[i].appointmentEndDate.hour + (modelList[i].appointmentEndDate.minute / 60))).toDouble() != 0
                ? ((80 + heightModifier) * (modelList[i].appointmentEndDate.hour + (modelList[i].appointmentEndDate.minute / 60))).toDouble() + 9
                : ((80 + heightModifier) * (modelList[i].appointmentEndDate.hour + (modelList[i].appointmentEndDate.minute / 60))).toDouble()
            : modelList[i].appointmentEndDate.hour != 0
                ? (((modelList[i].appointmentEndDate.difference(modelList[i].appointmentStartDate).inMinutes) / 60) * (80 + heightModifier))
                : modelList[i].appointmentEndDate.difference(modelList[i].appointmentStartDate).inHours * (80 + heightModifier);
  }

  double widthPositioned(double width, int maxGroupCount) => (width * 0.8) / (maxGroupCount);

  double leftPositioned(List<MobkitCalendarAppointmentModel> modelList, int i, double width, int maxGroupCount) {
    return 58.5 - 9.5 + ((modelList[i].index ?? 0) > 0 ? ((width * 0.8) / maxGroupCount) * (modelList[i].index ?? 0) : 0);
  }

  double topPositioned(List<MobkitCalendarAppointmentModel> modelList, int i, DateTime newDate) {
    return (!modelList[i].appointmentEndDate.isSameDay(newDate) && !modelList[i].appointmentStartDate.isSameDay(newDate))
        ? 0
        : (!modelList[i].appointmentStartDate.isSameDay(newDate) && modelList[i].appointmentEndDate.isSameDay(newDate))
            ? 0
            : ((80 + heightModifier) * (modelList[i].appointmentStartDate.hour + (modelList[i].appointmentStartDate.minute / 60))).toDouble() != 0
                ? ((80 + heightModifier) * (modelList[i].appointmentStartDate.hour + (modelList[i].appointmentStartDate.minute / 60))).toDouble() + 9
                : ((80 + heightModifier) * (modelList[i].appointmentStartDate.hour + (modelList[i].appointmentStartDate.minute / 60))).toDouble();
  }
}
