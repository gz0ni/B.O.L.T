import 'package:flutter/material.dart';

import '../core/connection_controller.dart';
import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';

/// Кольцевая "radar"-анимация вокруг кнопки — активна только в
/// состоянии `on`, как в мокапе (.ring + @keyframes radar).
class _RadarRings extends StatefulWidget {
  const _RadarRings({required this.active, required this.color});

  final bool active;
  final Color color;

  @override
  State<_RadarRings> createState() => _RadarRingsState();
}

class _RadarRingsState extends State<_RadarRings>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    if (widget.active) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant _RadarRings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return const SizedBox.shrink();
    // Три кольца со сдвигом по фазе .9s / 1.8s из 2.6s цикла — те же
    // пропорции, что в CSS-анимации мокапа.
    return Stack(
      alignment: Alignment.center,
      children: List.generate(3, (i) {
        final delay = i / 3; // 0, .333, .666 доли периода
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = (_controller.value + (1 - delay)) % 1.0;
            final scale = 0.72 + t * (1.28 - 0.72);
            final opacity = (1 - t) * 0.55;
            return Opacity(
              opacity: opacity.clamp(0, 1),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 208,
                  height: 208,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: widget.color, width: 1),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class PowerButton extends StatelessWidget {
  const PowerButton({
    super.key,
    required this.status,
    required this.onTap,
  });

  final ConnectionStatus status;
  final VoidCallback onTap;

  Color _glowColor(AppSemanticColors s) {
    switch (status) {
      case ConnectionStatus.on:
        return s.on;
      case ConnectionStatus.connecting:
        return s.connecting;
      case ConnectionStatus.error:
        return s.danger;
      case ConnectionStatus.idle:
        return s.idle;
    }
  }

  Color _glowDim(AppSemanticColors s) {
    switch (status) {
      case ConnectionStatus.on:
        return s.onDim;
      case ConnectionStatus.connecting:
        return s.connectingDim;
      case ConnectionStatus.error:
        return s.dangerDim;
      case ConnectionStatus.idle:
        return s.idleDim;
    }
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    final color = _glowColor(semantic);
    final dim = _glowDim(semantic);
    final isOn = status == ConnectionStatus.on;
    final isConnecting = status == ConnectionStatus.connecting;

    return SizedBox(
      width: 208,
      height: 208,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _RadarRings(active: isOn, color: semantic.on),
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: AppMotion.slow,
              curve: AppMotion.ease,
              width: 164,
              height: 164,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.36, -0.44),
                  radius: 0.9,
                  colors: [surfaces.card2, surfaces.card],
                  stops: const [0.0, 0.7],
                ),
                border: Border.all(color: surfaces.border),
                boxShadow: [
                  if (isOn || isConnecting)
                    BoxShadow(
                      color: dim,
                      blurRadius: isOn ? 46 : 34,
                      spreadRadius: isOn ? 6 : 4,
                    ),
                  const BoxShadow(
                    color: Color(0x99000000),
                    blurRadius: 40,
                    offset: Offset(0, 20),
                  ),
                ],
              ),
              child: Center(
                child: isConnecting
                    ? SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      )
                    : Icon(Icons.power_settings_new, size: 54, color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}