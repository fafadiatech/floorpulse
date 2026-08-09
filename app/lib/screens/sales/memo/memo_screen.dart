import 'package:flutter/material.dart';
import '../../../data/sales_mock_data.dart';
import '../../../models/sales_memo.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_utils.dart';

class MemoScreen extends StatefulWidget {
  const MemoScreen({super.key});

  @override
  State<MemoScreen> createState() => _MemoScreenState();
}

class _MemoScreenState extends State<MemoScreen> {
  MemoType _inputType = MemoType.note;
  final _contentController = TextEditingController();
  String? _selectedCustomerId;
  bool _isRecording = false;
  bool _hasRecorded = false;
  String _transcribedText = '';

  final _productController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    _productController.dispose();
    super.dispose();
  }

  void _startRecording() async {
    setState(() {
      _isRecording = true;
      _hasRecorded = false;
      _transcribedText = '';
    });
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() {
      _isRecording = false;
      _hasRecorded = true;
      _transcribedText =
          'Customer expressed strong interest in expanding order for next quarter. Requested pricing for bulk purchase of 10+ units. Will need formal quote by end of week.';
      _contentController.text = _transcribedText;
    });
  }

  void _saveMemo() {
    final content = _inputType == MemoType.voice
        ? _transcribedText
        : _contentController.text;
    if (content.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nothing to save')));
      return;
    }
    final customerName = _selectedCustomerId != null
        ? SalesMockData.customers
              .firstWhere((c) => c.id == _selectedCustomerId)
              .name
        : null;
    final newMemo = SalesMemo(
      id: 'm${DateTime.now().millisecondsSinceEpoch}',
      type: _inputType,
      content: content,
      createdAt: DateTime.now(),
      customerId: _selectedCustomerId,
      customerName: customerName,
      productInterest: _productController.text.isNotEmpty
          ? _productController.text
          : null,
    );
    SalesMockData.memos.insert(0, newMemo);
    _contentController.clear();
    _productController.clear();
    setState(() {
      _selectedCustomerId = null;
      _hasRecorded = false;
      _transcribedText = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Memo saved${customerName != null ? ' for $customerName' : ''}',
        ),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final memos = SalesMockData.memos;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Memo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input type toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _inputType = MemoType.voice;
                        _contentController.clear();
                        _hasRecorded = false;
                        _transcribedText = '';
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _inputType == MemoType.voice
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _inputType == MemoType.voice
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 4,
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mic,
                              size: 16,
                              color: _inputType == MemoType.voice
                                  ? AppTheme.primary
                                  : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Voice',
                              style: TextStyle(
                                color: _inputType == MemoType.voice
                                    ? AppTheme.primary
                                    : AppTheme.textSecondary,
                                fontWeight: _inputType == MemoType.voice
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _inputType = MemoType.note;
                        _hasRecorded = false;
                        _transcribedText = '';
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _inputType == MemoType.note
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _inputType == MemoType.note
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 4,
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit_note,
                              size: 16,
                              color: _inputType == MemoType.note
                                  ? AppTheme.primary
                                  : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Notes',
                              style: TextStyle(
                                color: _inputType == MemoType.note
                                    ? AppTheme.primary
                                    : AppTheme.textSecondary,
                                fontWeight: _inputType == MemoType.note
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Input area
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_inputType == MemoType.voice) ...[
                    Center(
                      child: GestureDetector(
                        onTap: _isRecording ? null : _startRecording,
                        child: Column(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: _isRecording
                                    ? AppTheme.danger
                                    : AppTheme.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (_isRecording
                                                ? AppTheme.danger
                                                : AppTheme.primary)
                                            .withValues(alpha: 0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isRecording ? Icons.stop : Icons.mic,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _isRecording
                                  ? 'Recording… tap to stop'
                                  : (_hasRecorded
                                        ? 'Re-record'
                                        : 'Tap to record'),
                              style: TextStyle(
                                color: _isRecording
                                    ? AppTheme.danger
                                    : AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_hasRecorded) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.success.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.record_voice_over,
                                  color: AppTheme.success,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Transcription',
                                  style: TextStyle(
                                    color: AppTheme.success,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _transcribedText,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ] else ...[
                    TextField(
                      controller: _contentController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Type your memo here…',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ],
                  const Divider(height: 20, color: AppTheme.divider),

                  // Customer & product
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCustomerId,
                      hint: const Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Associate with customer (optional)',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            'No customer',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ),
                        ...SalesMockData.customers.map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(
                              c.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _selectedCustomerId = v),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _productController,
                    decoration: const InputDecoration(
                      hintText: 'Product / service interest (optional)',
                      prefixIcon: Icon(
                        Icons.inventory_2_outlined,
                        color: AppTheme.textSecondary,
                        size: 18,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _saveMemo,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text(
                  'Save Memo',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Recent memos
            const Text(
              'Recent Memos',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            ...memos.map((m) => _MemoCard(memo: m)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _MemoCard extends StatelessWidget {
  final SalesMemo memo;
  const _MemoCard({required this.memo});

  @override
  Widget build(BuildContext context) {
    final isVoice = memo.type == MemoType.voice;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isVoice
                      ? AppTheme.primary.withValues(alpha: 0.1)
                      : AppTheme.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVoice ? Icons.mic : Icons.edit_note,
                      size: 11,
                      color: isVoice ? AppTheme.primary : AppTheme.success,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      isVoice ? 'Voice' : 'Note',
                      style: TextStyle(
                        color: isVoice ? AppTheme.primary : AppTheme.success,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                AppDateUtils.timeAgo(memo.createdAt),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            memo.content,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (memo.customerName != null || memo.productInterest != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (memo.customerName != null) ...[
                  const Icon(
                    Icons.business,
                    size: 11,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    memo.customerName!,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
                if (memo.productInterest != null) ...[
                  if (memo.customerName != null) const SizedBox(width: 10),
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 11,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    memo.productInterest!,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
