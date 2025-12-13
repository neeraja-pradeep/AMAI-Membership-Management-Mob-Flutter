import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/app/theme/colors.dart';
import 'package:myapp/core/network/api_client_provider.dart';
import 'package:myapp/features/home/domain/entities/upcoming_event.dart';
import 'package:myapp/features/home/infrastructure/data_sources/remote/home_api.dart';
import 'package:myapp/features/home/infrastructure/models/event_model.dart';
import 'package:myapp/features/home/presentation/screens/event_payment_screen.dart';

/// Event details screen showing full event information
class EventDetailsScreen extends ConsumerStatefulWidget {
  const EventDetailsScreen({
    required this.eventId,
    super.key,
  });

  final int eventId;

  @override
  ConsumerState<EventDetailsScreen> createState() =>
      _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> {
  bool _isLoading = false;
  bool _isRegistering = false;
  UpcomingEvent? _event;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
  }

  Future<void> _loadEventDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final homeApi = HomeApiImpl(apiClient: apiClient);

      final response = await homeApi.fetchEventById(eventId: widget.eventId);

      if (response.data != null && mounted) {
        setState(() {
          _event = response.data!.toDomain();
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Event not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading event details: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load event details. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRegister() async {
    if (_event == null) return;

    setState(() {
      _isRegistering = true;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final homeApi = HomeApiImpl(apiClient: apiClient);

      // Register for event with online payment mode
      final response = await homeApi.registerForEvent(
        eventId: widget.eventId,
        paymentMode: 'online',
      );

      if (response.data != null && mounted) {
        // Navigate to payment screen with booking details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventPaymentScreen(
              event: _event!,
              bookingData: response.data!,
            ),
          ),
        );
      } else {
        if (mounted) {
          _showError('Registration failed. Please try again.');
        }
      }
    } catch (e) {
      debugPrint('Error registering for event: $e');
      if (mounted) {
        _showError('Registration failed. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF60212E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _event?.title ?? 'Event Details',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
              onPressed: _loadEventDetails,
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

    if (_event == null) {
      return const Center(
        child: Text('Event not found'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image
          _buildEventImage(),
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date & Time
                _buildInfoSection(
                  'Date & Time',
                  '${_event!.displayDate} at ${_event!.displayTime}',
                  Icons.calendar_today,
                ),
                SizedBox(height: 20.h),
                // Venue
                _buildInfoSection(
                  'Venue',
                  _event!.venue,
                  Icons.location_on,
                ),
                SizedBox(height: 20.h),
                // Fee
                _buildInfoSection(
                  'Fee',
                  _event!.displayTicketPrice,
                  Icons.currency_rupee,
                ),
                if (_event!.description.isNotEmpty) ...[
                  SizedBox(height: 20.h),
                  // Description
                  _buildTextSection('Description', _event!.description),
                ],
                SizedBox(height: 32.h),
                // Register Button
                _buildRegisterButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventImage() {
    return _event!.fullBannerImageUrl != null
        ? Image.network(
            _event!.fullBannerImageUrl!,
            height: 250.h,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildImagePlaceholder(showLoading: true);
            },
          )
        : _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder({bool showLoading = false}) {
    return Container(
      height: 250.h,
      width: double.infinity,
      color: AppColors.grey200,
      child: Center(
        child: showLoading
            ? const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.brown),
              )
            : Icon(Icons.event_outlined, size: 48.sp, color: AppColors.grey400),
      ),
    );
  }

  Widget _buildInfoSection(String title, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Icon(icon, size: 20.sp, color: AppColors.brown),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          content,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    final isRegistrationOpen = _event!.isRegistrationOpen;

    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: (isRegistrationOpen && !_isRegistering) ? _handleRegister : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isRegistrationOpen ? AppColors.brown : AppColors.grey300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.r),
          ),
          elevation: 0,
        ),
        child: _isRegistering
            ? SizedBox(
                height: 20.h,
                width: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Register Now',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isRegistrationOpen ? AppColors.white : AppColors.grey500,
                ),
              ),
      ),
    );
  }
}
