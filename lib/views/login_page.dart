import 'dart:ui';
import 'dart:math'; // Added for sparkles
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // simplified import
import 'package:otobix_crm/controllers/login_controller.dart';
import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/utils/app_images.dart';
import 'package:otobix_crm/widgets/button_widget.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final formKey = GlobalKey<FormState>();
  final LoginController getxController = Get.put(LoginController());

  // Local Design Constants
  static const Color neonGreen = Color(0xFFCCFF00); // High-vis neon green
  static const Color darkBackgroundStart = Color(0xFF000000);
  static const Color darkBackgroundEnd = Color(0xFF1A1A1A);
  static const Color glassWhite = Color(0x0DFFFFFF); // 5% opacity white
  static const Color glassBorder = Color(0x33FFFFFF); // 20% opacity white

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Dark Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [darkBackgroundStart, darkBackgroundEnd],
              ),
            ),
          ),

          // 2. Decorative Background Elements (Optional Glows)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: neonGreen.withOpacity(0.4),
                boxShadow: [
                  BoxShadow(
                    color: neonGreen.withOpacity(0.4),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withOpacity(0.4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.4),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          // 3. Moving Car (Animated)
          const MovingCarWidget(),

          // Sparkles (Background)
          const Positioned.fill(child: SparkleField()),

          // Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: glassWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: glassBorder, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildAppLogo(),
                          const SizedBox(height: 30),
                          _buildSignInText(),
                          const SizedBox(height: 40),
                          _buildCustomTextField(
                            icon: Icons.person_outline,
                            label: 'User Name / User ID',
                            controller: getxController.userNameController,
                            hintText: 'e.g. amitparekh007',
                            keyboardType: TextInputType.text,
                            isRequired: true,
                          ),
                          const SizedBox(height: 20),
                          _buildCustomTextField(
                            icon: Icons.lock_outline,
                            label: 'Password',
                            controller: getxController.passwordController,
                            hintText: 'e.g. amit123',
                            keyboardType: TextInputType.visiblePassword,
                            isRequired: true,
                            isPasswordField: true,
                          ),
                          const SizedBox(height: 20),
                          _buildCustomTextField(
                            label: 'Contact Number',
                            controller: getxController.phoneNumberController,
                            hintText: 'e.g. 9876543210',
                            limitLengthToTen: true,
                            keyboardType: TextInputType.phone,
                            isRequired: true,
                            onSubmitted: (value) {
                              getxController.loginUser();
                            },
                          ),
                          const SizedBox(height: 40),
                          _buildContinueButton(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... (rest of the file remains same until _buildContinueButton)

  Widget _buildAppLogo() {
    return Container(
      decoration: BoxDecoration(
        // Removed color fill for "remove background" effect
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3), // Slightly stronger border
          width: 1.5,
        ),
        boxShadow: [
          // Stronger deep shadow for 3D pop
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            offset: const Offset(8, 12),
            blurRadius: 20,
            spreadRadius: -2,
          ),
          // Inner rim glow for glass edge
          BoxShadow(
             color: Colors.white.withOpacity(0.2),
             offset: const Offset(-2, -2),
             blurRadius: 8,
             spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Stronger blur
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              // Removed gradient fill - purely transparent now
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20), // Rounding the logo image itself
              child: Image.asset(
                AppImages.appLogo,
                height: 120,
              ),
            ),
          ),
        ),
      ),
    );
  }



  // Welcome Text
  Widget _buildSignInText() => Column(
        children: [
          const Text(
            'Login',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please enter your details',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      );

  Widget _buildCustomTextField({
    IconData? icon,
    required String label,
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
    required bool isRequired,
    bool isPasswordField = false,
    bool limitLengthToTen = false,
    Function(String)? onSubmitted,
  }) {
    String? validator(String? value) {
      final text = value?.trim() ?? "";
      if (isRequired && text.isEmpty) return "$label is required";
      if (label == "User Name / User ID" && text.isNotEmpty && text.length < 4) {
        return "User ID must be at least 4 characters";
      }
      if (isPasswordField && text.isNotEmpty) {
        final msg = getxController.validatePassword(text);
        if (msg != null) return msg;
      }
      if (label == "Contact Number" && text.isNotEmpty) {
        if (!RegExp(r'^[0-9]{10}$').hasMatch(text)) {
          return "Enter a valid 10-digit phone number";
        }
      }
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Removed label Text and SizedBox as per user request
        !isPasswordField
            ? TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                style: const TextStyle(color: Colors.white),
                maxLength: limitLengthToTen ? 10 : null,
                validator: validator,
                onFieldSubmitted: onSubmitted,
                decoration: _inputDecoration(hintText, icon),
              )
            : Obx(
                () => TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: const TextStyle(color: Colors.white),
                  maxLength: limitLengthToTen ? 10 : null,
                  obscureText: isPasswordField
                      ? getxController.obsecureText.value
                      : false,
                  validator: validator,
                  decoration: _inputDecoration(hintText, icon).copyWith(
                    suffixIcon: isPasswordField
                        ? GestureDetector(
                            onTap: () => getxController.obsecureText.value =
                                !getxController.obsecureText.value,
                            child: Icon(
                              getxController.obsecureText.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.white54,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hintText, IconData? icon) {
    return InputDecoration(
      counterText: "",
      filled: true,
      fillColor: Colors.black.withOpacity(0.3),
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.white.withOpacity(0.3),
        fontWeight: FontWeight.w400,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      prefixIcon: Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 12, 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon != null
                ? Icon(icon, color: neonGreen, size: 22)
                : const Text(
                    '+91',
                    style: TextStyle(
                      fontSize: 14,
                      color: neonGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            const SizedBox(width: 12),
            Container(
              width: 1,
              height: 24,
              color: Colors.white.withOpacity(0.2),
            ),
          ],
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: neonGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.red.withOpacity(0.7)),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) => Obx(
        () => Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [neonGreen, Color(0xFFAACC00)],
            ),
            boxShadow: [
              BoxShadow(
                color: neonGreen.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: getxController.isLoading.value
                  ? null
                  : () {
                      getxController.loginUser();
                    },
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: getxController.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ),
      );
}

class MovingCarWidget extends StatefulWidget {
  const MovingCarWidget({super.key});

  @override
  State<MovingCarWidget> createState() => _MovingCarWidgetState();
}

class _MovingCarWidgetState extends State<MovingCarWidget>
    with TickerProviderStateMixin {
  late final AnimationController _moveController;
  late final AnimationController _lightController;

  @override
  void initState() {
    super.initState();
    // Movement animation
    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // Headlight blinking animation (Dipper effect)
    _lightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), 
    )..repeat(reverse: false); // Custom repeating pattern via TweenSequence is better, or just repeat
  }

  @override
  void dispose() {
    _moveController.dispose();
    _lightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_moveController, _lightController]),
      builder: (context, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        const carWidth = 350.0;
        final startX = -carWidth;
        final endX = screenWidth + 200;
        
        final currentX = startX + (endX - startX) * _moveController.value;

        // Flicker effect calculation
        // Simulating a "dipper" flash pattern: High -> Low -> High -> Low with pauses
        // Using sine wave or simple threshold for "flicker"
        final flickerValue = _lightController.value;
        // Create a double blink effect: 
        // 0.0-0.2: On, 0.2-0.3: Off, 0.3-0.5: On, 0.5-1.0: Off (Pause)
        double lightOpacity = 0.0;
        if (flickerValue < 0.1) {
          lightOpacity = 0.2; // Dim
        } else if (flickerValue < 0.2) {
          lightOpacity = 1.0; // Bright flash 1
        } else if (flickerValue < 0.3) {
          lightOpacity = 0.2; // Dim
        } else if (flickerValue < 0.4) {
          lightOpacity = 1.0; // Bright flash 2
        } else {
          lightOpacity = 0.2; // Dim (resting state)
        }

        return Positioned(
          bottom: 20,
          left: currentX,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Headlights (Front - Torch Beam) - BEHIND CAR
              Positioned(
                right: -180, // Extend beam further
                bottom: 0, // Align with car headlight (moved up from -20)
                child: Opacity(
                  opacity: lightOpacity,
                  child: CustomPaint(
                    size: const Size(200, 120), 
                    painter: HeadlightBeamPainter(),
                  ),
                ),
              ),
              
               // 2. Tail Light (Rear) - BEHIND CAR
              Positioned(
                left: 10,
                bottom: 65,
                child: Opacity(
                  opacity: lightOpacity, 
                  child: Container(
                    width: 20,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent,
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Car Image - ON TOP
              Opacity(
                opacity: 0.9,
                child: Image.asset(
                  AppImages.carAnimation,
                  width: carWidth, 
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class HeadlightBeamPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Create a path for a trapezoid/cone shape
    // Assuming drawing from left (car) to right (outward)
    final path = Path();
    
    // Start narrow at the left center (headlight source)
    final sourceHeight = size.height * 0.2;
    final sourceTop = (size.height - sourceHeight) / 2;
    
    path.moveTo(0, sourceTop); // Top-left
    path.lineTo(size.width, 0); // Top-right (wide)
    path.lineTo(size.width, size.height); // Bottom-right (wide)
    path.lineTo(0, sourceTop + sourceHeight); // Bottom-left
    path.close();

    // Apply gradient: Bright white at source, fading to transparent
    final gradient = LinearGradient(
      colors: [
        Colors.white.withOpacity(0.9), // Source
        Colors.white.withOpacity(0.0), // End
      ],
      stops: const [0.0, 1.0],
    );

    paint.shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    paint.style = PaintingStyle.fill;
    
    // Optional: Add a subtle blur mask if performance allows, 
    // but a gradient usually suffices for a "beam" look.
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}





// Sparkle Implementation
class SparkleField extends StatefulWidget {
  const SparkleField({Key? key}) : super(key: key);

  @override
  State<SparkleField> createState() => _SparkleFieldState();
}

class _SparkleFieldState extends State<SparkleField> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Sparkle> _sparkles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Long cycle for continuous updates
    )..repeat();

    // Initialize random sparkles
    for (int i = 0; i < 20; i++) {
      _sparkles.add(_generateSparkle());
    }
  }

  _Sparkle _generateSparkle() {
    return _Sparkle(
      top: _random.nextDouble(), // 0.0 to 1.0 (relative height)
      left: _random.nextDouble(), // 0.0 to 1.0 (relative width)
      size: _random.nextDouble() * 4 + 2, // 2 to 6 size
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: _sparkles.map((sparkle) {
            return _buildSparkleItem(sparkle);
          }).toList(),
        );
      },
    );
  }

  Widget _buildSparkleItem(_Sparkle sparkle) {
    // Controller goes 0->1.
    // Use position as offset for opacity
    final double t = (_controller.value + sparkle.top) % 1.0; 
    final double opacity = (sin(t * 2 * pi) + 1) / 2; // 0.0 to 1.0 sine wave

    return Positioned(
      top: MediaQuery.of(context).size.height * sparkle.top,
      left: MediaQuery.of(context).size.width * sparkle.left,
      child: Opacity(
        opacity: opacity * 0.7, // Max opacity 0.7
        child: Container(
          width: sparkle.size,
          height: sparkle.size,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sparkle {
  final double top;
  final double left;
  final double size;

  _Sparkle({
    required this.top,
    required this.left,
    required this.size,
  });
}
