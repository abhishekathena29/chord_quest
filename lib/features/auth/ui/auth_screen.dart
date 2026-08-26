import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../core/widgets/mesh_background.dart';
import '../../../core/widgets/shapes.dart';
import '../../shell/ui/main_shell.dart';
import '../provider/auth_provider.dart';

/// Sign-in / sign-up screen on the glass aesthetic.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const _AuthView(),
    );
  }
}

class _AuthView extends StatelessWidget {
  const _AuthView();

  Future<void> _submit(BuildContext context) async {
    final provider = context.read<AuthProvider>();
    final ok = await provider.submit();
    if (ok && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();
    return Scaffold(
      body: MeshBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brand mark
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryContainer
                                .withValues(alpha: 0.5),
                            blurRadius: 50,
                            spreadRadius: 6,
                          ),
                        ],
                      ),
                      child: ClipPath(
                        clipper: HexagonClipper(),
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: const BoxDecoration(
                            gradient:
                                LinearGradient(colors: AppColors.brandGradient),
                          ),
                          child: const Icon(Icons.music_note,
                              color: AppColors.onPrimary, size: 44),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GradientText('MelodyQuest',
                        style: AppTypography.headlineLg),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      provider.isSignIn
                          ? 'Welcome back, shredder.'
                          : 'Start your guitar journey.',
                      style: AppTypography.bodyMd,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ModeToggle(provider: provider),
                          const SizedBox(height: AppSpacing.md),
                          if (!provider.isSignIn) ...[
                            const _GlassField(
                              label: 'Name',
                              hint: 'Jaxon Storm',
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                          const _GlassField(
                            label: 'Email',
                            hint: 'you@melodyquest.com',
                            icon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _GlassField(
                            label: 'Password',
                            hint: '••••••••',
                            icon: Icons.lock_outline,
                            obscure: provider.obscurePassword,
                            trailing: IconButton(
                              onPressed: provider.toggleObscure,
                              icon: Icon(
                                provider.obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.onSurfaceVariant,
                                size: 20,
                              ),
                            ),
                          ),
                          if (provider.isSignIn)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: Text(
                                  'Forgot password?',
                                  style: AppTypography.labelSm.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: AppSpacing.sm),
                          GradientButton(
                            label: provider.loading
                                ? 'Please wait…'
                                : (provider.isSignIn
                                    ? 'Sign In'
                                    : 'Create Account'),
                            icon: provider.loading ? null : Icons.arrow_forward,
                            onPressed: provider.loading
                                ? null
                                : () => _submit(context),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const _OrDivider(),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: _SocialButton(
                                  icon: Icons.g_mobiledata,
                                  label: 'Google',
                                  onTap: () => _submit(context),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _SocialButton(
                                  icon: Icons.apple,
                                  label: 'Apple',
                                  onTap: () => _submit(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.provider});

  final AuthProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          _seg('Sign In', provider.isSignIn,
              () => provider.isSignIn ? null : provider.toggleMode()),
          _seg('Sign Up', !provider.isSignIn,
              () => provider.isSignIn ? provider.toggleMode() : null),
        ],
      ),
    );
  }

  Widget _seg(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(colors: AppColors.brandGradient)
                : null,
            borderRadius: BorderRadius.circular(AppRadius.base),
          ),
          child: Text(
            label,
            style: AppTypography.labelMd.copyWith(
              color: active ? AppColors.onPrimary : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// Ghost-style input: semi-transparent fill that glows primary on focus.
class _GlassField extends StatefulWidget {
  const _GlassField({
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.trailing,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? trailing;
  final TextInputType? keyboardType;

  @override
  State<_GlassField> createState() => _GlassFieldState();
}

class _GlassFieldState extends State<_GlassField> {
  final FocusNode _node = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _node.addListener(() => setState(() => _focused = _node.hasFocus));
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTypography.labelSm),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: _focused ? AppColors.primary : AppColors.outlineVariant,
              width: _focused ? 1.5 : 1,
            ),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: AppColors.primaryContainer.withValues(alpha: 0.4),
                      blurRadius: 14,
                    ),
                  ]
                : null,
          ),
          child: TextField(
            focusNode: _node,
            obscureText: widget.obscure,
            keyboardType: widget.keyboardType,
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
            decoration: InputDecoration(
              prefixIcon: Icon(widget.icon,
                  color: AppColors.onSurfaceVariant, size: 20),
              suffixIcon: widget.trailing,
              hintText: widget.hint,
              hintStyle: AppTypography.bodyMd
                  .copyWith(color: AppColors.outline, fontSize: 15),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text('or continue with', style: AppTypography.labelSm),
        ),
        const Expanded(child: Divider(color: AppColors.outlineVariant)),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.onSurface, size: 22),
            const SizedBox(width: 6),
            Text(label, style: AppTypography.labelMd),
          ],
        ),
      ),
    );
  }
}
