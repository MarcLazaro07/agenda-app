import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/providers.dart';
import '../../../models/contact_model.dart';
import '../widgets/contact_tile.dart';
import '../widgets/contact_avatar.dart';
import 'contact_detail_screen.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final allContacts = ref.watch(contactsProvider);
          final myProfile = allContacts.firstWhere(
            (c) => c.isMyProfile,
            orElse: () => const ContactModel(
              id: 'me',
              name: 'Mi Perfil',
              isMyProfile: true,
            ),
          );
          final contacts = allContacts.where((c) => !c.isMyProfile).toList()
            ..sort((a, b) => a.name.compareTo(b.name));

          // Group by first letter
          final grouped = <String, List<ContactModel>>{};
          for (final contact in contacts) {
            final letter = contact.name.isNotEmpty
                ? contact.name[0].toUpperCase()
                : '?';
            grouped.putIfAbsent(letter, () => []).add(contact);
          }

          final sortedKeys = grouped.keys.toList()..sort();

          return CustomScrollView(
            slivers: [
              // ─── Header ───
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Text('Contactos', style: theme.textTheme.displaySmall),
                ),
              ),

              // ─── My Profile ───
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                sliver: SliverToBoxAdapter(
                  child: Card(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ContactDetailScreen(contact: myProfile),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            ContactAvatar(
                              name: 'Yo',
                              size: 48,
                              isPlaceholder: true,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mi Perfil',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Editar información personal',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              LucideIcons.chevronRight,
                              size: 18,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ─── Alphabetical list ───
              for (final letter in sortedKeys) ...[
                // ─── Letter header ───
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      letter,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                // ─── Contacts under letter ───
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final contact = grouped[letter]![index];
                      return ContactTile(
                        contact: contact,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ContactDetailScreen(contact: contact),
                            ),
                          );
                        },
                      );
                    }, childCount: grouped[letter]!.length),
                  ),
                ),
              ],

              // Bottom spacing
              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          );
        },
      ),
    );
  }
}
