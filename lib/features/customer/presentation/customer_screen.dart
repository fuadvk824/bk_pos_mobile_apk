import 'package:bk_pos/features/customer/provider/customer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomerScreen extends ConsumerStatefulWidget {
  const CustomerScreen({super.key});

  @override
  ConsumerState<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends ConsumerState<CustomerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.extentAfter < 300) {
        ref.read(customerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerProvider);
    final notifier = ref.read(customerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Customer",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Cari nama atau nomor HP",
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            notifier.refresh();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  notifier.search(value);
                  setState(() {});
                },
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: notifier.refresh,
                child: state.isLoading && state.customers.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : state.customers.isEmpty
                    ? const Center(
                        child: Text(
                          "Customer tidak ditemukan",
                          style: TextStyle(fontSize: 15),
                        ),
                      )
                    : ListView.separated(
                        controller: _scrollController,

                        physics: const AlwaysScrollableScrollPhysics(),

                        padding: const EdgeInsets.only(
                          left: 12,
                          right: 12,
                          top: 0,
                          bottom: 12,
                        ),

                        itemCount:
                            state.customers.length +
                            (state.isLoadingMore ? 1 : 0),

                        separatorBuilder: (_, _) => const SizedBox(height: 6),

                        itemBuilder: (context, index) {
                          // Loading indicator di bagian bawah
                          if (index >= state.customers.length) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final customer = state.customers[index];

                          return Card(
                            elevation: 1,
                            margin: EdgeInsets.zero,
                            color: Colors.white,
                            shadowColor: Colors.black12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 21,
                                      backgroundColor: Colors.blue.shade50,
                                      child: Text(
                                        customer.name.isNotEmpty
                                            ? customer.name[0].toUpperCase()
                                            : "?",
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            customer.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),

                                          const SizedBox(height: 5),

                                          Row(
                                            children: [
                                              Icon(
                                                Icons.phone_android,
                                                size: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  customer.phone.isEmpty
                                                      ? "-"
                                                      : customer.phone,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 3),

                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.location_on_outlined,
                                                size: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  customer.address.isEmpty
                                                      ? "-"
                                                      : customer.address,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.stars_rounded,
                                            size: 16,
                                            color: Colors.orange.shade700,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            customer.currentPoint.toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.orange.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
