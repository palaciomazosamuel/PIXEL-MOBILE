import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../../../main_navigation/presentation/screens/main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted || !success) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MainNavigationScreen()),
    );
  }

  void _openRecovery() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RecoverySheet(initialEmail: _emailController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FF),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.zero,
          children: [
            _LoginHeader(),
            Transform.translate(
              offset: const Offset(0, -34),
              child: _LoginPanel(
                emailController: _emailController,
                passwordController: _passwordController,
                obscurePassword: _obscurePassword,
                onTogglePassword: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                onRecovery: _openRecovery,
                onSubmit: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 330,
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 54),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF581C87), Color(0xFF831843), Color(0xFF1E40AF)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -80,
            right: -70,
            bottom: -60,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            right: -64,
            bottom: 14,
            child: Container(
              width: 190,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  tooltip: 'Volver',
                ),
              ),
              const SizedBox(height: 14),
              Image.asset(
                'assets/images/pixel-logo-gradient.png',
                width: 232,
                height: 76,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              const Text(
                'Bienvenido',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Inicia sesión para continuar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onRecovery,
    required this.onSubmit,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onRecovery;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 18),
          padding: const EdgeInsets.fromLTRB(20, 44, 20, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Color(0x140F172A),
                blurRadius: 28,
                offset: Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _LoginField(
                controller: emailController,
                icon: Icons.person,
                hintText: 'Correo electrónico',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              _LoginField(
                controller: passwordController,
                icon: Icons.lock_outline,
                hintText: 'Contraseña',
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onSubmit(),
                trailing: IconButton(
                  onPressed: onTogglePassword,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: authProvider.isLoading ? null : onRecovery,
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ),
              if (authProvider.errorMessage != null) ...[
                const SizedBox(height: 8),
                _StatusMessage(
                  message: authProvider.errorMessage!,
                  tone: _StatusTone.error,
                ),
              ],
              if (authProvider.recoveryMessage != null) ...[
                const SizedBox(height: 8),
                _StatusMessage(
                  message: authProvider.recoveryMessage!,
                  tone: _StatusTone.success,
                ),
              ],
              if (!AppConfig.hasApiBaseUrl) ...[
                const SizedBox(height: 8),
                const _StatusMessage(
                  message: 'Configura PIXEL_API_URL para usar datos reales del backend.',
                  tone: _StatusTone.error,
                ),
              ],
              const SizedBox(height: 22),
              SizedBox(
                height: 58,
                child: FilledButton(
                  onPressed: authProvider.isLoading ? null : onSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.violet,
                    disabledBackgroundColor: AppColors.primarySoft,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  child: authProvider.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Login'),
                ),
              ),
              const SizedBox(height: 22),
              const _ReadOnlyNotice(),
            ],
          ),
        );
      },
    );
  }
}

class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.controller,
    required this.icon,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.trailing,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? trailing;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      autocorrect: false,
      enableSuggestions: false,
      onSubmitted: onSubmitted,
      style: AppTextStyles.bodyStrong.copyWith(fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyMuted.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, color: AppColors.violet),
        suffixIcon: trailing,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE6E2EF), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE6E2EF), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.violet, width: 1.7),
        ),
      ),
    );
  }
}

class _RecoverySheet extends StatefulWidget {
  const _RecoverySheet({required this.initialEmail});

  final String initialEmail;

  @override
  State<_RecoverySheet> createState() => _RecoverySheetState();
}

class _RecoverySheetState extends State<_RecoverySheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialEmail.trim());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _controller.text.trim();
    if (email.isEmpty) return;
    final success = await context.read<AuthProvider>().forgotPassword(
      email: email,
    );
    if (!mounted || !success) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final authProvider = context.watch<AuthProvider>();

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Recuperar contraseña', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Escribe tu correo y te enviaremos instrucciones si existe una cuenta asociada.',
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: 18),
            _LoginField(
              controller: _controller,
              icon: Icons.mail_outline,
              hintText: 'Correo electrónico',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: authProvider.isLoading ? null : _submit,
              child: Text(authProvider.isLoading ? 'Enviando...' : 'Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _StatusTone { error, success }

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.message, required this.tone});

  final String message;
  final _StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final isError = tone == _StatusTone.error;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFFF1F2) : AppColors.accentSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isError ? const Color(0xFFFFCCD5) : const Color(0xFFCBEFE4),
        ),
      ),
      child: Text(
        message,
        style: AppTextStyles.label.copyWith(
          color: isError ? AppColors.danger : AppColors.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ReadOnlyNotice extends StatelessWidget {
  const _ReadOnlyNotice();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Modo consulta: sin crear, editar, aprobar ni eliminar.',
      textAlign: TextAlign.center,
      style: AppTextStyles.label.copyWith(color: AppColors.muted),
    );
  }
}
