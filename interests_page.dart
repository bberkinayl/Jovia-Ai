import 'package:flutter/material.dart';
import 'jovia_home.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({super.key});

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  final List<String> interests = [
    "Astroloji",
    "Tarot",
    "Burç Uyumu",
    "İlişkiler & Aşk",
    "Kendini Keşfet",
    "Meditasyon & Spiritüellik",
    "Kişisel Gelişim",
    "Günlük Enerji",
    "Doğum Haritası",
    "Evren Mesajları ✨",
  ];

  final Set<String> selected = {};

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFB892FF),
        Color(0xFF7B61FF),
        Color(0xFFFF85C0),
      ],
      stops: [0.0, 0.55, 1.0],
    );

    return Container(
      decoration: const BoxDecoration(gradient: gradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "İlgi Alanların",
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Seni daha iyi tanımamız için birkaç alan seç ✨",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  itemCount: interests.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, i) {
                    final item = interests[i];
                    final isSelected = selected.contains(item);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selected.remove(item);
                          } else {
                            selected.add(item);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white),
                          color: isSelected
                              ? const Color(0x33FFFFFF) // hafif beyaz overlay
                              : Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            item,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.purple,
                ),
                onPressed: () {
                  // Burada selected set'ini backend'e kaydedebilirsin (ileride)
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const JoviaHome()),
                  );
                },
                child: const Text("Tamamla"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}