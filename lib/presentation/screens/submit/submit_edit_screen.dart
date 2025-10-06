import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/index.dart';
import '../../../core/utils/index.dart';

class SubmitEditScreen extends StatefulWidget {
  final int ticketIndex;
  final List<int> ticketNumbers;
  final int ticketCount;

  const SubmitEditScreen({
    super.key,
    required this.ticketIndex,
    required this.ticketNumbers,
    required this.ticketCount,
  });

  @override
  State<SubmitEditScreen> createState() => _SubmitEditScreenState();
}

class _SubmitEditScreenState extends State<SubmitEditScreen> {
  List<int> _selectedNumbers = [];

  @override
  void initState() {
    super.initState();
    _selectedNumbers = List.from(widget.ticketNumbers);
  }

  void _toggleNumber(int number) {
    setState(() {
      if (_selectedNumbers.contains(number)) {
        _selectedNumbers.remove(number);
      } else if (_selectedNumbers.length < 6) {
        _selectedNumbers.add(number);
      }
    });
  }

  void _autoGenerate() {
    setState(() {
      _selectedNumbers = LottoGenerator.generateNumbers();
    });
  }

  void _confirm() {
    if (_selectedNumbers.length == 6) {
      // 번호를 부모 화면으로 전달하고 돌아가기
      context.pop(_selectedNumbers);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0088FF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 상태바
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppText(
                      '9:41',
                      style: AppTextStyle.caption,
                      color: Colors.black,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.signal_cellular_4_bar, size: 16),
                        const SizedBox(width: 4),
                        const Icon(Icons.wifi, size: 16),
                        const SizedBox(width: 4),
                        const Icon(Icons.battery_full, size: 16),
                      ],
                    ),
                  ],
                ),
              ),

              // 헤더
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: AppText(
                        '복권 번호 수정하기',
                        style: AppTextStyle.headline3,
                        color: Colors.black,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 24),
                  ],
                ),
              ),

              // 광고 영역
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF121313),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: AppText(
                    '광고 영역',
                    style: AppTextStyle.caption,
                    color: Colors.red,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 선택된 번호들
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _selectedNumbers.map((number) {
                    return Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _getNumberColor(number),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: AppText(
                          number.toString(),
                          style: AppTextStyle.caption,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // 번호 그리드
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 9,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: 45,
                  itemBuilder: (context, index) {
                    final number = index + 1;
                    final isSelected = _selectedNumbers.contains(number);
                    
                    return GestureDetector(
                      onTap: () => _toggleNumber(number),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? _getNumberColor(number) : const Color(0xFFD9D9D9),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: AppText(
                            number.toString(),
                            style: AppTextStyle.caption,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 하단 버튼들
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF628CFF)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextButton(
                          onPressed: _autoGenerate,
                          child: const AppText(
                            '자동 만들기',
                            style: AppTextStyle.button,
                            color: Color(0xFF0088FF),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0088FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextButton(
                          onPressed: _selectedNumbers.length == 6 ? _confirm : null,
                          child: const AppText(
                            '확인',
                            style: AppTextStyle.button,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNumberColor(int number) {
    return LottoGenerator.getNumberColor(number);
  }
}
