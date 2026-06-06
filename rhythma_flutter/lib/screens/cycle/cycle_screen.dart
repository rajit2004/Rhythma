import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../components/shared.dart';

class CycleScreen extends StatefulWidget {
  const CycleScreen({Key? key}) : super(key: key);

  @override
  State<CycleScreen> createState() => _CycleScreenState();
}

class _CycleScreenState extends State<CycleScreen> {
  int _selectedDay = 14;
  final int _today = 14;
  final int _monthDays = 30;
  final int _firstWeekday = 5; // Friday

  // Day → phase
  static String _phase(int day) {
    if (day <= 5) return 'Period';
    if (day <= 13) return 'Follicular';
    if (day <= 16) return 'Ovulation';
    return 'Luteal';
  }

  static Color _phaseColor(int day) {
    if (day <= 5) return RhythmaColors.rose;
    if (day <= 13) return RhythmaColors.primary;
    if (day <= 16) return RhythmaColors.teal;
    return RhythmaColors.coral;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _ScreenHeader(
            title: 'Cycle Tracker',
            subtitle: 'November 2025',
          ),

          // Calendar card
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Month nav
                Row(
                  children: [
                    _CircleBtn(icon: Icons.chevron_left_rounded, onTap: () {}),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'November 2025',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: RhythmaColors.foreground,
                          ),
                        ),
                      ),
                    ),
                    _CircleBtn(
                        icon: Icons.chevron_right_rounded, onTap: () {}),
                  ],
                ),
                const SizedBox(height: 14),

                // Weekday headers
                Row(
                  children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                      .map((d) => Expanded(
                            child: Center(
                              child: Text(
                                d,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: RhythmaColors.mutedFg,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),

                // Days grid
                Wrap(
                  children: [
                    // empty cells for first weekday
                    ...List.generate(
                      _firstWeekday,
                      (_) => const SizedBox(
                          width: double.infinity / 7,
                          height: 44),
                    ),
                    ...List.generate(_monthDays, (i) {
                      final day = i + 1;
                      final phase = _phase(day);
                      final phaseColor = _phaseColor(day);
                      final isSelected = _selectedDay == day;
                      final isToday = _today == day;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedDay = day),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 7 - 3,
                          height: 46,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? phaseColor
                                      : phaseColor.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$day',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isToday && !isSelected
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : RhythmaColors.foreground,
                                      ),
                                    ),
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? Colors.white
                                            : phaseColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 14),
                Container(height: 1, color: RhythmaColors.border),
                const SizedBox(height: 12),

                // Legend
                Wrap(
                  spacing: 14,
                  runSpacing: 6,
                  children: [
                    _Legend('Period', RhythmaColors.rose),
                    _Legend('Follicular', RhythmaColors.primary),
                    _Legend('Ovulation', RhythmaColors.teal),
                    _Legend('Luteal', RhythmaColors.coral),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Log section
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Log for Nov $_selectedDay · ${_phase(_selectedDay)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: RhythmaColors.foreground,
              ),
            ),
          ),
          _LogRow(
            icon: Icons.water_drop_outlined,
            label: 'Flow',
            options: const ['None', 'Light', 'Medium', 'Heavy'],
            color: RhythmaColors.rose,
          ),
          const SizedBox(height: 10),
          _LogRow(
            icon: Icons.sentiment_satisfied_alt_rounded,
            label: 'Mood',
            options: const ['😊', '😐', '😔', '😤', '🥰'],
            color: RhythmaColors.coral,
          ),
          const SizedBox(height: 10),
          _LogRow(
            icon: Icons.bolt_rounded,
            label: 'Energy',
            options: const ['Low', 'Mid', 'High'],
            color: RhythmaColors.primary,
          ),
          const SizedBox(height: 10),
          _LogRow(
            icon: Icons.bedtime_outlined,
            label: 'Sleep',
            options: const ['<5h', '5-7h', '7-9h', '9h+'],
            color: RhythmaColors.primary,
          ),
          const SizedBox(height: 10),
          _LogRow(
            icon: Icons.psychology_outlined,
            label: 'Symptoms',
            options: const ['Cramps', 'Headache', 'Bloating', 'Acne'],
            color: RhythmaColors.teal,
          ),
        ],
      ),
    );
  }
}

class _LogRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final List<String> options;
  final Color color;

  const _LogRow({
    required this.icon,
    required this.label,
    required this.options,
    required this.color,
  });

  @override
  State<_LogRow> createState() => _LogRowState();
}

class _LogRowState extends State<_LogRow> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, color: widget.color, size: 17),
              ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: RhythmaColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.options.map((opt) {
              final sel = _selected == opt;
              return GestureDetector(
                onTap: () => setState(
                    () => _selected = sel ? null : opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel
                        ? widget.color
                        : RhythmaColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    opt,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: sel
                          ? Colors.white
                          : RhythmaColors.foreground,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final String label;
  final Color color;
  const _Legend(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: RhythmaColors.mutedFg,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: RhythmaColors.surfaceMuted,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Icon(icon, size: 18, color: RhythmaColors.foreground),
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _ScreenHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 8, 2, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: RhythmaColors.foreground,
              )),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!,
                style: TextStyle(
                    fontSize: 13, color: RhythmaColors.mutedFg)),
          ],
        ],
      ),
    );
  }
}
