import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/index.dart';
import '../../../core/utils/index.dart';

// 기존 SubmitModalScreen을 SubmitModalContent로 변경
class SubmitModalScreen extends StatefulWidget {
  const SubmitModalScreen({super.key});

  @override
  State<SubmitModalScreen> createState() => _SubmitModalScreenState();
}

class _SubmitModalScreenState extends State<SubmitModalScreen> {
  int _ticketCount = 0;

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: '얼마나 응모할까요?',
      content: SubmitModalContent(
        onTicketCountChanged: (count) {
          setState(() {
            _ticketCount = count;
          });
        },
      ),
      footer: Container(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            text: '응모하기',
            onPressed: _ticketCount > 0 ? _submitTickets : null,
            isEnabled: _ticketCount > 0,
          ),
        ),
      ),
    );
  }

  void _submitTickets() {
    // 응모 정책 확인
    if (!SubmitPolicy.canSubmit()) {
      AppToast.error(
        context,
        message: SubmitPolicy.getTimeExceededMessage(),
        duration: const Duration(seconds: 6),
      );
      return;
    }
    
    // 응모 수량 유효성 검증
    if (!SubmitPolicy.isValidTicketCount(_ticketCount)) {
      AppToast.error(
        context,
        message: '응모 수량이 올바르지 않습니다.\n100장~10,000장까지 100장 단위로 응모 가능합니다.',
        duration: const Duration(seconds: 4),
      );
      return;
    }
    
    // 남은 시간 확인 토스트
    final remainingTime = SubmitPolicy.getRemainingTimeString();
    if (remainingTime != '응모 마감') {
      AppToast.info(
        context,
        message: '응모 마감까지 $remainingTime 남았습니다.',
        duration: const Duration(seconds: 2),
      );
    }
    
    context.pop();
    // 새로운 응모 플로우로 이동
    context.go('/submit/loading', extra: _ticketCount);
  }
}

class SubmitModalContent extends StatefulWidget {
  final Function(int) onTicketCountChanged;

  const SubmitModalContent({super.key, required this.onTicketCountChanged});

  @override
  State<SubmitModalContent> createState() => _SubmitModalContentState();
}

class _SubmitModalContentState extends State<SubmitModalContent> {
  int _ticketCount = 0; // Figma 디자인에 따라 0부터 시작
  final int _maxTickets = 10000; // 보유 복권 수
  final int _minTickets = 100; // 최소 응모 단위

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 회차 정보 카드
        _buildRoundInfoCard(),
        const SizedBox(height: 24),

        // 보유 복권 수
        _buildTicketBalance(),
        const SizedBox(height: 24),

        // 수량 스테퍼
        _buildQuantityStepper(),
        const SizedBox(height: 16),

        // 규칙 안내
        AppText(
          '*100장~10,000장까지 100장 단위로 응모 가능해요',
          style: AppTextStyle.caption,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildRoundInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: Column(
        children: [
          // 로또 6/45 제목
          AppText(
            '로또 6/45',
            style: AppTextStyle.headline3,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 8),

          // 회차 정보
          AppText(
            '${LottoDateTime.getNextRoundNumber()}회차  |  ${LottoDateTime.getAnnouncementTimeString()} 발표 예정',
            style: AppTextStyle.body,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 16),

          // 당첨금과 남은 시간
          Row(
            children: [
              // 당첨금
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      AppText(
                        '1억 2,000만원',
                        style: AppTextStyle.body,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 남은 시간
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      AppText(
                        '${LottoDateTime.getDaysUntilAnnouncement()}일 남음',
                        style: AppTextStyle.body,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketBalance() {
    return Row(
      children: [
        AppText(
          '보유하고 있는 복권',
          style: AppTextStyle.subtitle,
          color: AppColors.textPrimary,
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            // 보유 복권 상세 보기
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('보유 복권 상세 보기')));
          },
          child: AppText(
            '$_maxTickets장',
            style: AppTextStyle.subtitle,
            color: AppColors.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 감소 버튼
          GestureDetector(
            onTap: _decreaseCount,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _ticketCount > _minTickets
                      ? const Color(0xFFC9C9C9)
                      : const Color(0xFFD9D9D9),
                ),
              ),
              child: Icon(
                Icons.remove,
                color: _ticketCount > _minTickets
                    ? AppColors.textPrimary
                    : const Color(0xFFD9D9D9),
                size: 24,
              ),
            ),
          ),

          // 수량 표시 (탭 가능)
          GestureDetector(
            onTap: _showNumberInputDialog,
            child: Container(
              width: 116,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: AppText(
                  '$_ticketCount',
                  style: AppTextStyle.title,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          // 증가 버튼
          GestureDetector(
            onTap: _increaseCount,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _ticketCount < _maxTickets
                      ? const Color(0xFFC9C9C9)
                      : const Color(0xFFD9D9D9),
                ),
              ),
              child: Icon(
                Icons.add,
                color: _ticketCount < _maxTickets
                    ? AppColors.textPrimary
                    : const Color(0xFFD9D9D9),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _decreaseCount() {
    if (_ticketCount > _minTickets) {
      setState(() {
        _ticketCount = SubmitPolicy.normalizeTicketCount(_ticketCount - 100);
        widget.onTicketCountChanged(_ticketCount);
      });
    }
  }

  void _increaseCount() {
    if (_ticketCount < _maxTickets) {
      setState(() {
        _ticketCount = SubmitPolicy.normalizeTicketCount(_ticketCount + 100);
        widget.onTicketCountChanged(_ticketCount);
      });
    }
  }

  void _showNumberInputDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('복권 수량 입력'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '응모할 복권 수량',
                hintText: '100의 배수로 입력하세요',
              ),
              onChanged: (value) {
                final intValue = int.tryParse(value) ?? 0;
                if (intValue >= _minTickets && intValue <= _maxTickets) {
                  setState(() {
                    _ticketCount = intValue;
                    widget.onTicketCountChanged(_ticketCount);
                  });
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
