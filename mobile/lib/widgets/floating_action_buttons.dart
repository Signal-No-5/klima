import 'package:flutter/material.dart';

class KlimaFloatingActionButtons extends StatefulWidget {
  final VoidCallback onReportTap;
  final VoidCallback onHelpTap;
  final VoidCallback onSafeTap;

  const KlimaFloatingActionButtons({
    super.key,
    required this.onReportTap,
    required this.onHelpTap,
    required this.onSafeTap,
  });

  @override
  State<KlimaFloatingActionButtons> createState() =>
      _KlimaFloatingActionButtonsState();
}

class _KlimaFloatingActionButtonsState extends State<KlimaFloatingActionButtons>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Report Button
        ScaleTransition(
          scale: _animation,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildActionButton(
              icon: Icons.report,
              label: 'Mag-report',
              color: Colors.blue,
              onTap: () {
                widget.onReportTap();
                _toggle();
              },
            ),
          ),
        ),

        // Help Button
        ScaleTransition(
          scale: _animation,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildActionButton(
              icon: Icons.sos,
              label: 'Kailangan ng Tulong',
              color: Colors.red,
              onTap: () {
                widget.onHelpTap();
                _toggle();
              },
            ),
          ),
        ),

        // Safe Button
        ScaleTransition(
          scale: _animation,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildActionButton(
              icon: Icons.check_circle,
              label: 'Ligtas Ako',
              color: Colors.green,
              onTap: () {
                widget.onSafeTap();
                _toggle();
              },
            ),
          ),
        ),

        // Main FAB
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: Colors.orange,
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _animation,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          // Use theme surface color so label contrasts correctly in dark mode
          color: Theme.of(context).colorScheme.surface,
          elevation: 4,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                // Use onSurface so it contrasts with surface in both themes
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FloatingActionButton(
          mini: true,
          onPressed: onTap,
          backgroundColor: color,
          heroTag: label,
          child: Icon(icon),
        ),
      ],
    );
  }
}
