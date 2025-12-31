import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/profile_address_controller.dart';

class ProfileAddressView extends GetView<ProfileAddressController> {
  const ProfileAddressView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ProfileAddressView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ProfileAddressView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
