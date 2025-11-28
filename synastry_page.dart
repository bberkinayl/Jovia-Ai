import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SynastryPartnerData {
  final String name;
  final DateTime birthDate;
  final String birthPlace;
  final TimeOfDay? birthTime;

  SynastryPartnerData({
    required this.name,
    required this.birthDate,
    required this.birthPlace,
    this.birthTime,
  });
}

class SynastryPage extends StatefulWidget {
  final SynastryPartnerData partnerData;

  const SynastryPage({super.key, required this.partnerData});

  @override
  State<SynastryPage> createState() => _SynastryPageState();
}

class _SynastryPageState extends State<SynastryPage> {
  DateTime? _selfBirthDate;
  String _selfName = "Sen";

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSelfNatal();
  }

  Future<void> _loadSelfNatal() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString('natal_birth_date');
    final nameStr = prefs.getString('natal_name');

    DateTime? parsed;
    if (dateStr != null) {
      parsed = DateTime.tryParse(dateStr);
    }

    setState(() {
      _selfBirthDate = parsed;
      if (nameStr != null && nameStr.trim().isNotEmpty) {
        _selfName = nameStr.trim();
      } else {
        _selfName = "Sen";
      }
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1E0534), // koyu mor
        Color(0xFF7B61FF), // mor
        Color(0xFFFF85C0), // pembe
      ],
      stops: [0.0, 0.5, 1.0],
    );

    if (_loading) {
      return Container(
        decoration: const BoxDecoration(gradient: gradient),
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    // Güneş burçlarını hesapla
    final selfSign = _selfBirthDate == null
        ? "Bilinmiyor"
        : _getSunSign(_selfBirthDate!);
    final partnerSign = _getSunSign(widget.partnerData.birthDate);

    final selfElement = _getElementForSign(selfSign);
    final partnerElement = _getElementForSign(partnerSign);

    final generalText =
        _buildGeneralEnergyText(selfSign, partnerSign, _selfName, widget.partnerData.name);
    final loveText =
        _buildLovePassionText(selfSign, partnerSign, selfElement, partnerElement);
    final mindText =
        _buildMindCommunicationText(selfSign, partnerSign, selfElement, partnerElement);
    final emotionalText =
        _buildEmotionalHarmonyText(selfSign, partnerSign, selfElement, partnerElement);
    final karmicText =
        _buildKarmicText(selfSign, partnerSign, widget.partnerData.birthDate);
    final challengeText =
        _buildChallengesText(selfSign, partnerSign, selfElement, partnerElement);
    final scoreText = _buildScoreText(
      selfSign,
      partnerSign,
      selfElement,
      partnerElement,
    );

    return Container(
      decoration: const BoxDecoration(gradient: gradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Sinastri Analizi",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                        decorationColor: Colors.transparent,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "$_selfName & ${widget.partnerData.name}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    decoration: TextDecoration.none,
                    decorationColor: Colors.transparent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Güneş burçlarınız: $selfSign & $partnerSign",
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    decoration: TextDecoration.none,
                    decorationColor: Colors.transparent,
                  ),
                ),
                const SizedBox(height: 24),

                _buildSectionCard(
                  context: context,
                  title: "Genel Enerji Uyumu",
                  fullText: generalText,
                ),
                const SizedBox(height: 16),

                _buildSectionCard(
                  context: context,
                  title: "Aşk & Tutku",
                  fullText: loveText,
                ),
                const SizedBox(height: 16),

                _buildSectionCard(
                  context: context,
                  title: "Zihin & İletişim",
                  fullText: mindText,
                ),
                const SizedBox(height: 16),

                _buildSectionCard(
                  context: context,
                  title: "Duygusal Uyum",
                  fullText: emotionalText,
                ),
                const SizedBox(height: 16),

                _buildSectionCard(
                  context: context,
                  title: "Kader & Karmalar",
                  fullText: karmicText,
                ),
                const SizedBox(height: 16),

                _buildSectionCard(
                  context: context,
                  title: "Zorlu Açılar",
                  fullText: challengeText,
                ),
                const SizedBox(height: 16),

                _buildSectionCard(
                  context: context,
                  title: "Genel Uyum Skoru",
                  fullText: scoreText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------
  // YARDIMCI: KART
  // -------------------------
  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required String fullText,
  }) {
    final preview = _buildPreview(fullText);

    return GestureDetector(
      onTap: () => _openDetail(context, title, fullText),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
                decorationColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              preview,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
                decoration: TextDecoration.none,         // 🔥 alt çizgiyi kesin kapat
                decorationColor: Colors.transparent,     // ekstra garanti
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Devamını gör →",
                style: TextStyle(
                  color: Colors.purple.shade200,
                  fontSize: 12,
                  decoration: TextDecoration.none,
                  decorationColor: Colors.transparent,

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildPreview(String full) {
    if (full.length <= 180) return full;
    return full.substring(0, 180) + "...";
  }

  // -------------------------
  // BLUR MODAL DETAY
  // -------------------------
 void _openDetail(BuildContext context, String title, String content) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "synastry_detail",
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionDuration: const Duration(milliseconds: 280),
    transitionBuilder: (context, animation, _, __) {
      return Opacity(
        opacity: animation.value,
        child: Stack(
          children: [
            // Arka plan blur + Jovia degrade
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 12 * animation.value,
                sigmaY: 12 * animation.value,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xCC1E0534),
                      Color(0xCC7B61FF),
                      Color(0xCCFF85C0),
                    ],
                  ),
                ),
              ),
            ),

            // Ortadaki yorum paneli
            Center(
              child: Transform.scale(
                scale: 0.96 + 0.04 * animation.value,
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: const Color(0xF21E0534), // koyu mor, hafif opak
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.none,
                                decorationColor: Colors.transparent,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        content,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.45,
                          decoration: TextDecoration.none,         // 🔥 underline yok
                          decorationColor: Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}


  // -------------------------
  // BURÇ & ELEMENT YARDIMCILAR
  // -------------------------
  String _getSunSign(DateTime date) {
    final m = date.month;
    final d = date.day;

    if ((m == 3 && d >= 21) || (m == 4 && d <= 19)) return "Koç";
    if ((m == 4 && d >= 20) || (m == 5 && d <= 20)) return "Boğa";
    if ((m == 5 && d >= 21) || (m == 6 && d <= 20)) return "İkizler";
    if ((m == 6 && d >= 21) || (m == 7 && d <= 22)) return "Yengeç";
    if ((m == 7 && d >= 23) || (m == 8 && d <= 22)) return "Aslan";
    if ((m == 8 && d >= 23) || (m == 9 && d <= 22)) return "Başak";
    if ((m == 9 && d >= 23) || (m == 10 && d <= 22)) return "Terazi";
    if ((m == 10 && d >= 23) || (m == 11 && d <= 21)) return "Akrep";
    if ((m == 11 && d >= 22) || (m == 12 && d <= 21)) return "Yay";
    if ((m == 12 && d >= 22) || (m == 1 && d <= 19)) return "Oğlak";
    if ((m == 1 && d >= 20) || (m == 2 && d <= 18)) return "Kova";
    if ((m == 2 && d >= 19) || (m == 3 && d <= 20)) return "Balık";
    return "Bilinmiyor";
  }

  String _getElementForSign(String sign) {
    switch (sign) {
      case "Koç":
      case "Aslan":
      case "Yay":
        return "Ateş";
      case "Boğa":
      case "Başak":
      case "Oğlak":
        return "Toprak";
      case "İkizler":
      case "Terazi":
      case "Kova":
        return "Hava";
      case "Yengeç":
      case "Akrep":
      case "Balık":
        return "Su";
      default:
        return "Bilinmiyor";
    }
  }

  // -------------------------
  // UZUN YORUM FONKSİYONLARI
  // -------------------------
  String _buildGeneralEnergyText(
      String selfSign, String partnerSign, String selfName, String partnerName) {
    return
        "$selfName ve $partnerName arasındaki genel enerji, Güneş burçlarınız üzerinden okunuyor. "
        "$selfSign burcunun temel motivasyonu ile $partnerSign burcunun hayat yaklaşımı bir araya geldiğinde, "
        "ilişkinin omurgasını oluşturan ana tema ortaya çıkar.\n\n"
        "Bu ikili için asıl mesele; birbirinizin farklılıklarını tehdit değil, tamamlayıcı bir renk olarak görebilmek. "
        "Birinizin güçlü olduğu yerde diğerinizin öğrenebileceği çok şey var. "
        "Bu da ilişkinin tek boyutlu değil, zamanla gelişen ve katman kazanan bir bağ olma potansiyelini gösteriyor.\n\n"
        "Güneş–Güneş ve Güneş–Ay dinamikleri bu ilişkide kimin daha çok görünür olduğu, kimin daha çok taşıyıcı rol üstlendiği "
        "konusunda ipucu verir. Enerji dengesi yakalandığında, bu bağ hem arkadaşlık hem ortaklık hem de romantik alanlarda "
        "sizi destekleyebilir.";
  }

  String _buildLovePassionText(
      String selfSign, String partnerSign, String selfElement, String partnerElement) {
    final base =
        "Aşk ve tutku alanında en çok Venüs ve Mars enerjileri çalışsa da, Güneş burçlarınızın elementi de "
        "çekimin nasıl başladığını gösterir. $selfElement elementinin tonları ile $partnerElement elementinin tonu birleştiğinde, "
        "ilişkinin sıcaklığı ve ne kadar hızlı ısındığı ortaya çıkar.\n\n";

    String dynamicPart;
    if (selfElement == "Ateş" && partnerElement == "Ateş") {
      dynamicPart =
          "Bu ikili arasında kıvılcımlar çok hızlı oluşur. İkiniz de net, direkt ve tutkulu olduğunuz için, "
          "çekim alanı bir anda alevlenebilir. Ancak aynı hızla parlayıp aynı hızla yorulmamaya dikkat etmek gerekir; "
          "ilişkinin sürdürülebilirliği için duygusal sakinleşme alanları yaratmak önemli.";
    } else if (selfElement == "Su" && partnerElement == "Su") {
      dynamicPart =
          "Burada romantik ve duygusal bir manyetik alan var. Birbirinizin ruh halini sezmek, kelimesiz anlaşmak ve "
          "birbirinize derin bir şefkatle yaklaşmak mümkün. Tutku da yoğun ama daha çok duygusal bağ üzerinden akıyor.";
    } else if (selfElement == "Toprak" && partnerElement == "Toprak") {
      dynamicPart =
          "Aşkı daha ciddi, sakin ve kalıcı görmek gibi bir ortak çizginiz olabilir. Tutku; güven, sadakat ve birlikte "
          "bir gelecek kurma isteği üzerinden beslenir. İlişki ağır ağır ısınsa da, ısındığında uzun süreli bir bağ sunar.";
    } else if (selfElement == "Hava" && partnerElement == "Hava") {
      dynamicPart =
          "Tutku burada daha çok zihinsel çekim üzerinden oluşur. İyi sohbet, mizah ve entelektüel uyum "
          "aramızda bir elektrik yaratır. Flört enerjisi yüksektir, ancak duygusal derinliği ihmal etmemek gerekir.";
    } else {
      dynamicPart =
          "Elementleriniz farklı olduğu için aşk ve çekim alanında birbirinizi hem zorlayabilir hem de büyütebilirsiniz. "
          "Birinizin hızına diğeri sakinlik getirebilir, birinizin duygusallığı diğerinin mantığını dengeleyebilir. "
          "Bu çeşitlilik, doğru yönetildiğinde ilişkinin en heyecanlı kısmına dönüşebilir.";
    }

    return base + dynamicPart;
  }

  String _buildMindCommunicationText(
      String selfSign, String partnerSign, String selfElement, String partnerElement) {
    return
        "İletişim şekliniz, bu ilişkinin en kritik alanlarından biri. Merkür burçlarınız ve hava elementinin haritanızdaki ağırlığı "
        "konuşma tarzınızı, mizah anlayışınızı ve tartışma biçiminizi şekillendirir.\n\n"
        "Eğer aranızda güçlü bir zihinsel uyum varsa, küçük gerilimler bile konuşarak çözülebilir. "
        "Ancak biri daha içe dönük, diğeri daha dışa dönük iletişim kuruyorsa; duyguların açıkça ifade edilmesi için "
        "ekstra emek gerekebilir.\n\n"
        "Bu ilişki için öneri: Konuşmaktan vazgeçmemek. Suskun kalınan dönemlerde zihin hikâyeler üretir ve yanlış anlamalar büyüyebilir. "
        "Düzenli olarak 'biz iyi miyiz?' check-in’leri yapmak, ikinizi de güvende hissettirecektir.";
  }

  String _buildEmotionalHarmonyText(
      String selfSign, String partnerSign, String selfElement, String partnerElement) {
    return
        "Duygusal uyum, Ay burçlarınızın ve su elementinin haritanızdaki akışına göre şekillenir. "
        "Biriniz duygusunu hemen gösteren, diğeriniz daha mesafeli bir yapıdaysa; ihtiyaçlarınız ilk etapta çatışıyor gibi "
        "hissedilebilir.\n\n"
        "Bu ilişkide kalbin en çok ihtiyaç duyduğu şey; duyguya alan açılması. Savunmaya geçmeden, birbirinizin hassas "
        "noktalarını öğrenmek ve bu alanlara saygı göstermek, bağınızı çok güçlendirebilir. Özellikle zor zamanlarda "
        "birbirinizi suçlamadan, 'şu an neye ihtiyacın var?' sorusunu sormak çok iyileştirici olacaktır.\n\n"
        "Ay burçlarınız uyumluysa, birlikte olduğunuzda kendinizi garip bir şekilde 'evde' hissedebilirsiniz. "
        "Uzak görünse bile kalben tanıdık gelen bir enerji olabilir bu.";
  }

  String _buildKarmicText(
      String selfSign, String partnerSign, DateTime partnerBirthDate) {
    return
        "Kader ve karmalar alanında; Ay düğümleri, Vertex ve Pluto temasları devreye girer. "
        "Bu ilişki, sadece keyif almak için değil; aynı zamanda ruhsal olarak büyümek, bazı döngüleri kapatmak ve "
        "kendinizi daha derin tanımak için hayatınıza girmiş olabilir.\n\n"
        "Karmik bağlantıların hissi genelde şöyledir: 'Neden bu kişiden bu kadar etkileniyorum?' veya "
        "'Sanki onu çok eskiden tanıyormuşum gibi hissediyorum.' "
        "Bu ilişki de sizde böyle duygular uyandırıyorsa, birbirinizin hayat planında önemli bir rol oynuyor olabilirsiniz.\n\n"
        "Kader alanı; her zaman 'birlikte kalmak zorundasınız' anlamına gelmez. Bazen en büyük karmalar, "
        "hayatınızdan geçip size çok şey öğreten insanlarla yaşanır. Önemli olan, bu bağın size ne öğrettiğini fark etmek.";
  }

  String _buildChallengesText(
      String selfSign, String partnerSign, String selfElement, String partnerElement) {
    return
        "Her ilişkide olduğu gibi bu bağın da 'dikkat gerektiren' alanları var. "
        "Burada genellikle Satürn, Mars ve Pluto’nun zorlayıcı açıları devreye girer. Bunlar; sınır, öfke, güç mücadelesi ve "
        "kıskançlık temalarını tetikleyebilir.\n\n"
        "Bu ilişki içinde zaman zaman kendinizi test ediliyormuş gibi hissedebilirsiniz. "
        "Adil olmak, sınırlarınızı korumak ve birbirinizi değiştirmeye çalışmak yerine anlamaya çalışmak; "
        "bu zorlukları büyüme fırsatına dönüştürebilir.\n\n"
        "Öneri: Kriz anlarında 'haklı mıyım?' yerine 'buradan ne öğrenebilirim?' sorusunu sormayı deneyin. "
        "Bu, ilişkinin enerjisini savunmadan iş birliğine taşıyacaktır.";
  }

  String _buildScoreText(
    String selfSign,
    String partnerSign,
    String selfElement,
    String partnerElement,
  ) {
    int score = 70;

    if (selfElement == partnerElement && selfElement != "Bilinmiyor") {
      score += 10;
    }

    if ((selfElement == "Ateş" && partnerElement == "Hava") ||
        (selfElement == "Hava" && partnerElement == "Ateş") ||
        (selfElement == "Toprak" && partnerElement == "Su") ||
        (selfElement == "Su" && partnerElement == "Toprak")) {
      score += 5;
    }

    if ((selfElement == "Ateş" && partnerElement == "Su") ||
        (selfElement == "Su" && partnerElement == "Ateş")) {
      score -= 5;
    }

    if ((selfElement == "Toprak" && partnerElement == "Hava") ||
        (selfElement == "Hava" && partnerElement == "Toprak")) {
      score -= 5;
    }

    if (score > 95) score = 95;
    if (score < 40) score = 40;

    return
        "Bu ilişki için Jovia uyum skoru yaklaşık %$score seviyesinde görünüyor. "
        "Bu rakam; sadece 'iyi-kötü' demek için değil, hangi alanların doğal olarak akıp hangilerinin emek isteyeceğini "
        "göstermek için önemli.\n\n"
        "Güçlü taraflarınız; birbirinize ilham verme, yeni deneyimlere açılma ve kalıcı hatıralar yaratma potansiyeli taşıyor. "
        "Gelişim alanlarınız ise; iletişim esnasında savunmaya geçmemek, ego savaşlarına kapılmamak ve birbirinizin "
        "duygusal ihtiyaçlarına gerçekten kulak vermek.\n\n"
        "Ustalık, yüzdeyi büyütmek değil; bu bağı daha bilinçli, daha saygılı ve daha şefkatli bir zemine taşımakta gizli.";
  }
}