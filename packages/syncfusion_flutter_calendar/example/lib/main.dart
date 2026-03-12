import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';

void main() {
  return runApp(const CalendarApp());
}

/// The app which hosts the home page which contains the calendar on it.
class CalendarApp extends StatelessWidget {
  const CalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Calendar Demo', home: MyHomePage());
  }
}

/// The hove page which hosts the calendar
class MyHomePage extends StatefulWidget {
  /// Creates the home page to display teh calendar widget.
  const MyHomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SfCalendar(
          view: CalendarView.month,
          dataSource: MeetingDataSource(_getDataSource()),
          // by default the month appointment display mode set as Indicator, we can
          // change the display mode as appointment using the appointment display
          // mode property
          monthViewSettings: const MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
            dayFormat: 'EEE',
          ),
          timeSlotViewSettings: const TimeSlotViewSettings(
            numberOfDaysInView: 1,
            timeFormat: 'HH:mm',
            dayFormat: 'EEE',
          ),
          backgroundColor: const Color(0xFF000000),
          headerHeight: 0,
          viewHeaderHeight: 68,
          firstDayOfWeek: 1,
          todayHighlightColor: const Color(0xFF246BFD),
          todayTextStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFFFFFFFF),
            height: 1.57,
            fontWeight: FontWeight.bold,
          ),
          selectionDecoration: BoxDecoration(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.25),
          ),
          viewHeaderStyle: const ViewHeaderStyle(
            allDayPanelColor: Color(0xFFFFFFFF),
            backgroundColor: Color(0xFFFFFFFF),
            dayTextStyle: TextStyle(
              fontSize: 10,
              color: Color(0xFF888888),
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
            dateTextStyle: TextStyle(
              fontSize: 16,
              color: Color(0xFFFFFFFF),
              height: 1.625,
              fontWeight: FontWeight.w400,
            ),
          ),
          onTap: _onCalendarTapped,
        ),
      ),
    );
  }

  void _onCalendarTapped(CalendarTapDetails details) {
    final List<dynamic>? appointments = details.appointments;
    final DateTime? date = details.date;
    if (date == null) return;

    if (appointments == null || appointments.isEmpty) {
      _showDateDialog(date);
    } else if (appointments.length == 1) {
      _showMeetingDialog(appointments.first as Meeting);
    } else {
      _showMultipleEventsDialog(
        date,
        appointments.cast<Meeting>(),
      );
    }
  }

  void _showDateDialog(DateTime date) {
    showDialog<void>(
      context: context,
      builder: (_) => _CalendarDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DialogHeader(
              title: DateFormat('EEEE, MMM d').format(date),
              subtitle: DateFormat('yyyy').format(date),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.event_busy, color: Color(0xFF888888), size: 18),
                SizedBox(width: 8),
                Text(
                  'No events on this day',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMeetingDialog(Meeting meeting) {
    showDialog<void>(
      context: context,
      builder: (_) => _CalendarDialog(
        child: _MeetingDetail(meeting: meeting),
      ),
    );
  }

  void _showMultipleEventsDialog(DateTime date, List<Meeting> meetings) {
    showDialog<void>(
      context: context,
      builder: (_) => _CalendarDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DialogHeader(
              title: DateFormat('EEEE, MMM d').format(date),
              subtitle: '${meetings.length} events',
            ),
            const SizedBox(height: 12),
            ...meetings.map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MeetingDetail(meeting: m),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    final DateTime today = DateTime.now();
    final int y = today.year;
    final int m = today.month;

    // Normal event today
    meetings.add(Meeting(
      'Team Standup',
      DateTime(y, m, today.day, 9),
      DateTime(y, m, today.day, 10),
      const Color(0xFF246BFD),
      false,
    ));

    // Multiple events on same day (overlapping)
    meetings.add(Meeting(
      'Design Review',
      DateTime(y, m, today.day, 9, 30),
      DateTime(y, m, today.day, 11),
      const Color(0xFFE53935),
      false,
    ));

    // All-day event today
    meetings.add(Meeting(
      'Company Holiday',
      DateTime(y, m, today.day),
      DateTime(y, m, today.day, 23, 59),
      const Color(0xFFFF9800),
      true,
    ));

    // Event crossing midnight (starts today, ends tomorrow)
    meetings.add(Meeting(
      'Overnight Deploy',
      DateTime(y, m, today.day, 23),
      DateTime(y, m, today.day + 1, 2),
      const Color(0xFF7B1FA2),
      false,
    ));

    // Multi-day event spanning 3 days
    meetings.add(Meeting(
      'Offsite Retreat',
      DateTime(y, m, today.day + 2),
      DateTime(y, m, today.day + 4, 18),
      const Color(0xFF00897B),
      false,
    ));

    // Event at very start of day (00:00)
    meetings.add(Meeting(
      'Midnight Sync',
      DateTime(y, m, today.day + 1),
      DateTime(y, m, today.day + 1, 0, 30),
      const Color(0xFF546E7A),
      false,
    ));

    // Event at very end of day (23:30–23:59)
    meetings.add(Meeting(
      'Late Check-in',
      DateTime(y, m, today.day + 1, 23, 30),
      DateTime(y, m, today.day + 1, 23, 59),
      const Color(0xFFAD1457),
      false,
    ));

    // Weekend event
    final DateTime saturday = today.add(
      Duration(days: DateTime.saturday - today.weekday),
    );
    meetings.add(Meeting(
      'Weekend Workshop',
      DateTime(saturday.year, saturday.month, saturday.day, 10),
      DateTime(saturday.year, saturday.month, saturday.day, 16),
      const Color(0xFF2E7D32),
      false,
    ));

    // Very long title (truncation edge case)
    meetings.add(Meeting(
      'Annual Planning Meeting with All Department Heads',
      DateTime(y, m, today.day + 5, 14),
      DateTime(y, m, today.day + 5, 16),
      const Color(0xFFF57F17),
      false,
    ));

    // Event in previous month (leading date)
    final DateTime firstOfMonth = DateTime(y, m);
    if (firstOfMonth.weekday != DateTime.monday) {
      final DateTime prevMonthDate =
          firstOfMonth.subtract(const Duration(days: 2));
      meetings.add(Meeting(
        'Carry-over Task',
        DateTime(prevMonthDate.year, prevMonthDate.month, prevMonthDate.day, 11),
        DateTime(prevMonthDate.year, prevMonthDate.month, prevMonthDate.day, 12),
        const Color(0xFF78909C),
        false,
      ));
    }

    // Event in next month (trailing date)
    final DateTime lastOfMonth = DateTime(y, m + 1, 0);
    if (lastOfMonth.weekday != DateTime.sunday) {
      final DateTime nextMonthDate = lastOfMonth.add(const Duration(days: 2));
      meetings.add(Meeting(
        'Next Month Kickoff',
        DateTime(nextMonthDate.year, nextMonthDate.month, nextMonthDate.day, 9),
        DateTime(
            nextMonthDate.year, nextMonthDate.month, nextMonthDate.day, 10),
        const Color(0xFF00ACC1),
        false,
      ));
    }

    // Zero-duration event (start == end)
    meetings.add(Meeting(
      'Instant Reminder',
      DateTime(y, m, today.day + 3, 8),
      DateTime(y, m, today.day + 3, 8),
      const Color(0xFFEF5350),
      false,
    ));

    return meetings;
  }
}

// ---------------------------------------------------------------------------
// Dialog shell
// ---------------------------------------------------------------------------

class _CalendarDialog extends StatelessWidget {
  const _CalendarDialog({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1C1C1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            child,
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Color(0xFF246BFD)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable header inside the dialog
// ---------------------------------------------------------------------------

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF888888), fontSize: 13),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Single meeting detail block
// ---------------------------------------------------------------------------

class _MeetingDetail extends StatelessWidget {
  const _MeetingDetail({required this.meeting});

  final Meeting meeting;

  @override
  Widget build(BuildContext context) {
    final String timeLabel = meeting.isAllDay
        ? 'All day'
        : '${DateFormat('HH:mm').format(meeting.from)} – '
            '${DateFormat('HH:mm').format(meeting.to)}';

    final bool isMultiDay = !meeting.isAllDay &&
        (meeting.to.day != meeting.from.day ||
            meeting.to.month != meeting.from.month);

    final String dateLabel = meeting.isAllDay
        ? DateFormat('MMM d, yyyy').format(meeting.from)
        : isMultiDay
            ? '${DateFormat('MMM d').format(meeting.from)} – '
                '${DateFormat('MMM d, yyyy').format(meeting.to)}'
            : DateFormat('MMM d, yyyy').format(meeting.from);

    final bool isZeroDuration =
        !meeting.isAllDay && meeting.from == meeting.to;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: meeting.background, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            meeting.eventName,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _InfoRow(Icons.calendar_today_outlined, dateLabel),
          const SizedBox(height: 4),
          _InfoRow(Icons.access_time, timeLabel),
          if (meeting.isAllDay) ...[
            const SizedBox(height: 4),
            _InfoRow(Icons.event, 'All-day event'),
          ],
          if (isMultiDay) ...[
            const SizedBox(height: 4),
            _InfoRow(Icons.date_range, 'Spans multiple days'),
          ],
          if (isZeroDuration) ...[
            const SizedBox(height: 4),
            _InfoRow(Icons.alarm, 'Reminder (no duration)'),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF888888)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Data source
// ---------------------------------------------------------------------------

/// An object to set the appointment collection data source to calendar, which
/// used to map the custom appointment data to the calendar appointment, and
/// allows to add, remove or reset the appointment collection.
class MeetingDataSource extends CalendarDataSource {
  /// Creates a meeting data source, which used to set the appointment
  /// collection to the calendar
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).to;
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).background;
  }

  @override
  bool isAllDay(int index) {
    return _getMeetingData(index).isAllDay;
  }

  Meeting _getMeetingData(int index) {
    final dynamic meeting = appointments![index];
    late final Meeting meetingData;
    if (meeting is Meeting) {
      meetingData = meeting;
    }

    return meetingData;
  }
}

/// Custom business object class which contains properties to hold the detailed
/// information about the event data which will be rendered in calendar.
class Meeting {
  /// Creates a meeting class with required details.
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  /// Event name which is equivalent to subject property of [Appointment].
  String eventName;

  /// From which is equivalent to start time property of [Appointment].
  DateTime from;

  /// To which is equivalent to end time property of [Appointment].
  DateTime to;

  /// Background which is equivalent to color property of [Appointment].
  Color background;

  /// IsAllDay which is equivalent to isAllDay property of [Appointment].
  bool isAllDay;
}
