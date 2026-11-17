import 'package:book_store_app/app/modules/support_chat/controllers/support_chat_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/app/routes/deep_link_router.dart';
import 'package:book_store_app/config/app_config.dart';
import 'package:book_store_app/core/theme/base_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportChatView extends StatefulWidget {
  const SupportChatView({super.key});

  @override
  State<SupportChatView> createState() => _SupportChatViewState();
}

class _SupportChatViewState extends State<SupportChatView> {
  final c = Get.put(SupportChatController());
  final _input = TextEditingController();
  final _scroll = ScrollController();
  Worker? _worker;

  @override
  void initState() {
    super.initState();
    _worker = ever(c.messages, (_) => _toBottom());
  }

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  void _send() {
    final text = _input.text;
    _input.clear();
    c.send(text);
  }

  Future<void> _onChip(ChatChip chip) async {
    final link = chip.link;
    if (link == null) {
      c.send(chip.label);
      return;
    }
    if (DeepLinkRouter.open(link)) return;
    final uri = link.startsWith('http') ? Uri.parse(link) : Uri.parse(AppConfig.web(link));
    await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
  }

  @override
  void dispose() {
    _worker?.dispose();
    _input.dispose();
    _scroll.dispose();
    Get.delete<SupportChatController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: BaseColors.ink,
              child: Icon(Icons.support_agent_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: BaseSpacing.xs),
            Text('Edudeen Help'.tr, style: theme.textTheme.titleLarge),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Contact Us'.tr,
            icon: const Icon(Icons.mail_outline_rounded),
            onPressed: () => Get.toNamed(Routes.contactUsView),
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(() => c.notice.value == null
              ? const SizedBox.shrink()
              : MaterialBanner(
                  content: Text(c.notice.value!),
                  actions: [
                    TextButton(
                      onPressed: () => c.notice.value = null,
                      child: Text('Close'.tr),
                    ),
                  ],
                )),
          Expanded(
            child: Obx(() => ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(BaseSpacing.md),
                  itemCount: c.messages.length + (c.sending.value ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i >= c.messages.length) return const _Typing();
                    return _Bubble(entry: c.messages[i]);
                  },
                )),
          ),
          Obx(() => c.chips.isEmpty
              ? const SizedBox.shrink()
              : SizedBox(
                  height: 52,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: BaseSpacing.md),
                    itemCount: c.chips.length,
                    separatorBuilder: (_, __) => const SizedBox(width: BaseSpacing.xs),
                    itemBuilder: (_, i) {
                      final chip = c.chips[i];
                      return ActionChip(
                        avatar: chip.link == null
                            ? null
                            : const Icon(Icons.open_in_new_rounded, size: 16),
                        label: Text(chip.label),
                        onPressed: () => _onChip(chip),
                      );
                    },
                  ),
                )),
          Obx(() => c.pendingContactText.value == null
              ? const SizedBox.shrink()
              : _ContactCard(controller: c)),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  BaseSpacing.md, BaseSpacing.xs, BaseSpacing.xs, BaseSpacing.xs),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 1000,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Type your question…'.tr,
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(BaseRadius.pill),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(BaseRadius.pill),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: BaseSpacing.xxs),
                  Obx(() => IconButton.filled(
                        tooltip: 'Send'.tr,
                        onPressed: c.sending.value ? null : _send,
                        icon: const Icon(Icons.send_rounded),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.entry});
  final ChatEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mine = entry.author == ChatAuthor.me;
    final bg = mine ? BaseColors.ink : theme.colorScheme.surface;
    final fg = mine ? Colors.white : theme.colorScheme.onSurface;
    return Align(
      alignment: mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        child: Container(
          margin: const EdgeInsets.only(bottom: BaseSpacing.xs),
          padding: const EdgeInsets.symmetric(
              horizontal: BaseSpacing.sm, vertical: BaseSpacing.xs + 2),
          decoration: BoxDecoration(
            color: bg,
            border: mine ? null : Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadiusDirectional.only(
              topStart: const Radius.circular(BaseRadius.lg),
              topEnd: const Radius.circular(BaseRadius.lg),
              bottomStart: Radius.circular(mine ? BaseRadius.lg : BaseRadius.xs),
              bottomEnd: Radius.circular(mine ? BaseRadius.xs : BaseRadius.lg),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.author == ChatAuthor.team)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text('Edudeen team'.tr,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.primary)),
                ),
              Text(entry.text, style: theme.textTheme.bodyMedium?.copyWith(color: fg)),
              const SizedBox(height: 2),
              Text(DateFormat('h:mm a').format(entry.at),
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: fg.withValues(alpha: 0.6), fontWeight: FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Typing extends StatelessWidget {
  const _Typing();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: EdgeInsets.all(BaseSpacing.xs),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

/// Guests: name + email/phone once, so the Edudeen team can reply
/// (`source: 'needs_contact'` from the chatbot).
class _ContactCard extends StatefulWidget {
  const _ContactCard({required this.controller});
  final SupportChatController controller;

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
  final _name = TextEditingController();
  final _contact = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _contact.dispose();
    super.dispose();
  }

  void _submit() {
    final err = SupportChatController.validateContact(_name.text, _contact.text);
    setState(() => _error = err);
    if (err == null) widget.controller.submitContact(_name.text, _contact.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(
          BaseSpacing.md, 0, BaseSpacing.md, BaseSpacing.xs),
      padding: const EdgeInsets.all(BaseSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(BaseRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('So we can reply, share your name and an email or phone number.'.tr,
              style: theme.textTheme.bodyMedium),
          const SizedBox(height: BaseSpacing.xs),
          TextField(
            controller: _name,
            maxLength: 80,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: 'Your name'.tr, counterText: ''),
          ),
          const SizedBox(height: BaseSpacing.xs),
          TextField(
            controller: _contact,
            maxLength: 200,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'Email or phone'.tr,
              counterText: '',
              errorText: _error,
            ),
          ),
          const SizedBox(height: BaseSpacing.xs),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
                  onPressed: widget.controller.cancelContact,
                  child: Text('Cancel'.tr),
                ),
              ),
              const SizedBox(width: BaseSpacing.xs),
              Expanded(
                flex: 2,
                child: Obx(() => FilledButton(
                      style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                      onPressed: widget.controller.sending.value ? null : _submit,
                      child: Text('Send to Edudeen team'.tr),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
