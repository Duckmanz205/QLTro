import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../logic/admin/co_so_service.dart';
import '../../models/admin/tien_ich_model.dart';

class AddCoSoView extends StatefulWidget {
  final int maQuanLy;

  const AddCoSoView({
    super.key,
    required this.maQuanLy,
  });

  @override
  State<AddCoSoView> createState() => _AddCoSoViewState();
}

class _AddCoSoViewState extends State<AddCoSoView> {
  final _formKey = GlobalKey<FormState>();
  final CoSoService _service = CoSoService();
  final ImagePicker _imagePicker = ImagePicker();

  static const List<String> _loaiHinhItems = [
    'Nhà trọ',
    'KTX',
    'Chung cư',
  ];

  final TextEditingController _tenCoSoController = TextEditingController();
  final TextEditingController _diaChiController = TextEditingController();
  final TextEditingController _sdtController = TextEditingController();
  final TextEditingController _moTaController = TextEditingController();

  String _loaiHinh = 'Nhà trọ';
  bool _isLoading = false;

  final List<_PickedFacilityImage> _pickedImages = [];
  int? _selectedPickedImageIndex;

  double? _latitude;
  double? _longitude;

  List<TienIchModel> _tienIchList = [];
  final Set<int> _selectedTienIchIds = {};
  bool _isLoadingTienIch = true;

  @override
  void initState() {
    super.initState();
    _loadTienIch();
  }

  @override
  void dispose() {
    _tenCoSoController.dispose();
    _diaChiController.dispose();
    _sdtController.dispose();
    _moTaController.dispose();
    super.dispose();
  }

  Future<void> _loadTienIch() async {
    try {
      final data = await _service.getTienIchList();
      if (!mounted) return;

      setState(() {
        _tienIchList = data;
        _isLoadingTienIch = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingTienIch = false;
      });
    }
  }

  Future<void> _pickImagesFromDevice() async {
    try {
      final files = await _imagePicker.pickMultiImage(imageQuality: 85);

      if (files.isEmpty) return;

      final newItems = <_PickedFacilityImage>[];

      for (final file in files) {
        final bytes = await file.readAsBytes();
        newItems.add(
          _PickedFacilityImage(
            name: file.name,
            bytes: bytes,
            file: file,
          ),
        );
      }

      setState(() {
        _pickedImages.addAll(newItems);
        _selectedPickedImageIndex ??= 0;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể chọn ảnh: $e')),
      );
    }
  }

  void _selectPickedImage(int index) {
    setState(() {
      _selectedPickedImageIndex = index;
    });
  }

  void _removePickedImage(int index) {
    setState(() {
      _pickedImages.removeAt(index);

      if (_pickedImages.isEmpty) {
        _selectedPickedImageIndex = null;
        return;
      }

      if (_selectedPickedImageIndex == index) {
        _selectedPickedImageIndex = 0;
      } else if (_selectedPickedImageIndex != null &&
          _selectedPickedImageIndex! > index) {
        _selectedPickedImageIndex = _selectedPickedImageIndex! - 1;
      }
    });
  }

  Widget _buildCurrentDisplayImage() {
    if (_selectedPickedImageIndex != null &&
        _selectedPickedImageIndex! >= 0 &&
        _selectedPickedImageIndex! < _pickedImages.length) {
      return Image.memory(
        _pickedImages[_selectedPickedImageIndex!].bytes,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFF4EDF8),
      child: const Center(
        child: Icon(
          Icons.add_photo_alternate_outlined,
          color: Color(0xFF7B2CBF),
          size: 40,
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final maCoSo = await _service.createCoSo(
        tenCoSo: _tenCoSoController.text.trim(),
        diaChi: _diaChiController.text.trim(),
        loaiHinh: _loaiHinh,
        moTa: _moTaController.text.trim(),
        maQuanLy: widget.maQuanLy,
        latitude: _latitude,
        longitude: _longitude,
        maTienIchIds: _selectedTienIchIds.toList(),
      );

      if (maCoSo <= 0) {
        throw Exception('Không lấy được mã cơ sở sau khi tạo');
      }

      if (_pickedImages.isNotEmpty) {
        for (final item in _pickedImages) {
          await _service.uploadCoSoImage(
            maCoSo: maCoSo,
            file: item.file,
          );
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thêm cơ sở thành công'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể thêm cơ sở: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _cancel() {
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBackRow(),
              const SizedBox(height: 14),
              _buildHeaderCard(),
              const SizedBox(height: 16),
              _buildFormCard(),
            ],
          ),
        ),
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
        'Thêm cơ sở mới',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _sectionTitle('ẢNH CƠ SỞ'),
            const SizedBox(height: 10),
            _buildDisplayImageCard(),
            const SizedBox(height: 12),
            _buildImageActions(),
            const SizedBox(height: 12),
            _buildImageChooserList(),
            const SizedBox(height: 20),
            _sectionTitle('THÔNG TIN NHẬN DIỆN'),
            const SizedBox(height: 8),
            _inputField(
              controller: _tenCoSoController,
              label: 'Tên cơ sở *',
              hint: 'VD: Cơ sở Quận 7 - Luxury',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên cơ sở';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            _inputField(
              controller: _diaChiController,
              label: 'Địa chỉ cơ sở *',
              hint: '123 Nguyễn Văn Linh, P. Tân Phong',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập địa chỉ';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _sectionTitle('VỊ TRÍ MAP'),
            const SizedBox(height: 8),
            _buildMapPicker(),
            const SizedBox(height: 10),
            _buildCoordinateInfo(),
            const SizedBox(height: 18),
            _sectionTitle('THÔNG TIN CƠ BẢN'),
            const SizedBox(height: 8),
            _loaiHinhDropdown(),
            const SizedBox(height: 10),
            _inputField(
              controller: _sdtController,
              label: 'SĐT',
              hint: '0908 123 456',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            _sectionTitle('TIỆN ÍCH CƠ SỞ'),
            const SizedBox(height: 8),
            _buildTienIchSelector(),
            const SizedBox(height: 14),
            _sectionTitle('MÔ TẢ NGẮN'),
            const SizedBox(height: 8),
            _inputField(
              controller: _moTaController,
              label: '',
              hint: 'Nhập mô tả ngắn về cơ sở...',
              maxLines: 3,
            ),
            const SizedBox(height: 18),
            _buildActionButtons(),
          ],
        ),
      ),
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
              color:
                  selected ? const Color(0xFF7430A3) : const Color(0xFF191622),
              fontWeight: FontWeight.w700,
            ),
            side: BorderSide(
              color: selected
                  ? const Color(0xFF7430A3)
                  : Colors.black.withOpacity(0.12),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDisplayImageCard() {
    return Container(
      width: double.infinity,
      height: 190,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF4EDF8),
        border: Border.all(
          color: const Color(0xFF8A36B0).withOpacity(0.14),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildCurrentDisplayImage(),
          Positioned(
            right: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Ảnh sẽ upload khi bấm thêm',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _pickImagesFromDevice,
            icon: const Icon(Icons.upload_rounded, size: 18),
            label: const Text(
              'Chọn ảnh từ máy',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7430A3),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageChooserList() {
    if (_pickedImages.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F7FB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.black.withOpacity(0.04),
          ),
        ),
        child: Text(
          'Chưa có ảnh nào. Bạn hãy chọn ảnh từ máy để preview trước khi tạo cơ sở.',
          style: TextStyle(
            color: Colors.black.withOpacity(0.55),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Ảnh đã chọn',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF191622),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(_pickedImages.length, (index) {
            final item = _pickedImages[index];
            final isSelected = _selectedPickedImageIndex == index;

            return GestureDetector(
              onTap: () => _selectPickedImage(index),
              child: Container(
                width: 96,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFF4EDF8)
                      : const Color(0xFFF9F7FB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF7B2CBF)
                        : Colors.black.withOpacity(0.06),
                    width: isSelected ? 1.4 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            item.bytes,
                            width: 84,
                            height: 84,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removePickedImage(index),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF4D4F),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isSelected ? 'Ảnh chính' : 'Chọn chính',
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF7B2CBF)
                            : const Color(0xFF191622),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMapPicker() {
  final currentPoint = LatLng(
    _latitude ?? 10.7769,
    _longitude ?? 106.7009,
  );

  return Container(
    height: 240,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color(0xFF8A36B0).withOpacity(0.14),
      ),
    ),
    child: FlutterMap(
      options: MapOptions(
        initialCenter: currentPoint,
        initialZoom: 15.5,
        onTap: (tapPosition, point) {
          setState(() {
            _latitude = point.latitude;
            _longitude = point.longitude;
          });
        },
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',

          subdomains: const ['a', 'b', 'c'],

          userAgentPackageName: 'com.example.trosmart',

          tileProvider: NetworkTileProvider(),

          maxZoom: 19,
        ),

        if (_latitude != null && _longitude != null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(_latitude!, _longitude!),
                width: 42,
                height: 42,
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF7B2CBF),
                  size: 38,
                ),
              ),
            ],
          ),
      ],
    ),
  );
}

  Widget _buildCoordinateInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7FB),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: Colors.black.withOpacity(0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bấm trực tiếp lên bản đồ để chọn vị trí cơ sở',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF191622),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Latitude: ${_latitude?.toStringAsFixed(6) ?? 'Chưa có'}',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Colors.black.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Longitude: ${_longitude?.toStringAsFixed(6) ?? 'Chưa có'}',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Colors.black.withOpacity(0.65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loaiHinhDropdown() {
    return DropdownButtonFormField<String>(
      value: _loaiHinh,
      decoration: _inputDecoration(
        label: 'Loại hình',
        hint: '',
      ),
      items: _loaiHinhItems.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _loaiHinh = value;
        });
      },
      style: const TextStyle(
        color: Color(0xFF191622),
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 18,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _isLoading ? null : _cancel,
            child: const Text(
              'Hủy',
              style: TextStyle(
                color: Color(0xFFFF4D4F),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7430A3),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Thêm',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF7B2CBF),
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        color: Color(0xFF191622),
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
      ),
      decoration: _inputDecoration(
        label: label,
        hint: hint,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label.isEmpty ? null : label,
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.black.withOpacity(0.35),
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
      ),
      labelStyle: TextStyle(
        color: Colors.black.withOpacity(0.55),
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: const Color(0xFF8A36B0).withOpacity(0.22),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFF8A36B0),
          width: 1.2,
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
}

class _PickedFacilityImage {
  final String name;
  final Uint8List bytes;
  final XFile file;

  _PickedFacilityImage({
    required this.name,
    required this.bytes,
    required this.file,
  });
}