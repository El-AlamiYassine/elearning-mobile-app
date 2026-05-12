// lib/features/student/screens/explorer_screen.dart
import 'package:elearning/features/student/providers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExplorerScreen extends StatefulWidget {
  static const routeName = '/explorer';

  const ExplorerScreen({Key? key}) : super(key: key);

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<StudentProvider>(context, listen: false);
      if (provider.categories.isEmpty) {
        provider.fetchCategories();
      }
      // Appelle la méthode qui charge les cours (implémente fetchCourses() dans StudentProvider)
      if (provider.allCourses.isEmpty) {
        provider.fetchAllCourses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Explorer'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Catégories'),
              Tab(text: 'Cours'),
            ],
          ),
        ),
        body: Consumer<StudentProvider>(
          builder: (context, provider, _) {
            final isLoading = provider.isLoading;
            final error = provider.errorMessage;
            final categories = provider.categories;
            final courses = provider.allCourses;

            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (error != null && error.isNotEmpty) {
              return Center(child: Text(error));
            }

            return TabBarView(
              children: [
                // Tab 1 : Categories (reprise de ton UI)
                categories.isEmpty
                    ? const Center(child: Text('Aucune catégorie trouvée.'))
                    : Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: GridView.builder(
                          itemCount: categories.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 3 / 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final title = (category.nom); // adapte si besoin

                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    '/category-details',
                                    arguments: category,
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(child: _buildFallback(title)),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                // Tab 2 : Courses
                courses.isEmpty
                    ? const Center(child: Text('Aucun cours trouvé.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(12.0),
                        itemCount: courses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final course = courses[index];
                          // adapte les propriétés : titre, description, image...
                          final title = (course.titre);
                          final subtitle = (course.description ?? '');

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  '/course-details',
                                  arguments: course,
                                );
                              },
                              leading: CircleAvatar(
                                backgroundColor: Colors.blueGrey.shade100,
                                child: Text(
                                  title.isNotEmpty ? title[0].toUpperCase() : '?',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ),
                              title: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: subtitle.isNotEmpty
                                  ? Text(
                                      subtitle,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFallback(String title) {
    return Container(
      color: Colors.blueGrey.shade100,
      child: Center(
        child: Text(
          title.isNotEmpty ? title[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}