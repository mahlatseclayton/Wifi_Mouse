import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MouseApp());
}

class MouseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mouse & Keyboard Control App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        cardTheme: const CardThemeData(
          color: Color(0xFF1D1F33),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Color(0xFF1E88E5),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.5),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(Icons.mouse, size: 60, color: Colors.white),
              ),
              SizedBox(height: 30),

              Text(
                "Smart Mouse & Keyboard Control",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),

              Text(
                "Control your computer's mouse and keyboard from your phone",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),

              Container(
                height: 280,
                child: InstructionCarousel(),
              ),
              SizedBox(height: 30),

              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MouseControlScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1E88E5),
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Get Started",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HelpScreen()),
                      );
                    },
                    child: Text(
                      "Need Help?",
                      style: TextStyle(color: Color(0xFF1E88E5), fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InstructionCarousel extends StatefulWidget {
  @override
  _InstructionCarouselState createState() => _InstructionCarouselState();
}

class _InstructionCarouselState extends State<InstructionCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _instructions = [
    {
      "title": "Step 1: Find Your IP",
      "description": "On Windows: Open Command Prompt and type 'ipconfig'\nLook for 'IPv4 Address' under your network adapter"
    },
    {
      "title": "Step 2: Run Server",
      "description": "Make sure the Python server is running on your computer\nIt should show 'Listening on port 5000'"
    },
    {
      "title": "Step 3: Connect",
      "description": "Enter your computer's IP address and port 5000\nTap 'Connect' to establish connection"
    },
    {
      "title": "Step 4: Control",
      "description": "Use arrow buttons to move mouse\nTap for small moves, hold for fast movement"
    },
    {
      "title": "Step 5: Keyboard",
      "description": "Use the keyboard button to type text\nEnter access code when prompted for security"
    },
  ];

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        if (_currentPage < _instructions.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 250,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _instructions.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return InstructionCard(
                title: _instructions[index]["title"]!,
                description: _instructions[index]["description"]!,
              );
            },
          ),
        ),
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_instructions.length, (index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Color(0xFF1E88E5) : Colors.white30,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class InstructionCard extends StatelessWidget {
  final String title;
  final String description;

  const InstructionCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Color(0xFF1D1F33),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 40, color: Color(0xFF1E88E5)),
              SizedBox(height: 15),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              SingleChildScrollView(
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: Text("Help & Instructions"),
        backgroundColor: Color(0xFF1D1F33),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpSection(
              "Finding Your IP Address",
              [
                "Windows:",
                "1. Press Windows Key + R",
                "2. Type 'cmd' and press Enter",
                "3. Type 'ipconfig' and press Enter",
                "4. Look for 'IPv4 Address' under your network adapter",
                "",
                "Mac/Linux:",
                "1. Open Terminal",
                "2. Type 'ifconfig' and press Enter",
                "3. Look for 'inet' address under your network adapter",
              ],
              Icons.computer,
            ),
            SizedBox(height: 20),
            _buildHelpSection(
              "Setting Up the Server",
              [
                "1. Make sure Python is installed on your computer",
                "2. Install required packages: pip install pyautogui",
                "3. Run the server script: python server.py",
                "4. You should see 'Listening on port 5000'",
                "5. Note the secret key displayed in the console",
              ],
              Icons.settings,
            ),
            SizedBox(height: 20),
            _buildHelpSection(
              "Keyboard Features",
              [
                "• Tap the keyboard icon to open text input",
                "• Type any text and send it to your computer",
                "• Use special keys like Enter, Backspace, etc.",
                "• Access code required for security",
              ],
              Icons.keyboard,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection(String title, List<String> lines, IconData icon) {
    return Card(
      color: Color(0xFF1D1F33),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Color(0xFF1E88E5)),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            ...lines.map((line) => Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Text(line, style: TextStyle(color: Colors.white70)),
            )),
          ],
        ),
      ),
    );
  }
}

class MouseControlScreen extends StatefulWidget {
  @override
  _MouseControlScreenState createState() => _MouseControlScreenState();
}

class _MouseControlScreenState extends State<MouseControlScreen> {
  Socket? _tcpSocket;
  String _status = "Not connected";
  bool _isConnected = false;
  bool _showConnectionDialog = true;
  bool _showKeyboardDialog = false;
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController(text: "5000");
  final TextEditingController _accessCodeController = TextEditingController();
  final TextEditingController _keyboardController = TextEditingController();

  Timer? _holdTimer;
  final int _slowStep = 5;
  final int _fastStep = 25;

  @override
  void dispose() {
    _tcpSocket?.close();
    _holdTimer?.cancel();
    _ipController.dispose();
    _portController.dispose();
    _accessCodeController.dispose();
    _keyboardController.dispose();
    super.dispose();
  }

  void _connectToServer() async {
    String ip = _ipController.text.trim();
    String portText = _portController.text.trim();
    String accessCode = _accessCodeController.text.trim();

    if (ip.isEmpty) {
      setState(() {
        _status = "Please enter IP address";
      });
      return;
    }

    if (portText.isEmpty) {
      setState(() {
        _status = "Please enter port number";
      });
      return;
    }

    if (accessCode.isEmpty) {
      setState(() {
        _status = "Please enter access code";
      });
      return;
    }

    int port;
    try {
      port = int.parse(portText);
    } catch (e) {
      setState(() {
        _status = "Invalid port number";
      });
      return;
    }

    setState(() {
      _status = "Connecting...";
      _showConnectionDialog = false;
    });

    try {
      _tcpSocket = await Socket.connect(ip, port, timeout: Duration(seconds: 5));
      _tcpSocket!.setOption(SocketOption.tcpNoDelay, true);

      // Send access code for authentication
      _tcpSocket!.write(accessCode + "\n");

      // Wait for authentication response
      await _tcpSocket!.transform(StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          String response = String.fromCharCodes(data).trim();
          if (response == "AUTH_OK") {
            setState(() {
              _status = "Connected to $ip:$port";
              _isConnected = true;
            });
          } else {
            setState(() {
              _status = "Authentication failed";
              _isConnected = false;
              _showConnectionDialog = true;
            });
            _tcpSocket?.close();
          }
        },
      )).first;

      _tcpSocket!.listen((data) {}, onDone: () {
        setState(() {
          _status = "Connection closed";
          _isConnected = false;
          _showConnectionDialog = true;
        });
      }, onError: (err) {
        setState(() {
          _status = "Socket error: $err";
          _isConnected = false;
          _showConnectionDialog = true;
        });
      });
    } catch (e) {
      setState(() {
        _status = "Connection failed: $e";
        _isConnected = false;
        _showConnectionDialog = true;
      });
      _tcpSocket = null;
    }
  }

  void _disconnect() {
    _tcpSocket?.close();
    setState(() {
      _isConnected = false;
      _status = "Disconnected";
      _showConnectionDialog = true;
    });
  }

  void _showConnectionSetup() {
    setState(() {
      _showConnectionDialog = true;
    });
  }

  void _showKeyboard() {
    setState(() {
      _showKeyboardDialog = true;
      _keyboardController.clear();
    });
  }

  void _sendCommand(String cmd) {
    if (_tcpSocket != null && _isConnected) {
      try {
        _tcpSocket!.write(cmd + "\n");
      } catch (_) {}
    }
  }

  void _sendText() {
    String text = _keyboardController.text.trim();
    if (text.isNotEmpty) {
      _sendCommand("KEYBOARD $text");
      setState(() {
        _showKeyboardDialog = false;
        _keyboardController.clear();
      });
    }
  }

  void _sendSpecialKey(String key) {
    _sendCommand("PRESS $key");
  }

  void _moveArrow(int dx, int dy) {
    _sendCommand("MOVE $dx $dy");
  }

  void _startHold(int dx, int dy) {
    _holdTimer?.cancel();
    _holdTimer = Timer.periodic(Duration(milliseconds: 50), (_) {
      _sendCommand("MOVE $dx $dy");
    });
  }

  void _stopHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  void _showHelp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HelpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Smart Mouse & Keyboard Control"),
        backgroundColor: _isConnected ? Color(0xFF1E88E5) : Color(0xFFD32F2F),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: _showHelp,
          ),
          if (_isConnected)
            IconButton(
              icon: Icon(Icons.keyboard),
              onPressed: _showKeyboard,
            ),
          IconButton(
            icon: Icon(_isConnected ? Icons.settings : Icons.wifi),
            onPressed: _showConnectionSetup,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Status bar
                Container(
                  padding: EdgeInsets.all(16),
                  color: _isConnected ? Color(0xFF1B5E20) : Color(0xFFB71C1C),
                  child: Row(
                    children: [
                      Icon(_isConnected ? Icons.wifi : Icons.wifi_off, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _status,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (_isConnected)
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: _disconnect,
                        ),
                    ],
                  ),
                ),

                if (!_isConnected) ...[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off, size: 80, color: Colors.white54),
                        SizedBox(height: 20),
                        Text("Not Connected", style: TextStyle(fontSize: 24, color: Colors.white70)),
                        SizedBox(height: 10),
                        Text("Tap the wifi icon to connect", style: TextStyle(color: Colors.white54)),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _showHelp,
                          icon: Icon(Icons.help),
                          label: Text("Connection Help"),
                        ),
                      ],
                    ),
                  ),
                ],

                if (_isConnected) ...[
                  SizedBox(height: 30),

                  // Arrow controls with bigger buttons
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildArrowButton(Icons.keyboard_arrow_up, 0, -_slowStep),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildArrowButton(Icons.keyboard_arrow_left, -_slowStep, 0),
                            SizedBox(width: 80),
                            _buildArrowButton(Icons.keyboard_arrow_right, _slowStep, 0),
                          ],
                        ),
                        SizedBox(height: 20),
                        _buildArrowButton(Icons.keyboard_arrow_down, 0, _slowStep),
                      ],
                    ),
                  ),

                  // Quick actions
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text("Quick Actions", style: TextStyle(fontSize: 16, color: Colors.white70)),
                        ),
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 3,
                            childAspectRatio: 1.5,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            children: [
                              _buildActionCard("Left Click", Icons.mouse, Color(0xFF2196F3), () => _sendCommand("LEFT_CLICK")),
                              _buildActionCard("Right Click", Icons.mouse_outlined, Color(0xFFFF9800), () => _sendCommand("RIGHT_CLICK")),
                              _buildActionCard("Keyboard", Icons.keyboard, Color(0xFF9C27B0), _showKeyboard),
                              _buildActionCard("Scroll Up", Icons.arrow_upward, Color(0xFF4CAF50), () => _sendCommand("SCROLL 120")),
                              _buildActionCard("Scroll Down", Icons.arrow_downward, Color(0xFFF44336), () => _sendCommand("SCROLL -120")),
                              _buildActionCard("Enter", Icons.keyboard_return, Color(0xFFFF9800), () => _sendSpecialKey("enter")),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            // Connection Dialog
            if (_showConnectionDialog && !_isConnected)
              Container(
                color: Colors.black54,
                child: Center(
                  child: ConnectionDialog(
                    ipController: _ipController,
                    portController: _portController,
                    accessCodeController: _accessCodeController,
                    onConnect: _connectToServer,
                    onCancel: () => setState(() { _showConnectionDialog = false; }),
                  ),
                ),
              ),

            // Keyboard Dialog
            if (_showKeyboardDialog && _isConnected)
              Container(
                color: Colors.black54,
                child: Center(
                  child: KeyboardDialog(
                    keyboardController: _keyboardController,
                    onSend: _sendText,
                    onSpecialKey: _sendSpecialKey,
                    onCancel: () => setState(() { _showKeyboardDialog = false; }),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrowButton(IconData icon, int dx, int dy) {
    return GestureDetector(
      onTap: () => _moveArrow(dx, dy),
      onTapDown: (_) => _startHold(dx > 0 ? _fastStep : dx < 0 ? -_fastStep : 0, dy > 0 ? _fastStep : dy < 0 ? -_fastStep : 0),
      onTapUp: (_) => _stopHold(),
      onTapCancel: () => _stopHold(),
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF1D1F33),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF2196F3).withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 45, color: Color(0xFF2196F3)),
      ),
    );
  }

  Widget _buildActionCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: color),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConnectionDialog extends StatelessWidget {
  final TextEditingController ipController;
  final TextEditingController portController;
  final TextEditingController accessCodeController;
  final VoidCallback onConnect;
  final VoidCallback onCancel;

  const ConnectionDialog({
    required this.ipController,
    required this.portController,
    required this.accessCodeController,
    required this.onConnect,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Color(0xFF1D1F33),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi, size: 50, color: Color(0xFF1E88E5)),
            SizedBox(height: 16),
            Text("Connect to Server", style: TextStyle(fontSize: 20, color: Colors.white)),
            SizedBox(height: 24),
            TextField(
              controller: ipController,
              decoration: InputDecoration(
                labelText: "IP Address",
                hintText: "192.168.1.100",
                filled: true,
                fillColor: Color(0xFF0A0E21),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            TextField(
              controller: portController,
              decoration: InputDecoration(
                labelText: "Port",
                hintText: "5000",
                filled: true,
                fillColor: Color(0xFF0A0E21),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            TextField(
              controller: accessCodeController,
              decoration: InputDecoration(
                labelText: "Access Code",
                hintText: "Enter server access code",
                filled: true,
                fillColor: Color(0xFF0A0E21),
              ),
              style: TextStyle(color: Colors.white),
              obscureText: true,
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    child: Text("Cancel", style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConnect,
                    child: Text("Connect"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class KeyboardDialog extends StatelessWidget {
  final TextEditingController keyboardController;
  final VoidCallback onSend;
  final Function(String) onSpecialKey;
  final VoidCallback onCancel;

  const KeyboardDialog({
    required this.keyboardController,
    required this.onSend,
    required this.onSpecialKey,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Color(0xFF1D1F33),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Virtual Keyboard", style: TextStyle(fontSize: 20, color: Colors.white)),
            SizedBox(height: 16),
            TextField(
              controller: keyboardController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Type text to send",
                filled: true,
                fillColor: Color(0xFF0A0E21),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSpecialKeyButton("Enter", Icons.keyboard_return),
                _buildSpecialKeyButton("Backspace", Icons.backspace),
                _buildSpecialKeyButton("Space", Icons.space_bar),
                _buildSpecialKeyButton("Tab", Icons.tab),
                _buildSpecialKeyButton("Escape", Icons.scale),
              ],
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    child: Text("Cancel", style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onSend,
                    child: Text("Send Text"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialKeyButton(String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () => onSpecialKey(label.toLowerCase()),
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}