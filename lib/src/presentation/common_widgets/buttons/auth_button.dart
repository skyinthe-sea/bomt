import 'package:flutter/material.dart';

enum AuthButtonType { email, google, facebook, kakao }

class AuthButton extends StatelessWidget {
  final AuthButtonType type;
  final VoidCallback onPressed;
  final bool isLoading;
  final String? customText;

  const AuthButton({
    Key? key,
    required this.type,
    required this.onPressed,
    this.isLoading = false,
    this.customText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = _getButtonConfig(type);
    
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: config.backgroundColor,
          foregroundColor: config.textColor,
          elevation: 2,
          shadowColor: config.backgroundColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: config.borderColor != null 
                ? BorderSide(color: config.borderColor!, width: 1)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(config.textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  config.icon,
                  const SizedBox(width: 12),
                  Text(
                    customText ?? config.text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: config.textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  _AuthButtonConfig _getButtonConfig(AuthButtonType type) {
    switch (type) {
      case AuthButtonType.email:
        return _AuthButtonConfig(
          icon: const Icon(Icons.email_outlined, size: 20),
          text: '이메일로 계속하기',
          backgroundColor: const Color(0xFF667EEA),
          textColor: Colors.white,
        );
        
      case AuthButtonType.google:
        return _AuthButtonConfig(
          icon: _GoogleIcon(),
          text: 'Google로 계속하기',
          backgroundColor: Colors.white,
          textColor: const Color(0xFF1F2937),
          borderColor: const Color(0xFFE5E7EB),
        );
        
      case AuthButtonType.facebook:
        return _AuthButtonConfig(
          icon: const Icon(Icons.facebook, size: 20, color: Colors.white),
          text: 'Facebook으로 계속하기',
          backgroundColor: const Color(0xFF1877F2),
          textColor: Colors.white,
        );
        
      case AuthButtonType.kakao:
        return _AuthButtonConfig(
          icon: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF3C1E1E),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(
              child: Text(
                'K',
                style: TextStyle(
                  color: Color(0xFFFEE500),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          text: '카카오로 계속하기',
          backgroundColor: const Color(0xFFFEE500),
          textColor: const Color(0xFF3C1E1E),
        );
    }
  }
}

class _AuthButtonConfig {
  final Widget icon;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const _AuthButtonConfig({
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
      ),
      child: CustomPaint(
        painter: _GoogleIconPainter(),
      ),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Google "G" 로고 그리기 (간단한 버전)
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * 0.5, size.height), paint);
    
    paint.color = const Color(0xFFEA4335);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.5, 0, size.width * 0.5, size.height * 0.5), paint);
    
    paint.color = const Color(0xFFFBBC04);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.5, size.height * 0.5, size.width * 0.5, size.height * 0.5), paint);
    
    paint.color = const Color(0xFF34A853);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.5, size.width * 0.5, size.height * 0.5), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}