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

  @override
  void initState() {
    super.initState();
    _connectToServer();
  }

  @override
  void dispose() {
    _tcpSocket?.close();
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Connection Status Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                  Column(
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

                      SizedBox(width: 10),

                      // Connection Status
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isConnected ? Colors.green.shade100 : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _isConnected ? Colors.green.shade300 : Colors.blue.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(
                                _isConnected ? Icons.wifi : Icons.wifi_off,
                                size: 16,
                                color: _isConnected ? Colors.green.shade700 : Colors.blue.shade700
                            ),
                            SizedBox(width: 6),
                            Text(
                                _isConnected ? 'Connected' : 'Disconnected',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: _isConnected ? Colors.green.shade700 : Colors.blue.shade700
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

            SizedBox(height: 16),

            // Touchpad Area
            Expanded(
              flex: 5,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: _isSelectionMode
                        ? [Colors.orange.shade50, Colors.orange.shade100]
                        : [Colors.grey.shade50, Colors.grey.shade100],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 15,
                      offset: Offset(0, 6),
                      spreadRadius: 1,
                    ),
                  ],
                  border: Border.all(
                      color: _isSelectionMode ? Colors.orange.shade300 : Colors.grey.shade300,
                      width: 1.5
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: GestureDetector(
                    onPanStart: (details) {
                      if (_isSelectionMode) {
                        _startSelection();
                      }
                    },
                    onPanUpdate: (details) {
                      double deltaX = details.delta.dx * sensitivity;
                      double deltaY = details.delta.dy * sensitivity * -1;

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
                        _sendCommand("DOUBLE_CLICK"); // Double click to select word
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
                            padding: EdgeInsets.all(20),
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
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isSelectionMode ? Icons.text_fields : Icons.touch_app_outlined,
                              size: 48,
                              color: _isSelectionMode ? Colors.orange.shade700 : Colors.blue.shade700,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            _isSelectionMode ? 'Selection Mode' : 'Touchpad Zone',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: _isSelectionMode ? Colors.orange.shade800 : Colors.grey.shade800,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            _isSelectionMode
                                ? 'Drag = Select Text • Tap = Select Word\nRelease = Complete Selection'
                                : 'Drag = Move • Tap = Left Click\nDouble Tap = Enter • Long Press = Right Click',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: _isSelectionMode ? Colors.orange.shade600 : Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                          if (_isSelectionMode) ...[
                            SizedBox(height: 10),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.orange.shade300),
                              ),
                              child: Text(
                                'SELECTION ACTIVE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Control Panels
            Expanded(
              flex: 3,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Zoom Control
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'SENSITIVITY CONTROL',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: 12),
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
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.blue.shade300),
                                ),
                                child: Text(
                                  '${_zoomLevel.toStringAsFixed(1)}x',
                                  style: TextStyle(
                                    fontSize: 18,
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
                      child: GridView.count(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.2,
                        children: [
                          _buildActionCard("Left Click", Icons.mouse, Colors.blue, () => _sendCommand("LEFT_CLICK")),
                          _buildActionCard("Enter", Icons.keyboard_return, Colors.green, () => _sendCommand("ENTER")),
                          _buildActionCard("Right Click", Icons.mouse, Colors.orange, () => _sendCommand("RIGHT_CLICK")),
                          _buildActionCard("Select Word", Icons.text_fields, Colors.purple, () {
                            _sendCommand("DOUBLE_CLICK");
                            _updateAction("Word Selected");
                          }),
                          _buildActionCard("Scroll Up", Icons.arrow_upward, Colors.teal, () => _sendCommand("SCROLL 120")),
                          _buildActionCard("Scroll Down", Icons.arrow_downward, Colors.indigo, () => _sendCommand("SCROLL -120")),
                          _buildActionCard("Copy", Icons.content_copy, Colors.cyan, () => _sendCommand("COPY")),
                          _buildActionCard("Paste", Icons.content_paste, Colors.brown, () => _sendCommand("PASTE")),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, Colors.black, 0.1)!],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 24),
        onPressed: onPressed,
        padding: EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildActionCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: color),
              SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}