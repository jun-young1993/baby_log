import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';

import 'home_viewmodel.dart';
import '../../widgets/emotion_summary_card.dart';
import '../../widgets/video_list_item.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget builder(BuildContext context, HomeViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '우리 아기 하루',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: viewModel.refreshEmotionStats,
          ),
        ],
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: viewModel.refreshEmotionStats,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 오늘 날짜 표시
                    _buildTodayHeader(),
                    const SizedBox(height: 20),

                    // 감정 요약 카드
                    EmotionSummaryCard(
                      emotionStats: viewModel.emotionStats,
                      totalEmotions: viewModel.totalEmotions,
                      dominantEmotion: viewModel.dominantEmotion,
                    ),
                    const SizedBox(height: 24),

                    // 최근 영상 섹션
                    _buildRecentVideosSection(viewModel),
                    const SizedBox(height: 24),

                    // 영상 리스트
                    _buildVideoList(viewModel),
                  ],
                ),
              ),
            ),
      floatingActionButton: Stack(
        children: [
          // 감정 다이어리 버튼
          Positioned(
            bottom: 0,
            right: 0,
            child: FloatingActionButton(
              onPressed: viewModel.onDiaryPressed,
              backgroundColor: Colors.green[600],
              child: const Icon(
                Icons.calendar_today,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          // 영상 추가 버튼
          Positioned(
            bottom: 0,
            right: 70,
            child: FloatingActionButton(
              onPressed: viewModel.onAddVideoPressed,
              backgroundColor: Colors.blue[600],
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();

  @override
  void onViewModelReady(HomeViewModel viewModel) {
    viewModel.initialize();
  }

  Widget _buildTodayHeader() {
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy년 MM월 dd일 EEEE', 'ko_KR');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateFormat.format(now),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '오늘 아기의 감정을 기록해보세요',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildRecentVideosSection(HomeViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '최근 영상',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        TextButton(
          onPressed: () {
            // TODO: 전체 영상 목록으로 이동
          },
          child: const Text(
            '전체보기',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoList(HomeViewModel viewModel) {
    if (viewModel.recentVideos.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.recentVideos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final video = viewModel.recentVideos[index];
        return VideoListItem(
          video: video,
          onTap: () => viewModel.onVideoPressed(video['id']),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.videocam_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '아직 기록된 영상이 없어요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '첫 번째 영상을 추가해보세요!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
