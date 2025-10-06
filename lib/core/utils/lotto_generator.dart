import 'dart:math';
import 'package:flutter/material.dart';

class LottoGenerator {
  static final Random _random = Random();

  /// 6개 번호를 1-45 범위에서 중복 없이 생성
  static List<int> generateNumbers() {
    List<int> numbers = [];
    while (numbers.length < 6) {
      int number = _random.nextInt(45) + 1;
      if (!numbers.contains(number)) {
        numbers.add(number);
      }
    }
    numbers.sort();
    return numbers;
  }

  /// 여러 장의 복권 생성
  static List<List<int>> generateMultipleTickets(int count) {
    List<List<int>> tickets = [];
    for (int i = 0; i < count; i++) {
      tickets.add(generateNumbers());
    }
    return tickets;
  }

  /// 번호 유효성 검증
  static bool isValidNumbers(List<int> numbers) {
    if (numbers.length != 6) return false;
    
    // 중복 체크
    Set<int> uniqueNumbers = numbers.toSet();
    if (uniqueNumbers.length != 6) return false;
    
    // 범위 체크
    for (int number in numbers) {
      if (number < 1 || number > 45) return false;
    }
    
    return true;
  }

  /// 번호 색상 반환 (UI용)
  static int getNumberColorIndex(int number) {
    if (number <= 10) return 0; // 주황색
    if (number <= 20) return 1; // 초록색
    if (number <= 30) return 2; // 파란색
    if (number <= 40) return 3; // 진한 파란색
    return 4; // 보라색
  }

  /// 번호 색상 반환 (Color 객체)
  static Color getNumberColor(int number) {
    if (number <= 10) return const Color(0xFFFFB157);
    if (number <= 20) return const Color(0xFF22E400);
    if (number <= 30) return const Color(0xFF5DB4FF);
    if (number <= 40) return const Color(0xFF4569CC);
    return const Color(0xFF8E7AF3);
  }
}

