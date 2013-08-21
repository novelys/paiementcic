module FormHelpers

  def paiement_cic_form(payment, options = {})

    options[:button_text] ||= 'Payer'
    options[:button_class] ||= ''

    html = "<form name='paiementcic' action='#{payment.target_url}' method='post'>\n"

    html << "  <input type='hidden' name='version'           id='version'        value='#{payment.version}' />\n"
    html << "  <input type='hidden' name='TPE'               id='TPE'            value='#{payment.tpe}' />\n"
    html << "  <input type='hidden' name='date'              id='date'           value='#{payment.date}' />\n"
    html << "  <input type='hidden' name='montant'           id='montant'        value='#{payment.montant}' />\n"
    html << "  <input type='hidden' name='reference'         id='reference'      value='#{payment.reference}' />\n"
    html << "  <input type='hidden' name='MAC'               id='MAC'            value='#{payment.hmac_token}' />\n"
    html << "  <input type='hidden' name='url_retour'        id='url_retour'     value='#{payment.url_retour}' />\n"
    html << "  <input type='hidden' name='url_retour_ok'     id='url_retour_ok'  value='#{payment.url_retour_ok}' />\n"
    html << "  <input type='hidden' name='url_retour_err'    id='url_retour_err' value='#{payment.url_retour_err}' />\n"
    html << "  <input type='hidden' name='lgue'              id='lgue'           value='#{payment.lgue}' />\n"
    html << "  <input type='hidden' name='societe'           id='societe'        value='#{payment.societe}' />\n"
    html << "  <input type='hidden' name='texte-libre'       id='texte-libre'    value='#{payment.texte_libre}' />\n"
    html << "  <input type='hidden' name='mail'              id='mail'           value='#{payment.mail}' />\n"

    html << "  <input type='submit' name='submit_paiementcic' value='#{options[:button_text]}' class='#{options[:button_class]}' />\n"
    html << "</form>\n"

    html.respond_to?(:html_safe) ? html.html_safe : html

  end

end
