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
  Offset _lastDragDelta = Offset.zero; // For scroll direction

  @override
  void initState() {
    super.initState();
    _connectToServer(); // Connect from real device
  }

  @override
  void dispose() {
    _tcpSocket?.close();
    super.dispose();
  }

  void _connectToServer() async {
    String ip = 'YOUR_PC_LOCAL_IP'; // Replace with your PC IP
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
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade50, Colors.white],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current Action', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      Text(_lastAction, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.signal_wifi_4_bar, size: 16, color: Colors.blue.shade700),
                        SizedBox(width: 6),
                        Text(_status, style: TextStyle(fontSize: 12, color: Colors.blue.shade700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Touchpad
            Expanded(
              flex: 4,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.grey.shade50, Colors.grey.shade100]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 4), spreadRadius: 1)],
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      double deltaX = details.delta.dx * sensitivity;
                      double deltaY = details.delta.dy * sensitivity * -1;

                      if ((deltaX.abs() > 0 || deltaY.abs() > 0) && _shouldSendMove()) {
                        int sendDx = (deltaX * _zoomLevel).round();
                        int sendDy = (deltaY * _zoomLevel).round();
                        _sendCommand("MOVE $sendDx $sendDy");
                        if (sendDx != 0 || sendDy != 0) _updateAction("Move: $sendDx, $sendDy");
                        _lastDragDelta = Offset(sendDx.toDouble(), sendDy.toDouble());
                      }
                    },
                    onDoubleTap: () {
                      int scrollX = _lastDragDelta.dx.round();
                      int scrollY = _lastDragDelta.dy.round();

                      if (scrollX != 0 || scrollY != 0) {
                        _sendCommand("SCROLL $scrollY"); // scroll vertically
                        _updateAction("Scroll: $scrollY");
                      }
                    },
                    onTap: () => _sendCommand("LEFT_CLICK"),
                    onLongPress: () => _sendCommand("RIGHT_CLICK"),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.shade50),
                            child: Icon(Icons.touch_app_outlined, size: 40, color: Colors.blue.shade600),
                          ),
                          SizedBox(height: 20),
                          Text('Touchpad Zone', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                          SizedBox(height: 8),
                          Text('Drag = Move • Double Tap = Scroll • Tap = Left Click • Long press = Right Click', style: TextStyle(fontSize: 12, color: Colors.grey.shade500), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Zoom + Quick Actions
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  // Zoom
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Zoom Control', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                      SizedBox(width: 20),
                      _buildZoomButton(Icons.remove, () => _adjustZoom(-0.1)),
                      SizedBox(width: 12),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade300)),
                        child: Text('${_zoomLevel.toStringAsFixed(1)}x', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                      ),
                      SizedBox(width: 12),
                      _buildZoomButton(Icons.add, () => _adjustZoom(0.1)),
                    ],
                  ),
                  SizedBox(height: 12),
                  // Quick Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton("Left Click", "LEFT_CLICK", Colors.blue.shade600),
                      _buildActionButton("Double Click", "DOUBLE_CLICK", Colors.green.shade600),
                      _buildActionButton("Right Click", "RIGHT_CLICK", Colors.orange.shade600),
                      _buildActionButton("Scroll ↓", "SCROLL -120", Colors.purple.shade600, onLong: () => _sendCommand("SCROLL 120")),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(color: Colors.blue.shade600, borderRadius: BorderRadius.circular(8)),
      child: IconButton(icon: Icon(icon, color: Colors.white, size: 20), onPressed: onPressed),
    );
  }

  Widget _buildActionButton(String label, String cmd, Color color, {VoidCallback? onLong}) {
    return InkWell(
      onTap: () => _sendCommand(cmd),
      onLongPress: onLong,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mouse, color: color),
            SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
