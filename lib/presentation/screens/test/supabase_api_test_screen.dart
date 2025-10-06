import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_client.dart';
import '../../../providers/home_data_provider.dart';
import '../../shared/index.dart';

/// Supabase API 테스트 화면
class SupabaseApiTestScreen extends ConsumerStatefulWidget {
  const SupabaseApiTestScreen({super.key});

  @override
  ConsumerState<SupabaseApiTestScreen> createState() =>
      _SupabaseApiTestScreenState();
}

class _SupabaseApiTestScreenState extends ConsumerState<SupabaseApiTestScreen> {
  String _testResults = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText('Supabase API 테스트', style: AppTextStyle.title),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.textInverse,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 테스트 결과
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('테스트 결과', style: AppTextStyle.title),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    AppText(
                      _testResults.isEmpty ? '테스트를 실행해주세요.' : _testResults,
                      style: AppTextStyle.body,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 테스트 버튼들
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('API 테스트', style: AppTextStyle.title),
                  const SizedBox(height: 16),

                  // 기본 연결 테스트
                  PrimaryButton(
                    text: '기본 연결 테스트',
                    onPressed: _testBasicConnection,
                  ),
                  const SizedBox(height: 8),

                  // 라운드 데이터 테스트
                  PrimaryButton(text: '라운드 데이터 조회', onPressed: _testRoundsData),
                  const SizedBox(height: 8),

                  // 사용자 프로필 테스트
                  PrimaryButton(
                    text: '사용자 프로필 조회',
                    onPressed: _testUserProfile,
                  ),
                  const SizedBox(height: 8),

                  // 출석체크 테스트
                  PrimaryButton(text: '출석체크 테스트', onPressed: _testAttendance),
                  const SizedBox(height: 8),

                  // 걸음수 보상 테스트
                  PrimaryButton(
                    text: '걸음수 보상 테스트',
                    onPressed: _testStepsReward,
                  ),
                  const SizedBox(height: 8),

                  // 광고 보상 테스트
                  PrimaryButton(text: '광고 보상 테스트', onPressed: _testAdReward),
                  const SizedBox(height: 8),

                  // 전체 데이터 새로고침
                  PrimaryButton(
                    text: '전체 데이터 새로고침',
                    onPressed: _testRefreshData,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  void _addResult(String result) {
    setState(() {
      _testResults +=
          '${DateTime.now().toString().substring(11, 19)}: $result\n';
    });
  }

  Future<void> _testBasicConnection() async {
    _setLoading(true);
    _addResult('기본 연결 테스트 시작...');

    try {
      final client = LuckyWalkSupabaseClient.instance.client;
      _addResult('✅ Supabase 클라이언트 연결 성공');

      // 인증 상태 확인
      final user = client.auth.currentUser;
      if (user != null) {
        _addResult('✅ 사용자 인증됨: ${user.id}');
      } else {
        _addResult('⚠️ 사용자 인증되지 않음');
      }
    } catch (e) {
      _addResult('❌ 연결 실패: $e');
    }

    _setLoading(false);
  }

  Future<void> _testRoundsData() async {
    _setLoading(true);
    _addResult('라운드 데이터 조회 테스트 시작...');

    try {
      final rounds = await LuckyWalkSupabaseClient.instance.getLotteryRounds(
        limit: 3,
        status: 'scheduled',
      );

      _addResult('✅ 라운드 데이터 조회 성공: ${rounds.length}개');
      for (final round in rounds) {
        _addResult('  - 회차: ${round['round_number']}, 상태: ${round['status']}');
      }
    } catch (e) {
      _addResult('❌ 라운드 데이터 조회 실패: $e');
    }

    _setLoading(false);
  }

  Future<void> _testUserProfile() async {
    _setLoading(true);
    _addResult('사용자 프로필 조회 테스트 시작...');

    try {
      final homeData = ref.read(homeDataProvider);
      _addResult('✅ 홈 데이터 상태: ${homeData.isLoading ? "로딩중" : "완료"}');
      _addResult('  - 에러: ${homeData.error ?? "없음"}');
      _addResult('  - 라운드: ${homeData.currentRound != null ? "있음" : "없음"}');
      _addResult('  - 프로필: ${homeData.userProfile != null ? "있음" : "없음"}');
    } catch (e) {
      _addResult('❌ 사용자 프로필 조회 실패: $e');
    }

    _setLoading(false);
  }

  Future<void> _testAttendance() async {
    _setLoading(true);
    _addResult('출석체크 테스트 시작...');

    try {
      await ref.read(homeDataProvider.notifier).checkAttendance();
      _addResult('✅ 출석체크 성공');
    } catch (e) {
      _addResult('❌ 출석체크 실패: $e');
    }

    _setLoading(false);
  }

  Future<void> _testStepsReward() async {
    _setLoading(true);
    _addResult('걸음수 보상 테스트 시작...');

    try {
      await ref.read(homeDataProvider.notifier).claimStepsReward(5000);
      _addResult('✅ 5000걸음 보상 수령 성공');
    } catch (e) {
      _addResult('❌ 걸음수 보상 실패: $e');
    }

    _setLoading(false);
  }

  Future<void> _testAdReward() async {
    _setLoading(true);
    _addResult('광고 보상 테스트 시작...');

    try {
      await ref.read(homeDataProvider.notifier).claimAdReward(1);
      _addResult('✅ 1번째 광고 보상 수령 성공');
    } catch (e) {
      _addResult('❌ 광고 보상 실패: $e');
    }

    _setLoading(false);
  }

  Future<void> _testRefreshData() async {
    _setLoading(true);
    _addResult('전체 데이터 새로고침 테스트 시작...');

    try {
      await ref.read(homeDataProvider.notifier).refresh();
      _addResult('✅ 데이터 새로고침 성공');
    } catch (e) {
      _addResult('❌ 데이터 새로고침 실패: $e');
    }

    _setLoading(false);
  }
}
