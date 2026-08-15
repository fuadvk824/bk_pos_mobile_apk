import 'package:bk_pos/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/auth_provider.dart';

class AuthLoginScreen extends ConsumerStatefulWidget {
  const AuthLoginScreen({super.key});

  @override
  ConsumerState<AuthLoginScreen> createState() => _AuthLoginScreenState();
}

class _AuthLoginScreenState extends ConsumerState<AuthLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  bool isUsernameLogin = false;
  bool isObscure = true;

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }

    final emailRegex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }

    return null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username wajib diisi';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }

    return null;
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final errorMessage = await ref
        .read(authProvider.notifier)
        .login(loginController.text.trim(), passwordController.text);

    if (!mounted) return;

    // =========================
    // LOGIN GAGAL
    // =========================
    if (errorMessage != null) {
      AppToast.error(title: 'Login gagal', description: errorMessage);

      return;
    }

    // =========================
    // LOGIN BERHASIL
    // =========================
    AppToast.success(
      title: 'Login berhasil',
      description: 'Selamat datang kembali',
    );
  }

  void changeLoginType(bool username) {
    setState(() {
      isUsernameLogin = username;
      loginController.clear();
      passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // final authState = ref.watch(authProvider);
    // final isLoading = authState.isLoading;
    final isLoading = ref.watch(authLoadingProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.black.withValues(alpha: 0.05),
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'BK POS',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Login ke akun kamu',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment<bool>(
                              value: false,
                              icon: Icon(Icons.email_outlined),
                              label: Text('Email'),
                            ),
                            ButtonSegment<bool>(
                              value: true,
                              icon: Icon(Icons.person_outline),
                              label: Text('Username'),
                            ),
                          ],
                          selected: {isUsernameLogin},
                          onSelectionChanged: isLoading
                              ? null
                              : (value) {
                                  changeLoginType(value.first);
                                },
                        ),
                      ),

                      const SizedBox(height: 24),

                      TextFormField(
                        controller: loginController,
                        validator: isUsernameLogin
                            ? validateUsername
                            : validateEmail,
                        keyboardType: isUsernameLogin
                            ? TextInputType.text
                            : TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          labelText: isUsernameLogin ? 'Username' : 'Email',
                          hintText: isUsernameLogin
                              ? 'Masukkan username'
                              : 'Masukkan email',
                          prefixIcon: Icon(
                            isUsernameLogin
                                ? Icons.person_outline
                                : Icons.email_outlined,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: passwordController,
                        validator: validatePassword,
                        obscureText: isObscure,
                        textInputAction: TextInputAction.done,
                        enabled: !isLoading,
                        onFieldSubmitted: (_) {
                          if (!isLoading) {
                            submit();
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Masukkan password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                          suffixIcon: IconButton(
                            tooltip: isObscure
                                ? 'Tampilkan password'
                                : 'Sembunyikan password',
                            icon: Icon(
                              isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: isLoading
                                ? null
                                : () {
                                    setState(() {
                                      isObscure = !isObscure;
                                    });
                                  },
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : submit,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../provider/auth_provider.dart';

// class AuthLoginScreen extends ConsumerStatefulWidget {
//   const AuthLoginScreen({super.key});

//   @override
//   ConsumerState<AuthLoginScreen> createState() => _AuthLoginScreenState();
// }

// class _AuthLoginScreenState extends ConsumerState<AuthLoginScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final email = TextEditingController();
//   final password = TextEditingController();

//   bool isObscure = true;


//   String? validateEmail(String? value) {
//     if (value == null || value.isEmpty) {
//       return "Email wajib diisi";
//     }

//     final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

//     if (!emailRegex.hasMatch(value)) {
//       return "Format email tidak valid";
//     }

//     return null;
//   }

//   String? validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return "Password wajib diisi";
//     }
//     return null;
//   }

//   Future<void> submit() async {
//     if (!_formKey.currentState!.validate()) return;

//     await ref.read(authProvider.notifier).login(email.text, password.text);

//     if (!mounted) return;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authProvider);
//     final isLoading = authState.isLoading;

//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   blurRadius: 20,
//                   color: Colors.black.withValues(alpha: .05),
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text(
//                     "BK POS",
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     "Login ke akun kamu",
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                   const SizedBox(height: 30),
//                   // EMAIL
//                   TextFormField(
//                     controller: email,
//                     validator: validateEmail,
//                     keyboardType: TextInputType.emailAddress,
//                     decoration: InputDecoration(
//                       labelText: "Email",
//                       prefixIcon: const Icon(Icons.email_outlined),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 16),
                  
//                   // PASSWORD
//                   TextFormField(
//                     controller: password,
//                     validator: validatePassword,
//                     obscureText: isObscure,
//                     decoration: InputDecoration(
//                       labelText: "Password",
//                       prefixIcon: const Icon(Icons.lock_outline),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           isObscure ? Icons.visibility_off : Icons.visibility,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             isObscure = !isObscure;
//                           });
//                         },
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   // BUTTON
//                   SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton(
//                       // onPressed: auth.isLoading ? null : submit,
//                       onPressed: isLoading ? null : submit,
//                       style: ElevatedButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                       ),
//                       child: isLoading
//                           ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 color: Colors.white,
//                               ),
//                             )
//                           : const Text("Login", style: TextStyle(fontSize: 16)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

