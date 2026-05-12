import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/CourseProgress.dart';
import '../../../core/constants/colors.dart' as _C;
class CourseDetailPage extends StatelessWidget {
  final CourseProgress course;
  const CourseDetailPage({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pct = course.progressPercentage.clamp(0, 100);
    return Scaffold(
      backgroundColor: _C.Colors.pageBg,
      body: CustomScrollView(
        slivers: [
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
              background: course.imageUrl.isNotEmpty
                  ? Hero(
                      tag: course.id,
                      child: Image.network(
                        course.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: _C.Colors.navy),
                      ),
                    )
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
                    course.title,
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 22,
                      color: _C.Colors.bodyText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    // ignore: dead_code
                    course.instructorName ?? 'Inconnu',
                    style: const TextStyle(fontSize: 13, color: _C.Colors.subText),
                  ),
                  const SizedBox(height: 20),
                  // Progress card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _C.Colors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Progression',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _C.Colors.bodyText,
                              ),
                            ),
                            Text(
                              '${course.completedLessons}/${course.totalLessons} leçons',
                              style: const TextStyle(
                                fontSize: 12,
                                color: _C.Colors.subText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct / 100.0,
                            minHeight: 6,
                            backgroundColor: Colors.grey.shade100,
                            color: pct >= 100 ? _C.Colors.teal : _C.Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$pct% complété',
                          style: TextStyle(
                            fontSize: 12,
                            color: pct >= 100 ? _C.Colors.tealText : _C.Colors.indigoText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(
                        pct == 0 ? 'Commencer le cours' : 'Continuer',
                      ),
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
