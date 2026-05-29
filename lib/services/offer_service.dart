import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/offer_model.dart';

class OfferService {
  final _supabase = Supabase.instance.client;

  Future<List<OfferModel>> getOffers() async {
    final response = await _supabase
        .from('offers')
        .select(
          'offer_id, pro_id, offer_price, offer_description, created_at, '
          'products(pro_name, pro_price, pro_image)',
        )
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((item) => OfferModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> addOffer({
    required String productId,
    required int offerPrice,
    required String description,
  }) async {
    await _supabase.from('offers').insert({
      'pro_id': productId,
      'offer_price': offerPrice,
      'offer_description': description,
    });
  }

  Future<void> updateOffer({
    required String offerId,
    required String productId,
    required int offerPrice,
    required String description,
  }) async {
    final response = await _supabase
        .from('offers')
        .update({
          'pro_id': productId,
          'offer_price': offerPrice,
          'offer_description': description,
        })
        .eq('offer_id', offerId)
        .select('offer_id');

    if ((response as List<dynamic>).isEmpty) {
      throw Exception("Offer was not updated. Check offer id or policy.");
    }
  }

  Future<void> deleteOffer(String offerId) async {
    final response = await _supabase
        .from('offers')
        .delete()
        .eq('offer_id', offerId)
        .select('offer_id');

    if ((response as List<dynamic>).isEmpty) {
      throw Exception("Offer was not deleted. Check offer id or policy.");
    }
  }
}
