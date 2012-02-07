## refactor this
module PaiementCicHelper
  def paiement_cic_hidden_fields(price, order_reference, options = {})
    oa = PaiementCic.config(price, order_reference)

    oMac = PaiementCic.new
    sDate = Time.now.strftime("%d/%m/%Y:%H:%M:%S")
    chaine = [oMac.tpe, sDate, oa["montant"], oa["reference"].to_s, oa["texte-libre"], oMac.version, "FR", oMac.societe, "", "", "", "", "", "", "", "", "", "", ""].join("*")
    chaineMAC = oMac.computeHMACSHA1(chaine)
    
    html = '
        <input type="hidden" name="version"           id="version"        value="' + oa["version"] + '" />
        <input type="hidden" name="TPE"               id="TPE"            value="' + oa["TPE"] + '" />
        <input type="hidden" name="date"              id="date"           value="' + oa["date"] + '" />
        <input type="hidden" name="montant"           id="montant"        value="' + oa["montant"] + '" />
        <input type="hidden" name="reference"         id="reference"      value="' + oa["reference"].to_s + '" />
        <input type="hidden" name="MAC"               id="MAC"            value="' + chaineMAC + '" />
        <input type="hidden" name="url_retour"        id="url_retour"     value="' + options[:url_retour] + '" />
        <input type="hidden" name="url_retour_ok"     id="url_retour_ok"  value="' + options[:url_retour_ok] + '" />
        <input type="hidden" name="url_retour_err"    id="url_retour_err" value="' + options[:url_retour_err] + '" />
        <input type="hidden" name="lgue"              id="lgue"           value="' + oa["lgue"] + '" />
        <input type="hidden" name="societe"           id="societe"        value="' + oa["societe"] + '" />
        <input type="hidden" name="texte-libre"       id="texte-libre"    value="' + oa["texte-libre"] + '" />
        <input type="hidden" name="mail"              id="mail"	          value="''" />'

    html.respond_to?(:html_safe) ? html.html_safe : html
  end
end
