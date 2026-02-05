import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math' as Math;

// --- THE SDK IMPORT ---
import 'package:finite_sdk/finite_sdk.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
  ));
  runApp(const FiniteApp());
}

// ---------------------------------------------------------------------------
// 1. APP CONFIG
// ---------------------------------------------------------------------------

class FiniteApp extends StatelessWidget {
  const FiniteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F4F0),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1A1A1A),
          secondary: Color(0xFF8E8E8E),
          surface: Color(0xFFF4F4F0),
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const BootLoader(),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. THE SOLAR BREATH (Bootloader)
// ---------------------------------------------------------------------------

class BootLoader extends StatefulWidget {
  const BootLoader({super.key});
  @override
  State<BootLoader> createState() => _BootLoaderState();
}

class _BootLoaderState extends State<BootLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4000))
      ..repeat(reverse: false);

    _checkUser();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkUser() async {
    final prefs = await SharedPreferences.getInstance();
    final birthMillis = prefs.getInt('birth_date');
    final expectancy = prefs.getInt('expectancy');

    await Future.delayed(const Duration(milliseconds: 2500));

    if (mounted) {
      if (birthMillis != null && expectancy != null) {
        final dob = DateTime.fromMillisecondsSinceEpoch(birthMillis);
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                ArtifactScreen(dob: dob, expectancy: expectancy),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
            transitionDuration: const Duration(milliseconds: 1200),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const GenesisOnboarding()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: SolarBreathPainter(
                progress: _controller.value,
                color: const Color(0xFFFF4500),
              ),
              size: const Size(300, 300),
            );
          },
        ),
      ),
    );
  }
}

class SolarBreathPainter extends CustomPainter {
  final double progress;
  final Color color;

  SolarBreathPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;
    const int rings = 10;
    const double maxRadius = 120.0;

    for (int i = 1; i <= rings; i++) {
      double ratio = 1.0 - (i / rings);
      double dotBaseSize = 4.0 + (ratio * 6.0);
      double opacity = 0.3 + (ratio * 0.7);

      paint.color = color.withOpacity(opacity);

      final double ringRadius = (maxRadius / rings) * i;
      final int dotCount = (i * 6) + 4;

      for (int j = 0; j < dotCount; j++) {
        final double theta = (2 * Math.pi / dotCount) * j;
        double waveOffset = i * 0.2;
        double angle = (progress * 2 * Math.pi) - waveOffset;
        double flipFactor = Math.cos(angle);

        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(center.dx + ringRadius * Math.cos(theta),
                center.dy + ringRadius * Math.sin(theta)),
            width: dotBaseSize * flipFactor.abs(),
            height: dotBaseSize,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant SolarBreathPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ---------------------------------------------------------------------------
// 3. ONBOARDING
// ---------------------------------------------------------------------------

class GenesisOnboarding extends StatefulWidget {
  const GenesisOnboarding({super.key});
  @override
  State<GenesisOnboarding> createState() => _GenesisOnboardingState();
}

class _GenesisOnboardingState extends State<GenesisOnboarding> {
  int _step = 0;
  DateTime _selectedDate = DateTime(2000, 1, 1);
  int _expectancy = 80;

  void _next() async {
    if (_step == 0) {
      setState(() => _step = 1);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('birth_date', _selectedDate.millisecondsSinceEpoch);
      await prefs.setInt('expectancy', _expectancy);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                ArtifactScreen(dob: _selectedDate, expectancy: _expectancy),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
            transitionDuration: const Duration(milliseconds: 2000),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F0),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: Text(
                _step == 0
                    ? "When did your time begin?"
                    : "How long do you hope to see?",
                key: ValueKey(_step),
                style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A1A)),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 250,
              child: _step == 0
                  ? CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: _selectedDate,
                      maximumDate: DateTime.now(),
                      onDateTimeChanged: (d) =>
                          setState(() => _selectedDate = d),
                    )
                  : CupertinoPicker(
                      itemExtent: 40,
                      scrollController:
                          FixedExtentScrollController(initialItem: 80 - 1),
                      onSelectedItemChanged: (i) {
                        HapticFeedback.selectionClick();
                        setState(() => _expectancy = i + 1);
                      },
                      children: List.generate(
                        120,
                        (index) => Center(
                            child: Text("${index + 1}",
                                style: GoogleFonts.inter(
                                    fontSize: 24,
                                    color: const Color(0xFF1A1A1A)))),
                      ),
                    ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  child: Text(_step == 0 ? "NEXT" : "MATERIALIZE",
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. THE ARTIFACT SCREEN (Main Grid)
// ---------------------------------------------------------------------------

enum LifeScale { weeks, months, years }

class ArtifactScreen extends StatefulWidget {
  final DateTime dob;
  final int expectancy;

  const ArtifactScreen(
      {required this.dob, required this.expectancy, super.key});

  @override
  State<ArtifactScreen> createState() => _ArtifactScreenState();
}

class _ArtifactScreenState extends State<ArtifactScreen> {
  LifeScale _currentScale = LifeScale.weeks;
  late bool _isMoonlight;

  late DateTime _dob;
  late int _expectancy;

  List<Memory> _allMemories = [];
  Map<int, List<Memory>> _memoryCache = {};

  List<Goal> _allGoals = [];
  Map<int, List<Goal>> _goalCache = {};

  final List<Color> _palette = [
    const Color(0xFFFF4500),
    const Color(0xFF7393B3),
    const Color(0xFF556B2F),
    const Color(0xFFE2A76F),
    const Color(0xFF4A4A4A),
    const Color(0xFFD4AF37),
  ];

  @override
  void initState() {
    super.initState();
    _dob = widget.dob;
    _expectancy = widget.expectancy;

    final now = DateTime.now();
    _isMoonlight = now.hour >= 20 || now.hour < 6;
    _refreshData();
  }

  void _toggleMoonlight() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isMoonlight = !_isMoonlight;
    });
  }

  Future<void> _refreshData() async {
    final memData = await DatabaseHelper.instance.readAllMemories();
    final goalData = await DatabaseHelper.instance.readAllGoals();
    if (mounted) {
      setState(() {
        _allMemories = memData;
        _allGoals = goalData;
      });
      _recalculateCache();
    }
  }

  // --- RECALIBRATE ---
  void _showRecalibrationSheet() {
    DateTime tempDob = _dob;
    int tempExp = _expectancy;

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFFF4F4F0),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (context) {
          return StatefulBuilder(builder: (context, setSheetState) {
            return Container(
              height: 500,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Center(child: FiniteLogo(size: 80)),
                  const SizedBox(height: 20),
                  Text("Recalibrate",
                      style: GoogleFonts.fraunces(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),
                  Text("Origin Date",
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                  SizedBox(
                    height: 120,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: tempDob,
                      maximumDate: DateTime.now(),
                      onDateTimeChanged: (d) => tempDob = d,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text("Horizon (Years): $tempExp",
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                  Slider(
                    value: tempExp.toDouble(),
                    min: 10,
                    max: 120,
                    divisions: 110,
                    activeColor: const Color(0xFF1A1A1A),
                    onChanged: (v) => setSheetState(() => tempExp = v.toInt()),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A1A)),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setInt(
                            'birth_date', tempDob.millisecondsSinceEpoch);
                        await prefs.setInt('expectancy', tempExp);

                        setState(() {
                          _dob = tempDob;
                          _expectancy = tempExp;
                        });

                        _recalculateCache();
                        Navigator.pop(context);
                      },
                      child: const Text("CONFIRM CHANGE"),
                    ),
                  )
                ],
              ),
            );
          });
        });
  }

  void _recalculateCache() {
    final Map<int, List<Memory>> tempMemMap = {};
    final Map<int, List<Goal>> tempGoalMap = {};
    final dob = _dob;

    int getIndex(DateTime date) {
      if (_currentScale == LifeScale.weeks) {
        return date.difference(dob).inDays ~/ 7;
      } else if (_currentScale == LifeScale.months) {
        return (date.year - dob.year) * 12 + (date.month - dob.month);
      } else {
        return date.year - dob.year;
      }
    }

    for (var mem in _allMemories) {
      final date = DateTime.fromMillisecondsSinceEpoch(mem.dateMillis);
      final index = getIndex(date);
      if (index >= 0) {
        if (tempMemMap[index] == null) tempMemMap[index] = [];
        tempMemMap[index]!.add(mem);
      }
    }

    for (var goal in _allGoals) {
      final date = DateTime.fromMillisecondsSinceEpoch(goal.dateMillis);
      final index = getIndex(date);
      if (index >= 0) {
        if (tempGoalMap[index] == null) tempGoalMap[index] = [];
        tempGoalMap[index]!.add(goal);
      }
    }

    setState(() {
      _memoryCache = tempMemMap;
      _goalCache = tempGoalMap;
    });
  }

  void _handleDotTap(List<Memory> memories) {
    if (memories.length == 1) {
      _openCanvas(memories.first);
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => ClusterSheet(
            memories: memories,
            palette: _palette,
            onSelect: (mem) {
              Navigator.pop(context);
              _openCanvas(mem);
            }),
      );
    }
  }

  void _handleGoalDotTap(List<Goal> goals) {
    if (goals.length == 1) {
      _openGoalCanvas(goals.first);
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => GoalClusterSheet(
            goals: goals,
            palette: _palette,
            onSelect: (goal) {
              Navigator.pop(context);
              _openGoalCanvas(goal);
            }),
      );
    }
  }

  void _openCanvas(Memory? memory, [DateTime? dateOverride]) async {
    final date =
        dateOverride ?? DateTime.fromMillisecondsSinceEpoch(memory!.dateMillis);

    // Navigate to canvas and wait for result
    final bool? shouldRefresh = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => MemoryCanvas(
            initialDate: date, initialMemory: memory, palette: _palette),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );

    // Always refresh when coming back, in case of save OR delete
    _refreshData();
  }

  void _openGoalCanvas(Goal? goal, [DateTime? dateOverride]) async {
    final date =
        dateOverride ?? DateTime.fromMillisecondsSinceEpoch(goal!.dateMillis);

    final bool? shouldRefresh = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => GoalCanvas(
            initialDate: date, initialGoal: goal, palette: _palette),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );

    _refreshData();
  }

  Color _getDominantColor(List<Memory> memories) {
    if (memories.isEmpty) return Colors.transparent;
    if (memories.length == 1) return _palette[memories.first.colorIndex];

    final frequency = <int, int>{};
    for (var m in memories) {
      frequency[m.colorIndex] = (frequency[m.colorIndex] ?? 0) + 1;
    }
    final dominantEntry = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _palette[dominantEntry.first.key];
  }

  Color _getDominantGoalColor(List<Goal> goals) {
    if (goals.isEmpty) return Colors.transparent;
    if (goals.length == 1) return _palette[goals.first.colorIndex];

    final frequency = <int, int>{};
    for (var g in goals) {
      frequency[g.colorIndex] = (frequency[g.colorIndex] ?? 0) + 1;
    }
    final dominantEntry = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _palette[dominantEntry.first.key];
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final Color bgColor =
        _isMoonlight ? const Color(0xFF121212) : const Color(0xFFF4F4F0);
    final Color textColor =
        _isMoonlight ? const Color(0xFFE0E0E0) : const Color(0xFF1A1A1A);
    final Color stoneColor =
        _isMoonlight ? const Color(0xFF333333) : const Color(0xFFD1D1CB);
    final Color fogColor =
        _isMoonlight ? const Color(0xFF1A1A1A) : const Color(0xFFE5E5E0);
    final Color accentColor = const Color(0xFFFF4500);

    int totalUnits, livedUnits;
    String label;
    int crossAxisCount;
    double dotSize;

    switch (_currentScale) {
      case LifeScale.weeks:
        totalUnits = _expectancy * 52;
        livedUnits = now.difference(_dob).inDays ~/ 7;
        label = "Week $livedUnits / $totalUnits";
        crossAxisCount = 22;
        dotSize = 10.0;
        break;
      case LifeScale.months:
        totalUnits = _expectancy * 12;
        livedUnits = (now.year - _dob.year) * 12 + (now.month - _dob.month);
        label = "Month $livedUnits / $totalUnits";
        crossAxisCount = 12;
        dotSize = 20.0;
        break;
      case LifeScale.years:
        totalUnits = _expectancy;
        livedUnits = now.year - _dob.year;
        label = "Year $livedUnits / $totalUnits";
        crossAxisCount = 10;
        dotSize = 28.0;
        break;
    }

    final dailyQuote = QuoteVault.getDailyQuote();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            _isMoonlight ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: _dob,
              lastDate: DateTime.now(),
              builder: (context, child) => Theme(
                data: ThemeData.light().copyWith(
                  colorScheme:
                      const ColorScheme.light(primary: Color(0xFF1A1A1A)),
                ),
                child: child!,
              ),
            );
            if (picked != null) _openCanvas(null, picked);
          },
          backgroundColor: accentColor,
          child: const Icon(CupertinoIcons.add, color: Colors.white),
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: _isMoonlight
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _isMoonlight
                              ? []
                              : [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4))
                                ]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dailyQuote.text,
                            style: GoogleFonts.fraunces(
                              fontSize: 18,
                              height: 1.4,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "— ${dailyQuote.author}",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: _isMoonlight
                                  ? Colors.grey
                                  : const Color(0xFF8E8E8E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: _toggleMoonlight,
                          child: ThemeToggle(isMoonlight: _isMoonlight),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: _isMoonlight
                                ? const Color(0xFF1E1E1E)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              _scaleBtn("W", LifeScale.weeks, _isMoonlight),
                              _scaleBtn("M", LifeScale.months, _isMoonlight),
                              _scaleBtn("Y", LifeScale.years, _isMoonlight),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _showRecalibrationSheet,
                      child: Row(
                        children: [
                          _PulsingDot(size: 8, color: accentColor),
                          const SizedBox(width: 12),
                          Text(
                            label,
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                              letterSpacing: -1.0,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.settings,
                              size: 16, color: textColor.withOpacity(0.3))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  childAspectRatio: 1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final memories = _memoryCache[index];
                    final isPresent = index == livedUnits;

                    if (isPresent) {
                      Color dotColor = accentColor;
                      if (memories != null && memories.isNotEmpty) {
                        dotColor = _getDominantColor(memories);
                      }
                      return GestureDetector(
                        onTap: () {
                          if (memories != null && memories.isNotEmpty) {
                            _handleDotTap(memories);
                          } else {
                            _openCanvas(null, DateTime.now());
                          }
                        },
                        child: Center(
                          child: _PulsingDot(size: dotSize, color: dotColor),
                        ),
                      );
                    }

                    if (memories != null && memories.isNotEmpty) {
                      final dominantColor = memories.length == 1
                          ? _palette[memories.first.colorIndex]
                          : _getDominantColor(memories);

                      return GestureDetector(
                        onTap: () => _handleDotTap(memories),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dominantColor,
                            border: memories.length > 1
                                ? Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 1.5)
                                : null,
                          ),
                        ),
                      );
                    }

                    if (index < livedUnits) {
                      return _Dot(
                          type: _DotType.past,
                          color: stoneColor,
                          currentSize: dotSize);
                    }

                    // FUTURE / GOALS
                    final goals = _goalCache[index];
                    if (goals != null && goals.isNotEmpty) {
                      final dominantColor = goals.length == 1
                          ? _palette[goals.first.colorIndex]
                          : _getDominantGoalColor(goals);

                      return GestureDetector(
                        onTap: () => _handleGoalDotTap(goals),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dominantColor,
                            border: goals.length > 1
                                ? Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 1.5)
                                : null,
                          ),
                        ),
                      );
                    }

                    Color futureColor = fogColor;
                    if (_isMoonlight) futureColor = Colors.transparent;

                    return GestureDetector(
                        onTap: () {
                          // Tap on empty future dot -> Create Goal
                          _openGoalCanvas(null, DateTime.now()); // Date will be adjusted by user or we could calculate roughly
                        },
                        child: _Dot(
                            type: _DotType.future,
                            color: futureColor,
                            currentSize: dotSize));
                  },
                  childCount: totalUnits,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _scaleBtn(String text, LifeScale scale, bool isMoonlight) {
    final bool isSelected = _currentScale == scale;
    final Color activeColor = const Color(0xFF1A1A1A);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _currentScale = scale);
        _recalculateCache();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isMoonlight ? Colors.white : activeColor)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? (isMoonlight ? Colors.black : Colors.white)
                : Colors.grey,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. MEMORY CANVAS (Editor with Delete)
// ---------------------------------------------------------------------------

class MemoryCanvas extends StatefulWidget {
  final DateTime initialDate;
  final Memory? initialMemory;
  final List<Color> palette;

  const MemoryCanvas({
    required this.initialDate,
    required this.initialMemory,
    required this.palette,
    super.key,
  });

  @override
  State<MemoryCanvas> createState() => _MemoryCanvasState();
}

class _MemoryCanvasState extends State<MemoryCanvas> {
  late DateTime _date;
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late int _colorIndex;
  Timer? _debounce;
  int? _memoryId;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
    _memoryId = widget.initialMemory?.id;
    _titleCtrl = TextEditingController(text: widget.initialMemory?.title ?? "");
    _descCtrl =
        TextEditingController(text: widget.initialMemory?.description ?? "");
    _colorIndex = widget.initialMemory?.colorIndex ?? 0;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), _saveMemory);
    setState(() {});
  }

  Future<void> _changeDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1A1A1A)),
        ),
        child: child!,
      ),
    );

    if (picked != null && picked != _date) {
      setState(() => _date = picked);
      _saveMemory();
    }
  }

  Future<void> _saveMemory() async {
    if (_titleCtrl.text.isEmpty && _descCtrl.text.isEmpty) return;

    final mem = Memory(
      id: _memoryId,
      dateMillis: _date.millisecondsSinceEpoch,
      colorIndex: _colorIndex,
      title: _titleCtrl.text,
      description: _descCtrl.text,
    );

    if (_memoryId == null) {
      final newMem = await DatabaseHelper.instance.create(mem);
      setState(() => _memoryId = newMem.id);
    } else {
      await DatabaseHelper.instance.update(mem);
    }
  }

  // --- NEW DELETE LOGIC ---
  Future<void> _deleteMemory() async {
    if (_memoryId == null) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Forget this memory?", style: GoogleFonts.fraunces()),
        content: Text(
          "This action cannot be undone.",
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Forget", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.delete(_memoryId!);
      // Ensure we pop back and tell the previous screen we changed something
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFFAFAFA);
    final textColor = const Color(0xFF1A1A1A);
    final accentColor = widget.palette[_colorIndex];

    return Hero(
      tag: 'mem_${_memoryId ?? "new"}',
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(CupertinoIcons.chevron_down,
                color: textColor.withOpacity(0.5)),
            onPressed: () => Navigator.pop(context),
          ),
          title: GestureDetector(
            onTap: _changeDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentColor.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('MMMM d, yyyy').format(_date),
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: accentColor),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.edit,
                      size: 12, color: accentColor.withOpacity(0.5))
                ],
              ),
            ),
          ),
          centerTitle: true,
          // DELETE BUTTON ADDED HERE
          actions: [
            if (_memoryId != null)
              IconButton(
                icon: const Icon(CupertinoIcons.trash, size: 20),
                color: Colors.red.withOpacity(0.7),
                onPressed: _deleteMemory,
              ),
            const SizedBox(width: 16),
          ],
        ),
        body: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 32),
            children: [
              const SizedBox(height: 20),
              // Color Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.palette.length, (index) {
                  final isSelected = _colorIndex == index;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _colorIndex = index);
                      _saveMemory();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: isSelected ? 24 : 16,
                      height: isSelected ? 24 : 16,
                      decoration: BoxDecoration(
                        color: widget.palette[index],
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: textColor, width: 2)
                            : null,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),

              TextField(
                controller: _titleCtrl,
                onChanged: (_) => _onChanged(),
                maxLines: null,
                style: GoogleFonts.fraunces(
                    fontSize: 32,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: textColor),
                decoration: InputDecoration(
                  hintText: "Untitled.",
                  hintStyle:
                      GoogleFonts.fraunces(color: textColor.withOpacity(0.2)),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _descCtrl,
                onChanged: (_) => _onChanged(),
                maxLines: null,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  height: 1.6,
                  color: textColor.withOpacity(0.8),
                ),
                decoration: InputDecoration(
                  hintText: "Start writing...",
                  hintStyle:
                      GoogleFonts.inter(color: textColor.withOpacity(0.2)),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. CLUSTER SHEET
// ---------------------------------------------------------------------------

class ClusterSheet extends StatelessWidget {
  final List<Memory> memories;
  final List<Color> palette;
  final Function(Memory) onSelect;

  const ClusterSheet(
      {required this.memories,
      required this.palette,
      required this.onSelect,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF4F4F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Memories in this cycle",
                style: GoogleFonts.fraunces(
                    fontSize: 20, color: const Color(0xFF1A1A1A)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(12)),
                child: Text("${memories.length}",
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 20),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: memories.length,
              separatorBuilder: (_, __) => const Divider(height: 20),
              itemBuilder: (context, index) {
                final mem = memories[index];
                final date =
                    DateTime.fromMillisecondsSinceEpoch(mem.dateMillis);

                return InkWell(
                  onTap: () => onSelect(mem),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: palette[mem.colorIndex]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mem.title.isEmpty ? "Untitled" : mem.title,
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              DateFormat('MMM d, yyyy').format(date),
                              style: GoogleFonts.inter(
                                  color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(CupertinoIcons.chevron_right,
                          size: 16, color: Colors.grey)
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 7. OPTIMIZED ATOMS & VISUALS
// ---------------------------------------------------------------------------

class ThemeToggle extends StatelessWidget {
  final bool isMoonlight;
  const ThemeToggle({required this.isMoonlight, super.key});

  @override
  Widget build(BuildContext context) {
    final Color dayTrack = const Color(0xFFB0E0E6);
    final Color nightTrack = const Color(0xFF2C2C2C);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      width: 64,
      height: 32,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
          color: isMoonlight ? nightTrack : dayTrack,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ]),
      child: Stack(
        children: [
          if (isMoonlight) ...[
            const Positioned(left: 6, top: 8, child: _TinyStar(size: 2)),
            const Positioned(left: 14, top: 16, child: _TinyStar(size: 3)),
            const Positioned(left: 20, top: 6, child: _TinyStar(size: 2)),
          ] else ...[
            const Positioned(right: 8, top: 8, child: _TinyCloud()),
            const Positioned(right: 18, top: 16, child: _TinyCloud()),
          ],
          AnimatedAlign(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            alignment:
                isMoonlight ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isMoonlight
                    ? const Color(0xFFE0E0E0)
                    : const Color(0xFFFFD700),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  )
                ],
              ),
              child: isMoonlight
                  ? Stack(
                      children: [
                        Positioned(
                            top: 6,
                            right: 8,
                            child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    shape: BoxShape.circle))),
                        Positioned(
                            bottom: 8,
                            left: 6,
                            child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    shape: BoxShape.circle))),
                      ],
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyStar extends StatelessWidget {
  final double size;
  const _TinyStar({required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration:
          const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    );
  }
}

class _TinyCloud extends StatelessWidget {
  const _TinyCloud();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6), shape: BoxShape.circle),
    );
  }
}

enum _DotType { past, present, future }

class _Dot extends StatelessWidget {
  final _DotType type;
  final Color color;
  final double currentSize;

  const _Dot({
    super.key,
    required this.type,
    required this.color,
    required this.currentSize,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case _DotType.past:
        return Center(
          child: DecoratedBox(
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            child: SizedBox(width: currentSize, height: currentSize),
          ),
        );
      case _DotType.future:
        return Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: SizedBox(width: currentSize, height: currentSize),
          ),
        );
      case _DotType.present:
        return Center(child: _PulsingDot(size: currentSize, color: color));
    }
  }
}

class _PulsingDot extends StatefulWidget {
  final double size;
  final Color color;
  const _PulsingDot({required this.size, required this.color});
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500))
      ..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                  color: widget.color.withOpacity(0.4),
                  blurRadius: 6,
                  spreadRadius: 1)
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 8. GOAL CANVAS (Duplicate of MemoryCanvas for Goals)
// ---------------------------------------------------------------------------

class GoalCanvas extends StatefulWidget {
  final DateTime initialDate;
  final Goal? initialGoal;
  final List<Color> palette;

  const GoalCanvas({
    required this.initialDate,
    required this.initialGoal,
    required this.palette,
    super.key,
  });

  @override
  State<GoalCanvas> createState() => _GoalCanvasState();
}

class _GoalCanvasState extends State<GoalCanvas> {
  late DateTime _date;
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late int _colorIndex;
  Timer? _debounce;
  int? _goalId;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
    _goalId = widget.initialGoal?.id;
    _titleCtrl = TextEditingController(text: widget.initialGoal?.title ?? "");
    _descCtrl =
        TextEditingController(text: widget.initialGoal?.description ?? "");
    _colorIndex = widget.initialGoal?.colorIndex ?? 0;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), _saveGoal);
    setState(() {});
  }

  Future<void> _changeDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(), // Goals are for future (or today)
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1A1A1A)),
        ),
        child: child!,
      ),
    );

    if (picked != null && picked != _date) {
      setState(() => _date = picked);
      _saveGoal();
    }
  }

  Future<void> _saveGoal() async {
    if (_titleCtrl.text.isEmpty && _descCtrl.text.isEmpty) return;

    final goal = Goal(
      id: _goalId,
      dateMillis: _date.millisecondsSinceEpoch,
      colorIndex: _colorIndex,
      title: _titleCtrl.text,
      description: _descCtrl.text,
    );

    if (_goalId == null) {
      final newGoal = await DatabaseHelper.instance.createGoal(goal);
      setState(() => _goalId = newGoal.id);
    } else {
      await DatabaseHelper.instance.updateGoal(goal);
    }
  }

  // --- DELETE LOGIC ---
  Future<void> _deleteGoal() async {
    if (_goalId == null) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Forget this goal?", style: GoogleFonts.fraunces()),
        content: Text(
          "This action cannot be undone.",
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Forget", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteGoal(_goalId!);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFFAFAFA);
    final textColor = const Color(0xFF1A1A1A);
    final accentColor = widget.palette[_colorIndex];

    return Hero(
      tag: 'goal_${_goalId ?? "new"}',
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(CupertinoIcons.chevron_down,
                color: textColor.withOpacity(0.5)),
            onPressed: () => Navigator.pop(context),
          ),
          title: GestureDetector(
            onTap: _changeDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentColor.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('MMMM d, yyyy').format(_date),
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: accentColor),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.edit,
                      size: 12, color: accentColor.withOpacity(0.5))
                ],
              ),
            ),
          ),
          centerTitle: true,
          actions: [
            if (_goalId != null)
              IconButton(
                icon: const Icon(CupertinoIcons.trash, size: 20),
                color: Colors.red.withOpacity(0.7),
                onPressed: _deleteGoal,
              ),
            const SizedBox(width: 16),
          ],
        ),
        body: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 32),
            children: [
              const SizedBox(height: 20),
              // Color Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.palette.length, (index) {
                  final isSelected = _colorIndex == index;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _colorIndex = index);
                      _saveGoal();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: isSelected ? 24 : 16,
                      height: isSelected ? 24 : 16,
                      decoration: BoxDecoration(
                        color: widget.palette[index],
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: textColor, width: 2)
                            : null,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),

              TextField(
                controller: _titleCtrl,
                onChanged: (_) => _onChanged(),
                maxLines: null,
                style: GoogleFonts.fraunces(
                    fontSize: 32,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: textColor),
                decoration: InputDecoration(
                  hintText: "Untitled Goal.",
                  hintStyle:
                      GoogleFonts.fraunces(color: textColor.withOpacity(0.2)),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _descCtrl,
                onChanged: (_) => _onChanged(),
                maxLines: null,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  height: 1.6,
                  color: textColor.withOpacity(0.8),
                ),
                decoration: InputDecoration(
                  hintText: "What do you hope to achieve...",
                  hintStyle:
                      GoogleFonts.inter(color: textColor.withOpacity(0.2)),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class GoalClusterSheet extends StatelessWidget {
  final List<Goal> goals;
  final List<Color> palette;
  final Function(Goal) onSelect;

  const GoalClusterSheet(
      {required this.goals,
      required this.palette,
      required this.onSelect,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF4F4F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Goals for this cycle",
                style: GoogleFonts.fraunces(
                    fontSize: 20, color: const Color(0xFF1A1A1A)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(12)),
                child: Text("${goals.length}",
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 20),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: goals.length,
              separatorBuilder: (_, __) => const Divider(height: 20),
              itemBuilder: (context, index) {
                final goal = goals[index];
                final date =
                    DateTime.fromMillisecondsSinceEpoch(goal.dateMillis);

                return InkWell(
                  onTap: () => onSelect(goal),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: palette[goal.colorIndex]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal.title.isEmpty ? "Untitled" : goal.title,
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              DateFormat('MMM d, yyyy').format(date),
                              style: GoogleFonts.inter(
                                  color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(CupertinoIcons.chevron_right,
                          size: 16, color: Colors.grey)
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
