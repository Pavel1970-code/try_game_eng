import 'dart:math';
import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Try Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final Random _random = Random();
  int? _result;
  String? _message;
  bool _gameFinished = false;
  bool _hasResult = false;
  int _attempts = 0;
  bool _fakeWinUsed = false;
  bool _hintShown = false;
  bool _hintAfterFakeWinShown = false;
  bool _showInput = true;
  bool _isFakeWinPhase1 = false;
  int? _userInput;

  final List<String> _winMessages = [
    "I win 😂",
    "Still me 🤗",
    "Nice try. I win 🧐",
    "Missed 😘",
    "Almost… but I'm bigger 🤑",
    "You believed. Cute 😂",
    "Not today 🤗",
  ];

  void _processInput() {
    if (_gameFinished) return;

    final input = _controller.text.trim();
    if (input.isEmpty) return;

    final number = int.tryParse(input);
    if (number == null || number < 1) {
      _showError('Enter a number from 1 to 100');
      return;
    }

    int normalizedNumber = number > 100 ? 100 : number;
    _attempts++;

    // Check for hint on 8th attempt
    if (_attempts == 8 && !_hintShown && !_gameFinished) {
      setState(() {
        _message = 'Try 100.\nMaybe that\'s the one.';
        _hasResult = true;
        _showInput = false;
        _hintShown = true;
        _result = null;
        _userInput = null;
      });
      _controller.clear();
      _focusNode.unfocus();
      return;
    }

    // Check for fake win scenario
    if (_attempts == 3 && !_fakeWinUsed && normalizedNumber < 100) {
      _triggerFakeWin(normalizedNumber);
      return;
    }

    setState(() {
      if (normalizedNumber == 100) {
        _result = 101;
        _message = 'I win.\nMy game. My rules.\nNice try 😜';
        _gameFinished = true;
        _hasResult = true;
        _showInput = false;
        _userInput = null;
      } else {
        _result = normalizedNumber + 1;
        _userInput = normalizedNumber;
        _message = _winMessages[_random.nextInt(_winMessages.length)];
        _hasResult = true;
        _showInput = false;
      }
    });

    _controller.clear();
    _focusNode.unfocus();
  }

  void _triggerFakeWin(int normalizedNumber) {
    setState(() {
      _result = normalizedNumber - 1;
      _message = 'Wow. You did it.\nYou actually won…';
      _hasResult = true;
      _showInput = false;
      _isFakeWinPhase1 = true;
      _userInput = null;
    });

    _controller.clear();
    _focusNode.unfocus();

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;

      setState(() {
        _result = normalizedNumber + 1;
        _message = 'But nope 😛';
        _fakeWinUsed = true;
        _isFakeWinPhase1 = false;
        _userInput = null;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted || _gameFinished || _hintAfterFakeWinShown) return;

        setState(() {
          _message = 'Try 100.';
          _hasResult = true;
          _showInput = true;
          _result = null;
          _userInput = null;
          _hintAfterFakeWinShown = true;
        });
      });
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _resetGame() {
    if (_gameFinished) return;

    setState(() {
      _result = null;
      _message = null;
      _hasResult = false;
      _showInput = true;
      _userInput = null;
    });
    _controller.clear();
    _focusNode.requestFocus();
  }

  void _shareUrl() {
    final url = web.window.location.href;
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openUrl(String url) {
    web.window.open(url, '_blank');
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[200]!, Colors.grey[300]!],
          ),
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: SingleChildScrollView(
              child: _gameFinished ? _buildFinalScreen() : _buildGameScreen(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        // Header text
        Text(
          'Guess a number from 1 to 100 💡',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple[800],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),

        // Result block
        if (_hasResult) ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.deepPurple[50]!, Colors.deepPurple[100]!],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                if (_result != null &&
                    _userInput != null &&
                    !_isFakeWinPhase1 &&
                    _result != 101)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      '$_result > $_userInput',
                      key: ValueKey('$_result-$_userInput'),
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else if (_result != null)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      '$_result',
                      key: ValueKey(_result),
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple[800],
                      ),
                    ),
                  ),
                if (_result != null) const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _message ?? '',
                    key: ValueKey(_message),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepOrange[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],

        // Input field (hidden when showing result)
        if (_showInput && !_isFakeWinPhase1) ...[
          SizedBox(
            width: double.infinity,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Enter a number',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.deepPurple[300]!,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.deepPurple[300]!,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.deepPurple[800]!,
                    width: 3,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
              ),
              onSubmitted: (_) => _processInput(),
            ),
          ),
          const SizedBox(height: 24),
          // Submit button (hidden when showing result)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _processInput,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Submit',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],

        // "Давай ещё!" button (shown when result is displayed)
        if (_hasResult &&
            !_showInput &&
            !_isFakeWinPhase1 &&
            !_gameFinished) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _resetGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Try again!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildFinalScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        // Large result
        Text(
          '101',
          style: TextStyle(
            fontSize: 96,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple[800],
          ),
        ),
        const SizedBox(height: 24),

        // Final message
        Text(
          'I win.\nMy game. My rules.\nNice try 😜',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.deepOrange[700],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),

        // Divider
        Divider(color: Colors.grey[400], thickness: 1, height: 32),
        const SizedBox(height: 32),

        // Story block
        Column(
          children: [
            Text(
              'By the way…',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'I made this game in 1986,\n'
              'during a computer science class.\n\n'
              'It was written in BASIC.\n\n'
              'My teacher played it,\n'
              'laughed,\n'
              'gave me top grades\n'
              'and told me not to come back,\n'
              'so I wouldn\'t occupy the computer.',
              style: TextStyle(
                fontSize: 18,
                height: 1.6,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        const SizedBox(height: 40),

        // Share button
        _buildContactButton(
          emoji: '🔗',
          title: 'Share this game',
          subtitle: 'challenge your friends',
          onTap: _shareUrl,
        ),
        const SizedBox(height: 24),

        // Call to action
        Text(
          'If you enjoyed this, you can:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Contact buttons
        _buildContactButton(
          emoji: '☕',
          title: 'Buy me a coffee',
          subtitle: 'no pressure',
          onTap: () => _openUrl('https://buymeacoffee.com/paulgutn'),
        ),
        const SizedBox(height: 16),

        _buildContactButton(
          emoji: '📱',
          title: 'Order an app',
          subtitle: 'with the same attitude 😏',
          onTap: () => _openUrl('https://toprete.com'),
        ),
        const SizedBox(height: 16),

        const SizedBox(height: 16),

        _buildContactButton(
          emoji: '✈️',
          title: 'Message me on Telegram',
          subtitle: '',
          onTap: () => _openUrl('https://t.me/pliim1970'),
        ),
        const SizedBox(height: 16),

        _buildContactButton(
          emoji: '💬',
          title: 'Message me on WhatsApp',
          subtitle: '',
          onTap: () => _openUrl('https://wa.me/995579182894'),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildContactButton({
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.deepPurple[800],
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.deepPurple[300]!, width: 2),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
