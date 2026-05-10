import 'package:elearning/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';

class TeacherDashboard extends StatelessWidget {
  static const routeName = '/teacher-dashboard';

  final String teacherName;
  final String teacherEmail;

  const TeacherDashboard({
    Key? key,
    this.teacherName = 'Mme. Dupont',
    this.teacherEmail = 'dupont@ecole.edu',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final courses = [
      {'title': 'Mathématiques - 6ème', 'students': 24},
      {'title': 'Français - 5ème', 'students': 18},
      {'title': 'Histoire - 4ème', 'students': 22},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard enseignant'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(teacherName),
                accountEmail: Text(teacherEmail),
                currentAccountPicture: CircleAvatar(
                  child: Text(
                    teacherName.isNotEmpty ? teacherName[0] : 'T',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Tableau de bord'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.class_),
                title: const Text('Mes cours'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Étudiants'),
                onTap: () {},
              ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Se déconnecter'),
                onTap: () {
                  // Logique de déconnexion à implémenter
                  AuthProvider().logout();
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  child: Text(
                    teacherName.isNotEmpty ? teacherName[0] : 'T',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour,',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      teacherName,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),

            // Stats
            Row(
              children: [
                _StatCard(label: 'Cours', value: '3', color: Colors.blue),
                const SizedBox(width: 8),
                _StatCard(label: 'Étudiants', value: '64', color: Colors.green),
                const SizedBox(width: 8),
                _StatCard(label: 'Devoirs', value: '5', color: Colors.orange),
              ],
            ),
            const SizedBox(height: 20),

            // Courses list
            Text(
              'Mes cours',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: courses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final course = courses[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColorLight,
                      child: Text('${index + 1}'),
                    ),
                    title: Text(course['title'] as String),
                    subtitle:
                        Text('${course['students']} étudiants'),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        // navigate to course details
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Quick actions
            Text(
              'Actions rapides',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Nouveau cours'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Publier devoir'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.message),
        onPressed: () {
          // open messages or notifications
        },
        tooltip: 'Messages',
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    Key? key,
    required this.label,
    required this.value,
    this.color = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color.withOpacity(0.9)),
            ),
          ],
        ),
      ),
    );
  }
}