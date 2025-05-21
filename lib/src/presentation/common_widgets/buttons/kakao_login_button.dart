import 'package:flutter/material.dart';

class KakaoLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const KakaoLoginButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFEE500), // 카카오 노란색
          foregroundColor: const Color(0xFF191919), // 카카오 버튼 텍스트 색상
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: isLoading 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF191919),
                ),
              ) 
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 카카오 로고(간단하게 표현)
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    child: const Text(
                      'K',
                      style: TextStyle(
                        color: Color(0xFF191919),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '카카오로 로그인',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}