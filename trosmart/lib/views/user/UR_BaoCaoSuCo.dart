import 'package:flutter/material.dart';
import '../../widgets/user/issue_reporting_widgets.dart';

class IssueReportingScreen extends StatefulWidget {
  const IssueReportingScreen({super.key});

  @override
  State<IssueReportingScreen> createState() => _IssueReportingScreenState();
}

class _IssueReportingScreenState extends State<IssueReportingScreen> {
  Key _historyKey = UniqueKey();
  bool _showNewRequestForm = false;

  void _refreshHistory() {
    setState(() {
      _historyKey = UniqueKey();
      _showNewRequestForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ActionHeader(
              onTapCreate: () {
                setState(() {
                  _showNewRequestForm = !_showNewRequestForm;
                });
              },
            ),
            if (_showNewRequestForm)
              NewRequestForm(
                onSubmitSuccess: _refreshHistory,
                onCancel: () {
                  setState(() {
                    _showNewRequestForm = false;
                  });
                },
              ),
            const HistoryDivider(),
            IssueHistoryList(key: _historyKey),
            const SizedBox(height: 40),
            const FooterIndicator(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}