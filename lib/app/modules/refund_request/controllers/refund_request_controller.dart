import 'dart:io';
import 'package:book_store_app/app/data/models/enums/enums.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RefundRequestController extends GetxController {
  Rx<RefundIssue?> selectedIssue = Rx<RefundIssue?>(null);
  RxList<File> attachments = <File>[].obs;
  final messageController = TextEditingController();

  bool get canContinue => selectedIssue.value != null && attachments.isNotEmpty;
  final issues = {
    RefundIssue.missing: "Missing product or accessories",
    RefundIssue.notReceived: "Package wasn't received",
    RefundIssue.notAsDescribed: "Product doesn't match description",
    RefundIssue.damaged: "Package or product is damaged",
    RefundIssue.wrongItem: "Wrong product was sent",
    RefundIssue.defective: "Product is defective or doesn't work",
    RefundIssue.counterfeit: "Suspected counterfeit",
  };
  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 80);
    if (file != null) {
      attachments.add(File(file.path));
    }
  }

  void removeAttachment(int index) {
    attachments.removeAt(index);
  }
}
