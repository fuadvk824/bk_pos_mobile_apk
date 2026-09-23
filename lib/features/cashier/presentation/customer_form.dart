import 'package:bk_pos/features/cashier/presentation/input_decoration.dart';
import 'package:bk_pos/features/cashier/presentation/widgets/wilayah_search_field.dart';
import 'package:bk_pos/features/cashier/provider/customer_provider.dart';
import 'package:bk_pos/features/cashier/provider/wilayah_provider.dart';
import 'package:bk_pos/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class CustomerForm extends ConsumerStatefulWidget {
  const CustomerForm({super.key});

  @override
  ConsumerState<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends ConsumerState<CustomerForm> {
  late final TextEditingController searchController;
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;
  late final TextEditingController pointController;

  late final TextEditingController wilayahController;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    searchController = TextEditingController();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    pointController = TextEditingController();

    wilayahController = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();

    searchController.dispose();
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    pointController.dispose();

    wilayahController.dispose();

    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    if (value.trim().length < 2) {
      ref.read(customerProvider.notifier).hideCustomerResult();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(customerProvider.notifier).searchCustomer(value);
    });
  }

  void _searchWilayah(String value) {
    ref.read(wilayahProvider.notifier).search(value);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerProvider);
    final notifier = ref.read(customerProvider.notifier);

    final wilayahState = ref.watch(wilayahProvider);
    final wilayahNotifier = ref.read(wilayahProvider.notifier);

    nameController.text = state.customer.name;
    phoneController.text = state.customer.phone;
    addressController.text = state.customer.address;

    pointController.text = state.pointsUsed == 0
        ? ""
        : state.pointsUsed.toString();

    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.light,
      surfaceTintColor: AppColors.light,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Data Customer",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Cari nama atau nomor HP...",
                hintStyle: TextStyle(color: Colors.grey.shade500),

                prefixIcon: Icon(
                  LucideIcons.search,
                  size: 20,
                  color: Colors.grey.shade600,
                ),

                suffixIcon: state.loading
                    ? Padding(
                        padding: const EdgeInsets.all(14),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          searchController.clear();
                          notifier.hideCustomerResult();
                          setState(() {});
                        },
                      )
                    : null,

                filled: true,
                fillColor: Colors.grey.shade50,

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.dark),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.dark),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                ),
              ),
              onChanged: (v) {
                setState(() {});
                _onSearchChanged(v);
              },
            ),

            if (state.showResult && state.customers.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                constraints: const BoxConstraints(maxHeight: 220),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: state.customers.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),

                  itemBuilder: (context, index) {
                    final customer = state.customers[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        notifier.selectCustomer(customer);
                        searchController.text = customer.name;
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    customer.phone,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    customer.address,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${customer.currentPoint}",
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            if (state.showResult && !state.loading && state.customers.isEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Text(
                  "Customer tidak ditemukan.\nSilakan isi data customer baru.",
                ),
              ),

            const SizedBox(height: 5),

            TextField(
              controller: nameController,
              decoration: inputDecoration(
                label: "Nama Customer",
                icon: LucideIcons.user,
              ),
              onChanged: (v) {
                ref.read(customerProvider.notifier).updateCustomer(name: v);
              },
            ),

            const SizedBox(height: 5),

            TextField(
              controller: phoneController,
              decoration: inputDecoration(
                label: "No HP (opsional)",
                icon: LucideIcons.phone,
              ),
              onChanged: (v) {
                ref.read(customerProvider.notifier).updateCustomer(phone: v);
              },
            ),

            const SizedBox(height: 12),

            WilayahSearchField(
              controller: wilayahController,
              hierarchyLabel: wilayahState.hierarchyLabel,
              searchHint: wilayahState.searchHint,
              enabled: wilayahState.canSearch,
              loading: wilayahState.loading,
              results: wilayahState.results,
              onChanged: _searchWilayah,

              onSelected: (item) {
                wilayahNotifier.select(item);
                wilayahController.clear();
                setState(() {});
              },

              onClear: () {
                wilayahController.clear();
                wilayahNotifier.clear();
                setState(() {});
              },

              onUndo: () {
                wilayahController.clear();
                wilayahNotifier.clearLast();
                setState(() {});
              },

              onReset: () {
                wilayahController.clear();
                wilayahNotifier.clear();
                setState(() {});
              },
            ),

            const SizedBox(height: 5),

            TextField(
              controller: addressController,
              decoration: inputDecoration(
                label: "Alamat",
                icon: LucideIcons.mapPin,
              ),
              onChanged: (v) {
                ref.read(customerProvider.notifier).updateCustomer(address: v);
              },
            ),

            const SizedBox(height: 12),

            TextField(
              controller: pointController,
              keyboardType: TextInputType.number,
              decoration: inputDecoration(
                label: "Gunakan Point",
                icon: LucideIcons.star,
                suffix: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      "${state.customer.currentPoint}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              onChanged: (value) {
                ref
                    .read(customerProvider.notifier)
                    .updatePointsUsed(int.tryParse(value) ?? 0);
              },
            ),
          ],
        ),
      ),
    );
  }
}
