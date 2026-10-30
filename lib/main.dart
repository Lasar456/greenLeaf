import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Flutter Android shell for the exact mobile HTML prototype in assets/index.html.
/// The prototype is fully bundled and does not connect to any live GreenLeaf API.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF16B86F),
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFFFFFFFF),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const GreenLeafApp());
}

class GreenLeafApp extends StatelessWidget {
  const GreenLeafApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenLeaf',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F6F8),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF19C66B)),
      ),
      home: const GreenLeafPreviewScreen(),
    );
  }
}

class GreenLeafPreviewScreen extends StatefulWidget {
  const GreenLeafPreviewScreen({super.key});

  @override
  State<GreenLeafPreviewScreen> createState() => _GreenLeafPreviewScreenState();
}

class _GreenLeafPreviewScreenState extends State<GreenLeafPreviewScreen> {
  late final WebViewController _webController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF6F6F8))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            // An irrelevant subresource error must not blank the UI.
            if (error.isForMainFrame == true && mounted) {
              setState(() {
                _error = error.description;
                _isLoading = false;
              });
            }
          },
        ),
      );
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    try {
      await _webController.loadFlutterAsset('assets/index.html');
    } catch (exception) {
      if (mounted) {
        setState(() {
          _error = exception.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// Navigate within the SPA instead of unexpectedly leaving the app.
  Future<void> _handleAndroidBack() async {
    if (_isLoading || _error != null) return;
    try {
      final answer = await _webController.runJavaScriptReturningResult(r'''
        (() => {
          const modal = document.getElementById('modalOverlay');
          const conversation = document.getElementById('conversation');
          const active = document.querySelector('.page.active');
          if (modal?.classList.contains('show')) {
            modal.classList.remove('show');
            return 'handled';
          }
          if (conversation?.classList.contains('open')) {
            conversation.classList.remove('open');
            return 'handled';
          }
          if (active?.id === 'screen-billing') {
            window.showPage?.('more');
            return 'handled';
          }
          if (active?.id && active.id !== 'screen-home') {
            window.showPage?.('home');
            return 'handled';
          }
          return 'exit';
        })();
      ''');
      if (answer.toString().replaceAll('"', '').trim() == 'exit') {
        await SystemNavigator.pop();
      }
    } catch (_) {
      // The WebView may still be initializing; keep the app open.
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleAndroidBack();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              WebViewWidget(controller: _webController),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFF19C66B)),
                ),
              if (_error != null)
                ColoredBox(
                  color: const Color(0xFFF6F6F8),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 44),
                          const SizedBox(height: 14),
                          const Text(
                            'Could not load the GreenLeaf preview',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text('$_error', textAlign: TextAlign.center),
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: () {
                              setState(() {
                                _error = null;
                                _isLoading = true;
                              });
                              _loadPreview();
                            },
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
