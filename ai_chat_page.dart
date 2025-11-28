import 'package:flutter/material.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // basit demo mesaj listesi
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      fromUser: false,
      text:
          "Merhaba, ben Jovia AI 💫\n\nDoğum haritan, ilişkilerin ve önünde açılan yollar hakkında konuşmaya hazırım.",
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        _ChatMessage(fromUser: true, text: text),
      );
      _controller.clear();
    });

    // scroll aşağı
    _scrollToBottom();

    // demo bot cevabı (şimdilik)
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            fromUser: false,
            text:
                "Şimdilik demo modundayım ama enerji alanını okumaya başladım bile ✨\n\n"
                "Yakında buraya gerçek Jovia AI güçlerini bağlayacağız. Şu an sorduğun her şey, tasarımı iyileştirmemize yardımcı oluyor.",
          ),
        );
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Arka planda zaten Jovia gradient'i var (JoviaHome'dan geliyor),
    // o yüzden burada ekstra scaffold / gradient kullanmıyoruz.
    return Column(
      children: [
        const SizedBox(height: 8),

        // ÜST BÖLÜM – Jovia AI header
        _buildHeader(),

        const SizedBox(height: 8),

        // MESAJLAR
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: const Color(0x26000000),
            ),
            child: _buildMessages(),
          ),
        ),

        // MESAJ GİRİŞ ÇUBUĞU
        _buildInputBar(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x66B892FF),
              Color(0x667B61FF),
              Color(0x66FF85C0),
            ],
          ),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            // küçük “gezegen” avatar
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFB892FF),
                    Color(0xFF7B61FF),
                    Color(0xFFFF85C0),
                  ],
                ),
              ),
              child: const Icon(
                Icons.bubble_chart_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Jovia AI",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Astrolojik rehberin, ritüel arkadaşın ve kozmik koçun ✨",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isUser = msg.fromUser;
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.fromLTRB(
              isUser ? 60 : 8,
              4,
              isUser ? 8 : 60,
              4,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft:
                    Radius.circular(isUser ? 18 : 4), // kullanıcı sağ balon
                bottomRight:
                    Radius.circular(isUser ? 4 : 18), // jovia sol balon
              ),
              gradient: isUser
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFEAD9FF),
                      ],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF7B61FF),
                        Color(0xFFFF85C0),
                      ],
                    ),
              boxShadow: isUser
                  ? [
                      BoxShadow(
                        color: const Color(0x80FFFFFF),
                        blurRadius: 16,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: const Color(0x805F42FF),
                        blurRadius: 18,
                        spreadRadius: 0,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Text(
              msg.text,
              style: TextStyle(
                color: isUser ? const Color(0xFF3A2B5F) : Colors.white,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: const Color(0x33FFFFFF),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 4,
                  minLines: 1,
                  decoration: const InputDecoration(
                    hintText: "Bugün neyi merak ediyorsun? ✨",
                    hintStyle: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFB892FF),
                        Color(0xFF7B61FF),
                        Color(0xFFFF85C0),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
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

class _ChatMessage {
  final bool fromUser;
  final String text;

  _ChatMessage({
    required this.fromUser,
    required this.text,
  });
}
