import 'package:bk_pos/features/cashier/presentation/input_decoration.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:bk_pos/utils/format_rupiah.dart';
import 'package:flutter/material.dart';

class FloatingChangeCalculator extends StatefulWidget {
  final double totalTransaksi;

  const FloatingChangeCalculator({super.key, required this.totalTransaksi});

  @override
  State<FloatingChangeCalculator> createState() =>
      _FloatingChangeCalculatorState();
}

class _FloatingChangeCalculatorState extends State<FloatingChangeCalculator> {
  final TextEditingController _uangController = TextEditingController();

  bool _isOpen = false;
  double _uangDibayar = 0;
  double get _total => widget.totalTransaksi > 0 ? widget.totalTransaksi : 0;
  double get _kembalian => _uangDibayar - _total;

  void _onUangChanged(String value) {
    setState(() {
      _uangDibayar = parseRupiah(value);
    });
  }

  void _closeCalculator() {
    setState(() {
      _isOpen = false;
      _uangDibayar = 0;
      _uangController.clear();
    });
  }

  @override
  void dispose() {
    _uangController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _closeCalculator,
              child: Container(color: Colors.transparent),
            ),
          ),

        SafeArea(
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _isOpen
                    ? _buildCalculatorPanel()
                    : _buildFloatingButton(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingButton() {
    return Material(
      key: const ValueKey('calculator_button'),
      color: Colors.blueGrey.shade800,
      elevation: 6,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          setState(() => _isOpen = true);
        },
        child: const SizedBox(
          width: 52,
          height: 52,
          child: Icon(Icons.calculate_outlined, color: Colors.white, size: 26),
        ),
      ),
    );
  }

  Widget _buildCalculatorPanel() {
    final sudahCukup = _uangDibayar >= _total && _uangDibayar > 0;

    return Material(
      key: const ValueKey('calculator_panel'),
      elevation: 10,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: SizedBox(
        width: 280,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calculate_outlined, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Kalkulator Kembalian',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _closeCalculator,
                    icon: const Icon(Icons.close, size: 20),
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Tutup',
                  ),
                ],
              ),

              const Divider(),

              const Text(
                'Total Transaksi',
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                formatRupiah(_total),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _uangController,
                keyboardType: TextInputType.number,
                inputFormatters: [RupiahInputFormatter()],
                onChanged: _onUangChanged,
                decoration: inputDecoration(
                  label: 'Uang Dibayar Customer',
                  icon: Icons.payments_outlined,
                  suffix: _uangController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _uangController.clear();
                            setState(() {
                              _uangDibayar = 0;
                            });
                          },
                          icon: const Icon(Icons.close, size: 16),
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: sudahCukup
                      ? Colors.blue.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sudahCukup ? 'Kembalian' : 'Kurang Bayar',
                      style: TextStyle(
                        fontSize: 12,
                        color: sudahCukup
                            ? AppColors.secondary
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatRupiah(
                        sudahCukup
                            ? _kembalian
                            : (_total - _uangDibayar).clamp(0, double.infinity),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: sudahCukup
                            ? AppColors.secondary
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _uangController.clear();
                    setState(() => _uangDibayar = 0);
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reset'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
