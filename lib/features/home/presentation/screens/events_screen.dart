import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/core/network/api_client_provider.dart';
import 'package:myapp/features/home/domain/entities/upcoming_event.dart';
import 'package:myapp/features/home/infrastructure/data_sources/remote/home_api.dart';
import 'package:myapp/features/home/infrastructure/models/event_model.dart';
import 'package:myapp/features/home/presentation/screens/event_details_screen.dart';
import 'package:intl/intl.dart';

/// Events screen with three tabs: Upcoming, Ongoing, and Past events
class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  int _selectedTabIndex = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  List<UpcomingEvent> _events = [];
  String? _errorMessage;
  String? _nextUrl;
  String? _previousUrl;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Load more when within 200 pixels of the bottom
      _loadMoreEvents();
    }
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _events = []; // Clear existing events when loading fresh
      _nextUrl = null;
      _previousUrl = null;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final homeApi = HomeApiImpl(apiClient: apiClient);

      HomeApiResponse<List<EventModel>> response;

      // Fetch events based on selected tab
      switch (_selectedTabIndex) {
        case 0: // Upcoming
          response = await homeApi.fetchEvents(ifModifiedSince: '');
          break;
        case 1: // Ongoing
          response = await homeApi.fetchOngoingEvents(ifModifiedSince: '');
          break;
        case 2: // Past
          response = await homeApi.fetchPastEvents(ifModifiedSince: '');
          break;
        default:
          response = await homeApi.fetchEvents(ifModifiedSince: '');
      }

      if (response.data != null && mounted) {
        setState(() {
          _events = response.data!.map((model) => model.toDomain()).toList();
          _nextUrl = response.nextUrl;
          _previousUrl = response.previousUrl;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _events = [];
          _nextUrl = null;
          _previousUrl = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading events: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load events. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreEvents() async {
    // Don't load more if already loading or no next page
    if (_isLoadingMore || _nextUrl == null || _isLoading) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final homeApi = HomeApiImpl(apiClient: apiClient);

      final response = await homeApi.fetchEventsFromUrl(url: _nextUrl!);

      if (response.data != null && mounted) {
        setState(() {
          _events.addAll(response.data!.map((model) => model.toDomain()).toList());
          _nextUrl = response.nextUrl;
          _previousUrl = response.previousUrl;
          _isLoadingMore = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading more events: $e');
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Events',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Tab Bar
          _buildTabBar(),
          SizedBox(height: 16.h),
          // Events List
          Expanded(
            child: _buildEventsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        children: [
          _buildTab('Upcoming', 0),
          SizedBox(width: 12.w),
          _buildTab('Ongoing', 1),
          SizedBox(width: 12.w),
          _buildTab('Past', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedTabIndex != index) {
            setState(() {
              _selectedTabIndex = index;
            });
            _loadEvents();
          }
        },
        child: Container(
          height: 40.h,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brown : AppColors.grey100,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brown),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: AppColors.grey400),
            SizedBox(height: 16.h),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadEvents,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48.sp, color: AppColors.grey400),
            SizedBox(height: 16.h),
            Text(
              'No events available',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      color: AppColors.brown,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(24.w),
        itemCount: _events.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Show loading indicator at the bottom
          if (index == _events.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.brown),
              ),
            );
          }
          return _buildEventCard(_events[index]);
        },
      ),
    );
  }

  Widget _buildEventCard(UpcomingEvent event) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image
          _buildEventImage(event),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Title
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12.h),
                // Event Date
                _buildInfoRow(
                  Icons.calendar_today,
                  event.displayDate,
                ),
                SizedBox(height: 8.h),
                // Event Time
                _buildInfoRow(
                  Icons.access_time,
                  event.displayTime,
                ),
                SizedBox(height: 8.h),
                // Event Location
                _buildInfoRow(
                  Icons.location_on,
                  event.venue,
                ),
                SizedBox(height: 16.h),
                // Register Button
                _buildRegisterButton(event),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventImage(UpcomingEvent event) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
      child: event.fullBannerImageUrl != null
          ? Image.network(
              event.fullBannerImageUrl!,
              height: 180.h,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildImagePlaceholder(),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildImagePlaceholder(showLoading: true);
              },
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder({bool showLoading = false}) {
    return Container(
      height: 180.h,
      width: double.infinity,
      color: AppColors.grey200,
      child: Center(
        child: showLoading
            ? CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.brown),
              )
            : Icon(Icons.event_outlined, size: 48.sp, color: AppColors.grey400),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.textSecondary),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(UpcomingEvent event) {
    // TODO: Check if user is already registered for this event
    // For now, we'll show "Register Now" for all events
    final bool isRegistered = false; // This should come from API

    if (isRegistered) {
      return Column(
        children: [
          // Already Registered button (greyed out)
          Container(
            width: double.infinity,
            height: 44.h,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(22.r),
            ),
            child: Center(
              child: Text(
                'Already Registered',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey500,
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          // View Event button
          GestureDetector(
            onTap: () {
              // TODO: Navigate to event details screen
              debugPrint('View event: ${event.id}');
            },
            child: Container(
              width: double.infinity,
              height: 44.h,
              decoration: BoxDecoration(
                color: AppColors.brown,
                borderRadius: BorderRadius.circular(22.r),
              ),
              child: Center(
                child: Text(
                  'View Event',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Register Now button
    return GestureDetector(
      onTap: event.isRegistrationOpen
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailsScreen(
                    eventId: int.parse(event.id),
                  ),
                ),
              );
            }
          : null,
      child: Container(
        width: double.infinity,
        height: 44.h,
        decoration: BoxDecoration(
          color: event.isRegistrationOpen ? AppColors.brown : AppColors.grey300,
          borderRadius: BorderRadius.circular(22.r),
        ),
        child: Center(
          child: Text(
            'Register Now',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color:
                  event.isRegistrationOpen ? AppColors.white : AppColors.grey500,
            ),
          ),
        ),
      ),
    );
  }
}
