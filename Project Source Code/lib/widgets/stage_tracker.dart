import 'package:flutter/material.dart';
import '../core/constants/enums.dart';
import '../core/theme/app_colors.dart';

/// Horizontal stage tracker that animates as the mission progresses.
class StageTracker extends StatelessWidget {
  final MissionStage currentStage;

  const StageTracker({super.key, required this.currentStage});

  static const List<MissionStage> _ordered = [
    MissionStage.preparing,
    MissionStage.takingOff,
    MissionStage.flying,
    MissionStage.landing,
    MissionStage.delivering,
    MissionStage.returning,
    MissionStage.completed,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _ordered.indexOf(currentStage);
    return SizedBox(
      height: 64,
      child: Row(
        children: List.generate(_ordered.length, (i) {
          final isReached = i <= currentIndex;
          final isCurrent = i == currentIndex;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: isCurrent ? 14 : 10,
                    width: isCurrent ? 14 : 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isReached ? AppColors.primary : Colors.white12,
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.6),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _ordered[i].label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isReached
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                      fontSize: 10,
                      fontWeight:
                          isCurrent ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).expand((w) => [w, _Connector()]).toList()..removeLast(),
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 6,
      child: Center(
        child: Container(
          height: 2,
          color: Colors.white12,
        ),
      ),
    );
  }
}