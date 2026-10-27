import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/auth_service.dart';
import '../../../core/data/models/practice_session.dart';
import '../../../core/session/user_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../shell/provider/nav_provider.dart';
import '../provider/profile_provider.dart';

/// "Guitarist Profile" — avatar header, bento stats grid, earned badges, the
/// weekly practice challenge, recent sessions and account actions. Everything
/// is derived live from the signed-in player's [UserSession].
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<UserSession>();
    final p = ProfileView(session.profile);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      children: [
        _Header(provider: p),
        const SizedBox(height: AppSpacing.lg),
        Text('Guitarist Profile', style: AppTypography.headlineLgMobile),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.15,
          children: [for (final s in p.stats) _StatCard(stat: s)],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Earned Badges', style: AppTypography.headlineMd),
            Text(
              '${p.earnedBadges} / ${p.badges.length}',
              style: AppTypography.labelMd.copyWith(color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            alignment: WrapAlignment.spaceEvenly,
            children: [for (final b in p.badges) _BadgeTile(badge: b)],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Active Mission', style: AppTypography.headlineMd),
        const SizedBox(height: AppSpacing.md),
        _ChallengeCard(provider: p),
        const SizedBox(height: AppSpacing.lg),
        Text('Recent Sessions', style: AppTypography.headlineMd),
        const SizedBox(height: AppSpacing.md),
        _RecentSessions(sessions: session.recentSessions),
        const SizedBox(height: AppSpacing.lg),
        Text('Account', style: AppTypography.headlineMd),
        const SizedBox(height: AppSpacing.md),
        _AccountCard(email: session.user?.email ?? ''),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.provider});

  final ProfileView provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 128,
              height: 128,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                    AppColors.tertiary,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.inverseSurface,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const Icon(
                  Icons.person,
                  size: 64,
                  color: AppColors.inverseOnSurface,
                ),
              ),
            ),
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${provider.level}',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(provider.name, style: AppTypography.headlineLg),
        const SizedBox(height: AppSpacing.xs),
        Text(
          provider.rank,
          style: AppTypography.headlineMd.copyWith(color: AppColors.secondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            if (provider.skillLabel != null)
              _infoChip(Icons.music_note, provider.skillLabel!),
            if (provider.joined != null)
              _infoChip(Icons.calendar_today, provider.joined!),
          ],
        ),
      ],
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(text, style: AppTypography.labelSm),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final ProfileStat stat;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(stat.icon, color: stat.color, size: 26),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            stat.value,
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          Text(stat.label, style: AppTypography.labelSm),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});

  final ProfileBadge badge;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: badge.locked ? 0.5 : 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: badge.colors,
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                badge.icon,
                color: badge.locked
                    ? AppColors.onSurfaceVariant
                    : badge.colors.last,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          SizedBox(
            width: 72,
            child: Text(
              badge.label,
              textAlign: TextAlign.center,
              style: AppTypography.labelSm.copyWith(
                color: badge.locked
                    ? AppColors.onSurfaceVariant
                    : AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.provider});

  final ProfileView provider;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      accentColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.base),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.onPrimaryContainer,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'WEEKLY CHALLENGE',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(provider.challengeTitle, style: AppTypography.headlineMd),
          const SizedBox(height: AppSpacing.base),
          Text(provider.challengeBody, style: AppTypography.bodyMd),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress', style: AppTypography.labelSm),
              Text(
                '${(provider.challengeProgress * 100).round()}%',
                style: AppTypography.labelSm,
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: provider.challengeProgress,
              minHeight: 12,
              backgroundColor: AppColors.surfaceContainer,
              valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GradientButton(
            label: 'Practice Now',
            icon: Icons.arrow_forward,
            onPressed: () => context.read<NavProvider>().select(NavTab.learn),
          ),
        ],
      ),
    );
  }
}

class _RecentSessions extends StatelessWidget {
  const _RecentSessions({required this.sessions});

  final List<PracticeSession> sessions;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return AppCard(
        child: Text(
          'No sessions yet. Tap the record button to start practising.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMd,
        ),
      );
    }
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.base,
      ),
      child: Column(
        children: [
          for (final s in sessions)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                s.completed ? Icons.check_circle : Icons.music_note,
                color: s.completed
                    ? const Color(0xFF059669)
                    : AppColors.onSurfaceVariant,
              ),
              title: Text(s.songTitle, style: AppTypography.labelMd),
              subtitle: Text(
                '${_date(s.startedAt)} • '
                '${ProfileView.formatDuration(s.durationSeconds)} • '
                '${s.notesHit} notes',
                style: AppTypography.labelSm,
              ),
              trailing: Text(
                '+${s.xpEarned} XP',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _date(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.email});

  final String email;

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('Your progress is saved to your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<UserSession>().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.base,
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.mail_outline),
            title: Text('Signed in as', style: AppTypography.labelSm),
            subtitle: Text(email, style: AppTypography.labelMd),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout),
            title: Text('Sign out', style: AppTypography.labelMd),
            onTap: () => _signOut(context),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_outline, color: AppColors.error),
            title: Text(
              'Delete account',
              style: AppTypography.labelMd.copyWith(color: AppColors.error),
            ),
            subtitle: Text(
              'Permanently erase your account and all progress',
              style: AppTypography.labelSm,
            ),
            onTap: () => showDialog<void>(
              context: context,
              builder: (_) => const _DeleteAccountDialog(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Asks for the password (Firebase requires a recent sign-in) before wiping
/// the player's data and account.
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  Future<void> _delete() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<UserSession>().deleteAccount(_password.text);
      if (mounted) Navigator.of(context).pop();
    } on AuthFailure catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Could not delete your account. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete account?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This permanently deletes your account, practice history and '
            'progress. This cannot be undone.',
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _password,
            obscureText: true,
            enabled: !_busy,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Confirm your password',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.base),
            Text(
              _error!,
              style: AppTypography.labelSm.copyWith(color: AppColors.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _busy || _password.text.isEmpty ? null : _delete,
          child: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  'Delete',
                  style: TextStyle(color: AppColors.error),
                ),
        ),
      ],
    );
  }
}
