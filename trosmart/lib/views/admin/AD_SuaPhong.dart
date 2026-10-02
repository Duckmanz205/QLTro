import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'AD_XoaPhong.dart';
import '../../logic/admin/phong_service.dart';
import '../../models/admin/phong_model.dart';
import '../../models/admin/tien_ich_model.dart';
import '../../shared/api_constants.dart';

class EditPhongView extends StatefulWidget {
  final PhongModel room;
  final String tenCoSo;

  const EditPhongView({
    super.key,
    required this.room,
    required this.tenCoSo,
  });

  @override
  State<EditPhongView> createState() => _EditPhongViewState();
}

class _EditPhongViewState extends State<EditPhongView> {
  final _formKey = GlobalKey<FormState>();
  final PhongService _service = PhongService();
  final ImagePicker _imagePicker = ImagePicker();

  late final TextEditingController _soPhongController;
  late final TextEditingController _tangController;
  late final TextEditingController _dienTichController;
  late final TextEditingController _giaController;
  late final TextEditingController _soNguoiController;
  late final TextEditingController _moTaController;

  late String _trangThai;
  bool _isLoading = false;
  bool _isDeleting = false;
  bool _isLoadingTienIch = true;
  bool _isCreatingTienIch = false;

  XFile? _pickedImageFile;
  Uint8List? _pickedImageBytes;

  List<TienIchModel> _tienIchList = [];
  final Set<int> _selectedTienIchIds = {};

  @override
  void initState() {
    super.initState();

    _soPhongController = TextEditingController(text: widget.room.soPhong);
    _tangController = TextEditingController(
      text: widget.room.tang?.toString() ?? '',
    );
    _dienTichController = TextEditingController(
      text: widget.room.dienTich?.toString() ?? '',
    );
    _giaController = TextEditingController(
      text: widget.room.giaThue.toStringAsFixed(0),
    );
    _soNguoiController = TextEditingController(
      text: widget.room.soNguoiToiDa?.toString() ?? '',
    );
    _moTaController = TextEditingController(
      text: widget.room.moTa ?? '',
    );

    _trangThai = widget.room.statusLabel;

    _loadTienIch();
  }

  @override
  void dispose() {
    _soPhongController.dispose();
    _tangController.dispose();
    _dienTichController.dispose();
    _giaController.dispose();
    _soNguoiController.dispose();
    _moTaController.dispose();
    super.dispose();
  }

  Future<void> _loadTienIch() async {
    try {
      final data = await _service.getTienIchList();
      if (!mounted) return;

      final selectedNames = widget.room.tienIches
          .map((e) => e.trim().toLowerCase())
          .toSet();

      final selectedIds = <int>{};
      for (final item in data) {
        if (selectedNames.contains(item.tenTienIch.trim().toLowerCase())) {
          selectedIds.add(item.maTienIch);
        }
      }

      data.sort((a, b) => a.tenTienIch.compareTo(b.tenTienIch));

      setState(() {
        _tienIchList = data;
        _selectedTienIchIds
          ..clear()
          ..addAll(selectedIds);
        _isLoadingTienIch = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingTienIch = false;
      });
    }
  }

  bool _containsTienIchName(String ten) {
    final normalized = ten.trim().toLowerCase();
    return _tienIchList.any(
      (e) => e.tenTienIch.trim().toLowerCase() == normalized,
    );
  }

  Future<void> _openAddTienIchDialog() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Thêm tiện ích mới',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Ví dụ: Máy lạnh, Ban công, Tủ lạnh...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                Navigator.pop(dialogContext, text);
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null || result.trim().isEmpty) return;
    await _createTienIchAndSelect(result.trim());
  }

  Future<void> _createTienIchAndSelect(String tenTienIch) async {
    if (_containsTienIchName(tenTienIch)) {
      final existed = _tienIchList.firstWhere(
        (e) =>
            e.tenTienIch.trim().toLowerCase() ==
            tenTienIch.trim().toLowerCase(),
      );

      setState(() {
        _selectedTienIchIds.add(existed.maTienIch);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tiện ích đã tồn tại, đã tự chọn')),
      );
      return;
    }

    setState(() {
      _isCreatingTienIch = true;
    });

    try {
      final created = await _service.createTienIch(tenTienIch: tenTienIch);

      if (!mounted) return;

      setState(() {
        _tienIchList = [..._tienIchList, created]
          ..sort((a, b) => a.tenTienIch.compareTo(b.tenTienIch));
        _selectedTienIchIds.add(created.maTienIch);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm tiện ích mới')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể thêm tiện ích: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingTienIch = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (file == null) return;

      final bytes = await file.readAsBytes();

      setState(() {
        _pickedImageFile = file;
        _pickedImageBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể chọn ảnh: $e')),
      );
    }
  }

  int? _parseIntNullable(String value) {
    final clean = value.trim();
    if (clean.isEmpty) return null;
    return int.tryParse(clean);
  }

  num? _parseNumNullable(String value) {
    final clean = value.replaceAll(',', '.').trim();
    if (clean.isEmpty) return null;
    return num.tryParse(clean);
  }

  num _parseMoney(String value) {
    return num.tryParse(
          value.replaceAll('.', '').replaceAll(',', '').trim(),
        ) ??
        0;
  }

  String? _validateSoPhong(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Vui lòng nhập số phòng';
    if (text.length > 20) return 'Số phòng tối đa 20 ký tự';
    return null;
  }

  String? _validateTang(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;

    final parsed = int.tryParse(text);
    if (parsed == null) return 'Tầng phải là số nguyên';
    if (parsed < 1) return 'Tầng phải >= 1';
    return null;
  }

  String? _validateDienTich(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;

    final parsed = num.tryParse(text.replaceAll(',', '.'));
    if (parsed == null) return 'Diện tích không hợp lệ';
    if (parsed <= 0) return 'Diện tích phải > 0';
    return null;
  }

  String? _validateGia(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Nhập giá thuê';

    final parsed = _parseMoney(text);
    if (parsed <= 0) return 'Giá thuê phải > 0';
    return null;
  }

  String? _validateSoNguoi(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;

    final parsed = int.tryParse(text);
    if (parsed == null) return 'Số người phải là số nguyên';
    if (parsed < 1) return 'Số người tối đa phải >= 1';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final giaThue = _parseMoney(_giaController.text);
    final tang = _parseIntNullable(_tangController.text);
    final dienTich = _parseNumNullable(_dienTichController.text);
    final soNguoiToiDa = _parseIntNullable(_soNguoiController.text);

    setState(() => _isLoading = true);

    try {
      await _service.updatePhong(
        maPhong: widget.room.maPhong,
        maCoSo: widget.room.maCoSo,
        soPhong: _soPhongController.text.trim().toUpperCase(),
        tang: tang,
        dienTich: dienTich,
        giaThue: giaThue,
        soNguoiToiDa: soNguoiToiDa,
        trangThai: _trangThai,
        moTa: _moTaController.text.trim().isEmpty
            ? null
            : _moTaController.text.trim(),
        maTienIchIds: _selectedTienIchIds.toList(),
      );

      if (_pickedImageFile != null) {
        await _service.uploadPhongImage(
          maPhong: widget.room.maPhong,
          file: _pickedImageFile!,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật phòng thành công'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể cập nhật: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deletePhong() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DeletePhongView(
          room: widget.room,
          tenCoSo: widget.tenCoSo,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      Navigator.pop(context, true);
    }
  }

  void _cancel() {
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    final statusStyle = _statusStyle(_trangThai);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackRow(),
                const SizedBox(height: 14),
                _buildHeaderCard(),
                const SizedBox(height: 16),
                _buildImageCard(),
                const SizedBox(height: 12),
                _buildPickImageButton(),
                const SizedBox(height: 16),
                _buildOverviewCard(statusStyle),
                const SizedBox(height: 16),
                _buildSectionTitle('THÔNG TIN CẬP NHẬT'),
                const SizedBox(height: 10),
                _buildInput(
                  controller: _soPhongController,
                  label: 'Số phòng *',
                  hint: 'A101',
                  textCapitalization: TextCapitalization.characters,
                  validator: _validateSoPhong,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInput(
                        controller: _tangController,
                        label: 'Tầng',
                        hint: '1',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                        ],
                        validator: _validateTang,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInput(
                        controller: _dienTichController,
                        label: 'Diện tích (m²)',
                        hint: '25',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9.,-]'),
                          ),
                        ],
                        validator: _validateDienTich,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInput(
                        controller: _giaController,
                        label: 'Giá thuê hằng tháng (VNĐ) *',
                        hint: '3500000',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        validator: _validateGia,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInput(
                        controller: _soNguoiController,
                        label: 'Số người tối đa',
                        hint: '2',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                        ],
                        validator: _validateSoNguoi,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStatusDropdown(),
                const SizedBox(height: 18),
                _buildSectionTitle('TIỆN ÍCH PHÒNG'),
                const SizedBox(height: 10),
                _buildTienIchToolbar(),
                const SizedBox(height: 10),
                _buildTienIchSelector(),
                const SizedBox(height: 14),
                _buildSectionTitle('MÔ TẢ / GHI CHÚ'),
                const SizedBox(height: 10),
                _buildInput(
                  controller: _moTaController,
                  label: 'Mô tả',
                  hint: 'Nhập mô tả phòng...',
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
                _buildSaveButton(),
                const SizedBox(height: 12),
                _buildDeleteButton(),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: (_isLoading || _isDeleting) ? null : _cancel,
                    child: const Text(
                      'Hủy cập nhật',
                      style: TextStyle(
                        color: Color(0xFFFF4D4F),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTienIchToolbar() {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${_selectedTienIchIds.length} tiện ích đã chọn',
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.58),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: (_isLoading || _isCreatingTienIch) ? null : _openAddTienIchDialog,
          icon: _isCreatingTienIch
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add_rounded, size: 16),
          label: const Text(
            'Thêm tiện ích mới',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF7430A3),
            side: BorderSide(
              color: const Color(0xFF7430A3).withValues(alpha: 0.35),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTienIchSelector() {
    if (_isLoadingTienIch) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_tienIchList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F7FB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('Chưa có dữ liệu tiện ích'),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _tienIchList.map((item) {
          final selected = _selectedTienIchIds.contains(item.maTienIch);

          return FilterChip(
            selected: selected,
            label: Text(item.tenTienIch),
            onSelected: (value) {
              setState(() {
                if (value) {
                  _selectedTienIchIds.add(item.maTienIch);
                } else {
                  _selectedTienIchIds.remove(item.maTienIch);
                }
              });
            },
            selectedColor: const Color(0xFFEBDCF6),
            checkmarkColor: const Color(0xFF7430A3),
            labelStyle: TextStyle(
              color: selected
                  ? const Color(0xFF7430A3)
                  : const Color(0xFF191622),
              fontWeight: FontWeight.w700,
            ),
            side: BorderSide(
              color: selected
                  ? const Color(0xFF7430A3)
                  : Colors.black.withValues(alpha: 0.12),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBackRow() {
    return GestureDetector(
      onTap: _cancel,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Color(0xFF191622),
          ),
          SizedBox(width: 6),
          Text(
            'Quay lại',
            style: TextStyle(
              color: Color(0xFF191622),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF742EA1),
            Color(0xFF9C4FC1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Cập nhật thông tin phòng',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildImageCard() {
    return Container(
      width: double.infinity,
      height: 210,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF4EDF8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: _buildCurrentImage(),
    );
  }

  Widget _buildCurrentImage() {
    if (_pickedImageBytes != null) {
      return Image.memory(
        _pickedImageBytes!,
        fit: BoxFit.cover,
      );
    }

    final path = widget.room.hinhAnhPhong?.trim();
    final formattedPath = ApiConstants.formatImageUrl(path);
    if (formattedPath == null || formattedPath.isEmpty) {
      return const Center(
        child: Icon(
          Icons.image_outlined,
          color: Color(0xFF7430A3),
          size: 40,
        ),
      );
    }

    if (formattedPath.startsWith('assets/')) {
      return Image.asset(
        formattedPath,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return const Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Color(0xFF7430A3),
              size: 40,
            ),
          );
        },
      );
    }

    return Image.network(
      formattedPath,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        return const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Color(0xFF7430A3),
            size: 40,
          ),
        );
      },
    );
  }

  Widget _buildPickImageButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: (_isLoading || _isDeleting) ? null : _pickImage,
        icon: const Icon(Icons.upload_rounded),
        label: const Text(
          'Chọn ảnh phòng mới',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF7430A3),
          side: BorderSide(
            color: const Color(0xFF7430A3).withValues(alpha: 0.35),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(_RoomStatusStyle statusStyle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: statusStyle.bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _trangThai == 'Bảo trì'
                      ? Icons.build_rounded
                      : Icons.meeting_room_outlined,
                  color: statusStyle.mainColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'P.${widget.room.soPhong}',
                      style: const TextStyle(
                        color: Color(0xFF191622),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.tenCoSo,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.55),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: statusStyle.bgColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  _trangThai,
                  style: TextStyle(
                    color: statusStyle.mainColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _infoRow('Mã phòng', widget.room.maPhong.toString()),
          const SizedBox(height: 10),
          _infoRow('Mã cơ sở', widget.room.maCoSo.toString()),
          const SizedBox(height: 10),
          _infoRow('Giá hiện tại', _formatCurrency(widget.room.giaThue)),
          const SizedBox(height: 10),
          _infoRow(
            'Tầng hiện tại',
            widget.room.tang?.toString() ?? 'Chưa có',
          ),
          const SizedBox(height: 10),
          _infoRow(
            'Diện tích hiện tại',
            widget.room.dienTich != null
                ? '${widget.room.dienTich} m²'
                : 'Chưa có',
          ),
          const SizedBox(height: 10),
          _infoRow(
            'Số người hiện tại',
            widget.room.soNguoiToiDa?.toString() ?? 'Chưa có',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF7430A3),
        fontSize: 11.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.48),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF191622),
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _trangThai,
      decoration: _decoration('Trạng thái phòng'),
      items: const [
        DropdownMenuItem(
          value: 'Đang thuê',
          child: Text('Đang thuê'),
        ),
        DropdownMenuItem(
          value: 'Trống',
          child: Text('Trống'),
        ),
        DropdownMenuItem(
          value: 'Bảo trì',
          child: Text('Bảo trì'),
        ),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() => _trangThai = value);
      },
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      style: const TextStyle(
        color: Color(0xFF191622),
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
      ),
      decoration: _decoration(label, hint),
    );
  }

  InputDecoration _decoration(String label, [String? hint]) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: const Color(0xFF8A36B0).withValues(alpha: 0.25),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFF8A36B0),
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFFF4D4F),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFFF4D4F),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: (_isLoading || _isDeleting) ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7430A3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Lưu thay đổi ngay',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: (_isLoading || _isDeleting) ? null : _deletePhong,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFF4D4F),
          side: const BorderSide(color: Color(0xFFFF4D4F)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: _isDeleting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Xóa phòng',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
      ),
    );
  }

  String _formatCurrency(num value) {
    final text = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;

    for (int i = text.length - 1; i >= 0; i--) {
      buffer.write(text[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }

    return '${buffer.toString().split('').reversed.join()} VNĐ';
  }

  _RoomStatusStyle _statusStyle(String status) {
    if (status == 'Đang thuê') {
      return const _RoomStatusStyle(
        mainColor: Color(0xFF19D8B3),
        bgColor: Color(0xFFE7FFF8),
      );
    }

    if (status == 'Trống') {
      return const _RoomStatusStyle(
        mainColor: Color(0xFFF5A623),
        bgColor: Color(0xFFFFF3D9),
      );
    }

    return const _RoomStatusStyle(
      mainColor: Color(0xFFFF4D4F),
      bgColor: Color(0xFFFFE8E8),
    );
  }
}

class _RoomStatusStyle {
  final Color mainColor;
  final Color bgColor;

  const _RoomStatusStyle({
    required this.mainColor,
    required this.bgColor,
  });
}