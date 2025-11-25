import 'package:flutter/material.dart';
import '../widgets/qr_code_widget.dart';
import '../widgets/qr_scanner_widget.dart';

/// Screen with tabs for QR code display and scanning functionality
class QRCameraScreen extends StatefulWidget {
  const QRCameraScreen({super.key});

  @override
  State<QRCameraScreen> createState() => _QRCameraScreenState();
}

class _QRCameraScreenState extends State<QRCameraScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code), text: 'My QR'),
            Tab(icon: Icon(Icons.qr_code_scanner), text: 'Scan QR'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [QRCodeWidget(), QRScannerWidget()],
      ),
    );
  }
}
