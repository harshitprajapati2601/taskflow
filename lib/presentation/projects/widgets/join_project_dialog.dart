import 'package:flutter/material.dart';
import 'package:taskflow/presentation/projects/cubit/project_cubit.dart';

class JoinProjectDialog extends StatefulWidget {
  final ProjectCubit cubit;

  const JoinProjectDialog({
    super.key,
    required this.cubit
  });

  @override
  State<JoinProjectDialog> createState() => _JoinProjectDialogState();
}

class _JoinProjectDialogState extends State<JoinProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final error = await widget.cubit.joinProject(_codeController.text);

    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _loading = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Join a project'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                maxLength: 6,
                autocorrect: false,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText: 'Invite code',
                  prefixIcon: Icon(Icons.vpn_key_outlined),
                  counterText: '',
                ),
                validator: (v) => (v == null || v.trim().length != 6)
                    ? 'Enter the 6-character code'
                    : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: scheme.error)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text('Join'),
        ),
      ],
    );
  }
}
