// lib/presentation/views/admin/user_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/user_entity.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  UserRole? _selectedRoleFilter;
  UserStatus? _selectedStatusFilter;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load users when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadAllUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedRoleFilter = null;
      _selectedStatusFilter = null;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  List<UserEntity> _filterUsers(List<UserEntity> users) {
    return users.where((user) {
      final matchesSearch = _searchQuery.isEmpty ||
          user.displayName.toLowerCase().contains(_searchQuery) ||
          user.email.toLowerCase().contains(_searchQuery) ||
          user.displayId.toLowerCase().contains(_searchQuery);

      final matchesRole = _selectedRoleFilter == null || user.role == _selectedRoleFilter;
      final matchesStatus = _selectedStatusFilter == null || user.status == _selectedStatusFilter;

      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final adminVM = context.watch<AdminViewModel>();
    final filteredUsers = _filterUsers(adminVM.users);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Users',
            onPressed: () => adminVM.loadAllUsers(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ============================================
          // FILTERS & SEARCH SECTION
          // ============================================
          _buildFiltersSection(context, authVM),

          // ============================================
          // STATISTICS BANNER
          // ============================================
          if (adminVM.users.isNotEmpty)
            _buildStatisticsBanner(context, adminVM, filteredUsers),

          // ============================================
          // USER LIST SECTION
          // ============================================
          Expanded(
            child: _buildUserListSection(context, adminVM, filteredUsers),
          ),
        ],
      ),
    );
  }

  // ============================================
  // FILTERS SECTION WIDGET
  // ============================================
  Widget _buildFiltersSection(BuildContext context, AuthViewModel authVM) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by name, email or ID...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Filters Row
            Row(
              children: [
                Expanded(
                  child: _buildFilterChip(
                    context,
                    label: 'Role',
                    selected: _selectedRoleFilter,
                    options: UserRole.values,
                    onSelected: (value) {
                      setState(() {
                        _selectedRoleFilter = value as UserRole?;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChip(
                    context,
                    label: 'Status',
                    selected: _selectedStatusFilter,
                    options: UserStatus.values,
                    onSelected: (value) {
                      setState(() {
                        _selectedStatusFilter = value as UserStatus?;
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear_all),
                  tooltip: 'Clear Filters',
                  onPressed: _clearFilters,
                ),
              ],
            ),

            // Permissions Info
            if (!authVM.isAdmin)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Note: You can only manage regular users',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // FILTER CHIP BUILDER
  // ============================================
  Widget _buildFilterChip<T>(
      BuildContext context, {
        required String label,
        required T? selected,
        required List<T> options,
        required Function(T?) onSelected,
      }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: selected,
          isExpanded: true,
          hint: Text('All $label'),
          items: [
            DropdownMenuItem<T>(
              value: null,
              child: Text('All $label'),
            ),
            ...options.map((T option) {
              return DropdownMenuItem<T>(
                value: option,
                child: Text(
                  option.toString().split('.').last,
                  style: TextStyle(
                    color: _getColorForOption(option),
                  ),
                ),
              );
            }).toList(),
          ],
          onChanged: onSelected,
        ),
      ),
    );
  }

  Color _getColorForOption(dynamic option) {
    if (option is UserRole) {
      switch (option) {
        case UserRole.admin:
          return Colors.red;
        case UserRole.moderator:
          return Colors.orange;
        case UserRole.user:
          return Colors.blue;
      }
    } else if (option is UserStatus) {
      switch (option) {
        case UserStatus.free:
          return Colors.green;
        case UserStatus.pro:
          return Colors.purple;
        case UserStatus.expired:
          return Colors.amber;
        case UserStatus.suspended:
          return Colors.red;
      }
    }
    return Colors.black;
  }

  // ============================================
  // STATISTICS BANNER
  // ============================================
  Widget _buildStatisticsBanner(BuildContext context, AdminViewModel adminVM, List<UserEntity> filteredUsers) {
    final totalUsers = adminVM.users.length;
    final filteredCount = filteredUsers.length;
    final adminCount = adminVM.users.where((u) => u.role == UserRole.admin).length;
    final moderatorCount = adminVM.users.where((u) => u.role == UserRole.moderator).length;
    final proUsers = adminVM.users.where((u) => u.status == UserStatus.pro).length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(context, 'Total', totalUsers.toString(), Icons.people),
            _buildStatItem(context, 'Filtered', filteredCount.toString(), Icons.filter_list),
            _buildStatItem(context, 'Admins', adminCount.toString(), Icons.admin_panel_settings),
            _buildStatItem(context, 'Pro Users', proUsers.toString(), Icons.star),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Theme.of(context).primaryColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // ============================================
  // USER LIST SECTION
  // ============================================
  Widget _buildUserListSection(BuildContext context, AdminViewModel adminVM, List<UserEntity> filteredUsers) {
    if (adminVM.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (adminVM.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(adminVM.errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => adminVM.loadAllUsers(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _selectedRoleFilter != null || _selectedStatusFilter != null
                  ? 'No users match your filters'
                  : 'No users found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_searchQuery.isNotEmpty || _selectedRoleFilter != null || _selectedStatusFilter != null)
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear Filters'),
              ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Success Message
        if (adminVM.successMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.green[50],
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Text(adminVM.successMessage!)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => adminVM.clearMessages(),
                ),
              ],
            ),
          ),

        // User List
        Expanded(
          child: ListView.builder(
            itemCount: filteredUsers.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              return _buildUserCard(context, user, adminVM);
            },
          ),
        ),
      ],
    );
  }

  // ============================================
  // USER CARD WIDGET
  // ============================================
  Widget _buildUserCard(BuildContext context, UserEntity user, AdminViewModel adminVM) {
    final authVM = context.read<AuthViewModel>();
    final currentUser = authVM.user;
    final canManage = currentUser != null &&
        (currentUser.uid == user.uid ||
            authVM.canManageUser(user));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: user.photoUrl.isNotEmpty
              ? NetworkImage(user.photoUrl)
              : null,
          backgroundColor: Colors.grey[200],
          child: user.photoUrl.isEmpty
              ? Text(
            user.displayName[0].toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (user.uid == currentUser?.uid)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'You',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildRoleChip(user.role),
                const SizedBox(width: 6),
                _buildStatusChip(user.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'ID: ${user.displayId} • Joined: ${DateFormat('dd/MM/yyyy').format(user.createdAt)}',
              style: const TextStyle(fontSize: 11),
            ),
            if (user.subscriptionEnd != null)
              Text(
                'Subscription ends: ${DateFormat('dd/MM/yyyy').format(user.subscriptionEnd!)}',
                style: const TextStyle(fontSize: 11),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: canManage
              ? () => _showUserActionsMenu(context, user, adminVM)
              : null,
        ),
        onTap: canManage
            ? () => _showUserDetails(context, user, adminVM)
            : null,
      ),
    );
  }

  Widget _buildRoleChip(UserRole role) {
    Color color;
    switch (role) {
      case UserRole.admin:
        color = Colors.red;
        break;
      case UserRole.moderator:
        color = Colors.orange;
        break;
      case UserRole.user:
        color = Colors.blue;
        break;
    }

    return Chip(
      label: Text(
        role.name.toUpperCase(),
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    );
  }

  Widget _buildStatusChip(UserStatus status) {
    Color color;
    switch (status) {
      case UserStatus.free:
        color = Colors.green;
        break;
      case UserStatus.pro:
        color = Colors.purple;
        break;
      case UserStatus.expired:
        color = Colors.amber;
        break;
      case UserStatus.suspended:
        color = Colors.red;
        break;
    }

    return Chip(
      label: Text(
        status.name.toUpperCase(),
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    );
  }

  // ============================================
  // USER ACTIONS MENU
  // ============================================
  void _showUserActionsMenu(BuildContext context, UserEntity user, AdminViewModel adminVM) {
    final authVM = context.read<AuthViewModel>();
    final currentUser = authVM.user;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Manage ${user.displayName}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(),

              // Quick Actions
              if (currentUser?.uid != user.uid)
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Send Message'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement message feature
                  },
                ),

              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  _showUserDetails(context, user, adminVM);
                },
              ),

              if (currentUser?.uid != user.uid && authVM.canManageUser(user))
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Role & Status'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditUserDialog(context, user, adminVM);
                  },
                ),

              if (user.status != UserStatus.suspended && currentUser?.uid != user.uid && authVM.canManageUser(user))
                ListTile(
                  leading: const Icon(Icons.block, color: Colors.red),
                  title: const Text('Suspend User', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmAction(
                      context,
                      title: 'Suspend User',
                      message: 'Are you sure you want to suspend ${user.displayName}?',
                      action: () => adminVM.updateUserStatus(user.uid, UserStatus.suspended),
                    );
                  },
                ),

              if (user.status == UserStatus.suspended && currentUser?.uid != user.uid && authVM.canManageUser(user))
                ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: const Text('Unsuspend User', style: TextStyle(color: Colors.green)),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmAction(
                      context,
                      title: 'Unsuspend User',
                      message: 'Are you sure you want to unsuspend ${user.displayName}?',
                      action: () => adminVM.updateUserStatus(user.uid, UserStatus.free),
                    );
                  },
                ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // ============================================
  // USER DETAILS DIALOG
  // ============================================
  void _showUserDetails(BuildContext context, UserEntity user, AdminViewModel adminVM) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user.displayName),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: user.photoUrl.isNotEmpty
                        ? NetworkImage(user.photoUrl)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),

                _buildDetailRow('Email', user.email),
                _buildDetailRow('User ID', user.uid),
                _buildDetailRow('Display ID', user.displayId),
                _buildDetailRow('Account Created', DateFormat('dd/MM/yyyy HH:mm').format(user.createdAt)),
                _buildDetailRow('Role', user.role.name.toUpperCase()),
                _buildDetailRow('Status', user.status.name.toUpperCase()),

                if (user.currentPlanId != null)
                  _buildDetailRow('Current Plan', user.currentPlanId!),

                if (user.subscriptionEnd != null)
                  _buildDetailRow('Subscription End', DateFormat('dd/MM/yyyy').format(user.subscriptionEnd!)),

                _buildDetailRow('Trial Used', user.isTrialUsed ? 'Yes' : 'No'),
                _buildDetailRow('Trial End', DateFormat('dd/MM/yyyy').format(user.trialEndDate)),

                const SizedBox(height: 16),
                const Text(
                  'Account Age',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${DateTime.now().difference(user.createdAt).inDays} days'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            if (context.read<AuthViewModel>().canManageUser(user))
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showEditUserDialog(context, user, adminVM);
                },
                child: const Text('Edit User'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Text(value),
        ],
      ),
    );
  }

  // ============================================
  // EDIT USER DIALOG
  // ============================================
  void _showEditUserDialog(BuildContext context, UserEntity user, AdminViewModel adminVM) {
    UserRole selectedRole = user.role;
    UserStatus selectedStatus = user.status;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit User'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Role Selection
                    const Text('Select Role:', textAlign: TextAlign.left),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: UserRole.values.map((role) {
                        return FilterChip(
                          label: Text(role.name.toUpperCase()),
                          selected: selectedRole == role,
                          onSelected: (bool selected) {
                            setState(() => selectedRole = role);
                          },
                          backgroundColor: _getRoleColor(role, false),
                          selectedColor: _getRoleColor(role, true),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Status Selection
                    const Text('Select Status:', textAlign: TextAlign.left),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: UserStatus.values.map((status) {
                        return FilterChip(
                          label: Text(status.name.toUpperCase()),
                          selected: selectedStatus == status,
                          onSelected: (bool selected) {
                            setState(() => selectedStatus = status);
                          },
                          backgroundColor: _getStatusColor(status, false),
                          selectedColor: _getStatusColor(status, true),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedRole != user.role) {
                      adminVM.updateUserRole(user.uid, selectedRole);
                    }
                    if (selectedStatus != user.status) {
                      adminVM.updateUserStatus(user.uid, selectedStatus);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _getRoleColor(UserRole role, bool selected) {
    switch (role) {
      case UserRole.admin:
        return selected ? Colors.red : Colors.red[100]!;
      case UserRole.moderator:
        return selected ? Colors.orange : Colors.orange[100]!;
      case UserRole.user:
        return selected ? Colors.blue : Colors.blue[100]!;
    }
  }

  Color _getStatusColor(UserStatus status, bool selected) {
    switch (status) {
      case UserStatus.free:
        return selected ? Colors.green : Colors.green[100]!;
      case UserStatus.pro:
        return selected ? Colors.purple : Colors.purple[100]!;
      case UserStatus.expired:
        return selected ? Colors.amber : Colors.amber[100]!;
      case UserStatus.suspended:
        return selected ? Colors.red : Colors.red[100]!;
    }
  }

  // ============================================
  // CONFIRM ACTION DIALOG
  // ============================================
  void _confirmAction(
      BuildContext context, {
        required String title,
        required String message,
        required Function action,
      }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              action();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: title.toLowerCase().contains('suspend')
                  ? Colors.red
                  : Colors.green,
            ),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}