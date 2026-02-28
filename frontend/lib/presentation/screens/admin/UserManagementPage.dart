import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/user/user_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/user/user_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/user/user_state.dart';
import 'package:lokyatra_frontend/data/models/user.dart';

class UserManagementPage extends StatefulWidget {
  final ValueNotifier<String?> subtitleNotifier;
  const UserManagementPage({super.key, required this.subtitleNotifier});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage>
    with SingleTickerProviderStateMixin {

  static const admingrey = Colors.grey;
  static const _roles    = ['All', 'admin', 'owner', 'tourist'];

  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _roles.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _activeRole => _roles[_tabController.index];

  List<User> _applyFilters(List<User> all) {
    final q = _searchQuery.toLowerCase().trim();
    return all.where((u) {
      final matchSearch = q.isEmpty ||
          u.name.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q);
      final matchRole =
          _activeRole == 'All' || u.role.toLowerCase() == _activeRole;
      return matchSearch && matchRole;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserBloc()..add(FetchUsers()),
      child: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserLoaded) {
            widget.subtitleNotifier.value = '${state.users.length} users total';
          } else if (state is UserLoading) {
            widget.subtitleNotifier.value = 'Loading…';
          } else if (state is UserDeleted) {
            final extra = state.homestaysDeleted > 0
                ? ' · ${state.homestaysDeleted} homestay${state.homestaysDeleted > 1 ? 's' : ''} also deleted'
                : '';
            _snack(context, '${state.message}$extra',
                icon: Icons.check_circle_outline,
                color: Colors.green.shade600);
          } else if (state is UserError) {
            _snack(context, state.message,
                icon: Icons.error_outline, color: Colors.red.shade600);
          }
        },
        builder: (context, state) {
          if (state is UserLoading || state is UserInitial) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(admingrey),
              ),
            );
          }

          if (state is UserError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context.read<UserBloc>().add(FetchUsers()),
            );
          }

          final users    = (state is UserLoaded) ? state.users : <User>[];
          final filtered = _applyFilters(users);

          return Column(children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by name or email…',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),

            // Role filter tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.grey,
                  unselectedLabelColor: Colors.grey.shade500,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: _roles.map((r) {
                    final label = r == 'All'
                        ? 'All'
                        : '${r[0].toUpperCase()}${r.substring(1)}s';
                    return Tab(text: label);
                  }).toList(),
                ),
              ),
            ),

            // User list
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyState(query: _searchQuery, role: _activeRole)
                  : RefreshIndicator(
                onRefresh: () async =>
                    context.read<UserBloc>().add(FetchUsers()),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
                  itemBuilder: (ctx, i) => _UserCard(
                    user: filtered[i],
                    onDelete: () => _confirmDelete(ctx, filtered[i]),
                  ),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        actionsPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.red.shade50, shape: BoxShape.circle),
            child: const Icon(Icons.person_remove_rounded,
                color: Colors.red, size: 20),
          ),
          const SizedBox(width: 10),
          const Text('Delete User',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                    color: Colors.black87, fontSize: 14, height: 1.5),
                children: [
                  const TextSpan(text: 'Delete '),
                  TextSpan(
                      text: user.name,
                      style:
                      const TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: ' permanently?'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.red.shade700, size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'All their homestays will also be permanently deleted. This cannot be undone.',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.read<UserBloc>().add(DeleteUsers(user.id));
            },
            icon: const Icon(Icons.delete_forever, size: 16),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String msg,
      {required IconData icon, required Color color}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    ));
  }
}

// ── Stats Banner ──────────────────────────────────────────────────────────────
class StatsBanner extends StatelessWidget {
  final int total, active, admins, owners, tourists;
  const StatsBanner({
    super.key,
    required this.total,
    required this.active,
    required this.admins,
    required this.owners,
    required this.tourists,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF3E4040), Color(0xFF151414)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    padding:
    const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
    child: Row(children: [
      _Stat('Total',    total,    Colors.white),
      _div(),
      _Stat('Active',   active,   Colors.greenAccent.shade200),
      _div(),
      _Stat('Admins',   admins,   Colors.orangeAccent),
      _div(),
      _Stat('Owners',   owners,   Colors.amber.shade300),
      _div(),
      _Stat('Tourists', tourists, Colors.lightBlueAccent),
    ]),
  );

  Widget _div() => Container(
      height: 32,
      width: 1,
      color: Colors.white.withValues(alpha: 0.15));
}

class _Stat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _Stat(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('$count',
          style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.1)),
      const SizedBox(height: 2),
      Text(label,
          style: const TextStyle(
              color: Colors.white60, fontSize: 10.5)),
    ]),
  );
}

// ── User Card ─────────────────────────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onDelete;
  const _UserCard({required this.user, required this.onDelete});

  static const _adminBlue = Color(0xFF1E3A5F);

  @override
  Widget build(BuildContext context) {
    final role     = user.role.toLowerCase();
    final isActive = user.isActive ?? false;

    final roleColor = role == 'admin'
        ? _adminBlue
        : role == 'owner'
        ? Colors.amber.shade800
        : Colors.blue.shade600;

    final roleIcon = role == 'admin'
        ? Icons.shield_outlined
        : role == 'owner'
        ? Icons.home_work_outlined
        : Icons.person_outlined;

    final roleLabel = role[0].toUpperCase() + role.substring(1);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + active dot
            Stack(children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: roleColor.withValues(alpha: 0.12),
                backgroundImage: (user.profileImage != null &&
                    user.profileImage!.isNotEmpty)
                    ? NetworkImage(user.profileImage!)
                    : null,
                child: (user.profileImage == null ||
                    user.profileImage!.isEmpty)
                    ? Text(
                  user.name.isNotEmpty
                      ? user.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                      color: roleColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                )
                    : null,
              ),
              Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.green.shade500
                        : Colors.grey.shade400,
                    shape: BoxShape.circle,
                    border:
                    Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ]),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          user.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1A1A2E)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: roleColor.withValues(alpha: 0.3),
                              width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(roleIcon, size: 11, color: roleColor),
                            const SizedBox(width: 3),
                            Text(roleLabel,
                                style: TextStyle(
                                    color: roleColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),
                  _InfoRow(icon: Icons.email_outlined, text: user.email),
                  const SizedBox(height: 3),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    text: (user.phone != null && user.phone!.isNotEmpty)
                        ? user.phone!
                        : 'No phone number',
                    faint: user.phone == null || user.phone!.isEmpty,
                  ),

                  const SizedBox(height: 10),

                  Row(children: [
                    // Active/Inactive chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.shade50
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: isActive
                                ? Colors.green.shade300
                                : Colors.grey.shade300,
                            width: 1),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(
                          isActive
                              ? Icons.check_circle_outline
                              : Icons.cancel_outlined,
                          size: 12,
                          color: isActive
                              ? Colors.green.shade600
                              : Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? Colors.green.shade700
                                  : Colors.grey.shade600),
                        ),
                      ]),
                    ),

                    const Spacer(),

                    if (role != 'admin')
                      SizedBox(
                        height: 30,
                        child: TextButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline,
                              size: 14, color: Colors.red),
                          label: const Text('Delete',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10),
                            backgroundColor: Colors.red.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                  color: Colors.red.shade200, width: 1),
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _adminBlue.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _adminBlue.withValues(alpha: 0.2)),
                        ),
                        child: const Text('Protected',
                            style: TextStyle(
                                fontSize: 11,
                                color: _adminBlue,
                                fontWeight: FontWeight.w500)),
                      ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool faint;
  const _InfoRow(
      {required this.icon, required this.text, this.faint = false});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 13, color: Colors.grey.shade400),
    const SizedBox(width: 5),
    Expanded(
      child: Text(
        text,
        style: TextStyle(
            fontSize: 12,
            color: faint
                ? Colors.grey.shade400
                : Colors.grey.shade600,
            fontStyle:
            faint ? FontStyle.italic : FontStyle.normal),
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ]);
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String query;
  final String role;
  const _EmptyState({required this.query, required this.role});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.people_outline,
          size: 60, color: Colors.grey.shade300),
      const SizedBox(height: 12),
      Text(
        query.isNotEmpty
            ? 'No users matching "$query"'
            : 'No ${role == "All" ? "" : "$role "}users yet',
        style: TextStyle(color: Colors.grey.shade400, fontSize: 15),
      ),
    ]),
  );
}

// ── Error View ────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.wifi_off_rounded,
            size: 56, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text(message,
            textAlign: TextAlign.center,
            style:
            TextStyle(color: Colors.grey.shade500, fontSize: 14)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A5F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ]),
    ),
  );
}