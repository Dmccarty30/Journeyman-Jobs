# Phase 3: Advanced Features Implementation - Detailed Tasks

## 📅 Week 3 Overview

**Goal**: Implement rich messaging features including file attachments, reactions, threading, feed system, and push notifications
**Duration**: 5 working days
**Priority**: High - Essential for modern messaging experience

---

## Day 11: File Attachments System

### Task 11.1: Image Handling Implementation

**Estimated Time**: 4 hours
**Priority**: High

#### Subtasks

1. **Image Picker Integration** (1.5 hours)
   - [ ] Configure image_picker package
   - [ ] Implement camera capture
   - [ ] Add gallery selection
   - [ ] Handle multiple image selection
   - [ ] Add image compression

2. **Image Processing** (1.5 hours)
   - [ ] Implement image compression
   - [ ] Add resize options
   - [ ] Create thumbnail generation
   - [ ] Handle image orientation
   - [ ] Add watermark option for safety

3. **Image Storage** (1 hour)
   - [ ] Upload to Firebase Storage
   - [ ] Implement progress tracking
   - [ ] Add retry mechanism
   - [ ] Create cache management
   - [ ] Handle upload errors

**File: `image_attachment_service.dart`**

```dart
class ImageAttachmentService {
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int thumbnailSize = 200;
  static const int previewSize = 800;

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<ImageAttachment>> pickImages({
    bool allowMultiple = true,
    bool useCamera = false,
  }) async {
    try {
      final picker = useCamera
          ? [_picker.camera]
          : [_picker.gallery, _picker.camera];

      final List<XFile> pickedFiles = [];

      if (allowMultiple && !useCamera) {
        pickedFiles.addAll(await _picker.pickMultiImage());
      } else {
        final file = await (useCamera
            ? _picker.pickImage(source: ImageSource.camera)
            : _picker.pickImage(source: ImageSource.gallery));
        if (file != null) pickedFiles.add(file);
      }

      final attachments = <ImageAttachment>[];

      for (final file in pickedFiles) {
        if (await _validateImage(file)) {
          final attachment = await _processImage(file);
          if (attachment != null) {
            attachments.add(attachment);
          }
        }
      }

      return attachments;
    } catch (e) {
      debugPrint('Error picking images: $e');
      return [];
    }
  }

  Future<bool> _validateImage(XFile file) async {
    final size = await file.length();
    if (size > maxImageSize) {
      throw ImageSizeExceededException(
        'Image size exceeds ${maxImageSize ~/ (1024 * 1024)}MB limit',
      );
    }

    final bytes = await file.readAsBytes();
    final decoder = img.decodeImage(bytes);
    if (decoder == null) {
      throw InvalidImageException('Invalid image format');
    }

    return true;
  }

  Future<ImageAttachment?> _processImage(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final originalImage = img.decodeImage(bytes)!;

      // Create thumbnail
      final thumbnail = img.copyResize(
        originalImage,
        width: thumbnailSize,
        height: thumbnailSize,
        maintainAspect: true,
      );

      // Create preview
      final preview = img.copyResize(
        originalImage,
        width: previewSize,
        height: previewSize,
        maintainAspect: true,
      );

      // Compress if needed
      final compressed = originalImage.length > maxImageSize ~/ 2
          ? img.copyResize(
              originalImage,
              width: originalImage.width ~/ 2,
              height: originalImage.height ~/ 2,
            )
          : originalImage;

      return ImageAttachment(
        id: const Uuid().v4(),
        fileName: file.name,
        originalPath: file.path,
        thumbnailBytes: img.encodeJpg(thumbnail, quality: 80),
        previewBytes: img.encodeJpg(preview, quality: 85),
        compressedBytes: img.encodeJpg(compressed, quality: 90),
        originalSize: bytes.length,
        compressedSize: compressed.length,
        width: originalImage.width,
        height: originalImage.height,
        mimeType: lookupMimeType(file.path) ?? 'image/jpeg',
      );
    } catch (e) {
      debugPrint('Error processing image: $e');
      return null;
    }
  }

  Future<String> uploadImage(ImageAttachment attachment) async {
    try {
      final ref = _storage
          .ref()
          .child('chat_images')
          .child(attachment.id)
          .child(attachment.fileName);

      final uploadTask = ref.putData(
        attachment.compressedBytes,
        SettableMetadata(
          contentType: attachment.mimeType,
          customMetadata: {
            'original_name': attachment.fileName,
            'original_size': attachment.originalSize.toString(),
            'width': attachment.width.toString(),
            'height': attachment.height.toString(),
          },
        ),
      );

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw ImageUploadException('Failed to upload image: $e');
    }
  }
}
```

**Acceptance Criteria**:

- Images can be selected from camera/gallery
- Compression reduces file size while maintaining quality
- Upload progress is visible
- Images display with proper aspect ratio
- Error handling covers all failure cases

---

### Task 11.2: Document Handling Implementation

**Estimated Time**: 3 hours
**Priority**: High

#### Subtasks

1. **Document Picker Integration** (1 hour)
   - [ ] Configure file_picker package
   - [ ] Support PDF, DOC, DOCX, XLS, XLSX
   - [ ] Add file size validation (10MB limit)
   - [ ] Implement file type validation
   - [ ] Handle multiple file selection

2. **Document Preview** (1.5 hours)
   - [ ] Create PDF preview widget
   - [ ] Add document icon display
   - [ ] Show file metadata
   - [ ] Implement download progress
   - [ ] Add open-with functionality

3. **Document Storage** (30 min)
   - [ ] Upload to Firebase Storage
   - [ ] Create folder structure
   - [ ] Implement secure URLs
   - [ ] Add virus scanning (if available)

**File: `document_attachment_widget.dart`**

```dart
class DocumentAttachmentWidget extends StatelessWidget {
  final DocumentAttachment document;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final bool showProgress;

  const DocumentAttachmentWidget({
    Key? key,
    required this.document,
    this.onTap,
    this.onDownload,
    this.showProgress = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getFileColor().withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getFileIcon(),
                    color: _getFileColor(),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.fileName,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _formatFileSize(document.size),
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textGrey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatDate(document.uploadedAt),
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textGrey,
                            ),
                          ),
                        ],
                      ),
                      if (showProgress) ...[
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: document.downloadProgress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.accentCopper,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.download_outlined),
                  onPressed: onDownload,
                  color: AppTheme.primaryNavy,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon() {
    switch (document.extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor() {
    switch (document.extension.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (diff.inDays == 1) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    } else if (diff.inDays < 7) {
      return DateFormat('EEEE, h:mm a').format(date);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}
```

**Acceptance Criteria**:

- Documents can be selected and uploaded
- File type validation works
- Preview shows correct icons
- Download progress visible
- File size limits enforced

---

### Task 11.3: Attachment UI Components

**Estimated Time**: 2 hours
**Priority**: Medium

#### Subtasks

1. **Attachment Preview** (1 hour)
   - [ ] Create attachment preview grid
   - [ ] Show image thumbnails
   - [ ] Display document cards
   - [ ] Add remove button

2. **Upload Progress** (1 hour)
   - [ ] Create progress indicators
   - [ ] Show upload status
   - [ ] Add retry mechanism
   - [ ] Display error messages

**Acceptance Criteria**:

- Attachments display correctly
- Progress indicators update
- Errors show helpful messages
- UI responsive to loading states

---

## Day 12: Message Reactions & Threading

### Task 12.1: Enhanced Reaction System

**Estimated Time**: 3 hours
**Priority**: High

#### Subtasks

1. **Reaction Storage & Sync** (1 hour)
   - [ ] Implement reaction storage in Stream Chat
   - [ ] Sync reactions across clients
   - [ ] Handle reaction conflicts
   - [ ] Add reaction aggregation

2. **Reaction Picker UI** (1 hour)
   - [ ] Enhance reaction picker with search
   - [ ] Add frequently used reactions
   - [ ] Implement custom reaction upload
   - [ ] Add animation effects

3. **Reaction Display** (1 hour)
   - [ ] Show reactions below messages
   - [ ] Display reaction counts
   - [ ] Show who reacted
   - [ ] Add reaction animations

**File: `reaction_bar_widget.dart`**

```dart
class ReactionBarWidget extends StatefulWidget {
  final String messageId;
  final Map<String, List<String>> reactions;
  final String? currentUserId;
  final Function(String, bool) onReactionToggle;

  const ReactionBarWidget({
    Key? key,
    required this.messageId,
    required this.reactions,
    required this.currentUserId,
    required this.onReactionToggle,
  }) : super(key: key);

  @override
  State<ReactionBarWidget> createState() => _ReactionBarWidgetState();
}

class _ReactionBarWidgetState extends State<ReactionBarWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reactions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: widget.reactions.entries.map((entry) {
          final emoji = entry.key;
          final userIds = entry.value;
          final count = userIds.length;
          final isReactedByMe = widget.currentUserId != null &&
              userIds.contains(widget.currentUserId);

          return GestureDetector(
            onTap: () {
              _animationController.forward().then((_) {
                _animationController.reverse();
              });
              widget.onReactionToggle(emoji, isReactedByMe);
            },
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isReactedByMe ? _scaleAnimation.value : 1.0,
                  child: _buildReactionChip(
                    emoji: emoji,
                    count: count,
                    isReactedByMe: isReactedByMe,
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReactionChip({
    required String emoji,
    required int count,
    required bool isReactedByMe,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isReactedByMe
            ? AppTheme.accentCopper.withValues(alpha:0.2)
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        border: isReactedByMe
            ? Border.all(color: AppTheme.accentCopper, width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: AppTheme.bodySmall.copyWith(
              color: isReactedByMe ? AppTheme.accentCopper : AppTheme.textGrey,
              fontWeight: isReactedByMe ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
```

**Acceptance Criteria**:

- Reactions add/remove correctly
- Counts update in real-time
- UI shows user's reactions
- Animations are smooth and responsive

---

### Task 12.2: Message Threading Implementation

**Estimated Time**: 4 hours
**Priority**: High

#### Subtasks

1. **Thread Data Model** (1 hour)
   - [ ] Create Thread model
   - [ ] Implement thread metadata
   - [ ] Add thread participation tracking
   - [ ] Create thread settings

2. **Thread UI Components** (1.5 hours)
   - [ ] Create thread reply button
   - [ ] Show thread indicator
   - [ ] Display thread preview
   - [ ] Add thread counter

3. **Thread Screen** (1.5 hours)
   - [ ] Create ThreadScreen
   - [ ] Show parent message
     - [ ] Display thread messages
     - [ ] Implement thread input
     - [ ] Add thread navigation

**File: `thread_screen.dart`**

```dart
class ThreadScreen extends StatefulWidget {
  final String channelId;
  final String parentMessageId;
  final Message parentMessage;

  const ThreadScreen({
    Key? key,
    required this.channelId,
    required this.parentMessageId,
    required this.parentMessage,
  }) : super(key: key);

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: Text('Thread'),
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: MessageBubble(
              message: widget.parentMessage,
              isOwnMessage: widget.parentMessage.user?.id ==
                  context.read<ChatProvider>().currentUserId,
              isThreadParent: true,
              onTap: null,
            ),
          ),
        ),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          final threadMessages = provider.getThreadMessages(
            widget.parentMessageId,
          );

          return Column(
            children: [
              Expanded(
                child: threadMessages.isEmpty
                    ? _buildEmptyThreadState()
                    : _buildThreadMessages(threadMessages),
              ),
              ThreadMessageInput(
                parentMessageId: widget.parentMessageId,
                channelId: widget.channelId,
                onSend: _sendThreadMessage,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyThreadState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 64,
            color: AppTheme.textGrey,
          ),
          const SizedBox(height: 16),
          Text(
            'Start a thread',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.textGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reply to this message to start a thread',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreadMessages(List<Message> messages) {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isOwnMessage = message.user?.id ==
            context.read<ChatProvider>().currentUserId;

        return MessageBubble(
          message: message,
          isOwnMessage: isOwnMessage,
          isThreadReply: true,
          onTap: null,
        );
      },
    );
  }

  void _sendThreadMessage(String text) {
    context.read<ChatProvider>().sendThreadMessage(
      channelId: widget.channelId,
      parentMessageId: widget.parentMessageId,
      text: text,
    );

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
```

**Acceptance Criteria**:

- Threads create properly
- Thread messages display correctly
- Parent message always visible
- Thread replies work

---

## Day 13: Feed System Implementation

### Task 13.1: Feed Channel Creation

**Estimated Time**: 3 hours
**Priority**: High

#### Subtasks

1. **Feed Channel Types** (1 hour)
   - [ ] Create announcement channels
   - [ ] Create job posting channels
   - [ ] Create safety alert channels
   - [ ] Create general feed channels

2. **Feed Permissions** (1 hour)
   - [ ] Implement posting permissions
   - [ ] Add moderation roles
   - [ ] Create read-only access
   - [ ] Set up posting queues

3. **Feed Configuration** (1 hour)
   - [ ] Configure feed settings
   - [ ] Set up auto-moderation
   - [ ] Add content filters
   - [ ] Implement feed rules

**File: `feed_service.dart`**

```dart
class FeedService {
  final StreamChatService _chatService;

  FeedService(this._chatService);

  Future<Either<ChatException, Channel>> createFeedChannel({
    required String feedName,
    required FeedType feedType,
    bool isPublic = true,
    List<String> moderators = const [],
    FeedSettings? settings,
  }) async {
    try {
      final extraData = {
        'name': feedName,
        'type': 'feed',
        'feed_type': feedType.value,
        'is_public': isPublic,
        'moderators': moderators,
        'created_by': _chatService.currentUserId,
        'settings': settings?.toJson() ?? FeedSettings.defaultSettings.toJson(),
        'electrical_feed': true,
        'feed_features': _getFeedFeatures(feedType),
        'created_at': DateTime.now().toIso8601String(),
      };

      final channelType = feedType == FeedType.announcement
          ? 'livestream'
          : 'messaging';

      final channel = await _chatService.client.channel(
        channelType,
        extraData: extraData,
      );

      // Set up feed-specific permissions
      if (!isPublic) {
        await channel.update({
          'members': moderators + [_chatService.currentUserId!],
        });
      }

      return Right(channel);
    } catch (e) {
      return Left(ChannelCreationException(e.toString()));
    }
  }

  List<String> _getFeedFeatures(FeedType type) {
    switch (type) {
      case FeedType.announcement:
        return ['pinning', 'moderation', 'priority', 'push_all'];
      case FeedType.job_posting:
        return ['job_cards', 'apply_button', 'deadline_tracking', 'share_crew'];
      case FeedType.safety_alert:
        return ['priority', 'acknowledgment', 'escalation', 'push_all'];
      case FeedType.general:
        return ['reactions', 'comments', 'sharing', 'moderation'];
      default:
        return [];
    }
  }

  Future<Either<ChatException, void>> publishToFeed({
    required String channelId,
    required String title,
    required String content,
    FeedPostType postType = FeedPostType.text,
    Map<String, dynamic>? attachments,
    List<String>? tags,
    bool isPriority = false,
  }) async {
    try {
      final channel = _chatService.client.channel(
        channelType: 'messaging',
        id: channelId,
      );

      final messageData = {
        'title': title,
        'content': content,
        'post_type': postType.value,
        'attachments': attachments ?? {},
        'tags': tags ?? [],
        'is_priority': isPriority,
        'feed_metadata': {
          'published_at': DateTime.now().toIso8601String(),
          'published_by': _chatService.currentUserId,
        },
      };

      await channel.sendMessage(MessageRequest(
        text: content,
        extraData: messageData,
      ));

      return const Right(null);
    } catch (e) {
      return Left(MessageSendingException(e.toString()));
    }
  }
}

enum FeedType {
  announcement('announcement'),
  job_posting('job_posting'),
  safety_alert('safety_alert'),
  general('general');

  const FeedType(this.value);
  final String value;
}

enum FeedPostType {
  text('text'),
  image('image'),
  document('document'),
  job_posting('job_posting'),
  safety_alert('safety_alert'),
  poll('poll');

  const FeedPostType(this.value);
  final String value;
}

class FeedSettings {
  final bool allowComments;
  final bool requireModeration;
  final bool autoDeleteOld;
  final int maxPostAge;
  final List<String> blockedWords;

  const FeedSettings({
    this.allowComments = true,
    this.requireModeration = false,
    this.autoDeleteOld = false,
    this.maxPostAge = 30,
    this.blockedWords = const [],
  });

  static const FeedSettings defaultSettings = FeedSettings();

  Map<String, dynamic> toJson() => {
        'allow_comments': allowComments,
        'require_moderation': requireModeration,
        'auto_delete_old': autoDeleteOld,
        'max_post_age': maxPostAge,
        'blocked_words': blockedWords,
      };
}
```

**Acceptance Criteria**:

- Feed channels create with correct types
- Permissions enforced properly
- Settings apply correctly
- Features enabled per feed type

---

### Task 13.2: Feed UI Implementation

**Estimated Time**: 4 hours
**Priority**: High

#### Subtasks

1. **Feed Screen Layout** (1.5 hours)
   - [ ] Create FeedScreen with tabs
   - [ ] Implement feed filters
   - [ ] Add search functionality
   - [ ] Create post creation FAB

2. **Feed Post Cards** (2 hours)
   - [ ] Design post card layout
   - [ ] Show post metadata
   - [ ] Add interaction buttons
     - [ ] Implement post filtering
     - [ ] Add pagination

3. **Feed Moderation** (30 min)
   - [ ] Create moderation tools
   - [ ] Add approve/reject buttons
   - [ ] Implement flagging system
   - [ ] Show moderation queue

**Acceptance Criteria**:

- Feed posts display correctly
- Filters work properly
- Interactions are responsive
- Moderation tools functional

---

### Task 13.3: Feed Post Creation

**Estimated Time**: 2 hours
**Priority**: Medium

#### Subtasks

1. **Post Creator** (1 hour)
   - [ ] Create post creation dialog
   - [ ] Add rich text editor
   - [ ] Implement attachment upload
   - [ ] Add tag system

2. **Post Validation** (1 hour)
   - [ ] Validate post content
   - [ ] Check permissions
   - [ ] Run moderation checks
   - [ ] Show preview

**Acceptance Criteria**:

- Posts create successfully
- Validation works properly
- Permissions enforced
- Preview accurate

---

## Day 14: Push Notifications

### Task 14.1: Firebase Messaging Setup

**Estimated Time**: 3 hours
**Priority**: High

#### Subtasks

1. **FCM Configuration** (1 hour)
   - [ ] Initialize Firebase Messaging
   - [ ] Request notification permissions
   - [ ] Handle token refresh
   - [ ] Store FCM token

2. **Notification Channels** (1 hour)
   - [ ] Create notification channels
   - [ ] Configure channel importance
   - [ ] Set up notification sounds
   - [ ] Add vibration patterns

3. **Message Handling** (1 hour)
   - [ ] Handle foreground messages
   - [ ] Handle background messages
   - [ ] Handle notification taps
   - [ ] Deep link handling

**File: `notification_service.dart`**

```dart
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Request permissions
    await _requestPermissions();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get FCM token
    await _getFCMToken();

    // Set up message handlers
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      debugPrint('User declined notification permissions');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels
    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    const crewChannel = AndroidNotificationChannel(
      'crew_messages',
      'Crew Messages',
      description: 'Messages from your crew channels',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    const safetyChannel = AndroidNotificationChannel(
      'safety_alerts',
      'Safety Alerts',
      description: 'Important safety alerts',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    const jobChannel = AndroidNotificationChannel(
      'job_postings',
      'Job Postings',
      description: 'New job opportunities',
      importance: Importance.default_,
      enableVibration: true,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(crewChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(safetyChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(jobChannel);
  }

  Future<void> _getFCMToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _saveFCMToken(token);
      debugPrint('FCM Token: $token');
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((token) {
      _saveFCMToken(token);
    });
  }

  Future<void> _saveFCMToken(String token) async {
    // Save token to user profile in Firestore
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'fcmToken': token});
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _getChannelId(message.data['type']),
            _getChannelName(message.data['type']),
            channelDescription: _getChannelDescription(message.data['type']),
            icon: android?.smallIcon,
            color: AppTheme.accentCopper,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  void _handleMessageTap(RemoteMessage message) {
    // Handle navigation when notification is tapped
    final data = message.data;
    if (data['type'] == 'crew_message') {
      Get.context?.go('/chat/${data['channelId']}');
    } else if (data['type'] == 'safety_alert') {
      Get.context?.go('/alerts/${data['alertId']}');
    } else if (data['type'] == 'job_posting') {
      Get.context?.go('/jobs/${data['jobId']}');
    }
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    await Firebase.initializeApp();
    debugPrint('Background message received: ${message.messageId}');
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      final data = jsonDecode(payload);
      _handleMessageTap(RemoteMessage.fromMap(data));
    }
  }

  String _getChannelId(String? type) {
    switch (type) {
      case 'crew_message':
        return 'crew_messages';
      case 'safety_alert':
        return 'safety_alerts';
      case 'job_posting':
        return 'job_postings';
      default:
        return 'general';
    }
  }

  String _getChannelName(String? type) {
    switch (type) {
      case 'crew_message':
        return 'Crew Messages';
      case 'safety_alert':
        return 'Safety Alerts';
      case 'job_posting':
        return 'Job Postings';
      default:
        return 'General';
    }
  }

  String _getChannelDescription(String? type) {
    switch (type) {
      case 'crew_message':
        return 'Messages from your crew channels';
      case 'safety_alert':
        return 'Important safety alerts';
      case 'job_posting':
        return 'New job opportunities';
      default:
        return 'General notifications';
    }
  }
}
```

**Acceptance Criteria**:

- Notifications receive when app is in background
- Foreground notifications display properly
- Tapping notifications navigates correctly
- Permissions handled gracefully

---

### Task 14.2: Notification Types Implementation

**Estimated Time**: 2 hours
**Priority**: High

#### Subtasks

1. **Crew Notifications** (30 min)
   - [ ] New crew message
   - [ ] Crew invitation
   - [ ] Crew member joined/left
   - [ ] Crew updates

2. **Safety Alert Notifications** (30 min)
   - [ ] Immediate safety alerts
   - [ ] Weather warnings
   - [ ] Site hazards
   - [ ] Emergency contacts

3. **Job Notifications** (30 min)
   - [ ] New job postings
   - [ ] Job application updates
   - [ ] Interview requests
   - [ ] Job recommendations

4. **System Notifications** (30 min)
   - [ ] App updates
   - [ ] Maintenance notices
   - [ ] Feature announcements
   - [ ] Policy updates

**Acceptance Criteria**:

- All notification types work
- Notification content is relevant
- Deep links work correctly
- Badge counts update

---

## Day 15: Offline Support Enhancement

### Task 15.1: Persistence Configuration

**Estimated Time**: 2 hours
**Priority**: Medium

#### Subtasks

1. **Enhanced Persistence** (1 hour)
   - [ ] Configure Stream Chat persistence
   - [ ] Set up offline message queue
   - [ ] Implement conflict resolution
   - [ ] Add sync indicators

2. **Offline UI** (1 hour)
   - [ ] Show offline status
   - [ ] Display pending messages
     - [ ] Add retry failed messages
     - [ ] Implement sync progress

**Acceptance Criteria**:

- Messages send when back online
- Conflicts resolve automatically
- UI shows offline status
- Sync indicators visible

---

## 🎯 Week 3 Deliverables

### Completed Features

1. ✅ Image attachment support with compression
2. ✅ Document attachment handling
3. ✅ Enhanced reaction system with electrical emojis
4. ✅ Message threading implementation
5. ✅ Feed system with moderation
6. ✅ Push notifications for all message types
7. ✅ Safety alert notifications
8. ✅ Job sharing notifications
9. ✅ Offline message queue
10. ✅ Attachment preview and download

### Working Components

- Files can be attached and sent
- Reactions add in real-time
- Threads organize conversations
- Feed posts display correctly
- Notifications receive reliably
- Offline mode works seamlessly

### Ready for Testing

- Complete attachment flow
- Real-time reactions
- Threaded conversations
- Feed posting and moderation
- Push notification delivery
- Offline synchronization

---

## ✅ Week 3 Completion Checklist

### Core Features

- [ ] Image attachments functional
- [ ] Document attachments working
- [ ] Reaction system active
- [ ] Message threading implemented
- [ ] Feed system operational
- [ ] Push notifications active
- [ ] Offline support enhanced

### Quality Assurance

- [ ] All features tested
- [ ] Performance optimized
- [ ] Memory usage within limits
- [ ] Battery consumption acceptable

### Documentation

- [ ] Feature documentation complete
- [ ] API integration documented
- [ ] User guide updated
- [ ] Troubleshooting guide created

---

## 🚀 Next Week Preparation

### Before starting Phase 4

1. Collect user feedback on Phase 3 features
2. Analyze notification delivery rates
3. Review attachment performance
4. Test offline synchronization thoroughly
5. Prepare electrical-specific features design

### Phase 4 Preview

- Job sharing integration with existing Job model
- Safety alert system with acknowledgment
- Location sharing and job site features
- Electrical-themed customizations
- Performance optimization for field use

This detailed task breakdown for Phase 3 provides comprehensive guidance for implementing advanced messaging features that will create a modern, feature-rich chat experience tailored for electrical workers.
