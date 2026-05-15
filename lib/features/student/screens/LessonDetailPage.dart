import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/Lesson.dart';
import '../../../core/constants/colors.dart' as _C;

class LessonDetailPage extends StatefulWidget {
  final List<Lesson> lessons;
  final int initialIndex;
  final Future<Lesson?> Function(int lessonId) fetchLessonDetails;
  final Future<void> Function(int lessonId) markLessonCompleted;
  final Set<int> initialCompletedIds;

  const LessonDetailPage({
    Key? key,
    required this.lessons,
    required this.initialIndex,
    required this.fetchLessonDetails,
    required this.markLessonCompleted,
    this.initialCompletedIds = const {},
  }) : super(key: key);

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  late PageController _pageController;
  late int _currentIndex;

  // Cache des détails déjà chargés  lessonId → Lesson
  final Map<int, Lesson> _detailsCache = {};
  final Map<int, bool> _loadingMap = {};
  final Map<int, String?> _errorMap = {};

  // Leçons marquées complétées dans cette session
  final Set<int> _completedIds = {};
  final Map<int, bool> _markingMap = {}; // lessonId → en cours de marquage

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Pré-remplir depuis les IDs déjà connus (passés par CourseLessonsPage)
    _completedIds.addAll(widget.initialCompletedIds);

    // Fusionner aussi les progresses embarquées dans les leçons
    for (final lesson in widget.lessons) {
      if (lesson.id != null &&
          lesson.progresses != null &&
          lesson.progresses!.any((p) => p.completed == true)) {
        _completedIds.add(lesson.id!);
      }
    }

    _loadDetails(_currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails(int index) async {
    final lesson = widget.lessons[index];
    final id = lesson.id;
    if (id == null) return;
    if (_detailsCache.containsKey(id)) return;
    if (_loadingMap[id] == true) return;

    setState(() {
      _loadingMap[id] = true;
      _errorMap[id] = null;
    });

    final detail = await widget.fetchLessonDetails(id);

    if (!mounted) return;
    setState(() {
      _loadingMap[id] = false;
      if (detail != null) {
        _detailsCache[id] = detail;
      } else {
        _errorMap[id] = 'Erreur lors du chargement des détails.';
      }
    });
  }

  Future<void> _markCompleted(int lessonId) async {
    if (_completedIds.contains(lessonId)) return;
    if (_markingMap[lessonId] == true) return;

    setState(() => _markingMap[lessonId] = true);

    try {
      await widget.markLessonCompleted(lessonId);
      if (!mounted) return;
      setState(() {
        _completedIds.add(lessonId);
        _markingMap[lessonId] = false;
      });
      _showCompletionToast();
    } catch (_) {
      if (!mounted) return;
      setState(() => _markingMap[lessonId] = false);
    }
  }

  void _showCompletionToast() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 90),
        duration: const Duration(seconds: 2),
        backgroundColor: _C.Colors.teal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text(
              'Leçon marquée comme terminée !',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    _loadDetails(index);
    // Précharger la suivante
    if (index + 1 < widget.lessons.length) _loadDetails(index + 1);
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.lessons.length;

    return Scaffold(
      backgroundColor: _C.Colors.pageBg,
      body: Stack(
        children: [
          // ── PageView ──────────────────────────────────────────────
          PageView.builder(
            controller: _pageController,
            itemCount: total,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final lesson = widget.lessons[index];
              final int? id = lesson.id;
              final isLoading = id != null && _loadingMap[id] == true;
              final error = id != null ? _errorMap[id] : null;
              final detail = id != null ? _detailsCache[id] : null;

              final bool isCompleted = id != null && _completedIds.contains(id);
              final bool isMarking = id != null && _markingMap[id] == true;

              return _LessonPage(
                lesson: detail ?? lesson,
                isLoading: isLoading,
                error: error,
                index: index,
                total: total,
                isCompleted: isCompleted,
                isMarking: isMarking,
                onRetry: () => _loadDetails(index),
                onMarkCompleted: id != null && !isCompleted
                    ? () => _markCompleted(id)
                    : null,
              );
            },
          ),

          // ── Top overlay: back + progress ─────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context, Set<int>.from(_completedIds)),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 18,
                        color: _C.Colors.bodyText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Progress pills
                  Expanded(
                    child: _ProgressPills(
                      total: total,
                      current: _currentIndex,
                      completedIds: _completedIds,
                      lessons: widget.lessons,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Counter
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.06),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      '${_currentIndex + 1}/$total',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _C.Colors.bodyText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom nav arrows ─────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomNav(
                currentIndex: _currentIndex,
                total: total,
                currentLessonId: widget.lessons[_currentIndex].id,
                completedIds: _completedIds,
                isCurrentCompleted: widget.lessons[_currentIndex].id != null &&
                    _completedIds.contains(widget.lessons[_currentIndex].id),
                isMarking: widget.lessons[_currentIndex].id != null &&
                    _markingMap[widget.lessons[_currentIndex].id] == true,
                onMarkCompleted: widget.lessons[_currentIndex].id != null &&
                        !_completedIds
                            .contains(widget.lessons[_currentIndex].id)
                    ? () => _markCompleted(widget.lessons[_currentIndex].id!)
                    : null,
                onPrev: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                ),
                onNext: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                ),
              ),
          ),
        ],
      ),
    );
  }
}

// ── Single lesson page content ───────────────────────────────────────────────

class _LessonPage extends StatelessWidget {
  final Lesson lesson;
  final bool isLoading;
  final String? error;
  final int index;
  final int total;
  final bool isCompleted;
  final bool isMarking;
  final VoidCallback onRetry;
  final VoidCallback? onMarkCompleted;

  const _LessonPage({
    required this.lesson,
    required this.isLoading,
    required this.error,
    required this.index,
    required this.total,
    required this.isCompleted,
    required this.isMarking,
    required this.onRetry,
    this.onMarkCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Video / thumbnail area ──────────────────────────────
          _VideoArea(videoUrl: lesson.videoUrl),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lesson number chip + completed badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _C.Colors.indigo.withOpacity(.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Leçon ${index + 1} sur $total',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _C.Colors.indigoText,
                        ),
                      ),
                    ),
                    if (isCompleted) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _C.Colors.teal.withOpacity(.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded,
                                size: 11, color: _C.Colors.tealText),
                            const SizedBox(width: 4),
                            Text(
                              'Terminée',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _C.Colors.tealText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  lesson.titre,
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 22,
                    color: _C.Colors.bodyText,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 20),

                // Content / loading / error
                if (isLoading)
                  const _ContentSkeleton()
                else if (error != null)
                  _ErrorBlock(message: error!, onRetry: onRetry)
                else
                  _LessonContent(lesson: lesson),

                // ── Mark as completed button ────────────────────
                const SizedBox(height: 8),
                _MarkCompletedButton(
                  isCompleted: isCompleted,
                  isMarking: isMarking,
                  onTap: onMarkCompleted,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Video area ───────────────────────────────────────────────────────────────

class _VideoArea extends StatelessWidget {
  final String? videoUrl;
  const _VideoArea({this.videoUrl});

  @override
  Widget build(BuildContext context) {
    final hasVideo = videoUrl != null && videoUrl!.isNotEmpty;

    return Container(
      height: 220,
      width: double.infinity,
      color: _C.Colors.navy,
      child: hasVideo
          ? Stack(
              alignment: Alignment.center,
              children: [
                // Placeholder thumbnail tint
                Container(color: _C.Colors.navy.withOpacity(.85)),
                // Play button
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.15),
                    border: Border.all(
                        color: Colors.white.withOpacity(.4), width: 2),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                // URL label at bottom
                Positioned(
                  bottom: 12,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.videocam_rounded,
                            color: Colors.white70, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            videoUrl!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.article_rounded,
                      color: Colors.white.withOpacity(.3), size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Leçon texte',
                    style: TextStyle(
                      color: Colors.white.withOpacity(.4),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ── Lesson content ────────────────────────────────────────────────────────────

class _LessonContent extends StatelessWidget {
  final Lesson lesson;
  const _LessonContent({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main content
        if (lesson.contenu != null && lesson.contenu!.isNotEmpty) ...[
          Text(
            'Contenu',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _C.Colors.bodyText,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            lesson.contenu!,
            style: const TextStyle(
              fontSize: 14,
              height: 1.7,
              color: _C.Colors.subText,
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Documents
        if (lesson.documents != null && lesson.documents!.isNotEmpty) ...[
          _SectionTitle(title: 'Documents', icon: Icons.attach_file_rounded),
          const SizedBox(height: 10),
          ...lesson.documents!.map((doc) => _DocumentTile(doc: doc)),
          const SizedBox(height: 24),
        ],

        // Quiz
        if (lesson.quiz != null) ...[
          _SectionTitle(title: 'Quiz', icon: Icons.quiz_rounded),
          const SizedBox(height: 10),
          _QuizCard(quiz: lesson.quiz!),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: _C.Colors.indigoText),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _C.Colors.bodyText,
          ),
        ),
      ],
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final dynamic doc; // Document model
  const _DocumentTile({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.Colors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _C.Colors.indigo.withOpacity(.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.description_rounded,
                size: 18, color: _C.Colors.indigoText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              doc.titre ?? doc.fileName ?? 'Document',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _C.Colors.bodyText,
              ),
            ),
          ),
          Icon(Icons.download_rounded,
              size: 18, color: _C.Colors.subText),
        ],
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final dynamic quiz;
  const _QuizCard({required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _C.Colors.teal.withOpacity(.08),
            _C.Colors.indigo.withOpacity(.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.Colors.teal.withOpacity(.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _C.Colors.teal.withOpacity(.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.quiz_rounded,
                size: 22, color: _C.Colors.tealText),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.titre ?? 'Quiz disponible',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _C.Colors.bodyText,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Testez vos connaissances',
                  style: TextStyle(fontSize: 12, color: _C.Colors.subText),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _C.Colors.teal,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Démarrer',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mark Completed Button ─────────────────────────────────────────────────────

class _MarkCompletedButton extends StatelessWidget {
  final bool isCompleted;
  final bool isMarking;
  final VoidCallback? onTap;

  const _MarkCompletedButton({
    required this.isCompleted,
    required this.isMarking,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: isCompleted
            ? _C.Colors.teal.withOpacity(.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCompleted
              ? _C.Colors.teal.withOpacity(.4)
              : _C.Colors.cardBorder,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isCompleted || isMarking ? null : onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isMarking)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _C.Colors.indigoText,
                  ),
                )
              else
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    key: ValueKey(isCompleted),
                    size: 18,
                    color: isCompleted
                        ? _C.Colors.tealText
                        : _C.Colors.subText,
                  ),
                ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  isCompleted
                      ? 'Leçon terminée'
                      : isMarking
                          ? 'Enregistrement...'
                          : 'Marquer comme terminée',
                  key: ValueKey('$isCompleted-$isMarking'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? _C.Colors.tealText
                        : _C.Colors.subText,
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

// ── Skeleton loader ───────────────────────────────────────────────────────────

class _ContentSkeleton extends StatefulWidget {
  const _ContentSkeleton();

  @override
  State<_ContentSkeleton> createState() => _ContentSkeletonState();
}

class _ContentSkeletonState extends State<_ContentSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: .4, end: .9).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bar(double.infinity, 14),
          const SizedBox(height: 8),
          _bar(double.infinity, 14),
          const SizedBox(height: 8),
          _bar(200, 14),
          const SizedBox(height: 20),
          _bar(120, 14),
          const SizedBox(height: 8),
          _bar(double.infinity, 14),
          const SizedBox(height: 8),
          _bar(160, 14),
        ],
      ),
    );
  }

  Widget _bar(double width, double height) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(6),
        ),
      );
}

// ── Error block ───────────────────────────────────────────────────────────────

class _ErrorBlock extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBlock({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade300, size: 32),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.red.shade400, fontSize: 13)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

// ── Progress pills ────────────────────────────────────────────────────────────

class _ProgressPills extends StatelessWidget {
  final int total;
  final int current;
  final Set<int> completedIds;
  final List<Lesson> lessons;

  const _ProgressPills({
    required this.total,
    required this.current,
    required this.completedIds,
    required this.lessons,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i == current;
        final lessonId = lessons[i].id;
        final done = lessonId != null && completedIds.contains(lessonId);
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 4,
            decoration: BoxDecoration(
              color: done
                  ? _C.Colors.teal
                  : active
                      ? _C.Colors.indigo
                      : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

// ── Bottom navigation ─────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final int total;
  final int? currentLessonId;
  final Set<int> completedIds;
  final bool isCurrentCompleted;
  final bool isMarking;
  final VoidCallback? onMarkCompleted;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _BottomNav({
    required this.currentIndex,
    required this.total,
    required this.currentLessonId,
    required this.completedIds,
    required this.isCurrentCompleted,
    required this.isMarking,
    required this.onMarkCompleted,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = currentIndex == 0;
    final isLast = currentIndex == total - 1;

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Prev
          Expanded(
            child: AnimatedOpacity(
              opacity: isFirst ? 0.3 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: isFirst ? null : onPrev,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: _C.Colors.pageBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _C.Colors.cardBorder),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_ios_rounded,
                          size: 14, color: _C.Colors.bodyText),
                      SizedBox(width: 6),
                      Text(
                        'Précédent',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _C.Colors.bodyText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Next / Terminer — disabled until lesson is completed
          Expanded(
            child: GestureDetector(
              onTap: isCurrentCompleted
                  ? (isLast
                      ? () => Navigator.pop(context, Set<int>.from(completedIds))
                      : onNext)
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 48,
                decoration: BoxDecoration(
                  color: isCurrentCompleted
                      ? (isLast ? _C.Colors.teal : _C.Colors.navy)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLast ? 'Terminer' : 'Suivant',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isCurrentCompleted
                            ? Colors.white
                            : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      isLast
                          ? Icons.check_rounded
                          : Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: isCurrentCompleted
                          ? Colors.white
                          : Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 