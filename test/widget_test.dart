import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(MouseApp());
}

class MouseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mouse Control App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: MouseControlScreen(),
    );
  }
}

class MouseControlScreen extends StatefulWidget {
  @override
  _MouseControlScreenState createState() => _MouseControlScreenState();
}

class _MouseControlScreenState extends State<MouseControlScreen> {
  double _zoomLevel = 1.0;
  String _lastAction = 'Ready';
  Socket? _tcpSocket;
  String _status = "Not connected";
  DateTime _lastMoveSent = DateTime.fromMillisecondsSinceEpoch(0);
  double sensitivity = 1.0;
  bool _isConnected = false;
  Offset _lastDragDelta = Offset.zero;
  bool _isSelectionMode = false;
  bool _isDraggingSelection = false;

  // Arrow button states
  bool _isLeftPressed = false;
  bool _isRightPressed = false;
  bool _isUpPressed = false;
  bool _isDownPressed = false;
  Timer? _arrowTimer;
  int _arrowSpeed = 5;

  @override
  void initState() {
    super.initState();
    _connectToServer();
  }

  @override
  void dispose() {
    _tcpSocket?.close();
    _arrowTimer?.cancel();
    super.dispose();
  }

  void _connectToServer() async {
    String ip = '172.16.28.88';
    int port = 5000;

    try {
      _tcpSocket = await Socket.connect(ip, port, timeout: Duration(seconds: 3));
      _tcpSocket!.setOption(SocketOption.tcpNoDelay, true);
      setState(() {
        _status = "Connected to $ip:$port";
        _isConnected = true;
      });

      _tcpSocket!.listen((data) {
        // handle server responses if needed
      }, onDone: () {
        setState(() {
          _status = "Connection closed";
          _isConnected = false;
        });
      }, onError: (err) {
        setState(() {
          _status = "Socket error: $err";
          _isConnected = false;
        });
      });
    } catch (e) {
      setState(() {
        _status = "Connection failed: $e";
        _isConnected = false;
      });
      _tcpSocket = null;
    }
  }

  void _sendCommand(String cmd) {
    if (_tcpSocket != null && _isConnected) {
      try {
        _tcpSocket!.write(cmd + "\n");
        _updateAction("Sent: $cmd");
      } catch (e) {
        _updateAction("Send failed");
      }
    } else {
      _updateAction("Not connected");
    }
  }

  void _updateAction(String message) {
    setState(() {
      _lastAction = message;
    });
  }

  void _adjustZoom(double change) {
    setState(() {
      _zoomLevel = (_zoomLevel + change).clamp(0.5, 3.0);
      _lastAction = 'Zoom: ${_zoomLevel.toStringAsFixed(1)}x';
      sensitivity = 1.0 / _zoomLevel;
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _lastAction = _isSelectionMode ? 'Selection Mode: ON' : 'Selection Mode: OFF';
    });
  }

  void _startSelection() {
    if (_isSelectionMode) {
      setState(() {
        _isDraggingSelection = true;
      });
      _sendCommand("LEFT_CLICK_DOWN");
      _updateAction("Selecting...");
    }
  }

  void _endSelection() {
    if (_isSelectionMode && _isDraggingSelection) {
      setState(() {
        _isDraggingSelection = false;
      });
      _sendCommand("LEFT_CLICK_UP");
      _updateAction("Selection Complete");
    }
  }

  void _startArrowMovement(String direction) {
    _arrowTimer?.cancel();

    // Single tap movement (normal speed)
    _moveInDirection(direction, 1);

    // Start timer for hold movement (fast speed)
    _arrowTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      _moveInDirection(direction, _arrowSpeed);
    });
  }

  void _stopArrowMovement() {
    _arrowTimer?.cancel();
    _arrowTimer = null;
    setState(() {
      _isLeftPressed = false;
      _isRightPressed = false;
      _isUpPressed = false;
      _isDownPressed = false;
    });
  }

  void _moveInDirection(String direction, int speedMultiplier) {
    int dx = 0;
    int dy = 0;

    switch (direction) {
      case 'left':
        dx = -5 * speedMultiplier;
        setState(() => _isLeftPressed = true);
        break;
      case 'right':
        dx = 5 * speedMultiplier;
        setState(() => _isRightPressed = true);
        break;
      case 'up':
        dy = -5 * speedMultiplier;
        setState(() => _isUpPressed = true);
        break;
      case 'down':
        dy = 5 * speedMultiplier;
        setState(() => _isDownPressed = true);
        break;
    }

    _sendCommand("MOVE $dx $dy");
    _updateAction("Arrow: $dx, $dy");
  }

  bool _shouldSendMove() {
    final now = DateTime.now();
    if (now.difference(_lastMoveSent).inMilliseconds >= 20) {
      _lastMoveSent = now;
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Touchpad'),
        backgroundColor: _isConnected ?
        (_isSelectionMode ? Colors.orange.shade700 : Colors.green.shade700) :
        Colors.blue.shade700,
        elevation: 2,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Connection Status Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isSelectionMode
                      ? [Colors.orange.shade50, Colors.white]
                      : _isConnected
                      ? [Colors.green.shade50, Colors.white]
                      : [Colors.blue.shade50, Colors.white],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current Action',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        Text(_lastAction,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _isSelectionMode
                                    ? Colors.orange.shade800
                                    : _isConnected ? Colors.green.shade800 : Colors.blue.shade800
                            )),
                      ],
                    ),
                  ),

                  // Selection Mode Toggle
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isSelectionMode ? Colors.orange.shade100 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: _isSelectionMode ? Colors.orange.shade300 : Colors.grey.shade300
                          ),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _toggleSelectionMode,
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                width: 40,
                                height: 24,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: _isSelectionMode ? Colors.orange.shade400 : Colors.grey.shade400,
                                ),
                                child: AnimatedAlign(
                                  duration: Duration(milliseconds: 200),
                                  alignment: _isSelectionMode ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    margin: EdgeInsets.all(2),
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                                'Select',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _isSelectionMode ? Colors.orange.shade700 : Colors.grey.shade700
                                )
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 8),

            // Connection Status
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _isConnected ? Colors.green.shade50 : Colors.blue.shade50,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                      _isConnected ? Icons.wifi : Icons.wifi_off,
                      size: 16,
                      color: _isConnected ? Colors.green.shade700 : Colors.blue.shade700
                  ),
                  SizedBox(width: 6),
                  Text(
                      _isConnected ? 'Connected to Server' : 'Disconnected',
                      style: TextStyle(
                          fontSize: 12,
                          color: _isConnected ? Colors.green.shade700 : Colors.blue.shade700
                      )
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Touchpad Area with Visible Arrow Buttons
            Expanded(
              flex: 4,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  children: [
                    // Main Touchpad Area
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      margin: EdgeInsets.all(20), // Space for arrows
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: _isSelectionMode
                              ? [Colors.orange.shade50, Colors.orange.shade100]
                              : [Colors.grey.shade50, Colors.grey.shade100],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                            color: _isSelectionMode ? Colors.orange.shade300 : Colors.grey.shade300,
                            width: 1.5
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: GestureDetector(
                          onPanStart: (details) {
                            if (_isSelectionMode) {
                              _startSelection();
                            }
                          },
                          onPanUpdate: (details) {
                            double deltaX = details.delta.dx * sensitivity;
                            double deltaY = details.delta.dy * sensitivity;

                            if ((deltaX.abs() > 0 || deltaY.abs() > 0) && _shouldSendMove()) {
                              int sendDx = (deltaX * _zoomLevel).round();
                              int sendDy = (deltaY * _zoomLevel).round();

                              if (_isSelectionMode && _isDraggingSelection) {
                                _sendCommand("MOVE $sendDx $sendDy");
                                _updateAction("Selecting: $sendDx, $sendDy");
                              } else {
                                _sendCommand("MOVE $sendDx $sendDy");
                                _updateAction("Move: $sendDx, $sendDy");
                              }

                              _lastDragDelta = Offset(sendDx.toDouble(), sendDy.toDouble());
                            }
                          },
                          onPanEnd: (details) {
                            if (_isSelectionMode) {
                              _endSelection();
                            }
                          },
                          onDoubleTap: () => _sendCommand("ENTER"),
                          onTap: () {
                            if (_isSelectionMode) {
                              _sendCommand("DOUBLE_CLICK");
                              _updateAction("Word Selected");
                            } else {
                              _sendCommand("LEFT_CLICK");
                            }
                          },
                          onLongPress: () => _sendCommand("RIGHT_CLICK"),
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: _isSelectionMode
                                          ? [Colors.orange.shade200, Colors.orange.shade300]
                                          : [Colors.blue.shade100, Colors.blue.shade200],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _isSelectionMode ? Icons.text_fields : Icons.touch_app_outlined,
                                    size: 40,
                                    color: _isSelectionMode ? Colors.orange.shade700 : Colors.blue.shade700,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  _isSelectionMode ? 'Selection Mode' : 'Touchpad',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: _isSelectionMode ? Colors.orange.shade800 : Colors.grey.shade800,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _isSelectionMode
                                      ? 'Drag to select text\nTap to select word'
                                      : 'Drag to move • Tap to click\nDouble tap = Enter',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _isSelectionMode ? Colors.orange.shade600 : Colors.grey.shade600,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Arrow Buttons - Positioned around the touchpad
                    // Left Arrow
                    Positioned(
                      left: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _buildArrowButton(
                          'Left',
                          Icons.arrow_back_ios,
                          _isLeftPressed,
                        ),
                      ),
                    ),

                    // Right Arrow
                    Positioned(
                      right: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _buildArrowButton(
                          'Right',
                          Icons.arrow_forward_ios,
                          _isRightPressed,
                        ),
                      ),
                    ),

                    // Up Arrow
                    Positioned(
                      top: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: _buildArrowButton(
                          'Up',
                          Icons.arrow_drop_up,
                          _isUpPressed,
                        ),
                      ),
                    ),

                    // Down Arrow
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: _buildArrowButton(
                          'Down',
                          Icons.arrow_drop_down,
                          _isDownPressed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Zoom Control
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'SENSITIVITY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton(
                        Icons.remove,
                            () => _adjustZoom(-0.1),
                        Colors.red.shade400,
                      ),
                      SizedBox(width: 16),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade300),
                        ),
                        child: Text(
                          '${_zoomLevel.toStringAsFixed(1)}x',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      _buildControlButton(
                        Icons.add,
                            () => _adjustZoom(0.1),
                        Colors.green.shade400,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Quick Actions Grid
            Expanded(
              flex: 2,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.3,
                  children: [
                    _buildActionCard("Left", Icons.mouse, Colors.blue, () => _sendCommand("LEFT_CLICK")),
                    _buildActionCard("Enter", Icons.keyboard_return, Colors.green, () => _sendCommand("ENTER")),
                    _buildActionCard("Right", Icons.mouse, Colors.orange, () => _sendCommand("RIGHT_CLICK")),
                    _buildActionCard("Word", Icons.text_fields, Colors.purple, () {
                      _sendCommand("DOUBLE_CLICK");
                      _updateAction("Word Selected");
                    }),
                    _buildActionCard("Scroll ↑", Icons.arrow_upward, Colors.teal, () => _sendCommand("SCROLL 120")),
                    _buildActionCard("Scroll ↓", Icons.arrow_downward, Colors.teal, () => _sendCommand("SCROLL -120")),
                    _buildActionCard("PgUp", Icons.keyboard_arrow_up, Colors.indigo, () => _sendCommand("PAGE_UP")),
                    _buildActionCard("PgDn", Icons.keyboard_arrow_down, Colors.indigo, () => _sendCommand("PAGE_DOWN")),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Arrow Button Builder (big + labeled)
  Widget _buildArrowButton(String direction, IconData icon, bool isPressed) {
    return GestureDetector(
      onTapDown: (details) => _startArrowMovement(direction.toLowerCase()),
      onTapUp: (details) => _stopArrowMovement(),
      onTapCancel: () => _stopArrowMovement(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isPressed ? Colors.blue.shade400 : Colors.blue.shade600,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            direction.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed, Color color) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildActionCard(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
