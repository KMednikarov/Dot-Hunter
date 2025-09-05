import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';

import 'bloc/game_cubit.dart';
import 'leaderboard_page.dart';

class GamePage extends StatelessWidget {
  final bool glowEnabled;
  final bool powerupButtonsRight;
  const GamePage({super.key, required this.glowEnabled, required this.powerupButtonsRight});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameCubit(),
      child: _GameView(glowEnabled: glowEnabled, powerupButtonsRight: powerupButtonsRight),
    );
  }
}

class _GameView extends StatefulWidget {
  final bool glowEnabled;
  final bool powerupButtonsRight;
  const _GameView({required this.glowEnabled, required this.powerupButtonsRight});

  @override
  State<_GameView> createState() => _GameViewState();
}

class _GameViewState extends State<_GameView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  static const double _cooldownDuration = 5.0;
  late final AudioPlayer _bgmPlayer;
  late final AudioPlayer _tapPlayer;
  late final AudioPlayer _losePlayer;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    if (widget.glowEnabled) {
      _glowController.repeat(reverse: true);
    }
    _bgmPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
    _tapPlayer = AudioPlayer();
    _losePlayer = AudioPlayer();
    _bgmPlayer.play(AssetSource('audio/background.mp3'));
  }

  @override
  void dispose() {
    _bgmPlayer.dispose();
    _tapPlayer.dispose();
    _losePlayer.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Widget _buildPowerButton({
    required IconData icon,
    required int charges,
    required VoidCallback? onPressed,
    required String heroTag,
    required double cooldown,
  }) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: Stack(
        key: ValueKey(charges),
        alignment: Alignment.center,
        children: [
          FloatingActionButton(
            heroTag: heroTag,
            mini: true,
            onPressed: cooldown > 0 ? null : onPressed,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Text(
                    '$charges',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (cooldown > 0)
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                value: cooldown / _cooldownDuration,
                backgroundColor: Colors.black26,
                valueColor: const AlwaysStoppedAnimation(Colors.white70),
                strokeWidth: 4,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dot Hunter'),
        actions: [
          BlocBuilder<GameCubit, GameState>(
            buildWhen: (p, c) => p.isPaused != c.isPaused,
            builder: (context, state) {
              return IconButton(
                icon: Icon(state.isPaused ? Icons.play_arrow : Icons.pause),
                onPressed: () => context.read<GameCubit>().togglePause(),
              );
            },
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<GameCubit, GameState>(
            listenWhen: (previous, current) =>
                !previous.isGameOver && current.isGameOver,
            listener: (context, state) {
              final gameCubit = context.read<GameCubit>();
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text('Game Over'),
                    content: Text('Score: ${state.score}'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          Navigator.of(dialogContext)
                              .push(
                            MaterialPageRoute(
                              builder: (_) => const LeaderboardPage(),
                            ),
                          )
                              .then((_) => gameCubit.restart());
                        },
                        child: const Text('Leaderboard'),
                      ),
                      TextButton(
                        onPressed: () =>
                            Share.share('I scored ${state.score} in Dot Hunter!'),
                        child: const Text('Share'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          Share.share('I scored ${state.score} in Dot Hunter!');
                        },
                        child: const Text('Share'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          gameCubit.restart();
                        },
                        child: const Text('Play Again'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          Navigator.of(dialogContext).pop();
                        },
                        child: const Text('Main Menu'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          BlocListener<GameCubit, GameState>(
            listenWhen: (previous, current) => current.score > previous.score,
            listener: (context, state) {
              _tapPlayer.play(AssetSource('audio/tap.mp3'));
            },
          ),
          BlocListener<GameCubit, GameState>(
            listenWhen: (previous, current) => current.lives < previous.lives,
            listener: (context, state) {
              _losePlayer.play(AssetSource('audio/lose_life.mp3'));
            },
          ),
        ],
        child: BlocBuilder<GameCubit, GameState>(
          builder: (context, state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                context.read<GameCubit>().updateAreaSize(
                    Size(constraints.maxWidth, constraints.maxHeight));
                return Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (details) =>
                            context.read<GameCubit>().handleTap(details.localPosition),
                        child: Stack(
                          children: [
                            ...state.dots.map(
                              (dot) => Positioned(
                                left: dot.position.dx - dot.radius,
                                top: dot.position.dy - dot.radius,
                                child: AnimatedBuilder(
                                  animation: _glowController,
                                  builder: (context, child) {
                                    final blur = widget.glowEnabled
                                        ? 8 + (_glowController.value * 6)
                                        : 8.0;
                                    final spread = widget.glowEnabled
                                        ? 1 + (_glowController.value * 2)
                                        : 1.0;
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      width: dot.radius * 2,
                                      height: dot.radius * 2,
                                      decoration: BoxDecoration(
                                        color: dot.color,
                                        shape: BoxShape.circle,
                                        boxShadow: dot.color == Colors.red
                                            ? null
                                            : [
                                                BoxShadow(
                                                  color: dot.color.withOpacity(0.6),
                                                  blurRadius: blur,
                                                  spreadRadius: spread,
                                                ),
                                              ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          state.maxLives,
                          (index) => Icon(
                            Icons.favorite,
                            color: index < state.lives
                                ? Colors.red
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Text('Score: ${state.score}'),
                    ),
                    Positioned(
                      bottom: 10,
                      left: widget.powerupButtonsRight ? null : 10,
                      right: widget.powerupButtonsRight ? 10 : null,
                      child: Row(
                        children: [
                          _buildPowerButton(
                            icon: Icons.flash_on,
                            charges: state.slowPowerupCharges,
                            onPressed: (state.slowPowerupCharges > 0 &&
                                    !state.isSlowActive &&
                                    state.slowCooldown <= 0)
                                ? () =>
                                    context.read<GameCubit>().useSlowPowerup()
                                : null,
                            heroTag: 'slowPower',
                            cooldown: state.slowCooldown,
                          ),
                          const SizedBox(width: 10),
                          _buildPowerButton(
                            icon: Icons.ac_unit,
                            charges: state.freezePowerupCharges,
                            onPressed: (state.freezePowerupCharges > 0 &&
                                    !state.isFreezeActive &&
                                    state.freezeCooldown <= 0)
                                ? () =>
                                    context.read<GameCubit>().useFreezePowerup()
                                : null,
                            heroTag: 'freezePower',
                            cooldown: state.freezeCooldown,
                          ),
                          const SizedBox(width: 10),
                          _buildPowerButton(
                            icon: Icons.shield,
                            charges: state.shieldPowerupCharges,
                            onPressed: (state.shieldPowerupCharges > 0 &&
                                    !state.isShieldActive &&
                                    state.shieldCooldown <= 0)
                                ? () =>
                                    context.read<GameCubit>().useShieldPowerup()
                                : null,
                            heroTag: 'shieldPower',
                            cooldown: state.shieldCooldown,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
