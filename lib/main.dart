import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:logging/logging.dart';

// The main function, the entry point of the Flutter application.
void main() {
  runApp(const RobotApp()); // Runs the RobotApp widget.
}

//  A StatelessWidget, meaning its state cannot change over its lifetime.
class RobotApp extends StatelessWidget {
  const RobotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Robot Remote', // Sets the title of the application.
      theme: ThemeData(
        primarySwatch: Colors.blue, // Sets the primary color scheme for the app.
        visualDensity: VisualDensity.adaptivePlatformDensity, //  Improves layout adaptation to different screen densities.
        fontFamily: 'Inter', // Sets the default font family.
      ),
      initialRoute: '/', // Sets the initial route when the app starts.  In this case, it's '/'.
      routes: {
        '/': (context) => const RemoteControlPage(), // Defines the route '/' and associates it with the RemoteControlPage widget.
        '/webview': (context) => const WebViewPage(), // Defines the route '/webview' and associates it with the WebViewPage widget.
      },
      debugShowCheckedModeBanner: false, // Hides the debug banner.
    );
  }
}

// A StatelessWidget for the main control page of the robot remote.
class RemoteControlPage extends StatelessWidget {
  const RemoteControlPage({super.key});

  // Method to build a control button.
  Widget buildControlButton(String label) {
    return Expanded( //  Expands the button to fill available space.
      child: Container(
        margin: const EdgeInsets.all(16), // Adds margin around the button.
        height: 90, // Sets the height of the button.
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white, // Sets the background color of the button.
            side: const BorderSide(color: Colors.black, width: 3), // Sets the border style.
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // Rounds the corners of the button.
            ),
          ),
          onPressed: () {}, //  A placeholder for the button's action.  Currently, it does nothing.
          child: Text(
            label, // Displays the text on the button.
            style: const TextStyle(
              fontSize: 36, // Sets the font size.
              color: Colors.black, // Sets the text color.
              fontWeight: FontWeight.normal, // Sets the font weight.
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Sets the background color of the page.
      appBar: AppBar(
        title: const Text('Robot Remote Control', style: TextStyle(fontFamily: 'Inter')), // Sets the title of the app bar.
        centerTitle: true, // Centers the title in the app bar.
        backgroundColor: Colors.blue, // Sets the background color of the app bar.
      ),
      body: Center( // Centers the content of the page.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centers the column vertically.
          children: [
            // First row of buttons.
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centers the row horizontally.
              children: [
                buildControlButton('前'), // "Forward" button.
                buildControlButton('后'), // "Backward" button.
              ],
            ),
            // Second row of buttons.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildControlButton('左'), // "Left" button.
                buildControlButton('右'), // "Right" button.
              ],
            ),
            const SizedBox(height: 20), // Adds vertical space.
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/webview'); // Navigates to the '/webview' route when pressed.
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Sets padding.
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), // Rounds the button.
                backgroundColor: Colors.blue, // Sets the button's background color.
              ),
              child: const Text(
                'Go to Webpage', // Text of the button.
                style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Inter'), // Text style.
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// A StatefulWidget, meaning its state can change.  This is used for the WebView.
class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  _WebViewPageState createState() => _WebViewPageState(); // Creates the state for the WebViewPage.
}

// The state class for the WebViewPage.
class _WebViewPageState extends State<WebViewPage> {
  // Initialize the WebViewController directly here
  late final WebViewController _webViewController;
  final _logger = Logger('WebViewPage');

  @override
  void initState() {
    super.initState();
    // Initialize the WebViewController with all its configurations
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Enables JavaScript execution
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // You can show a loading indicator here if needed
            _logger.info('WebView is loading (progress: $progress%)');
          },
          onPageStarted: (String url) {
            _logger.info('Page started loading: $url'); // Prints when a page starts loading.
          },
          onPageFinished: (String url) {
            _logger.info('Page finished loading: $url'); // Prints when a page finishes loading.
          },
          onWebResourceError: (WebResourceError error) {
            _logger.severe('''
Page resource error:
  Code: ${error.errorCode}
  Description: ${error.description}
  For: ${error.url}
  ErrorType: ${error.errorType}
''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              _logger.info('Blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            _logger.info('Allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onHttpAuthRequest: (HttpAuthRequest request) {
            // Handle HTTP authentication if needed
            _logger.info('HTTP Auth Request for: ${request.host}');
          },
        ),
      )
      ..loadRequest(Uri.parse('http://192.168.10.10:8085')); // The initial URL to load. Replace with your URL.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Embedded Webpage', style: TextStyle(fontFamily: 'Inter')), // App bar title.
        centerTitle: true, // Centers the title.
        backgroundColor: Colors.blue,
      ),
      body: SafeArea( // Ensures the WebView is within the safe area of the screen.
        child: WebViewWidget( // Use WebViewWidget here
          controller: _webViewController, // Pass the initialized controller
        ),
      ),
    );
  }
}