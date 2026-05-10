import 'package:elearning/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  // Exemple de données (à remplacer par des données réelles)
  final Map<String, int> _stats = const {
    'Utilisateurs': 1240,
    'Cours': 86,
    'Inscriptions': 5320,
    'Commentaires': 412,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord - Admin'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
            tooltip: 'Rechercher',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Logique de déconnexion à implémenter
              AuthProvider().logout();
              Navigator.pushReplacementNamed(context, '/');
            },
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: const Text('Admin'),
                accountEmail: const Text('admin@example.com'),
                currentAccountPicture: CircleAvatar(
                  child: Text(
                    'A',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Tableau de bord'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Utilisateurs'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.book),
                title: const Text('Cours'),
                onTap: () {},
              ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Paramètres'),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistiques principales
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
                shrinkWrap: true,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                children: _stats.entries.map((entry) {
                  return _StatCard(
                    title: entry.key,
                    value: entry.value.toString(),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Actions rapides
              const Text(
                'Actions rapides',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _ActionChip(
                    icon: Icons.add,
                    label: 'Ajouter un cours',
                    color: Colors.green,
                    onTap: () {},
                  ),
                  _ActionChip(
                    icon: Icons.person_add,
                    label: 'Ajouter un utilisateur',
                    color: Colors.blue,
                    onTap: () {},
                  ),
                  _ActionChip(
                    icon: Icons.report,
                    label: 'Voir rapports',
                    color: Colors.orange,
                    onTap: () {},
                  ),
                  _ActionChip(
                    icon: Icons.message,
                    label: 'Messages',
                    color: Colors.purple,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Exemple de section additionnelle
              Card(
                child: ListTile(
                  leading: const Icon(Icons.announcement),
                  title: const Text('Annonces récentes'),
                  subtitle: const Text('Aucune annonce pour le moment.'),
                  trailing: TextButton(
                    child: const Text('Gérer'),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        tooltip: 'Créer',
        onPressed: () {},
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({Key? key, required this.title, required this.value})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                _iconForTitle(title),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(title, style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'utilisateurs':
        return Icons.people;
      case 'cours':
        return Icons.book;
      case 'inscriptions':
        return Icons.play_circle_fill;
      case 'commentaires':
        return Icons.chat_bubble;
      default:
        return Icons.insert_chart;
    }
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color, size: 18),
      ),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Colors.grey[100],
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
