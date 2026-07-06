import 'dart:io';

import 'package:book_store_app/app/data/models/messaging/conversation_model.dart';
import 'package:book_store_app/app/data/models/messaging/message_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Buyer↔seller human messaging — `solvexo-api`'s `/api/messaging/*`.
///
/// Unlike most of this app's endpoints, the messaging controller returns
/// its service methods' results directly (no `{success, data}` envelope),
/// so every method here reads `response.data` as the raw payload.
class MessagingRepository {
  final BaseClient _client = BaseClient();

  // ─── Conversations ──────────────────────────────────────────────────────

  Future<ConversationModel?> startConversation(String storeId) async {
    try {
      final response = await _client.post(
        ApiConstants.startConversation,
        data: {'storeId': storeId},
      );
      return ConversationModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ startConversation error: $e');
      ToastUtil.showToast('Could not start conversation.');
      return null;
    }
  }

  Future<({List<ConversationModel> conversations, int total, int page, int pages})>
      getConversations({
    int page = 1,
    int limit = 20,
    String? storeId,
    bool? isArchived,
    bool? isPinned,
    String? q,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.conversations,
        requiresAuth: true,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (storeId != null && storeId.isNotEmpty) 'storeId': storeId,
          if (isArchived != null) 'isArchived': isArchived.toString(),
          if (isPinned != null) 'isPinned': isPinned.toString(),
          if (q != null && q.isNotEmpty) 'q': q,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final conversations = (data['conversations'] as List? ?? [])
          .map((c) => ConversationModel.fromJson(c as Map<String, dynamic>))
          .toList();
      return (
        conversations: conversations,
        total: data['total'] as int? ?? conversations.length,
        page: data['page'] as int? ?? page,
        pages: data['pages'] as int? ?? 1,
      );
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return (conversations: <ConversationModel>[], total: 0, page: 1, pages: 0);
    } catch (e) {
      debugPrint('❌ getConversations error: $e');
      return (conversations: <ConversationModel>[], total: 0, page: 1, pages: 0);
    }
  }

  Future<ConversationModel?> getConversationById(String id) async {
    try {
      final response = await _client.get(
        ApiConstants.conversationById(id),
        requiresAuth: true,
      );
      return ConversationModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ getConversationById error: $e');
      return null;
    }
  }

  Future<bool> setArchived(String id, bool archive) async {
    try {
      final response = await _client.patch(
        archive ? ApiConstants.archiveConversation(id) : ApiConstants.restoreConversation(id),
      );
      return (response.data as Map<String, dynamic>)['isArchived'] as bool? ?? archive;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return !archive;
    } catch (e) {
      debugPrint('❌ setArchived error: $e');
      return !archive;
    }
  }

  Future<bool> setPinned(String id, bool pin) async {
    try {
      final response = await _client.patch(
        ApiConstants.pinConversation(id),
        queryParameters: {'pin': pin.toString()},
      );
      return (response.data as Map<String, dynamic>)['isPinned'] as bool? ?? pin;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return !pin;
    } catch (e) {
      debugPrint('❌ setPinned error: $e');
      return !pin;
    }
  }

  Future<bool> setMuted(String id, bool mute) async {
    try {
      final response = await _client.patch(
        ApiConstants.muteConversation(id),
        queryParameters: {'mute': mute.toString()},
      );
      return (response.data as Map<String, dynamic>)['isMuted'] as bool? ?? mute;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return !mute;
    } catch (e) {
      debugPrint('❌ setMuted error: $e');
      return !mute;
    }
  }

  Future<bool> deleteConversation(String id) async {
    try {
      await _client.delete(ApiConstants.deleteConversation(id));
      return true;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ deleteConversation error: $e');
      return false;
    }
  }

  // ─── Messages ───────────────────────────────────────────────────────────

  Future<MessageModel?> sendMessage(
    String conversationId, {
    required String type,
    String? text,
    List<Map<String, dynamic>>? attachments,
    Map<String, dynamic>? productShare,
    Map<String, dynamic>? replyTo,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.conversationMessages(conversationId),
        data: {
          'type': type,
          if (text != null) 'text': text,
          if (attachments != null) 'attachments': attachments,
          if (productShare != null) 'productShare': productShare,
          if (replyTo != null) 'replyTo': replyTo,
        },
      );
      return MessageModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ sendMessage error: $e');
      ToastUtil.showToast('Could not send message.');
      return null;
    }
  }

  Future<({List<MessageModel> messages, String? nextCursor, bool hasMore})> getMessages(
    String conversationId, {
    String? before,
    int limit = 30,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.conversationMessages(conversationId),
        requiresAuth: true,
        queryParameters: {
          'limit': limit,
          if (before != null && before.isNotEmpty) 'before': before,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final messages = (data['messages'] as List? ?? [])
          .map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
          .toList();
      return (
        messages: messages,
        nextCursor: data['nextCursor'] as String?,
        hasMore: data['hasMore'] as bool? ?? false,
      );
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return (messages: <MessageModel>[], nextCursor: null, hasMore: false);
    } catch (e) {
      debugPrint('❌ getMessages error: $e');
      return (messages: <MessageModel>[], nextCursor: null, hasMore: false);
    }
  }

  Future<MessageModel?> editMessage(String messageId, String text) async {
    try {
      final response = await _client.patch(
        ApiConstants.editMessage(messageId),
        data: {'text': text},
      );
      return MessageModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ editMessage error: $e');
      return null;
    }
  }

  Future<bool> deleteMessage(String messageId) async {
    try {
      await _client.delete(ApiConstants.deleteMessage(messageId));
      return true;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ deleteMessage error: $e');
      return false;
    }
  }

  Future<bool> markSeen({required String conversationId, required String lastMessageId}) async {
    try {
      await _client.post(
        ApiConstants.markMessageSeen(lastMessageId),
        queryParameters: {'conversationId': conversationId},
      );
      return true;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ markSeen error: $e');
      return false;
    }
  }

  // ─── Attachments ────────────────────────────────────────────────────────

  Future<MessageAttachment?> uploadAttachment(String conversationId, File file) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });
      final response = await _client.post(
        ApiConstants.conversationAttachments(conversationId),
        data: formData,
      );
      return MessageAttachment.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ uploadAttachment error: $e');
      ToastUtil.showToast('Could not upload attachment.');
      return null;
    }
  }

  // ─── Moderation ─────────────────────────────────────────────────────────

  Future<bool> blockUser({required String targetId, required String targetRole, String? reason}) async {
    try {
      await _client.post(
        ApiConstants.blockUser,
        data: {
          'targetId': targetId,
          'targetRole': targetRole,
          if (reason != null) 'reason': reason,
        },
      );
      return true;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ blockUser error: $e');
      return false;
    }
  }

  Future<bool> reportTarget({
    required String targetType,
    required String targetId,
    required String reason,
    String? details,
  }) async {
    try {
      await _client.post(
        ApiConstants.reportTarget,
        data: {
          'targetType': targetType,
          'targetId': targetId,
          'reason': reason,
          if (details != null) 'details': details,
        },
      );
      return true;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ reportTarget error: $e');
      return false;
    }
  }
}
