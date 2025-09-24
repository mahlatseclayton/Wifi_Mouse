import 'package:flutter/material.dart';

void main() {
  runApp(const WiFiMouseApp());
}

class WiFiMouseApp extends StatelessWidget {
  const WiFiMouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wi-Fi Mouse',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const WiFiMouseScreen(),
    );
  }
}

class WiFiMouseScreen extends StatefulWidget {
  const WiFiMouseScreen({super.key});

  @override
  State<WiFiMouseScreen> createState() => _WiFiMouseScreenState();
}

class _WiFiMouseScreenState extends State<WiFiMouseScreen> {
  double _cursorX = 0.0;
  double _cursorY = 0.0;
  double _scrollDelta = 0.0;
  double _scaleFactor = 1.0;
  bool _isScrolling = false;

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _handleCursorMove(ScaleUpdateDetails details) {
    setState(() {
      _cursorX += details.horizontalScale; // Use horizontalScale for dx
      _cursorY += details.verticalScale;   // Use verticalScale for dy
    });
    _showToast('Move dx=${details.horizontalScale.toStringAsFixed(1)}, dy=${details.verticalScale.toStringAsFixed(1)}');
  }

  void _handleScrollZoom(ScaleUpdateDetails details) {
    if (details.scale != 1.0) {
      // This is a zoom/pinch gesture
      setState(() {
        _scaleFactor = details.scale;
      });

      if (details.scale > 1.0) {
        _showToast('Zoom In (${details.scale.toStringAsFixed(2)}x)');
      } else if (details.scale < 1.0) {
        _showToast('Zoom Out (${details.scale.toStringAsFixed(2)}x)');
      }
    } else {
      // This is a pan/scroll gesture (scale == 1.0 means no scaling)
      setState(() {
        _scrollDelta += details.verticalScale;
      });
      final String direction = details.verticalScale > 0 ? 'Down' : 'Up';
      _showToast('Scroll $direction (${details.verticalScale.abs().toStringAsFixed(1)})');
    }
  }

  void _handleLeftClick() {
    _showToast('Left Click');
  }

  void _handleOkClick() {
    _showToast('OK (Enter)');
  }

  void _handleRightClick() {
    _showToast('Right Click');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wi-Fi Mouse'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Cursor Area (Top, Big Zone)
          Expanded(
            flex: 7, // Takes most of the space
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: GestureDetector(
                onScaleUpdate: _handleCursorMove,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mouse,
                        size: 48,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cursor Area\nDrag to move mouse',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Position: X=${_cursorX.toStringAsFixed(1)}, Y=${_cursorY.toStringAsFixed(1)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Scroll/Zoom Area (Middle, Thin Strip)
          Container(
            height: 60, // Thin strip for scroll/zoom
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: GestureDetector(
              onScaleUpdate: _handleScrollZoom,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swipe_vertical,
                    color: Colors.blue.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Scroll & Zoom Area',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Swipe to scroll • Pinch to zoom',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Scroll: ${_scrollDelta.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Zoom: ${_scaleFactor.toStringAsFixed(2)}x',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          // Buttons Row (Bottom)
          Container(
            height: 80,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Left Click Button
                ElevatedButton(
                  onPressed: _handleLeftClick,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.mouse, size: 20),
                      SizedBox(height: 4),
                      Text('Left Click'),
                    ],
                  ),
                ),

                // OK (Enter) Button
                ElevatedButton(
                  onPressed: _handleOkClick,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 20),
                      SizedBox(height: 4),
                      Text('OK (Enter)'),
                    ],
                  ),
                ),

                // Right Click Button
                ElevatedButton(
                  onPressed: _handleRightClick,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.mouse, size: 20),
                      SizedBox(height: 4),
                      Text('Right Click'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}