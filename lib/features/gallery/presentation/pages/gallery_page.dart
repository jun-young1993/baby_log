import 'package:baby_log/features/dashboard/presentation/widgets/aws_s3_object_album_infinity_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_common/state/aws/s3/s3_object_page_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class GalleryPage extends StatefulWidget {
  final User user;
  const GalleryPage({super.key, required this.user});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  S3ObjectBloc get s3ObjectBloc => context.read<S3ObjectBloc>();
  NoticeBloc get noticeBloc => context.read<NoticeBloc>();
  S3ObjectPageBloc get s3ObjectPageBloc => context.read<S3ObjectPageBloc>();
  @override
  void initState() {
    super.initState();
    _checkNoticeExistence(
      _currentMonth.year.toString(),
      _currentMonth.month.toString(),
    );
  }

  void _checkNoticeExistence(String year, String month) {
    s3ObjectBloc.add(S3ObjectEvent.checkObjectsExistenceByMonth(year, month));
    noticeBloc.add(
      NoticeEvent.checkNoticeExistence(widget.user.id, year, month),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Tr.common.gallery.tr(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: _goToToday,
          ),
        ],
      ),
      body: Column(
        children: [
          // 월 네비게이션
          _buildMonthNavigation(),

          // 캘린더 그리드
          Expanded(child: _buildCalendarGrid()),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _previousMonth,
            icon: Icon(
              Icons.chevron_left,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          GestureDetector(
            onTap: _showMonthPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentMonth.year}년 ${_currentMonth.month}월',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _nextMonth,
            icon: Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    // 요일 헤더
    final weekdays = [
      Tr.date.day1.tr(),
      Tr.date.day2.tr(),
      Tr.date.day3.tr(),
      Tr.date.day4.tr(),
      Tr.date.day5.tr(),
      Tr.date.day6.tr(),
      Tr.date.day7.tr(),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 요일 헤더
          Row(
            children: weekdays
                .map(
                  (day) => Expanded(
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),

          // 캘린더 그리드
          Expanded(
            child: S3ObjectObjectsExistenceByMonthSelector(
              (objectsExistence) => NoticeNoticeExistenceByMonthSelector(
                (noticeExistence) => GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                  ),
                  itemCount: 42, // 6주 * 7일
                  itemBuilder: (context, index) {
                    final dayNumber = index - firstWeekday + 1;

                    if (dayNumber < 1 || dayNumber > daysInMonth) {
                      return const SizedBox.shrink();
                    }

                    final date = DateTime(
                      _currentMonth.year,
                      _currentMonth.month,
                      dayNumber,
                    );
                    final isSelected = _isSameDay(date, _selectedDate);
                    final isToday = _isSameDay(date, DateTime.now());

                    // 실제 S3 데이터에서 사진 존재 여부 확인
                    final dateString =
                        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                    final hasPhotos = objectsExistence[dateString] ?? false;
                    final hasDiary = noticeExistence[dateString] ?? false;

                    return _buildCalendarDay(
                      dayNumber: dayNumber,
                      date: date,
                      isSelected: isSelected,
                      isToday: isToday,
                      hasPhotos: hasPhotos,
                      hasDiary: hasDiary,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDay({
    required int dayNumber,
    required DateTime date,
    required bool isSelected,
    required bool isToday,
    required bool hasPhotos,
    required bool hasDiary,
  }) {
    return GestureDetector(
      onTap: () => _selectDate(date),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : isToday
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isToday && !isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                dayNumber.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected || isToday
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : isToday
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),

            // 표시점들
            Positioned(
              bottom: 4,
              left: 4,
              right: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 사진이 있는 날짜 표시
                  if (hasPhotos)
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),

                  // 사진과 일기가 모두 있으면 간격 추가
                  if (hasPhotos && hasDiary) const SizedBox(width: 2),

                  // 일기가 있는 날짜 표시
                  if (hasDiary)
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });

    noticeBloc.add(
      NoticeEvent.findAllByDate(
        widget.user.id,
        date.year.toString(),
        date.month.toString(),
        date.day.toString(),
      ),
    );
    s3ObjectPageBloc.add(ClearS3Object());
    s3ObjectPageBloc.add(
      FetchS3ObjectsByDate(
        year: date.year.toString(),
        month: date.month.toString(),
        day: date.day.toString(),
      ),
    );

    // 해당 날짜가 현재 월과 다르면 월 변경
    if (date.year != _currentMonth.year || date.month != _currentMonth.month) {
      setState(() {
        _currentMonth = DateTime(date.year, date.month);
      });
      _checkNoticeExistence(date.year.toString(), date.month.toString());
    }

    // 선택된 날짜의 사진들을 보여주는 다이얼로그 또는 페이지로 이동
    _showDatePhotos(date);
  }

  void _showDatePhotos(DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.3,
        maxChildSize: 1,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 핸들
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 헤더
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // 이전 날짜 버튼
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _selectDate(date.subtract(const Duration(days: 1)));
                      },

                      icon: Icon(
                        Icons.chevron_left,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                    ),

                    // 날짜 표시
                    Expanded(
                      child: Text(
                        Tr.date.yearAndMonthAndDayFormat.tr(
                          namedArgs: {
                            'year': date.year.toString(),
                            'month': date.month.toString(),
                            'day': date.day.toString(),
                          },
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),

                    // 다음 날짜 버튼
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _selectDate(date.add(const Duration(days: 1)));
                      },
                      icon: Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                    ),

                    // 닫기 버튼
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              // 액션 버튼들
              _buildActionButtons(date),

              const SizedBox(height: 16),

              // 내용 섹션
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      // 탭 바
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: TabBar(
                          // indicator: BoxDecoration(
                          //   color: Theme.of(context).colorScheme.primary,
                          //   // borderRadius: BorderRadius.circular(25),
                          // ),
                          // labelColor: Colors.white,
                          unselectedLabelColor: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                          tabs: [
                            Tab(text: Tr.common.album.tr()),
                            Tab(text: Tr.common.log.tr()),
                          ],
                        ),
                      ),

                      // 탭 내용
                      Expanded(
                        child: TabBarView(
                          children: [
                            // 사진 탭
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: _buildPhotosForDate(date),
                            ),
                            // 일기 탭
                            _buildDiaryForDate(date),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(DateTime date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.push(
                  '/daily-record/${date.toIso8601String().split('T')[0]}',
                );
              },
              icon: Icon(Icons.edit_note, color: Colors.white, size: 20),
              label: Text(
                Tr.baby.writeDiary.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // 사진 추가 기능 (추후 구현)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('사진 추가 기능은 준비 중입니다.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              icon: Icon(
                Icons.add_a_photo,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              label: Text(
                '사진 추가',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosForDate(DateTime date) {
    return AwsS3ObjectAlbumInfinityGrid(
      user: widget.user,
      initState: () {},
      fetchNextPage: () {
        s3ObjectPageBloc.add(
          FetchS3ObjectsByDate(
            year: date.year.toString(),
            month: date.month.toString(),
            day: date.day.toString(),
          ),
        );
      },
    );
  }

  Widget _buildDiaryForDate(DateTime date) {
    // 실제로는 해당 날짜의 일기들을 가져와서 표시
    return NoticeIsNoticesByDateLoadingSelector((isLoading) {
      if (isLoading) {
        return Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.white,
            size: 200,
          ),
        );
      }
      return NoticeNoticesByDateSelector((notices) {
        if (notices == null || notices.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.edit_note,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ),
                const SizedBox(height: 12),
                Text(
                  Tr.baby.onBoardingTitle.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Tr.baby.babyLogDescription2.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView.builder(
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final notice = notices[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_stories,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          notice.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notice.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // 작성 시간 태그
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#${notice.createdAt.hour.toString().padLeft(2, '0')}:${notice.createdAt.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 제목 태그
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#${notice.title.length > 10 ? notice.title.substring(0, 10) + '...' : notice.title}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      });
    });
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    // 새로운 월의 데이터 가져오기
    _checkNoticeExistence(
      _currentMonth.year.toString(),
      _currentMonth.month.toString(),
    );
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    // 새로운 월의 데이터 가져오기
    _checkNoticeExistence(
      _currentMonth.year.toString(),
      _currentMonth.month.toString(),
    );
  }

  void _goToToday() {
    setState(() {
      _currentMonth = DateTime.now();
      _selectedDate = DateTime.now();
    });
    // 오늘 날짜의 데이터 가져오기
    _checkNoticeExistence(
      _currentMonth.year.toString(),
      _currentMonth.month.toString(),
    );
  }

  void _showMonthPicker() {
    showDatePicker(
      context: context,
      initialDate: _currentMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    ).then((selectedDate) {
      if (selectedDate != null) {
        setState(() {
          _currentMonth = selectedDate;
        });
        // 선택된 월의 데이터 가져오기
        _checkNoticeExistence(
          _currentMonth.year.toString(),
          _currentMonth.month.toString(),
        );
      }
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _hasDiaryForDate(DateTime date) {
    // 실제로는 해당 날짜에 일기가 있는지 확인
    // 예시로 랜덤하게 true/false 반환
    return date.day % 5 == 0;
  }
}
