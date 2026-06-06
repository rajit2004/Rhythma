import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/theme.dart';

class RhythmaBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const RhythmaBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  static const _tabs = [
    _NavTab(icon: Icons.home_rounded, label: 'Home'),
    _NavTab(icon: Icons.favorite_rounded, label: 'Cycle'),
    _NavTab(icon: Icons.auto_awesome_rounded, label: 'Ask'),
    _NavTab(icon: Icons.bar_chart_rounded, label: 'Insights'),
    _NavTab(icon: Icons.person_rounded, label: 'You'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: RhythmaColors.surface.withOpacity(0.78),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: RhythmaColors.lavender.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: RhythmaColors.primary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final active = i == currentIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 40,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: active
                                ? RhythmaGradients.primary
                                : null,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: active
                                ? [
                                    BoxShadow(
                                      color: RhythmaColors.primary
                                          .withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            tab.icon,
                            size: 18,
                            color: active
                                ? Colors.white
                                : RhythmaColors.mutedFg,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? RhythmaColors.foreground
                                : RhythmaColors.mutedFg,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  final IconData icon;
  final String label;
  const _NavTab({required this.icon, required this.label});
}
