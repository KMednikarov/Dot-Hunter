import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A simple step-by-step tutorial shown on first launch.
class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _controller = PageController();
  int _index = 0;

  int _score = 0;
  int _lives = 3;
  bool _poweredUp = false;

  final List<Map<String, dynamic>> _steps = const [
    {
      'text': 'Tap the red dots to score points.',
      'icon': Icons.circle,
      'color': Colors.red,
    },
    {
      'text': 'Avoid the blue dots or lose a life.',
      'icon': Icons.circle,
      'color': Colors.blue,
    },
    {
      'text': 'Use power-ups to gain an advantage!',
      'icon': Icons.flash_on,
      'color': Colors.orange,
    },
  ];

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenTutorial', true);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: _complete,
            child: const Text('Skip'),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _index = i),
              children: [
                _buildScoreStep(),
                _buildAvoidStep(),
                _buildPowerStep(),
              ],
//             child: PageView.builder(
//               controller: _controller,
//               itemCount: _steps.length,
//               onPageChanged: (i) {
//                 setState(() => _index = i);
//               },
//               itemBuilder: (context, i) {
//                 final step = _steps[i];
//                 return Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Icon(
//                           step['icon'] as IconData,
//                           size: 120,
//                           color: step['color'] as Color,
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Text(
//                         step['text']!,
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(fontSize: 18),
//                       ),
//                     ),
//                   ],
//                 );
//               },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _index == 2
//                 onPressed: _index == _steps.length - 1
                    ? _complete
                    : () => _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                child: Text(_index == 2 ? 'Done' : 'Next'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => setState(() => _score++),
          child: const Icon(
            Icons.circle,
            size: 120,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 16),
        const Text('Tap the red dots to score points.'),
        Text('Score: $_score'),
      ],
    );
  }

  Widget _buildAvoidStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => setState(() {
            if (_lives > 0) {
              _lives--;
            }
          }),
          child: const Icon(
            Icons.circle,
            size: 120,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 16),
        const Text('Avoid the blue dots or lose a life.'),
        Text('Lives: $_lives'),
      ],
    );
  }

  Widget _buildPowerStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => setState(() => _poweredUp = !_poweredUp),
          child: Icon(
            Icons.flash_on,
            size: 120,
            color: _poweredUp ? Colors.orange : Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        const Text('Use power-ups to gain an advantage!'),
        if (_poweredUp)
          const Text(
            'Power-up activated!',
            style: TextStyle(color: Colors.orange),
          ),
      ],
    );
  }
}


