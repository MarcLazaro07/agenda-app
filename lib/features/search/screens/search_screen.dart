import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../providers/providers.dart';
import '../../../models/event_model.dart';
import '../../../models/contact_model.dart';
import '../../../models/category_model.dart';
import '../../events/screens/event_detail_screen.dart';
import '../../contacts/screens/contact_detail_screen.dart';
import '../../contacts/widgets/contact_avatar.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

enum SearchFilter { all, events, contacts }

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  SearchFilter _filter = SearchFilter.all;
  String _query = '';

  // Advanced Filters
  DateTime? _filterDate;
  EventPriority? _filterPriority;
  String? _filterCategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EventModel> _getFilteredEvents(List<EventModel> events) {
    if (_filter == SearchFilter.contacts) return [];

    return events.where((e) {
      if (_query.isNotEmpty &&
          !e.title.toLowerCase().contains(_query.toLowerCase())) {
        return false;
      }
      if (_filterDate != null) {
        if (e.date.year != _filterDate!.year ||
            e.date.month != _filterDate!.month ||
            e.date.day != _filterDate!.day) {
          return false;
        }
      }
      if (_filterPriority != null && e.priority != _filterPriority) {
        return false;
      }
      if (_filterCategoryId != null && e.categoryId != _filterCategoryId) {
        return false;
      }
      return true;
    }).toList();
  }

  List<ContactModel> _getFilteredContacts(List<ContactModel> contacts) {
    if (_filter == SearchFilter.events) return [];
    if (_query.isEmpty) return contacts.where((c) => !c.isMyProfile).toList();
    return contacts
        .where(
          (c) =>
              !c.isMyProfile &&
              c.name.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
  }

  String _getPriorityName(EventPriority p) {
    switch (p) {
      case EventPriority.high:
        return 'Alta';
      case EventPriority.medium:
        return 'Media';
      case EventPriority.low:
        return 'Baja';
    }
  }

  void _showPriorityFilter() {
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
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Filtrar por prioridad',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              ...EventPriority.values.map((p) {
                return ListTile(
                  title: Text(_getPriorityName(p)),
                  onTap: () {
                    setState(() => _filterPriority = p);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Filtrar por categoría',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                ...ref.read(categoriesProvider).map((c) {
                  return ListTile(
                    leading: CircleAvatar(radius: 8, backgroundColor: c.color),
                    title: Text(c.name),
                    onTap: () {
                      setState(() => _filterCategoryId = c.id);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
                if (isActive && onClear != null) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onClear,
                    child: Icon(
                      LucideIcons.x,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final events = ref.watch(eventsProvider);
    final contacts = ref.watch(contactsProvider);
    final categories = ref.watch(categoriesProvider);

    final filteredEvents = _getFilteredEvents(events);
    final filteredContacts = _getFilteredContacts(contacts);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ───
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text('Buscar', style: theme.textTheme.displaySmall),
          ),

          // ─── Search bar ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              autofocus: false,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Buscar eventos, contactos...',
                prefixIcon: Icon(
                  LucideIcons.search,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: Icon(
                          LucideIcons.x,
                          size: 18,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),

          // ─── Filter chips ───
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: SearchFilter.values.map((f) {
                  final isSelected = f == _filter;
                  final label = switch (f) {
                    SearchFilter.all => 'Todo',
                    SearchFilter.events => 'Eventos',
                    SearchFilter.contacts => 'Contactos',
                  };
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _filter = f;
                        // Reset advanced filters if we go to Contacts
                        if (f == SearchFilter.contacts) {
                          _filterDate = null;
                          _filterPriority = null;
                          _filterCategoryId = null;
                        }
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withValues(
                                  alpha: 0.12,
                                )
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline.withValues(
                                    alpha: 0.5,
                                  ),
                          ),
                        ),
                        child: Text(
                          label,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ─── Advanced Event Filters ───
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child:
                _filter == SearchFilter.events ||
                    _filterDate != null ||
                    _filterPriority != null ||
                    _filterCategoryId != null
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: _filterDate == null
                                ? 'Fecha'
                                : DateFormat('dd MMM').format(_filterDate!),
                            icon: LucideIcons.calendar,
                            isActive: _filterDate != null,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _filterDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null)
                                setState(() => _filterDate = date);
                            },
                            onClear: () => setState(() => _filterDate = null),
                          ),
                          _buildFilterChip(
                            label: _filterPriority == null
                                ? 'Prioridad'
                                : _getPriorityName(_filterPriority!),
                            icon: LucideIcons.alertCircle,
                            isActive: _filterPriority != null,
                            onTap: _showPriorityFilter,
                            onClear: () =>
                                setState(() => _filterPriority = null),
                          ),
                          _buildFilterChip(
                            label: _filterCategoryId == null
                                ? 'Categoría'
                                : categories
                                      .firstWhere(
                                        (c) => c.id == _filterCategoryId,
                                        orElse: () => const CategoryModel(
                                          id: 'fallback',
                                          name: 'General',
                                          color: Colors.grey,
                                        ),
                                      )
                                      .name,
                            icon: LucideIcons.tag,
                            isActive: _filterCategoryId != null,
                            onTap: _showCategoryFilter,
                            onClear: () =>
                                setState(() => _filterCategoryId = null),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(height: 8),
          ),

          // ─── Results ───
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Events results
                ...filteredEvents.map((event) {
                  final category = categories.firstWhere(
                    (c) => c.id == event.categoryId,
                    orElse: () => const CategoryModel(
                      id: 'fallback',
                      name: 'General',
                      color: Colors.grey,
                    ),
                  );
                  return _SearchResultEvent(
                    event: event,
                    categoryColor: category.color,
                    categoryName: category.name,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EventDetailScreen(event: event),
                        ),
                      );
                    },
                  );
                }),
                // Contacts results
                ...filteredContacts.map((contact) {
                  return _SearchResultContact(
                    contact: contact,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ContactDetailScreen(contact: contact),
                        ),
                      );
                    },
                  );
                }),
                if (filteredEvents.isEmpty && filteredContacts.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Column(
                        children: [
                          Icon(
                            LucideIcons.searchX,
                            size: 48,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Sin resultados',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultEvent extends StatelessWidget {
  final EventModel event;
  final Color categoryColor;
  final String categoryName;
  final VoidCallback onTap;

  const _SearchResultEvent({
    required this.event,
    required this.categoryColor,
    required this.categoryName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 36,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          categoryName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: categoryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (event.time != null) ...[
                          Text(
                            ' · ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          Text(
                            event.time!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.calendar,
                size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultContact extends StatelessWidget {
  final ContactModel contact;
  final VoidCallback onTap;

  const _SearchResultContact({required this.contact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            children: [
              ContactAvatar(name: contact.name, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  contact.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                LucideIcons.user,
                size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
