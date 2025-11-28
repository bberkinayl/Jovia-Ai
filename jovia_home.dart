import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'ai_chat_page.dart';
import 'synastry_page.dart';

import 'notifications_page.dart';

class JoviaHome extends StatefulWidget {
  const JoviaHome({super.key});

  @override
  State<JoviaHome> createState() => _JoviaHomeState();
}

class _JoviaHomeState extends State<JoviaHome> {
  int _currentIndex = 0;
  

  // renkler
  final Color _activeColor = Colors.white;
  final Color _inactiveColor = const Color.fromRGBO(255, 255, 255, 0.6);

  // Natal form state
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthPlaceController = TextEditingController();
  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  String _relationshipStatus = "Belirtmek istemiyorum";

  // Profil foto
  final ImagePicker _imagePicker = ImagePicker();
  String? _profileImagePath;

  Future<void> _openSynastryPartnerBottomSheet() async {
  final prefs = await SharedPreferences.getInstance();

  // Daha önce kayıtlı partner bilgisi varsa onları çek
  final savedName = prefs.getString('syn_partner_name');
  final savedPlace = prefs.getString('syn_partner_place');
  final savedDateStr = prefs.getString('syn_partner_birth_date');
  final savedHour = prefs.getInt('syn_partner_birth_hour');
  final savedMinute = prefs.getInt('syn_partner_birth_minute');

  DateTime? _pBirthDate =
      savedDateStr != null ? DateTime.tryParse(savedDateStr) : null;
  TimeOfDay? _pBirthTime = (savedHour != null && savedMinute != null)
      ? TimeOfDay(hour: savedHour, minute: savedMinute)
      : null;

  final TextEditingController _pName =
      TextEditingController(text: savedName ?? "");
  final TextEditingController _pPlace =
      TextEditingController(text: savedPlace ?? "");

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E0534),
                  Color(0xFF7B61FF),
                  Color(0xFFFF85C0),
                ],
              ),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const Text(
                        "İlişki Analizi İçin Partner Bilgileri",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Sinastri yorumunu doğru yapabilmem için partnerinin temel doğum bilgilerine ihtiyacım var.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Partner adı
                      TextField(
                        controller: _pName,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Partner adı",
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white38),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Doğum tarihi
                      const Text(
                        "Doğum Tarihi",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final result = await showDatePicker(
                            context: context,
                            initialDate:
                                _pBirthDate ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (result != null) {
                            setModalState(() => _pBirthDate = result);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: const Color(0x26FFFFFF),
                            border: Border.all(color: Colors.white),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _pBirthDate == null
                                    ? "Gün / Ay / Yıl"
                                    : "${_pBirthDate!.day.toString().padLeft(2, '0')}.${_pBirthDate!.month.toString().padLeft(2, '0')}.${_pBirthDate!.year}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const Icon(Icons.calendar_month,
                                  color: Colors.white),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Doğum saati
                      const Text(
                        "Doğum Saati (opsiyonel)",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final result = await showTimePicker(
                                  context: context,
                                  initialTime: _pBirthTime ??
                                      const TimeOfDay(hour: 12, minute: 0),
                                );
                                if (result != null) {
                                  setModalState(() => _pBirthTime = result);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: const Color(0x26FFFFFF),
                                  border: Border.all(color: Colors.white),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _pBirthTime == null
                                          ? "Saat / Dakika"
                                          : "${_pBirthTime!.hour.toString().padLeft(2, '0')}:${_pBirthTime!.minute.toString().padLeft(2, '0')}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Icon(Icons.access_time,
                                        color: Colors.white),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: () {
                              setModalState(() => _pBirthTime = null);
                            },
                            child: const Text(
                              "Bilmiyorum",
                              style: TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Doğum yeri
                      TextField(
                        controller: _pPlace,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Doğum Yeri (Şehir, Ülke)",
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white38),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF7B61FF),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: () async {
                            if (_pName.text.trim().isEmpty ||
                                _pBirthDate == null ||
                                _pPlace.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "İlişki analizi için partner adı, doğum tarihi ve doğum yerini doldurmalısın ✨"),
                                ),
                              );
                              return;
                            }

                            // 🔐 Partner bilgilerini kalıcı kaydet
                            await prefs.setString(
                                'syn_partner_name', _pName.text.trim());
                            await prefs.setString('syn_partner_place',
                                _pPlace.text.trim());
                            await prefs.setString('syn_partner_birth_date',
                                _pBirthDate!.toIso8601String());
                            if (_pBirthTime != null) {
                              await prefs.setInt(
                                  'syn_partner_birth_hour', _pBirthTime!.hour);
                              await prefs.setInt('syn_partner_birth_minute',
                                  _pBirthTime!.minute);
                            } else {
                              await prefs.remove('syn_partner_birth_hour');
                              await prefs.remove('syn_partner_birth_minute');
                            }

                            final partner = SynastryPartnerData(
                              name: _pName.text.trim(),
                              birthDate: _pBirthDate!,
                              birthPlace: _pPlace.text.trim(),
                              birthTime: _pBirthTime,
                            );

                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SynastryPage(partnerData: partner),
                              ),
                            );
                          },
                          child: const Text("Analize Başla 💕"),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      );
    },
  );
}


  

  @override
  void initState() {
    super.initState();
    _loadNatalData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthPlaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFB892FF), // açık lila
        Color(0xFF7B61FF), // mor
        Color(0xFFFF85C0), // pembe
      ],
      stops: [0.0, 0.55, 1.0],
    );

    return Container(
      decoration: const BoxDecoration(gradient: gradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            // sağ üst bildirim çanı
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                onPressed: () {
                  final List<String> notifications = [
                    "Bugün Ay, Venüs ile uyumlu açı yapıyor 💫",
                    "Yeni bir astro rehber yayınlandı!",
                  ];

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NotificationsPage(notifications: notifications),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_none,
                    size: 26, color: Colors.white),
              ),
            ),
          ],
        ),

        // gösterilen sayfa
        body: SafeArea(child: _buildPage(_currentIndex)),

        // alt bar
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  // -------------------------
  // SAYFA SEÇİMİ
  // -------------------------

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const Center(
          child: Text(
            'Home Page',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        );
      case 1:
        return const Center(
          child: Text('Bond Page',
              style: TextStyle(color: Colors.white, fontSize: 24)),
        );
      case 2:
        return const Center(
          child: Text('Create Page',
              style: TextStyle(color: Colors.white, fontSize: 24)),
        );
      case 3:
        return const AiChatPage();
      case 4:
        return _buildProfilePage(); // <- Natal & yorum burada
      default:
        return const SizedBox.shrink();
    }
  }

  // -------------------------
  // PROFILE + NATAL BÖLÜMÜ
  // -------------------------

  Widget _buildProfilePage() {
    final bool hasNatalData = _birthDate != null ||
        _birthPlaceController.text.trim().isNotEmpty ||
        _nameController.text.trim().isNotEmpty;

    final String displayName = _nameController.text.trim().isEmpty
        ? "Jovia Kullanıcısı"
        : _nameController.text.trim();

    final String subtitleText = hasNatalData
        ? _buildNatalSummary()
        : "Profil bilgilerini yakında buradan düzenleyebileceksin.";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profil başlığı
          const Text(
            "Profilin",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Buradan kendini ve gökyüzünü yönetebilirsin.",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Profil kartı + foto + özet
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0x33FFFFFF),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickProfileImage,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white),
                    ),
                    child: ClipOval(
                      child: _profileImagePath != null
                          ? Image.file(
                              File(_profileImagePath!),
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 34,
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitleText,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // NATAL CHART KARTI (bilgileri düzenleme)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0x33FFFFFF),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Doğum Haritan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Doğum bilgilerini buradan istediğin zaman güncelleyebilirsin.",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.purple,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        onPressed: _openNatalBottomSheet,
                        child: const Text("Doğum Bilgilerini Düzenle ✨"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          

          const SizedBox(height: 16),


          // DOĞUM HARİTASI YORUM KARTI (Beta)
          _buildNatalInterpretationCard(),
          
          const SizedBox(height: 16),


          // SİNASTRİ BÖLMESİ
          _buildSynastrySectionCard(),

          const SizedBox(height: 16),

          // TRANSİT BÖLMESİ
          _buildTransitSectionCard(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // -------------------------
  // YORUM KARTI (PREVIEW + BLUR OVERLAY)
  // -------------------------
  

  Widget _buildNatalInterpretationCard() {
    if (_birthDate == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0x26FFFFFF),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Doğum Haritası Yorumu",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Doğum tarihini eklediğinde seni Jovia stilinde yorumlamaya başlayacağım 💫",
              style: TextStyle(color: Colors.white70, fontSize: 13),
              
              
            ),
          ],
        ),
      );
      
    }
    

    final String sign = _getSunSign(_birthDate!);
    final String signEmoji = _getSunSignEmoji(sign);
    final String comment = _getSunSignComment(sign, _relationshipStatus);

    final String preview = comment.length > 200
        ? comment.substring(0, 200) + "..."
        : comment;

    return GestureDetector(
      onTap: () => _openNatalCommentOverlay(comment),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0x26FFFFFF),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Doğum Haritası Yorumu",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Güneş burcun: $sign $signEmoji",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              preview,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              "Devamını gör →",
              style: TextStyle(
                color: Colors.purple.shade200,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------
  // BLUR OVERLAY RİTÜEL EKRANI
  // -------------------------
  

void _openNatalCommentOverlay(String comment) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "natal_comment",
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final size = MediaQuery.of(context).size;

      return Stack(
        children: [
          // ARKA PLAN: BLUR + JOVIA GRADIENT
          AnimatedOpacity(
            opacity: animation.value,
            duration: const Duration(milliseconds: 250),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 14 * animation.value,
                  sigmaY: 14 * animation.value,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xCCB892FF), // lila
                        Color(0xCC7B61FF), // mor
                        Color(0xCCFF85C0), // pembe
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // YORUM PANELİ – geçişli mor/pembe/lila arka plan
          Transform.translate(
            offset: Offset(0, (1 - animation.value) * 80),
            child: Opacity(
              opacity: animation.value,
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 32,
                  ),
                  padding: const EdgeInsets.all(20),
                  constraints: BoxConstraints(
                    maxHeight: size.height * 0.82,
                    minHeight: size.height * 0.6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xF2B892FF), // lila
                        Color(0xF27B61FF), // mor
                        Color(0xF2FF85C0), // pembe
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ÜST BAR
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Doğum Haritası Yorumu",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration
                                  .none, // ALT ÇİZGİ YOK (garanti)
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child:
                                const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      
                      const Text(
                        "Bu alan sadece sana özel. Yorumu sakince oku, içinden ne uyuyorsa onu al 💫",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.4,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // UZUN YORUM – preview’la aynı havada
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            comment,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.45,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
} 

     // -------------------------
  // SİNASTRİ / İLİŞKİ ANALİZİ KARTI
  // -------------------------
  Widget _buildSynastrySectionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0x26FFFFFF),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "İlişki & Sinastri Yorumu",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Kendi haritan ile bir başkasının haritasını karşılaştırıp aranızdaki kimyayı, uyumu ve zorlu açıları burada analiz edeceğiz.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF7B61FF),
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  onPressed: _openSynastryPartnerBottomSheet,

                  child: const Text("İlişki analizi başlat 💕"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------
  // TRANSİT / ZAMANLAMA KARTI
  // -------------------------
  Widget _buildTransitSectionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0x26FFFFFF),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Transit & Zamanlama",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Jüpiter döngülerin, Satürn derslerin ve güncel gökyüzü hareketlerinin haritana nasıl değdiğini burada göreceksin.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  onPressed: () {
                    // TODO: transit takvimi / günlük yorum ekranına gideceğiz
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Transit yorum ekranını birazdan beraber tasarlarız ✨",
                        ),
                      ),
                    );
                  },
                  child: const Text("Transitlerini gör 🔮"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  // -------------------------
  // SUN SIGN & ELEMENT & UZUN YORUM
  // -------------------------

  String _getSunSign(DateTime date) {
    final int m = date.month;
    final int d = date.day;

    // Klasik tropikal zodyak tarih aralıkları
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

  String _getSunSignEmoji(String sign) {
    switch (sign) {
      case "Koç":
        return "♈";
      case "Boğa":
        return "♉";
      case "İkizler":
        return "♊";
      case "Yengeç":
        return "♋";
      case "Aslan":
        return "♌";
      case "Başak":
        return "♍";
      case "Terazi":
        return "♎";
      case "Akrep":
        return "♏";
      case "Yay":
        return "♐";
      case "Oğlak":
        return "♑";
      case "Kova":
        return "♒";
      case "Balık":
        return "♓";
      default:
        return "✨";
    }
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

  String _getSunSignComment(String sign, String relationshipStatus) {
    // 1) Burç bazlı ana yorum
    final String element = _getElementForSign(sign);
    String base;

    switch (sign) {
      case "Koç":
        base =
            "Güneşin Koç’ta: hızlı karar veren, risk almaktan korkmayan ve çoğu zaman içgüdüsel hareket eden bir enerjin var. "
            "Sen yeni başlangıçların öncüsüsün; çoğu insanın cesaret edemediği kapıları sen açıyorsun. "
            "Bazen çok acele ediyor gibi hissedebilirsin ama aslında hayat senin için deneyerek öğrenmek üzerine kurulu. "
            "Enerjini doğru alana yönelttiğinde hem kendin hem çevrendekiler için büyük bir motivasyon kaynağı oluyorsun.";
        break;
      case "Boğa":
        base =
            "Güneşin Boğa’da: stabilite, konfor ve güven senin için çok önemli. "
            "Hayatta adım adım ilerlemeyi seviyorsun ve bu tempo seni çok sağlam temellere götürüyor. "
            "İlişkilerde, işte ve para konusunda uzun vadeli düşünüp kalıcı şeyler inşa etmeye yatkınsın. "
            "Güzellik, estetik ve dokunsal deneyimler senin yaşam enerjini besleyen ana kaynaklardan.";
        break;
      case "İkizler":
        base =
            "Güneşin İkizler’de: meraklı, hareketli ve zihinsel olarak hep online bir enerjin var. "
            "Senin için hayat; konuşmalar, fikirler, trendler ve öğrenilecek sonsuz şeyle dolu dev bir bilgi akışı gibi. "
            "Tek bir role sıkışmak sana göre değil; farklı ortamlarda farklı yanlarını gösterebilmek seni canlı tutuyor. "
            "Zihnin çok hızlı çalıştığı için bazen dağılmış hissedebilirsin ama doğru alanlara odaklandığında inanılmaz yaratıcı çözümler üretebiliyorsun.";
        break;
      case "Yengeç":
        base =
            "Güneşin Yengeç’te: duygular, aidiyet ve içsel güvenlik senin için çok değerli. "
            "İnsanları sezgisel olarak okuma yeteneğin yüksek; çoğu zaman söylenmeyeni hissediyorsun. "
            "Geçmiş, anılar, aile ve kökler senin hayat hikâyende özel bir yer tutuyor. "
            "Duygusal dünyana saygı gösterdiğinde hem kendine hem başkalarına yumuşak ve şifalı bir alan açıyorsun.";
        break;
      case "Aslan":
        base =
            "Güneşin Aslan’da: sahnede olmayı hak eden, yaratıcı ve gururlu bir kalbin var. "
            "Hayat senden görünür olmanı, kendini ifade etmeni ve içindeki çocuğu canlı tutmanı istiyor. "
            "Yaratıcı projeler, sahne, sanat ve spotlight senin doğal oyun alanın. "
            "Kalbini açtığında insanlara da cesurca kendileri olma izni veriyorsun.";
        break;
      case "Başak":
        base =
            "Güneşin Başak’ta: detaycı, analiz eden ve sürekli iyileştirmek isteyen bir enerjin var. "
            "Sen sorunları büyütmek için değil çözmek için görürsün. "
            "Günlük hayatın düzeni, verimlilik ve faydalı olma isteği sende çok güçlü. "
            "Eleştirel bakışın şefkatle birleştiğinde, hem kendin hem başkaları için inanılmaz bir iyileştirici oluyorsun.";
        break;
      case "Terazi":
        base =
            "Güneşin Terazi’de: denge, estetik ve ilişkiler üzerinden kendini tanımlayan bir enerjin var. "
            "Hayat sana sürekli 'dengeyi kur, güzeli seç ve adil olanı gözet' diyor. "
            "İnsanlarla bağ kurarken uyum ve zarafet senin için çok önemli. "
            "Sanat, tasarım, sosyal ilişkiler ve estetik bakışın senin doğal sahnelerin.";
        break;
      case "Akrep":
        base =
            "Güneşin Akrep’te: derin, sezgisel ve dönüştürücü bir kalbin var. "
            "Yüzeysel olan hiçbir şey seni tatmin etmiyor; perdenin arkasındaki gerçek dinamiği görmek istiyorsun. "
            "Kriz, dönüşüm, bitiş ve yeniden doğuş temaları hayatında normalden biraz daha belirgin olabilir. "
            "Karanlıktan güç çıkarabildiğin için başkalarının zorlandığı yerlerde sen çok güçlü durabiliyorsun.";
        break;
      case "Yay":
        base =
            "Güneşin Yay’da: özgürlük, keşif ve anlam arayışı senin ana temaların. "
            "Senin için hayat; seyahatler, yeni kültürler ve büyük sorularla dolu bir macera. "
            "Dar kalıplar ve katı kurallar sana göre değil; geniş bakış açıları seni daha çok besliyor. "
            "Nereye gidersen git, yanında götürdüğün şey aslında içindeki neşe ve umut duygusu.";
        break;
      case "Oğlak":
        base =
            "Güneşin Oğlak’ta: hedef odaklı, ciddi ve sorumluluk almaktan kaçmayan bir enerjin var. "
            "Hayat seni erken yaşlardan itibaren olgunlaştırmış olabilir; bu da hem güçlü hem yorucu hissettirebilir. "
            "Uzun vadeli hedefler, kariyer ve kalıcı bir şeyler inşa etme isteği sende çok baskın. "
            "Adım adım, sistemli ve stratejik ilerlediğinde büyük yapıların mimarı olabilirsin.";
        break;
      case "Kova":
        base =
            "Güneşin Kova’da: özgün, bağımsız ve geleceğe dönük bir enerjin var. "
            "Kalabalığın içinde bile kendi çizgini koruyorsun ve çoğu zaman çağının biraz ilerisindesin. "
            "Fikirlerin, tarzın veya ilişkilerin klasik olmak zorunda değil; alternatif olan sana daha çok yakışıyor. "
            "Arkadaşlıklar, topluluklar ve kolektif projeler senin için çok besleyici olabilir.";
        break;
      case "Balık":
        base =
            "Güneşin Balık’ta: sezgisel, empatik ve hayal gücü yüksek bir enerjin var. "
            "Dünyayı sadece mantık üzerinden değil, kalbinin titreşimleri üzerinden de algılıyorsun. "
            "Sanat, müzik, sinema ve ruhsal arayışlar seni derinden etkileyebilir. "
            "Sınırlarını korumayı öğrendiğinde, varlığın başkaları için çok şifalı bir alana dönüşebiliyor.";
        break;
      default:
        base =
            "Güneş burcun haritanın kalbi. Hayatta 'ben böyle parlıyorum' dediğin yer tam olarak burada. "
            "Enerjin, motivasyonun ve kimlik algın bu bölgeden yönetiliyor.";
    }

    // 2) Element + ilişki durumu bazlı aşk/ilişki kuyruğu
    String loveTail;

    switch (relationshipStatus) {
      case "Bekarım":
        switch (element) {
          case "Ateş":
            loveTail =
                " Aşk tarafında şu an en büyük tema, kalbini hafife almak yerine tutkunu ciddiye almak. "
                "Bekarlık senin için durağan değil; flört enerjisi, yeni insanlar ve macera ihtimaliyle dolu canlı bir alan.";
            break;
          case "Toprak":
            loveTail =
                " Bekarlık senin için aslında içsel temellerini güçlendirme dönemi. "
                "Kalıcı bir ilişkiye hazırlandığın bu süreçte, kendi değerini ve sınırlarını netleştirmen en büyük yatırımın.";
            break;
          case "Hava":
            loveTail =
                " Şu anda aşk, zihinsel uyum ve iyi sohbetle geliyor. "
                "Bekarlık döneminde bile bağlantıda kalmak, sohbet etmek ve flörtöz bir iletişim kurmak senin için çok besleyici.";
            break;
          case "Su":
            loveTail =
                " Bekar olsan bile kalbin aslında derin bağlar arıyor. "
                "Bu dönemde duygularını daha iyi tanımak, geçmişten gelen kırgınlıkları temizlemek aşk hayatın için güçlü bir zemin yaratıyor.";
            break;
          default:
            loveTail =
                " Bekarlık senin için bir eksiklik değil; kendini daha iyi duyabildiğin, kalbinin neye hazır olduğunu keşfettiğin bir alan.";
        }
        break;

      case "İlişkim var":
        switch (element) {
          case "Ateş":
            loveTail =
                " İlişki içinde tutkunun canlı kalması senin için çok önemli. "
                "Beraber yeni deneyimler yaşamak, rutini zaman zaman bozmak ve ilişkiye heyecan katmak bağınızı güçlendiriyor.";
            break;
          case "Toprak":
            loveTail =
                " İlişki senin için güven, sadakat ve omuz omuza yürümek demek. "
                "Somut planlar, ortak hedefler ve uzun vadeli düşünmek bu ilişkiyi daha sağlam bir zemine taşıyor.";
            break;
          case "Hava":
            loveTail =
                " Senin için ilişkide en önemli şeylerden biri, konuşabilmek ve aynı zihinsel frekansta buluşmak. "
                "Paylaşılan fikirler, hayaller ve sohbetler bu ilişkiyi canlı tutan ana yakıt.";
            break;
          case "Su":
            loveTail =
                " Duygusal yakınlık ve içtenlik senin için ilişkinin kalbi. "
                "Birbirinize hassas alanlarınızı güvenle açabildiğinizde, bağınız çok daha derin ve şefkatli bir forma geçiyor.";
            break;
          default:
            loveTail =
                " İlişkinin nasıl göründüğünden çok içeride nasıl hissettirdiği önemli. "
                "Kalbin gerçekten görüldüğünü hissettiğinde bu bağ senin için çok daha anlamlı hale geliyor.";
        }
        break;

      case "Evliyim":
        switch (element) {
          case "Ateş":
            loveTail =
                " Evlilik senin için sadece rutin bir yapı değil; birlikte büyünecek, risk alınacak ve hayatı daha cesur yaşanacak bir ortaklık. "
                "Bağınızın canlı kalması için zaman zaman beraber maceraya çıkmanız çok iyi geliyor.";
            break;
          case "Toprak":
            loveTail =
                " Evlilik senin için güven, sorumluluk ve birlikte kurulan bir hayat demek. "
                "Finansal düzen, ortak hedefler ve düzenli emek bu ilişkiyi yıllar içinde daha da güçlendiriyor.";
            break;
          case "Hava":
            loveTail =
                " Evlilikte zihinsel uyum ve arkadaşlık senin için çok önemli. "
                "Eşinle sadece partner değil, aynı zamanda iyi bir dost olmak bu ilişkiyi hafif ve ferah hissettiriyor.";
            break;
          case "Su":
            loveTail =
                " Evlilikten beklentin sadece aynı evde yaşamak değil; ruhsal ve duygusal bir yol arkadaşı bulmak. "
                "Birlikte geçirilen sakin anlar, derin sohbetler ve ortak duygusal alanlar bu bağı kutsallaştırıyor.";
            break;
          default:
            loveTail =
                " Uzun vadeli ilişkilerde, senin için en önemli şey saygı ve içtenlik. "
                "Kalbinin gördüğünü ve değer gördüğünü hissettiğin bir evlilik, haritanın güçlü temalarından biri olabilir.";
        }
        break;

      case "Durum karmaşık":
        switch (element) {
          case "Ateş":
            loveTail =
                " Kalbinin ritmi şu anda biraz dalgalı olabilir; bir yanın özgürlük isterken, diğer yanın derin bağları özleyebilir. "
                "İlişki alanındaki bu karışıklık, aslında neye gerçekten tutku duyduğunu keşfetme sürecinin parçası.";
            break;
          case "Toprak":
            loveTail =
                " Durum karmaşık görünse de, içten içe netlik ve somutluk arıyorsun. "
                "Haritan, ilişkilerde seni oyalayan, yorup ileri götürmeyen dinamikleri sorgulama zamanında olabileceğini söylüyor.";
            break;
          case "Hava":
            loveTail =
                " Zihninde belki bin tane soru, bin tane ihtimal var şu an. "
                "Bu karışıklıkta, her şeyi çözmek zorunda hissetmek yerine önce kendi düşüncelerini sakinleştirmek sana iyi gelebilir.";
            break;
          case "Su":
            loveTail =
                " Duygusal olarak karmaşa yaşıyor olabilirsin; bir yanın bırakmak isterken, diğer yanın tutunmak isteyebilir. "
                "Haritan, iç sesini ciddiye alıp duygularını yok saymaman gerektiğini fısıldıyor.";
            break;
          default:
            loveTail =
                " Karmaşık görünen ilişkiler bazen en büyük farkındalıkları getirir. "
                "Şu an yaşadıkların, 'ben ne istiyorum?' sorusuna daha net cevap verebilmen için bir süreç olabilir.";
        }
        break;

      default:
        switch (element) {
          case "Ateş":
            loveTail =
                " İlişkilerde enerjin yüksek ve çekim alanın güçlü. "
                "Kim hayatına girerse girsin, senin iç motivasyonun ve yaşam coşkun bu bağların gerçek tonu olacak.";
            break;
          case "Toprak":
            loveTail =
                " İlişkilere yaklaşımın ciddi ve kalıcı; emek vermeye hazırsın ama karşılığında aynı istikrarı görmek istiyorsun. "
                "Haritan, uzun vadede sağlam bağlar kurma potansiyelini vurguluyor.";
            break;
          case "Hava":
            loveTail =
                " Bağ kurarken önce zihin, sonra kalp devreye girebilir. "
                "Zihinsel uyum yakaladığın ilişkiler, senin için çok daha kalıcı ve anlamlı hale geliyor.";
            break;
          case "Su":
            loveTail =
                " Duygusal bağlar senin için çok derin bir alan. "
                "İlişkilerde sezgilerini yok saymadığın ve duygularını hafife almadığın sürece kalbin sana doğru yolu gösterecek.";
            break;
          default:
            loveTail =
                " İlişkiler alanında kalbinin ritmini takip etmek, senin için en güvenilir pusula. "
                "Ne zaman gerçekten huzurlu hissettiğine dikkat etmek, doğru yöne gittiğinin işareti.";
        }
    }

    // 3) Doğum saatine göre mini flavor (gece/gündüz)
    String timeFlavor = "";
    if (_birthTime != null) {
      final h = _birthTime!.hour;
      final bool isNight = h < 6 || h >= 18;
      if (isNight) {
        timeFlavor =
            " Gece doğmuş biri olarak, iç dünyan ve sezgilerin gündüz hayatından bile daha aktif olabilir; yalnız kaldığın anlarda çok şey fark ediyorsun.";
      } else {
        timeFlavor =
            " Gündüz doğmuş biri olarak, enerjini daha çok dış dünyaya akıtma eğilimindesin; insanlar genelde seni fark etmeden geçemiyor.";
      }
    }

    return base + loveTail + timeFlavor;
  }

  // -------------------------
  // ÖZET METİN
  // -------------------------

  String _buildNatalSummary() {
    final name = _nameController.text.trim().isEmpty
        ? "Haritan"
        : "${_nameController.text.trim()}’ın haritası";

    final dateText =
        _birthDate == null ? "Tarih yok" : _formatDate(_birthDate);
    final placeText = _birthPlaceController.text.trim().isEmpty
        ? "Doğum yeri yok"
        : _birthPlaceController.text.trim();

    final timeText =
        _birthTime == null ? "Saat bilinmiyor" : _formatTime(_birthTime);

    return "$name • $dateText • $timeText • $placeText";
  }
  

  // -------------------------
  // ALT BAR
  // -------------------------
  

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BottomAppBar(
          color: const Color.fromRGBO(0, 0, 0, 0.18),
          child: SizedBox(
            height: 72,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _bottomItem(icon: Icons.home_filled, label: 'Home', index: 0),
                _bottomItem(icon: Icons.link, label: 'Bond', index: 1),
                _bottomItem(icon: Icons.add, label: 'Create', index: 2),
                _bottomItem(
                    icon: Icons.smart_toy_outlined, label: 'AI Chat', index: 3),
                _bottomItem(
                    icon: Icons.person_outline, label: 'Profile', index: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool selected = _currentIndex == index;
    final Color iconColor = selected ? _activeColor : _inactiveColor;
    final Color textColor = selected ? _activeColor : _inactiveColor;

    // SADECE + BUTONUNA GLOW
    if (index == 2) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _currentIndex = index),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB892FF).withAlpha(0xCC), // lila glow
                        blurRadius: 22,
                        spreadRadius: 3,
                      ),
                      BoxShadow(
                        color: const Color(0xFFFF85C0).withAlpha(0xB3), // pembe glow
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 26, color: iconColor),
                ),
                const SizedBox(height: 6),
                Text(label, style: TextStyle(fontSize: 12, color: textColor)),
              ],
            ),
          ),
        ),
      );
    }

    // NORMAL BUTONLAR
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 26, color: iconColor),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontSize: 12, color: textColor)),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------
  // PROFİL FOTO SEÇME
  // -------------------------

  Future<void> _pickProfileImage() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImagePath = image.path;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', _profileImagePath!);
    }
  }

  // -------------------------
  // NATAL BOTTOM SHEET (STATEFULBUILDER İLE)
  // -------------------------

  void _openNatalBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xF21E0534), // ARGB, opak mor ton
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const Text(
                          "Doğum Bilgilerin",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Seni doğru yorumlayabilmemiz için birkaç bilgiye ihtiyacımız var.",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 20),

                        // Ad (opsiyonel)
                        TextField(
                          controller: _nameController,
                          onChanged: (_) {
                            setState(() {});
                            modalSetState(() {});
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: "Adın (opsiyonel)",
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white38),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Doğum Tarihi
                        const Text(
                          "Doğum Tarihi",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _pickDate(modalSetState),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white),
                              color: const Color(0x26FFFFFF),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDate(_birthDate),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                                const Icon(Icons.calendar_month,
                                    color: Colors.white),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Doğum Saati
                        const Text(
                          "Doğum Saati",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _pickTime(modalSetState),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.white),
                                    color: const Color(0x26FFFFFF),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatTime(_birthTime),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                      const Icon(Icons.access_time,
                                          color: Colors.white),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            TextButton(
                              onPressed: () {
                                modalSetState(() => _birthTime = null);
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Doğum saatini bilmiyorsan yaklaşık saati tahmin etmek yine de işimize yarar 💫",
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                "Bilmiyorum",
                                style: TextStyle(
                                  color: Colors.white,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Doğum Yeri
                        TextField(
                          controller: _birthPlaceController,
                          onChanged: (_) {
                            setState(() {});
                            modalSetState(() {});
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: "Doğum Yeri (Şehir, Ülke)",
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white38),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // İlişki durumu (opsiyonel)
                        const Text(
                          "İlişki Durumun (opsiyonel)",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            "Bekarım",
                            "İlişkim var",
                            "Evliyim",
                            "Durum karmaşık",
                            "Belirtmek istemiyorum",
                          ].map((status) {
                            final selected = _relationshipStatus == status;
                            return ChoiceChip(
                              label: Text(
                                status,
                                style: const TextStyle(
                                  color: Colors.purple, // her zaman mor yazı
                                  fontSize: 12,
                                ),
                              ),
                              selected: selected,
                              selectedColor: Colors.white, // seçiliyken beyaz
                              backgroundColor:
                                  const Color(0x26FFFFFF), // hafif beyaz
                              side: const BorderSide(color: Colors.white),
                              onSelected: (_) {
                                modalSetState(() {
                                  _relationshipStatus = status;
                                });
                                setState(() {});
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.purple,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            onPressed: _saveNatalForm,
                            child: const Text("Haritayı Kaydet ve Devam Et"),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // -------------------------
  // NATAL FORM YARDIMCI FONKSİYONLAR
  // -------------------------

  Future<void> _pickDate(
    void Function(void Function()) modalSetState,
  ) async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: "Doğum Tarihin",
    );
    if (result != null) {
      modalSetState(() => _birthDate = result);
      setState(() {});
    }
  }

  Future<void> _pickTime(
    void Function(void Function()) modalSetState,
  ) async {
    final result = await showTimePicker(
      context: context,
      initialTime: _birthTime ?? const TimeOfDay(hour: 12, minute: 0),
      helpText: "Doğum Saati",
    );
    if (result != null) {
      modalSetState(() => _birthTime = result);
      setState(() {});
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Gün / Ay / Yıl";
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return "Saat / Dakika";
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  Future<void> _saveNatalForm() async {
    if (_birthDate == null || _birthPlaceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Doğum tarihi ve doğum yeri zorunlu ✨")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('natal_name', _nameController.text.trim());
    await prefs.setString(
        'natal_place', _birthPlaceController.text.trim());
    await prefs.setString('natal_rel', _relationshipStatus);

    if (_birthDate != null) {
      await prefs.setString(
          'natal_birth_date', _birthDate!.toIso8601String());
    }

    if (_birthTime != null) {
      await prefs.setInt('natal_birth_hour', _birthTime!.hour);
      await prefs.setInt('natal_birth_minute', _birthTime!.minute);
    } else {
      await prefs.remove('natal_birth_hour');
      await prefs.remove('natal_birth_minute');
    }

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Doğum haritan kaydedildi 💫")),
    );
    setState(() {});
  }

  Future<void> _loadNatalData() async {
    final prefs = await SharedPreferences.getInstance();

    final savedName = prefs.getString('natal_name');
    final savedPlace = prefs.getString('natal_place');
    final savedRel = prefs.getString('natal_rel');
    final savedDateStr = prefs.getString('natal_birth_date');
    final savedHour = prefs.getInt('natal_birth_hour');
    final savedMinute = prefs.getInt('natal_birth_minute');
    final savedProfileImagePath = prefs.getString('profile_image_path');

    setState(() {
      if (savedName != null) _nameController.text = savedName;
      if (savedPlace != null) _birthPlaceController.text = savedPlace;
      if (savedRel != null) _relationshipStatus = savedRel;

      if (savedDateStr != null) {
        final parsed = DateTime.tryParse(savedDateStr);
        if (parsed != null) {
          _birthDate = parsed;
        }
      }

      if (savedHour != null && savedMinute != null) {
        _birthTime = TimeOfDay(hour: savedHour, minute: savedMinute);
      }

      if (savedProfileImagePath != null) {
        _profileImagePath = savedProfileImagePath;
      }
    });
  }
}