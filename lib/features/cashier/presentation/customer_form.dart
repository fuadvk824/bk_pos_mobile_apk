import 'package:bk_pos/features/cashier/provider/customer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    searchController = TextEditingController();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    pointController = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();

    searchController.dispose();
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    pointController.dispose();

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerProvider);

    final notifier = ref.read(customerProvider.notifier);

    /// sync controller ketika customer dipilih
    nameController.text = state.customer.name;
    phoneController.text = state.customer.phone;
    addressController.text = state.customer.address;

    pointController.text = state.pointsUsed == 0
        ? ""
        : state.pointsUsed.toString();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// SEARCH
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Cari Nama / No HP",
                prefixIcon: const Icon(Icons.search),

                suffixIcon: state.loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          notifier.hideCustomerResult();
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),

            /// RESULT
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

                    return ListTile(
                      dense: true,
                      title: Text(customer.name),
                      subtitle: Text(customer.phone),
                      trailing: Text(
                        "P ${customer.currentPoint}",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        notifier.selectCustomer(customer);

                        searchController.text = customer.name;
                      },
                    );
                  },
                ),
              ),

            if (state.showResult &&
                !state.loading &&
                state.customers.isEmpty)
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

            const SizedBox(height: 16),

            /// NAMA
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nama Customer"),
              onChanged: (v) {
                notifier.updateCustomer(name: v);
              },
            ),

            const SizedBox(height: 12),

            /// HP
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "No HP"),
              onChanged: (v) {
                notifier.updateCustomer(phone: v);
              },
            ),

            const SizedBox(height: 12),

            /// ALAMAT
            TextField(
              controller: addressController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Alamat"),
              onChanged: (v) {
                notifier.updateCustomer(address: v);
              },
            ),

            const SizedBox(height: 12),

            /// POINT
            TextField(
              controller: pointController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText:
                    "Gunakan Point (Tersedia ${state.customer.currentPoint})",
              ),
              onChanged: (v) {
                notifier.updatePointsUsed(int.tryParse(v) ?? 0);
              },
            ),
          ],
        ),
      ),
    );
  }
}
 