import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> labels;
  final double circleRadius;
  final double lineHeight;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? textColor;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.labels,
    this.circleRadius = 16.0,
    this.lineHeight = 3.0,
    this.activeColor,
    this.inactiveColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    // Move the assertion to the build method
    assert(labels.length == totalSteps,
        'Number of labels must match the total steps');
            
    final theme = Theme.of(context);
    final actualActiveColor = activeColor ?? theme.colorScheme.primary;
    final actualInactiveColor = inactiveColor ?? Colors.grey.shade300;
    final actualTextColor = textColor ?? theme.textTheme.bodyMedium?.color ?? Colors.black;

    return Column(
      children: [
        Row(
          children: List.generate(totalSteps * 2 - 1, (index) {
            // For even indices, render a circle
            if (index % 2 == 0) {
              final stepNumber = (index ~/ 2) + 1;
              final isActive = stepNumber <= currentStep;
              
              return _buildCircle(
                stepNumber.toString(),
                isActive,
                actualActiveColor,
                actualInactiveColor,
                actualTextColor,
              );
            } 
            // For odd indices, render a line
            else {
              final prevStepNumber = (index ~/ 2) + 1;
              final isActive = prevStepNumber <= currentStep;
              
              return _buildLine(
                isActive,
                actualActiveColor,
                actualInactiveColor,
              );
            }
          }),
        ),
        const SizedBox(height: 8),
        _buildLabels(actualActiveColor, actualInactiveColor, actualTextColor),
      ],
    );
  }

  Widget _buildCircle(
    String text,
    bool isActive,
    Color activeColor,
    Color inactiveColor,
    Color textColor,
  ) {
    return Container(
      width: circleRadius * 2,
      height: circleRadius * 2,
      decoration: BoxDecoration(
        color: isActive ? activeColor : inactiveColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : textColor,
            fontWeight: FontWeight.bold,
            fontSize: circleRadius * 0.75,
          ),
        ),
      ),
    );
  }

  Widget _buildLine(
    bool isActive,
    Color activeColor,
    Color inactiveColor,
  ) {
    return Expanded(
      child: Container(
        height: lineHeight,
        color: isActive ? activeColor : inactiveColor,
      ),
    );
  }

  Widget _buildLabels(
    Color activeColor,
    Color inactiveColor,
    Color textColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(totalSteps, (index) {
        final stepNumber = index + 1;
        final isActive = stepNumber <= currentStep;
        
        return SizedBox(
          width: (stepNumber == 1 || stepNumber == totalSteps) 
              ? circleRadius * 2 
              : circleRadius * 4,
          child: Text(
            labels[index],
            style: TextStyle(
              color: isActive ? activeColor : textColor,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
            textAlign: stepNumber == 1 
                ? TextAlign.left 
                : (stepNumber == totalSteps ? TextAlign.right : TextAlign.center),
          ),
        );
      }),
    );
  }
}