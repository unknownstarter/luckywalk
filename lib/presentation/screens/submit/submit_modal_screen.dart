import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SubmitModalScreen extends StatefulWidget {
  const SubmitModalScreen({super.key});

  @override
  State<SubmitModalScreen> createState() => _SubmitModalScreenState();
}

class _SubmitModalScreenState extends State<SubmitModalScreen> {
  int _ticketCount = 100;
  final int _maxTickets = 10000; // 보유 복권 수 (예시)
  final int _minTickets = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('응모하기'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타이틀
            const Text(
              '얼마나 응모할까요?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // 회차 카드
            _buildRoundCard(),
            const SizedBox(height: 24),
            
            // 보유 복권 수
            _buildTicketBalance(),
            const SizedBox(height: 24),
            
            // 수량 스테퍼
            _buildQuantityStepper(),
            const SizedBox(height: 16),
            
            // 규칙 안내
            const Text(
              '*한번에 100장부터 응모할 수 있어요',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            
            // 응모하기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSubmit() ? _submitTickets : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  '응모하기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _canSubmit() ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.confirmation_number,
                color: Color(0xFF1E3A8A),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '로또 6/45',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '3일 남음',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '1234회차 | 2025.08.27 발표 예정',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '1억 2,000만원',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketBalance() {
    return Row(
      children: [
        const Text(
          '보유하고 있는 복권 ',
          style: TextStyle(fontSize: 16),
        ),
        GestureDetector(
          onTap: () {
            // 보유 복권 상세 보기
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('보유 복권 상세 보기')),
            );
          },
          child: Text(
            '$_maxTickets장',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityStepper() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _ticketCount > _minTickets ? _decreaseCount : null,
            icon: const Icon(Icons.remove_circle_outline),
            iconSize: 32,
            color: _ticketCount > _minTickets ? const Color(0xFF1E3A8A) : Colors.grey,
          ),
          Text(
            '$_ticketCount',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: _ticketCount < _maxTickets ? _increaseCount : null,
            icon: const Icon(Icons.add_circle_outline),
            iconSize: 32,
            color: _ticketCount < _maxTickets ? const Color(0xFF1E3A8A) : Colors.grey,
          ),
        ],
      ),
    );
  }

  bool _canSubmit() {
    return _ticketCount >= _minTickets && _ticketCount <= _maxTickets;
  }

  void _decreaseCount() {
    if (_ticketCount > _minTickets) {
      setState(() {
        _ticketCount = (_ticketCount - 100).clamp(_minTickets, _maxTickets);
      });
    }
  }

  void _increaseCount() {
    if (_ticketCount < _maxTickets) {
      setState(() {
        _ticketCount = (_ticketCount + 100).clamp(_minTickets, _maxTickets);
      });
    }
  }

  void _submitTickets() {
    // TODO: 실제 응모 로직 구현
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('응모 확인'),
        content: Text('$_ticketCount장을 응모하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processSubmission();
            },
            child: const Text('응모하기'),
          ),
        ],
      ),
    );
  }

  void _processSubmission() {
    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // 시뮬레이션된 응모 처리
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_ticketCount장 응모 완료!'),
          backgroundColor: Colors.green,
        ),
      );
      
      context.pop(); // 모달 닫기
    });
  }
}
