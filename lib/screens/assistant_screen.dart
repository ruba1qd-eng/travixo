// المساعد الذكي المحسّن — Travixo Assistant
// يرد على أي سؤال: تحيات، أسئلة عامة، وأسئلة التطبيق
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../l10n/app_localizations.dart';
import '../screens/haptic.dart';
import 'package:provider/provider.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({Key? key}) : super(key: key);
  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _Msg {
  final String text;
  final bool isUser;
  final List<_Action>? actions;
  _Msg({required this.text, required this.isUser, this.actions});
}

class _Action {
  final String label;
  final VoidCallback onTap;
  _Action({required this.label, required this.onTap});
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _msgs = [];
  bool _thinking = false;

  @override
  void initState() {
    super.initState();
    _addBot(
      'مرحباً بك في Travixo! 🧡\n\n'
      'أنا مساعدك الذكي، اسألني عن:\n'
      '🏨 الفنادق\n'
      '🚗 السيارات\n'
      '✈️ الرحلات\n'
      '🗺️ الأماكن\n\n'
      'أو اسألني أي سؤال عام — كيف حالك؟ ما اسمك؟ ما عاصمة اليمن؟ أنا هنا لمساعدتك!',
      actions: [
        _Action(label: '🏨 فنادق', onTap: () => _sendQuick('أين أفضل الفنادق؟')),
        _Action(label: '🚗 سيارات', onTap: () => _sendQuick('ما هي السيارات المتاحة؟')),
        _Action(label: '🗺️ أماكن', onTap: () => _sendQuick('ما هي أفضل الأماكن السياحية؟')),
        _Action(label: '👋 كيف حالك؟', onTap: () => _sendQuick('كيف حالك؟')),
      ],
    );
  }

  void _addBot(String text, {List<_Action>? actions}) {
    setState(() => _msgs.add(_Msg(text: text, isUser: false, actions: actions)));
    _scrollToBottom();
  }

  void _addUser(String text) {
    setState(() => _msgs.add(_Msg(text: text, isUser: true)));
    _scrollToBottom();
  }

  void _sendQuick(String text) {
    _ctrl.text = text;
    _send();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ====== محرك الذكاء المحسّن — يرد على أي سؤال ======
  String _respond(String input) {
    final q = input.toLowerCase().trim();
    if (q.isEmpty) return 'لم أفهم سؤالك، حاول مرة أخرى 😊';

    // 1. التحيات
    if (_matchesAny(q, ['مرحبا', 'مرحباً', 'هلا', 'اهلا', 'السلام', 'سلام', 'هاي', 'hello', 'hi', 'hey', 'صباح', 'مساء', 'مساء الخير', 'صباح الخير'])) {
      return _random([
        'أهلاً وسهلاً! 🧡 كيف أقدر أساعدك اليوم؟',
        'مرحباً بك! أنا Travixo، مساعدك الذكي. اسألني أي شيء!',
        'هلا والله! جاهز لأي سؤال — عن التطبيق أو عن أي شيء ثاني 😊',
        'أهلين! نورت Travixo. وش تبي تعرف اليوم؟',
      ]);
    }

    // 2. كيف حالك
    if (_matchesAny(q, ['كيف حالك', 'كيفك', 'شلونك', 'how are you', 'كيف الحال', 'وش اخبارك', 'اخبارك', 'وش صاير'])) {
      return _random([
        'الحمدلله تمام! 🧡 أنا مساعد ذكي ما عندي مشاعر، لكني جاهز أساعدك 24/7!',
        'ممتاز! شكراً لسؤالك 😊 وش تبي تعرف اليوم؟',
        'أنا بخير ما دام أساعدك! اسألني أي شيء.',
        'تمام التام! جاهز لأي سؤال عن السفر أو أي شيء ثاني.',
      ]);
    }

    // 3. من أنت / اسمك
    if (_matchesAny(q, ['من انت', 'من أنت', 'وش اسمك', 'ما اسمك', 'who are you', 'your name', 'عرفني بنفسك', 'انت مين', 'مين انت', 'ما هو اسمك'])) {
      return 'أنا Travixo 🧡 — مساعدك الذكي للسفر والتنقل في اليمن.\n\n'
          'أساعدك تحجز:\n'
          '🏨 فنادق\n'
          '🚗 سيارات\n'
          '✈️ رحلات\n'
          '🗺️ أماكن سياحية\n\n'
          'وأيضاً أقدر أرد على أسئلتك العامة! جرب اسألني أي شيء.';
    }

    // 4. شكراً
    if (_matchesAny(q, ['شكرا', 'شكراً', 'thanks', 'thank you', 'مشكور', 'يعطيك العافية', 'تسلم', 'الله يسلمك'])) {
      return _random([
        'العفو! 🧡 أنا هنا دائماً لمساعدتك.',
        'ولا يهمك! اسألني أي وقت.',
        'تسلم! هل تحتاج شيء ثاني؟',
        'العفو والله! جاهز لأي سؤال.',
      ]);
    }

    // 5. وقت / تاريخ
    if (_matchesAny(q, ['كم الساعة', 'الوقت', 'what time', 'التاريخ', 'today', 'يوم', 'وش اليوم', 'كم التاريخ'])) {
      final now = DateTime.now();
      final days = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
      return '📅 اليوم: ${days[now.weekday % 7]}\n'
          '📆 التاريخ: ${now.day}/${now.month}/${now.year}\n'
          '🕐 الوقت: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    }

    // 6. طقس
    if (_matchesAny(q, ['طقس', 'حرارة', 'جو', 'weather', 'حار', 'بارد', 'مطر', 'شمس'])) {
      return 'للأسف ما عندي بيانات طقس مباشرة حالياً 🌤️\n\n'
          'لكن أنصحك تتحقق من تطبيق الطقس على جوالك.\n\n'
          'تقدر تسألني عن الفنادق أو الأماكن في أي محافظة!';
    }

    // 7. أسئلة عامة عن اليمن
    if (_matchesAny(q, ['عاصمة اليمن', 'عاصمة', 'yemen capital', 'capital'])) {
      return 'عاصمة اليمن هي صنعاء 🏛️\n\n'
          'مدينة تاريخية رائعة، مصنفة ضمن مواقع التراث العالمي!\n\n'
          'عندي فيها فنادق مميزة:\n'
          '• موفنبيك صنعاء\n'
          '• شيراتون صنعاء\n'
          '• بريميه صنعاء\n\n'
          'تبي أحجز لك؟';
    }
    if (_matchesAny(q, ['سقطرى', 'socotra', 'جزيرة سقطرى'])) {
      return 'سقطرى جزيرة يمنية ساحرة 🌴\n\n'
          'مشهورة بـ:\n'
          '🌳 شجرة دم الأخوين (فريدة في العالم)\n'
          '🏖️ شاطئ قلنسية\n'
          '🦎 حيوانات ونباتات نادرة\n\n'
          'مصنفة ضمن مواقع التراث العالمي!\n\n'
          'تبي تكتشف أماكن فيها؟';
    }
    if (_matchesAny(q, ['اليمن', 'yemen', 'بلد', 'بلدي'])) {
      return 'اليمن 🇾🇪 — أرض الحضارات والتاريخ!\n\n'
          'مشهورة بـ:\n'
          '🏛️ صنعاء القديمة (5000 سنة)\n'
          '🏜️ شبام حضرموت (مانهاتن الصحراء)\n'
          '🌴 سقطرى (جزيرة فريدة)\n'
          '⛰️ جبال فيروزية\n\n'
          'أساعدك تستكشفها! وش تبي تعرف؟';
    }

    // 8. فنادق
    if (_matchesAny(q, ['فندق', 'hotels', 'حجز فندق', 'أين أنام', 'نوم', 'اقامة', 'إقامة'])) {
      return 'عندي 15 فندق حقيقي في 6 محافظات! 🏨\n\n'
          '🏛️ صنعاء: موفنبيك، شيراتون، بريميه\n'
          '🌊 عدن: راديسون بلو، كريسنت\n'
          '⛰️ تعز: السعيد، صنعاء للضيافة\n'
          '🏜️ حضرموت: السيالة، سيئون\n'
          '🌴 الحديدة: كورنيش\n'
          '🌿 إب: خضراء\n\n'
          'الأسعار تبدأ من 20,000 ريال/ليلة\n\n'
          'تبي أحجز لك في أي محافظة؟';
    }

    // 9. سيارات
    if (_matchesAny(q, ['سيارة', 'car', 'تأجير', 'سائق', 'نقل', 'سيارات'])) {
      return 'عندي 12 سيارة للتأجير! 🚗\n\n'
          '💰 اقتصادية: كيا بيكاتو، تويوتا كورولا\n'
          '🛋️ مريحة: كامري، سوناتا\n'
          '🚙 رباعية: لاند كروزر، برادو\n'
          '✨ فاخرة: لكزس LX، مرسيدس S-Class\n\n'
          'الأسعار تبدأ من 27,000 ريال/يوم\n\n'
          'مع سائق أو بدون — وش تبي؟';
    }

    // 10. رحلات
    if (_matchesAny(q, ['رحلة', 'trip', 'جولة', 'tour', 'سفر', 'travel'])) {
      return 'عندي 3 جولات جاهزة! ✈️\n\n'
          '🌊 عطلة رفاهية في عدن\n'
          '🏜️ جولة حضرموت الأسبوعية\n'
          '🏛️ جولة صنعاء التاريخية\n\n'
          'كل جولة فيها برنامج يومي مفصل.\n\n'
          'تبي تفاصيل أي جولة؟';
    }

    // 11. أماكن
    if (_matchesAny(q, ['مكان', 'أماكن', 'places', 'سياحة', 'visit', 'زياره', 'زيارة', 'سياحي'])) {
      return 'عندي 18 مكان سياحي! 🗺️\n\n'
          '🏛️ صنعاء القديمة (يونسكو)\n'
          '🏰 دار الحجر\n'
          '🏜️ شبام حضرموت\n'
          '🌳 شجرة دم الأخوين - سقطرى\n'
          '🌉 جسر شهارة\n'
          '⛰️ جبل برع\n'
          '🏖️ شاطئ قلنسية\n\n'
          'تبي تكتشف أماكن في محافظة معينة؟';
    }

    // 12. محافظات محددة
    if (_matchesAny(q, ['صنعاء', 'sanaa', 'sana', 'صنعا'])) {
      return 'صنعاء عاصمة اليمن 🏛️\n\n'
          'مدينة تاريخية رائعة (5000 سنة)!\n\n'
          'عندي فيها:\n'
          '🏨 4 فنادق: موفنبيك، شيراتون، بريميه، برج السلام\n'
          '🗺️ أماكن: صنعاء القديمة، دار الحجر\n\n'
          'تبي أحجز لك فندق؟';
    }
    if (_matchesAny(q, ['عدن', 'aden'])) {
      return 'عدن المدينة الساحلية! 🌊\n\n'
          'عندي فيها:\n'
          '🏨 فندقان: راديسون بلو، كريسنت\n'
          '✈️ جولة: عطلة رفاهية في عدن\n\n'
          'تبي تفاصيل أكثر؟';
    }
    if (_matchesAny(q, ['تعز', 'taiz'])) {
      return 'تعز مدينة الجبل! ⛰️\n\n'
          'عندي فيها:\n'
          '🏨 فندقان: السعيد، صنعاء للضيافة\n\n'
          'تبي أحجز لك؟';
    }
    if (_matchesAny(q, ['حضرموت', 'hadramaut', 'سيئون', 'seiyun'])) {
      return 'حضرموت وادي دوّان! 🏜️\n\n'
          'عندي فيها:\n'
          '🏨 فندقان: السيالة، سيئون\n'
          '🗺️ مكان: شبام (مانهاتن الصحراء)\n'
          '✈️ جولة أسبوعية\n\n'
          'تبي تكتشفها؟';
    }
    if (_matchesAny(q, ['حديدة', 'hodeidah', 'hudeida'])) {
      return 'الحديدة المدينة الساحلية! 🌊\n\n'
          'عندي فيها:\n'
          '🏨 فندق كورنيش الحديدة\n\n'
          'تبي تفاصيل أكثر؟';
    }
    if (_matchesAny(q, ['إب', 'ib', 'ibb'])) {
      return 'إب مدينة الضباب! 🌿\n\n'
          'عندي فيها:\n'
          '🏨 فندق خضراء إب\n\n'
          'تبي تحجز؟';
    }

    // 13. أسعار / محفظة
    if (_matchesAny(q, ['سعر', 'price', 'كم', 'محفظة', 'wallet', 'رصيد', 'فلوس', 'money'])) {
      return 'محفظتك فيها 100,000 ريال يمني 💰\n'
          '(رصيد ترحيبي تجريبي)\n\n'
          'الأسعار:\n'
          '🏨 فنادق: تبدأ من 20,000 ريال/ليلة\n'
          '🚗 سيارات: تبدأ من 27,000 ريال/يوم\n'
          '✈️ جولات: حسب البرنامج\n\n'
          'تبي تشوف تفاصيل أي خدمة؟';
    }

    // 14. مساعدة عامة
    if (_matchesAny(q, ['مساعدة', 'help', 'ساعدني', 'وش تسوي', 'what can you do', 'ايش تقدر'])) {
      return 'أقدر أساعدك في:\n\n'
          '🏨 حجز الفنادق\n'
          '🚗 تأجير السيارات\n'
          '✈️ الرحلات والجولات\n'
          '🗺️ اكتشاف الأماكن\n'
          '💰 المحفظة والحجوزات\n\n'
          'وأيضاً أرد على أسئلتك العامة!\n\n'
          'جرب اسألني: "كيف حالك؟" أو "ما اسمك؟" أو "أين أفضل فندق؟"';
    }

    // 15. وداع
    if (_matchesAny(q, ['باي', 'bye', 'مع السلامة', 'وداعا', 'see you', 'الى اللقاء', 'إلى اللقاء'])) {
      return _random([
        'مع السلامة! 🧡 أتمنى لك رحلة سعيدة.',
        'باي باي! أنا هنا متى ما احتجتني.',
        'الله معك!回来随时找我 (أرجع متى ما تبي)',
        'في أمان الله! 🌟',
      ]);
    }

    // 16. أسئلة شخصية عامة
    if (_matchesAny(q, ['عمرك', 'كم عمرك', 'age', 'old are you'])) {
      return 'أنا مساعد ذكي، ما عندي عمر بالمعنى البشري! 😊\n\n'
          'لكني أُحدّث باستمرار لأخدمك أفضل.\n\n'
          'اسألني عن السفر أو أي شيء ثاني!';
    }
    if (_matchesAny(q, ['وينك', 'وين انت', 'where are you', 'مكانك'])) {
      return 'أنا موجود في تطبيق Travixo على جوالك! 📱\n\n'
          'جاهز أساعدك في أي وقت.\n\n'
          'وش تبي تعرف؟';
    }
    if (_matchesAny(q, ['تحبني', 'do you love me', 'احبك', 'i love you'])) {
      return 'أنا أحبك كمستخدم Travixo! 🧡\n\n'
          'هدفي أساعدك وتكون رحلتك مميزة.\n\n'
          'اسألني أي شيء!';
    }

    // 17. أسئلة عشوائية / عامة جداً
    if (_matchesAny(q, ['ما هو', 'ما هي', 'what is', 'what are', 'عرفني', 'explain'])) {
      return 'سؤال جميل! 🤔\n\n'
          'حالياً تخصصي هو السفر والتنقل في اليمن.\n\n'
          'جرب تسألني عن:\n'
          '• "أين أفضل فندق في صنعاء؟"\n'
          '• "كم سعر تأجير سيارة؟"\n'
          '• "ما هي أفضل الأماكن السياحية؟"\n\n'
          'أو اسألني: "كيف حالك؟" أو "ما اسمك؟"';
    }

    // Fallback ذكي — لأي شيء آخر
    return _random([
      'فهمت! 😊 حالياً تخصصي هو السفر في اليمن — فنادق، سيارات، رحلات، أماكن.\n\n'
          'لكن اسألني أي سؤال وسأحاول أفيدك!\n\n'
          'جرب: "كيف حالك؟" أو "ما اسمك؟" أو "أين أفضل فندق؟"',
      'سؤال مثير للاهتمام! 🤔\n\n'
          'أنا متخصص في مساعدة المسافرين في اليمن.\n\n'
          'جرب تسألني عن الفنادق أو السيارات أو الأماكن!',
      'ما عندي إجابة دقيقة لهذا السؤال حالياً 😅\n\n'
          'لكن أقدر أساعدك في:\n'
          '🏨 الفنادق\n'
          '🚗 السيارات\n'
          '🗺️ الأماكن\n\n'
          'وش تبي تعرف؟',
    ]);
  }

  bool _matchesAny(String q, List<String> keywords) {
    return keywords.any((k) => q.contains(k));
  }

  String _random(List<String> list) => list[DateTime.now().millisecondsSinceEpoch % list.length];

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    _addUser(text);
    setState(() => _thinking = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() => _thinking = false);
      _addBot(_respond(text));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(l.t('assistant'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _msgs.length + (_thinking ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i == _msgs.length && _thinking) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: TIColors.orangeSoft,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 6, height: 6, child: Container(decoration: BoxDecoration(color: TIColors.orange, shape: BoxShape.circle))),
                          const SizedBox(width: 4),
                          SizedBox(width: 6, height: 6, child: Container(decoration: BoxDecoration(color: TIColors.orange, shape: BoxShape.circle))),
                          const SizedBox(width: 4),
                          SizedBox(width: 6, height: 6, child: Container(decoration: BoxDecoration(color: TIColors.orange, shape: BoxShape.circle))),
                        ],
                      ),
                    ),
                  );
                }
                final m = _msgs[i];
                return Align(
                  alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                    decoration: BoxDecoration(
                      color: m.isUser ? TIColors.orange : TIColors.orangeSoft,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.text,
                          style: TextStyle(
                            color: m.isUser ? Colors.white : TIColors.navy,
                            fontSize: 15,
                          ),
                        ),
                        if (m.actions != null && m.actions!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: m.actions!.map((a) => GestureDetector(
                              onTap: () {
                                Haptics.light();
                                a.onTap();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  a.label,
                                  style: TextStyle(
                                    color: m.isUser ? Colors.white : TIColors.orangeDeep,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            )).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: l.t('ask_anything'),
                      hintStyle: TextStyle(color: TIColors.lightSub, fontSize: 14),
                      filled: true,
                      fillColor: TIColors.lightCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Haptics.light();
                    _send();
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: TIColors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }
}
