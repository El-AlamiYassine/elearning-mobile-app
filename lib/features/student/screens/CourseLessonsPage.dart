import 'package:elearning/features/models/Lesson.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/CourseProgress.dart';
import '../../../core/constants/colors.dart' as _C;
import 'LessonDetailPage.dart';

class CourseLessonsPage extends StatefulWidget {
  final CourseProgress course;
  final Future<List<Lesson>> Function(int courseId) fetchLessons;
  final Future<Lesson?> Function(int lessonId) fetchLessonDetails;
  final Future<void> Function(int lessonId) markLessonCompleted;

  const CourseLessonsPage({
    Key? key,
    required this.course,
    required this.fetchLessons,
    required this.fetchLessonDetails,
    required this.markLessonCompleted,
  }) : super(key: key);

  @override
  State<CourseLessonsPage> createState() => _CourseLessonsPageState();
}

class _CourseLessonsPageState extends State<CourseLessonsPage> {
  Future<List<Lesson>>? _lessonsFuture;

  // IDs complétés localement (accumulés session après session sans re-fetch)
  final Set<int> _localCompletedIds = {};

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }
  Future<void> _loadLessons() async {
    final lessons = await widget.fetchLessons(widget.course.id);

    final Set<int> newCompleted = {};

   for (final l in lessons) {
      if (l.id != null && l.completed == true) {
        _localCompletedIds.add(l.id!);
      }
    }

    if (mounted) {
      setState(() {
        _localCompletedIds
          ..clear()
          ..addAll(newCompleted);

        _lessonsFuture = Future.value(lessons);
      });
    }
  }
  Future<void> _openLessons(List<Lesson> lessons, int index) async {
    // Retourne Set<int> des nouveaux IDs complétés pendant la session
    final result = await Navigator.push<Set<int>>(
      context,
      MaterialPageRoute(
        builder: (_) => LessonDetailPage(
          lessons: lessons,
          initialIndex: index,
          fetchLessonDetails: widget.fetchLessonDetails,
          markLessonCompleted: widget.markLessonCompleted,
          initialCompletedIds: Set.from(_localCompletedIds),
        ),
      ),
    );

    if (mounted) {
      await _loadLessons();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = widget.course.progressPercentage.clamp(0, 100);

    return Scaffold(
      backgroundColor: _C.Colors.pageBg,
      body: CustomScrollView(
        slivers: [
          // ── App Bar with hero image ──────────────────────────────────
          SliverAppBar(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(.25),
                    border: Border.all(
                      color: Colors.white.withOpacity(.15),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _C.Colors.navy,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.course.imageUrl.isNotEmpty
                  ? Hero(
                      tag: widget.course.id,
                      child: Image.network(
                        widget.course.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: _C.Colors.navy),
                      ),
                    )
                  : Container(color: _C.Colors.navy),
            ),
          ),

          // ── Course info + progress ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.course.title,
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 22,
                      color: _C.Colors.bodyText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.course.instructorName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _C.Colors.subText,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mini progress bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _C.Colors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$pct% complété',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: pct >= 100
                                    ? _C.Colors.tealText
                                    : _C.Colors.indigoText,
                              ),
                            ),
                            Text(
                              '${widget.course.completedLessons}/${widget.course.totalLessons} leçons',
                              style: const TextStyle(
                                fontSize: 12,
                                color: _C.Colors.subText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct / 100.0,
                            minHeight: 6,
                            backgroundColor: Colors.grey.shade100,
                            color: pct >= 100
                                ? _C.Colors.teal
                                : _C.Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section title
                  Text(
                    'Contenu du cours',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 18,
                      color: _C.Colors.bodyText,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // ── Lessons list ─────────────────────────────────────────────
          FutureBuilder<List<Lesson>>(
            future: _lessonsFuture ?? Future.value([]),
            builder: (context, snapshot) {
              // Loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // Error
              if (snapshot.hasError || !snapshot.hasData) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: _C.Colors.subText, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          'Erreur lors du chargement des leçons.',
                          style: const TextStyle(
                            color: _C.Colors.subText,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => setState(() {
                            _lessonsFuture =
                                widget.fetchLessons(widget.course.id);
                          }),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final lessons = snapshot.data!;

              // Pré-remplir les IDs déjà complétés depuis les données serveur
              for (final l in lessons) {
                if (l.id != null &&
                    l.progresses != null &&
                    l.progresses!.any((p) => p.completed == true)) {
                  _localCompletedIds.add(l.id!);
                }
              }

              if (lessons.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Aucune leçon disponible.',
                      style: TextStyle(
                        color: _C.Colors.subText,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final lesson = lessons[index];

                      final bool isCompleted = lesson.completed == true;

                      // Déverrouillée si première, ou si la précédente est complétée
                      final bool isLocked =
                      index > 0 && lessons[index - 1].completed != true;

                      return _LessonTile(
                        lesson: lesson,
                        index: index,
                        isCompleted: isCompleted,
                        isLocked: isLocked,
                        onTap: isLocked
                            ? null
                            : () => _openLessons(lessons, index),
                      );
                    },
                    childCount: lessons.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Lesson Tile ──────────────────────────────────────────────────────────────

class _LessonTile extends StatelessWidget {
  final Lesson lesson;
  final int index;
  final bool isCompleted;
  final bool isLocked;
  final VoidCallback? onTap;

  const _LessonTile({
    required this.lesson,
    required this.index,
    required this.isCompleted,
    required this.isLocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasVideo = lesson.videoUrl != null && lesson.videoUrl!.isNotEmpty;
    final hasQuiz = lesson.quiz != null;

    Color statusColor;
    IconData statusIcon;

    if (isCompleted) {
      statusColor = _C.Colors.teal;
      statusIcon = Icons.check_circle_rounded;
    } else if (isLocked) {
      statusColor = Colors.grey.shade300;
      statusIcon = Icons.lock_rounded;
    } else {
      statusColor = _C.Colors.indigo;
      statusIcon = Icons.play_circle_rounded;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isLocked ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCompleted
                ? _C.Colors.teal.withOpacity(.3)
                : _C.Colors.cardBorder,
          ),
        ),
        child: Row(
          children: [
            // Index circle
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor.withOpacity(.12),
              ),
              alignment: Alignment.center,
              child: isLocked
                  ? Icon(Icons.lock_rounded,
                      size: 14, color: Colors.grey.shade400)
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
            ),
            const SizedBox(width: 12),

            // Title & badges
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.titre,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isLocked
                          ? Colors.grey.shade400
                          : _C.Colors.bodyText,
                    ),
                  ),
                  if (hasVideo || hasQuiz) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (hasVideo)
                          _Badge(
                            icon: Icons.videocam_rounded,
                            label: 'Vidéo',
                            color: _C.Colors.indigo,
                            muted: isLocked,
                          ),
                        if (hasVideo && hasQuiz)
                          const SizedBox(width: 6),
                        if (hasQuiz)
                          _Badge(
                            icon: Icons.quiz_rounded,
                            label: 'Quiz',
                            color: _C.Colors.teal,
                            muted: isLocked,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Status icon
            Icon(statusIcon, color: statusColor, size: 22),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool muted;

  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    final c = muted ? Colors.grey.shade300 : color.withOpacity(.15);
    final tc = muted ? Colors.grey.shade400 : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: tc),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: tc,
            ),
          ),
        ],
      ),
    );
  }
}