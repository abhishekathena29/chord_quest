import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/session/user_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/gradient_button.dart';
import '../provider/auth_provider.dart';

/// Sign-in / sign-up screen: flat fields on a plain background, one bold
/// headline, one button, and a plain text link to switch modes — no tabs,
/// no social login.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(context.read<UserSession>()),
      child: const _AuthView(),
    );
  }
}

class _AuthView extends StatelessWidget {
  const _AuthView();

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<AuthProvider>().submit();
  }

  Future<void> _forgotPassword(BuildContext context) async {
    final sent = await context.read<AuthProvider>().sendPasswordReset();
    if (!sent || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset email sent. Check your inbox.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Text(
                        provider.isSignIn
                            ? 'Welcome back'
                            : 'Create new account',
                        key: ValueKey(provider.isSignIn),
                        textAlign: TextAlign.center,
                        style: AppTypography.headlineLg,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      provider.isSignIn
                          ? 'Sign in to continue your guitar journey.'
                          : 'Please fill in the form to continue.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMd,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (!provider.isSignIn) ...[
                      _FlatField(
                        hint: 'Full name',
                        controller: provider.nameController,
                        keyboardType: TextInputType.name,
                        autofillHints: const [AutofillHints.name],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    _FlatField(
                      hint: 'Email address',
                      controller: provider.emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _FlatField(
                      hint: 'Password',
                      controller: provider.passwordController,
                      obscure: provider.obscurePassword,
                      trailing: _ObscureToggle(provider: provider),
                      autofillHints: [
                        provider.isSignIn
                            ? AutofillHints.password
                            : AutofillHints.newPassword,
                      ],
                      onSubmitted: (_) => _submit(context),
                    ),
                    if (provider.isSignIn)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: provider.loading
                              ? null
                              : () => _forgotPassword(context),
                          child: Text(
                            'Forgot password?',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    if (provider.error != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        provider.error!,
                        textAlign: TextAlign.center,
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    GradientButton(
                      label: provider.loading
                          ? 'Please wait…'
                          : (provider.isSignIn ? 'Sign In' : 'Sign Up'),
                      onPressed: provider.loading
                          ? null
                          : () => _submit(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Plain-text mode switcher — no segmented tab control.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          provider.isSignIn
                              ? "Don't have an account?"
                              : 'Already have an account?',
                          style: AppTypography.bodyMd,
                        ),
                        TextButton(
                          onPressed: provider.loading
                              ? null
                              : provider.toggleMode,
                          child: Text(
                            provider.isSignIn ? 'Sign Up' : 'Login',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
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

class _ObscureToggle extends StatelessWidget {
  const _ObscureToggle({required this.provider});

  final AuthProvider provider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: provider.toggleObscure,
        child: Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.onSurface,
            shape: BoxShape.circle,
          ),
          child: Icon(
            provider.obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.white,
            size: 14,
          ),
        ),
      ),
    );
  }
}

/// Flat, borderless-until-focused input matching the reference form fields.
class _FlatField extends StatefulWidget {
  const _FlatField({
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.trailing,
    this.keyboardType,
    this.autofillHints,
    this.onSubmitted,
  });

  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final Widget? trailing;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  @override
  State<_FlatField> createState() => _FlatFieldState();
}

class _FlatFieldState extends State<_FlatField> {
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: _focused ? AppColors.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _node,
        obscureText: widget.obscure,
        keyboardType: widget.keyboardType,
        autofillHints: widget.autofillHints,
        autocorrect: false,
        textInputAction: widget.onSubmitted != null
            ? TextInputAction.done
            : TextInputAction.next,
        onSubmitted: widget.onSubmitted,
        style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
        decoration: InputDecoration(
          suffixIcon: widget.trailing,
          hintText: widget.hint,
          hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.outline),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
        ),
      ),
    );
  }
}
