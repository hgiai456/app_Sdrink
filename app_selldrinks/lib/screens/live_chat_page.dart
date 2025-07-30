import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LiveChatPage extends StatefulWidget {
  const LiveChatPage({super.key});

  @override
  State<LiveChatPage> createState() => _LiveChatPageState();
}

class _LiveChatPageState extends State<LiveChatPage> {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    final String htmlContent = '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Live Chat</title>
        <style>
            body { 
                margin: 0; 
                padding: 0; 
                font-family: Arial, sans-serif;
                background-color: #f5f5f5;
                height: 100vh;
                overflow: hidden;
            }
            #loading {
                text-align: center;
                margin-top: 50px;
                font-size: 16px;
                color: #666;
            }
            /* Force Tawk widget to be visible */
            .tawk-flex {
                height: 100vh !important;
                width: 100% !important;
            }
        </style>
    </head>
    <body>
        <div id="loading">Đang kết nối chat...</div>
        
        <!--Start of Tawk.to Script-->
        <script type="text/javascript">
        var Tawk_API=Tawk_API||{}, Tawk_LoadStart=new Date();
        (function(){
        var s1=document.createElement("script"),s0=document.getElementsByTagName("script")[0];
        s1.async=true;
        s1.src='https://embed.tawk.to/68839ac1db7610192eeaae69/1j111914a';
        s1.charset='UTF-8';
        s1.setAttribute('crossorigin','*');
        s0.parentNode.insertBefore(s1,s0);
        })();
        
        // Khi Tawk.to load xong
        Tawk_API.onLoad = function(){
            console.log('Tawk.to loaded successfully');
            document.getElementById('loading').style.display = 'none';
            
            // Force maximize chat
            setTimeout(function() {
                Tawk_API.maximize();
            }, 1000);
        };
        
        // Khi chat ready
        Tawk_API.onChatMaximized = function(){
            console.log('Chat maximized');
        };
        </script>
        <!--End of Tawk.to Script-->
    </body>
    </html>
    ''';

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setUserAgent(
            'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
          )
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                debugPrint('Page started loading: $url');
              },
              onPageFinished: (String url) {
                debugPrint('Page finished loading: $url');
                setState(() {
                  isLoading = false;
                });
              },
              onWebResourceError: (WebResourceError error) {
                debugPrint('Page resource error: ${error.description}');
              },
            ),
          )
          ..loadHtmlString(htmlContent, baseUrl: 'https://tawk.to');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0), // Tăng chiều cao AppBar
        child: AppBar(
          backgroundColor: const Color(0xFF383838), // Màu đen giống ảnh
          elevation: 0,
          flexibleSpace: SafeArea(child: Container()),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            ),
        ],
      ),
    );
  }
}
