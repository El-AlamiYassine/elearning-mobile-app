import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/Category.dart';
import '../models/Course.dart';
import '../providers/student_provider.dart';
import '../../../core/constants/BottomNavStudent.dart';
import '../../../core/constants/colors.dart' as _C;

class ExplorerPage extends StatefulWidget {
  const ExplorerPage({Key? key}) : super(key: key);

  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  final _searchController = TextEditingController();
  int? _selectedCategoryId; // null = "Tous"
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () => setState(() => _query = _searchController.text.toLowerCase()),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<StudentProvider>(context, listen: false);
      await provider.fetchCategories();
      await provider.fetchAllCourses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onCategoryTap(int? categoryId) async {
    setState(() => _selectedCategoryId = categoryId);
    await Provider.of<StudentProvider>(context, listen: false)
        .fetchAllCourses(categoryId: categoryId);
  }

  // ── Color per category index ───────────────────────────────────────────────
  static const _palettes = [
    (bg: Color(0xFFEEF2FF), text: Color(0xFF4B5FCC), thumb: Color(0xFF7B9FFF)),
    (bg: Color(0xFFE1F5EE), text: Color(0xFF0F6E56), thumb: Color(0xFF5DCAA5)),
    (bg: Color(0xFFFEF9EE), text: Color(0xFFB7700F), thumb: Color(0xFFEF9F27)),
    (bg: Color(0xFFFAECE7), text: Color(0xFF993C1D), thumb: Color(0xFFD85A30)),
    (bg: Color(0xFFFBEAF0), text: Color(0xFF993556), thumb: Color(0xFFD4537E)),
    (bg: Color(0xFFEAF3DE), text: Color(0xFF3B6D11), thumb: Color(0xFF639922)),
  ];

  ({Color bg, Color text, Color thumb}) _palette(int index) =>
      _palettes[index % _palettes.length];

  String _initial(String title) =>
      title.trim().isNotEmpty ? title.trim()[0].toUpperCase() : 'C';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.Colors.pageBg,
      body: Consumer<StudentProvider>(
        builder: (context, provider, _) {
          // ── Group courses by category ──────────────────────────────────────
          final filtered = _query.isEmpty
              ? provider.allCourses
              : provider.allCourses.where((c) =>
                  c.titre.toLowerCase().contains(_query)
                ).toList();

          // Build map: categoryId → list of courses
          final Map<int, List<Course>> byCat = {};
          for (final course in filtered) {
            byCat.putIfAbsent(course.categorie?.id ?? 0 , () => []).add(course);
          }

          return CustomScrollView(
            slivers: [
              // ── Hero ──────────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 175.0,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: _C.Colors.navy,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: _ExplorerHero(
                    totalCourses: provider.allCourses.length,
                    totalCategories: provider.categories.length,
                    searchController: _searchController,
                  ),
                ),
              ),

              // ── Category chips ─────────────────────────────────────────────
              SliverPersistentHeader(
                pinned: true,
                delegate: _ChipBarDelegate(
                  categories: provider.categories,
                  selectedId: _selectedCategoryId,
                  onTap: _onCategoryTap,
                  palette: _palette,
                ),
              ),

              // ── Loading ────────────────────────────────────────────────────
              if (provider.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: _C.Colors.indigo),
                  ),
                )

              // ── Error ──────────────────────────────────────────────────────
              else if (provider.errorMessage != null)
                SliverFillRemaining(
                  child: _ExplorerError(
                    onRetry: () async {
                      await provider.fetchCategories();
                      await provider.fetchAllCourses(
                          categoryId: _selectedCategoryId);
                    },
                  ),
                )

              // ── Empty ──────────────────────────────────────────────────────
              else if (filtered.isEmpty)
                const SliverFillRemaining(child: _ExplorerEmpty())

              // ── Content: one section per category ─────────────────────────
              else if (_selectedCategoryId != null)
                // Single category → grid view
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  sliver: _CourseGrid(
                    courses: filtered,
                    palette: _palette,
                    initial: _initial,
                    onTap: (c) => _openDetail(context, c),
                  ),
                )
              else
                // All categories → section list
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final catId = byCat.keys.elementAt(index);
                      final courses = byCat[catId]!;
                      final cat = provider.categories.firstWhere(
                        (c) => c.id == catId,
                        orElse: () => Category(id: catId, nom: 'Sans catégorie', description: ''),
                      );
                      final catIndex =
                          provider.categories.indexWhere((c) => c.id == catId);
                      return _CategorySection(
                        category: cat,
                        courses: courses,
                        palette: _palette(catIndex < 0 ? index : catIndex),
                        initial: _initial,
                        onSeeAll: () => _onCategoryTap(catId),
                        onCourseTap: (c) => _openDetail(context, c),
                      );
                    },
                    childCount: byCat.length,
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavStudent(currentIndex: 2),
    );
  }

  void _openDetail(BuildContext context, Course course) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CourseExplorerDetailPage(course: course)),
    );
  }
}

// ─── Hero ─────────────────────────────────────────────────────────────────────
class _ExplorerHero extends StatelessWidget {
  final int totalCourses;
  final int totalCategories;
  final TextEditingController searchController;

  const _ExplorerHero({
    required this.totalCourses,
    required this.totalCategories,
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
            child: _Circle(size: 160, color: const Color(0xFF2D3566)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Explorer',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 26,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$totalCourses cours · $totalCategories catégories',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(.4),
                      letterSpacing: .4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(.12)),
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
                                fontSize: 13, color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Rechercher un cours…',
                              hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(.3)),
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

// ─── Pinned chip bar ──────────────────────────────────────────────────────────
class _ChipBarDelegate extends SliverPersistentHeaderDelegate {
  final List<Category> categories;
  final int? selectedId;
  final void Function(int?) onTap;
  final ({Color bg, Color text, Color thumb}) Function(int) palette;

  const _ChipBarDelegate({
    required this.categories,
    required this.selectedId,
    required this.onTap,
    required this.palette,
  });

  @override
  double get minExtent => 52;
  @override
  double get maxExtent => 52;

  @override
  bool shouldRebuild(_ChipBarDelegate old) =>
      old.selectedId != selectedId || old.categories != categories;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _C.Colors.pageBg,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "Tous" chip
          _Chip(
            label: 'Tous',
            selected: selectedId == null,
            onTap: () => onTap(null),
          ),
          const SizedBox(width: 8),
          ...categories.asMap().entries.map((e) {
            final p = palette(e.key);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _Chip(
                label: e.value.nom,
                selected: selectedId == e.value.id,
                selectedBg: p.bg,
                selectedText: p.text,
                onTap: () => onTap(e.value.id),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? selectedBg;
  final Color? selectedText;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedBg,
    this.selectedText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? (selectedBg ?? _C.Colors.navy)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? (selectedBg ?? _C.Colors.navy)
                : _C.Colors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected
                ? (selectedText ?? Colors.white)
                : _C.Colors.subText,
          ),
        ),
      ),
    );
  }
}

// ─── Category section ─────────────────────────────────────────────────────────
class _CategorySection extends StatelessWidget {
  final Category category;
  final List<Course> courses;
  final ({Color bg, Color text, Color thumb}) palette;
  final String Function(String) initial;
  final VoidCallback onSeeAll;
  final void Function(Course) onCourseTap;

  const _CategorySection({
    required this.category,
    required this.courses,
    required this.palette,
    required this.initial,
    required this.onSeeAll,
    required this.onCourseTap,
  });

  @override
  Widget build(BuildContext context) {
    // Show max 4 in grid; rest via "Voir tout"
    final preview = courses.take(4).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: palette.thumb,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.nom,
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 17,
                      color: _C.Colors.bodyText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: palette.bg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${courses.length}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: palette.text,
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: const Text(
                  'Voir tout',
                  style: TextStyle(
                    fontSize: 12,
                    color: _C.Colors.indigo,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 2-column grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.82,
            ),
            itemCount: preview.length,
            itemBuilder: (context, i) => _CourseCard(
              course: preview[i],
              palette: palette,
              initial: initial(preview[i].titre),
              onTap: () => onCourseTap(preview[i]),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Course grid (single-category view) ──────────────────────────────────────
class _CourseGrid extends StatelessWidget {
  final List<Course> courses;
  final ({Color bg, Color text, Color thumb}) Function(int) palette;
  final String Function(String) initial;
  final void Function(Course) onTap;

  const _CourseGrid({
    required this.courses,
    required this.palette,
    required this.initial,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          final p = palette(i);
          return _CourseCard(
            course: courses[i],
            palette: p,
            initial: initial(courses[i].titre),
            onTap: () => onTap(courses[i]),
          );
        },
        childCount: courses.length,
      ),
    );
  }
}

// ─── Course card ──────────────────────────────────────────────────────────────
class _CourseCard extends StatelessWidget {
  final Course course;
  final ({Color bg, Color text, Color thumb}) palette;
  final String initial;
  final VoidCallback onTap;

  const _CourseCard({
    required this.course,
    required this.palette,
    required this.initial,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: palette.bg,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    image: (course.imageUrl ?? '').isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(course.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: (course.imageUrl ?? '').isEmpty
                      ? Text(
                          initial,
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 36,
                            color: palette.thumb,
                          ),
                        )
                      : null,
                ),
              ),
              // Info
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.titre,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _C.Colors.bodyText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${course.formateur.nom} ${course.formateur.prenom}',
                        style: const TextStyle(
                            fontSize: 10, color: _C.Colors.subText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            course.categorie?.nom ?? 'Sans catégorie',
                            style: TextStyle(
                              fontSize: 9,
                              color: palette.text,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
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

// ─── Detail page ──────────────────────────────────────────────────────────────
class CourseExplorerDetailPage extends StatelessWidget {
  final Course course;
  const CourseExplorerDetailPage({Key? key, required this.course})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.Colors.pageBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _C.Colors.navy,
            flexibleSpace: FlexibleSpaceBar(
              background: (course.imageUrl ?? '').isNotEmpty
                  ? Image.network(course.imageUrl!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: _C.Colors.navy))
                  : Container(color: _C.Colors.navy),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.titre,
                    style: GoogleFonts.dmSerifDisplay(
                        fontSize: 22, color: _C.Colors.bodyText),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${course.formateur.nom}  ${course.formateur.prenom}',
                    style: const TextStyle(
                        fontSize: 13, color: _C.Colors.subText),
                  ),
                  if ((course.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _C.Colors.bodyText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course.description!,
                      style: const TextStyle(
                          fontSize: 13,
                          color: _C.Colors.subText,
                          height: 1.6),
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.rocket_launch_rounded),
                      label: const Text("S'inscrire au cours"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.Colors.navy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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


// ─── Empty / Error states ─────────────────────────────────────────────────────
class _ExplorerEmpty extends StatelessWidget {
  const _ExplorerEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              size: 56, color: _C.Colors.subText.withOpacity(.3)),
          const SizedBox(height: 14),
          const Text('Aucun cours trouvé',
              style: TextStyle(fontSize: 15, color: _C.Colors.subText)),
        ],
      ),
    );
  }
}

class _ExplorerError extends StatelessWidget {
  final VoidCallback onRetry;
  const _ExplorerError({required this.onRetry});

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
        color: color.withOpacity(.6),
      ),
    );
  }
}