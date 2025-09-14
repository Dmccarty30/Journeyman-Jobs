import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/app_theme.dart';
import '../../../models/job_model.dart';
import '../../../models/user_model.dart';
import 'recipient_selector.dart';

/// Modal for selecting recipients and sharing jobs
/// 
/// Features:
/// - Electrical-themed design with copper accents
/// - Job preview with key details
/// - Recipient selection with search functionality
/// - Personal message input
/// - Share progress indication
class JJShareModal extends StatefulWidget {
  /// The job to be shared
  final Job job;
  
  /// List of available contacts/recipients
  final List<UserModel> contacts;
  
  /// Callback when share is confirmed
  final Function(List<UserModel> recipients, String? message) onShare;
  
  /// Whether sharing is in progress
  final bool isSharing;

  const JJShareModal({
    Key? key,
    required this.job,
    required this.contacts,
    required this.onShare,
    this.isSharing = false,
  }) : super(key: key);

  @override
  State<JJShareModal> createState() => _JJShareModalState();
}

class _JJShareModalState extends State<JJShareModal>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocus = FocusNode();
  
  List<UserModel> _selectedRecipients = [];
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    
    // Animate in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocus.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleShare() {
    if (_selectedRecipients.isNotEmpty && !widget.isSharing) {
      final message = _messageController.text.trim();
      widget.onShare(
        _selectedRecipients,
        message.isEmpty ? null : message,
      );
    }
  }

  void _handleClose() {
    _slideController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.5),
      child: Stack(
        children: [
          // Backdrop tap to close
          Positioned.fill(
            child: GestureDetector(
              onTap: _handleClose,
              child: Container(color: Colors.transparent),
            ),
          ),
          
          // Modal content
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                  minHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                margin: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    _buildHeader(),
                    
                    // Content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppTheme.spacingLg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Job preview
                            _buildJobPreview(),
                            
                            const SizedBox(height: AppTheme.spacingLg),
                            
                            // Recipient selector
                            _buildRecipientSection(),
                            
                            const SizedBox(height: AppTheme.spacingLg),
                            
                            // Message input
                            _buildMessageSection(),
                          ],
                        ),
                      ),
                    ),
                    
                    // Footer
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: const BoxDecoration(
        gradient: AppTheme.electricalGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusLg),
          topRight: Radius.circular(AppTheme.radiusLg),
        ),
      ),
      child: Row(
        children: [
          // Lightning icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: const Icon(
              Icons.flash_on_rounded,
              color: Colors.white,
              size: 20,
            ),
          )
            .animate()
            .scale(delay: 100.ms)
            .shimmer(duration: 1000.ms, color: Colors.white.withOpacity(0.5)),
          
          const SizedBox(width: AppTheme.spacingMd),
          
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share Job Opportunity',
                  style: AppTheme.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Spread the word to your network',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          
          // Close button
          IconButton(
            onPressed: _handleClose,
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobPreview() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.accentCopper.withOpacity(0.3),
          width: AppTheme.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job title and company
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.job.jobTitle ?? "Job Title",
                      style: AppTheme.titleMedium.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      widget.job.company,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.accentCopper,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Job type badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSm,
                  vertical: AppTheme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentCopper.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Text(
                  widget.job.typeOfWork ?? widget.job.classification ?? "Job",
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.accentCopper,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Key details
          Row(
            children: [
              // Location
              Expanded(
                child: _buildJobDetail(
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  value: widget.job.location,
                ),
              ),
              
              // Pay rate
              if (widget.job.wage != null)
                Expanded(
                  child: _buildJobDetail(
                    icon: Icons.payments_outlined,
                    label: 'Rate',
                    value: '\$${widget.job.wage}/hr',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: AppTheme.spacingXs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.labelSmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecipientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 20,
              color: AppTheme.accentCopper,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              'Select Recipients',
              style: AppTheme.titleSmall.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_selectedRecipients.isNotEmpty) ...[
              const SizedBox(width: AppTheme.spacingSm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSm,
                  vertical: AppTheme.spacingXxs,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentCopper,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Text(
                  '${_selectedRecipients.length}',
                  style: AppTheme.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        
        const SizedBox(height: AppTheme.spacingMd),
        
        JJRecipientSelector(
          contacts: widget.contacts,
          selectedRecipients: _selectedRecipients,
          onRecipientsChanged: (recipients) {
            setState(() {
              _selectedRecipients = recipients;
            });
          },
        ),
      ],
    );
  }

  Widget _buildMessageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.message_outlined,
              size: 20,
              color: AppTheme.accentCopper,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              'Personal Message (Optional)',
              style: AppTheme.titleSmall.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppTheme.spacingMd),
        
        TextField(
          controller: _messageController,
          focusNode: _messageFocus,
          maxLines: 3,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: 'Add a personal note about this opportunity...',
            filled: true,
            fillColor: AppTheme.surfaceElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(
                color: AppTheme.borderLight,
                width: AppTheme.borderWidthThin,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(
                color: AppTheme.borderLight,
                width: AppTheme.borderWidthThin,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: const BorderSide(
                color: AppTheme.accentCopper,
                width: AppTheme.borderWidthMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.radiusLg),
          bottomRight: Radius.circular(AppTheme.radiusLg),
        ),
        border: Border(
          top: BorderSide(
            color: AppTheme.borderLight,
            width: AppTheme.borderWidthThin,
          ),
        ),
      ),
      child: Row(
        children: [
          // Cancel button
          Expanded(
            child: OutlinedButton(
              onPressed: widget.isSharing ? null : _handleClose,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: AppTheme.mediumGray,
                  width: AppTheme.borderWidthThin,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingMd,
                ),
              ),
              child: Text(
                'Cancel',
                style: AppTheme.buttonMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: AppTheme.spacingMd),
          
          // Share button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _selectedRecipients.isEmpty || widget.isSharing
                  ? null
                  : _handleShare,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCopper,
                disabledBackgroundColor: AppTheme.mediumGray,
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingMd,
                ),
              ),
              child: widget.isSharing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Text(
                          'Sharing...',
                          style: AppTheme.buttonMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.flash_on_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Text(
                          'Share Job',
                          style: AppTheme.buttonMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
