import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/CourseProgress.dart';
import '../providers/student_provider.dart';
import '../../../core/constants/colors.dart' as _C;
import 'course_details.dart';
import '../../../core/constants/BottomNavStudent.dart';

class StudentCoursPage extends StatefulWidget {
  const StudentCoursPage({Key? key}) : super(key: key);

  @override
  State<StudentCoursPage> createState() => _StudentCoursPageState();
}
class _StudentCoursPageState extends State<StudentCoursPage> {
  late Future<List<CourseProgress>> _coursesFuture;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _coursesFuture = _load();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<CourseProgress>> _load() =>
      StudentProvider().fetchCourses();

  Future<void> _refresh() {
    setState(() => _coursesFuture = _load());
    return _coursesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.Colors.pageBg,
      body: FutureBuilder<List<CourseProgress>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          final loading = snapshot.connectionState == ConnectionState.waiting;
          final courses = snapshot.data ?? [];
          final filtered = _query.isEmpty
              ? courses
              : courses
                  .where((c) =>
                      c.title.toLowerCase().contains(_query) ||
                      // ignore: dead_code
                      (c.instructorName ?? '').toLowerCase().contains(_query))
                  .toList();

          return CustomScrollView(
            slivers: [
              // ── Hero header ─────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 180.0,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: _C.Colors.navy,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: _CoursHeroBg(
                    totalCount: courses.length,
                    inProgressCount: courses
                        .where((c) =>
                            c.progressPercentage > 0 &&
                            c.progressPercentage < 100)
                        .length,
                    searchController: _searchController,
                  ),
                ),
              ),

              // ── States ───────────────────────────────────────────────────
              if (loading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: _C.Colors.indigo),
                  ),
                )
              else if (snapshot.hasError)
                SliverFillRemaining(
                  child: _CoursErrorState(onRetry: _refresh),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(child: _CoursEmptyState())
              else
                // ── Course list ────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CourseCard(
                          course: filtered[i],
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  CourseDetailPage(course: filtered[i]),
                            ),
                          ),
                        ),
                      ),
                      childCount: filtered.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavStudent(
        currentIndex: 1,
      ),
    );
  }
}

// ─── Hero background ──────────────────────────────────────────────────────────
class _CoursHeroBg extends StatelessWidget {
  final int totalCount;
  final int inProgressCount;
  final TextEditingController searchController;

  const _CoursHeroBg({
    required this.totalCount,
    required this.inProgressCount,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _C.Colors.navy,
      child: Stack(
        children: [
          Positioned(
            top: -50, right: -50,
            child: _Circle(size: 160, color: _C.Colors.navyLight),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Mes Cours',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 24,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$inProgressCount en cours · ${totalCount - inProgressCount} terminés',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(.4),
                      letterSpacing: .4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Search bar
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(.12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(Icons.search_rounded,
                            size: 16,
                            color: Colors.white.withOpacity(.4)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Rechercher un cours…',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(.3),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            cursorColor: _C.Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Course card ──────────────────────────────────────────────────────────────
class _CourseCard extends StatelessWidget {
  final CourseProgress course;
  final VoidCallback onTap;

  const _CourseCard({required this.course, required this.onTap});

  Color get _accentColor {
    if (course.progressPercentage >= 100) return _C.Colors.teal;
    if (course.progressPercentage == 0) return const Color(0xFFEF9F27);
    return _C.Colors.indigo;
  }

  Color get _accentBg {
    if (course.progressPercentage >= 100) return _C.Colors.tealBg;
    if (course.progressPercentage == 0) return const Color(0xFFFEF9EE);
    return _C.Colors.indigoBg;
  }

  @override
  Widget build(BuildContext context) {
    final pct = course.progressPercentage.clamp(0, 100);
    final initial = course.title.isNotEmpty
        ? course.title[0].toUpperCase()
        : 'C';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _C.Colors.cardBorder),
          ),
          child: Row(
            children: [
              // Thumbnail / initial
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: _accentBg,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(15),
                  ),
                  image: course.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(course.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: course.imageUrl.isEmpty
                    ? Text(
                        initial,
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 28,
                          color: _accentColor,
                        ),
                      )
                    : null,
              ),
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _C.Colors.bodyText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        // ignore: dead_code
                        '${course.instructorName ?? "Inconnu"} · ${course.totalLessons} leçons',
                        style: const TextStyle(
                          fontSize: 11,
                          color: _C.Colors.subText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: pct / 100.0,
                                minHeight: 4,
                                backgroundColor: Colors.grey.shade100,
                                color: _accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$pct%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _accentColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: Colors.grey.shade300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Detail page ──────────────────────────────────────────────────────────────

class _CoursEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              size: 56, color: _C.Colors.subText.withOpacity(.3)),
          const SizedBox(height: 14),
          const Text(
            'Aucun cours trouvé',
            style: TextStyle(fontSize: 15, color: _C.Colors.subText),
          ),
        ],
      ),
    );
  }
}

class _CoursErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _CoursErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          const Text('Erreur lors du chargement.'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(backgroundColor: _C.Colors.navy),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
  
}

class _Circle extends StatelessWidget {
  final double size;
  final Color color;
  const _Circle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // ignore: deprecated_member_use
        color: color.withOpacity(.6),
      ),
    );
  }
}

