import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/delivery_model.dart';

class DeliveryState {
  final DeliveryModel delivery;

  const DeliveryState({this.delivery = const DeliveryModel()});

  DeliveryState copyWith({DeliveryModel? delivery}) {
    return DeliveryState(delivery: delivery ?? this.delivery);
  }
}

class DeliveryNotifier extends StateNotifier<DeliveryState> {
  DeliveryNotifier() : super(const DeliveryState());

  void updateType(String type) {
    state = state.copyWith(
      delivery: state.delivery.copyWith(
        deliveryType: type,
        shippingCost: type == "pickup" ? 0 : state.delivery.shippingCost,
      ),
    );
  }

  void updateShipping(double value) {
    if (value < 0) value = 0;

    state = state.copyWith(
      delivery: state.delivery.copyWith(shippingCost: value),
    );
  }

  void updateNotes(String notes) {
    state = state.copyWith(delivery: state.delivery.copyWith(notes: notes));
  }

  void clear() {
    state = const DeliveryState();
  }
}

final deliveryProvider = StateNotifierProvider<DeliveryNotifier, DeliveryState>(
  (ref) => DeliveryNotifier(),
);
