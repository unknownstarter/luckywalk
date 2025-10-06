import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/index.dart';
import '../../../core/utils/index.dart';

class SubmitConfirmScreen extends StatefulWidget {
  final int ticketCount;

  const SubmitConfirmScreen({
    super.key,
    required this.ticketCount,
  });

  @override
  State<SubmitConfirmScreen> createState() => _SubmitConfirmScreenState();
}

class _SubmitConfirmScreenState extends State<SubmitConfirmScreen> {
  List<List<int>> _generatedTickets = [];

  @override
  void initState() {
    super.initState();
    _generateTickets();
  }

  void _generateTickets() {
    _generatedTickets = LottoGenerator.generateMultipleTickets(widget.ticketCount ~/ 100);
  }

  void _editTicket(int index) async {
    final result = await context.push('/submit/edit', extra: {
      'ticketIndex': index,
      'ticketNumbers': _generatedTickets[index],
      'ticketCount': widget.ticketCount,
    });
    
    if (result != null && result is List<int>) {
      setState(() {
        _generatedTickets[index] = result;
      });
    }
  }

  void _submitTickets() {
    // 실제 응모 로직 (추후 구현)
    context.go('/submit/complete', extra: {
      'ticketCount': widget.ticketCount,
    });
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
                        '복권 만들기 컨펌 스크린',
                        style: AppTextStyle.headline3,
                        color: Colors.black,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 24),
                  ],
                ),
              ),

                    // 제목
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          AppText(
                            '${widget.ticketCount}장의 복권이 만들어졌어요!',
                            style: AppTextStyle.headline3,
                            color: Colors.black,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const AppText(
                            '직접 번호를 수정할 수 있어요',
                            style: AppTextStyle.body,
                            color: Color(0xFF696969),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

              const SizedBox(height: 24),

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

              // 복권 목록
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _generatedTickets.length,
                  itemBuilder: (context, index) {
                    return _buildTicketCard(index);
                  },
                ),
              ),

              // 하단 버튼
              Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _submitTickets,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0088FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const AppText(
                      '바로 응모하기 (플로팅 버튼)',
                      style: AppTextStyle.button,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(int index) {
    final numbers = _generatedTickets[index];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
      ),
      child: Row(
        children: [
          // 번호들
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: numbers.map((number) {
                return Container(
                  width: 36,
                  height: 36,
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
          
          // 편집 버튼
          GestureDetector(
            onTap: () => _editTicket(index),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit,
                size: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getNumberColor(int number) {
    return LottoGenerator.getNumberColor(number);
  }
}
