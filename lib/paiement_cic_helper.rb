module PaiementCicHelper
  def paiement_cic_hidden_fields(order, order_transaction)
    oa = PaiementCic.config(order.amount, order_transaction.reference)

    hsh = oa.dup
    hsh["url_retour"]     = edit_account_order_url(order)
    hsh["url_retour_ok"]  = bank_ok_order_transaction_url(order_transaction)
    hsh["url_retour_err"] = bank_err_order_transaction_url(order_transaction)
    hsh["MAC"] = PaiementCic.calculate_hmac(oa)

    res = "\n"
    hsh.each{|key, value|
      res << hidden_field_tag(key, value) << "\n"
    }
    res
  end
end
