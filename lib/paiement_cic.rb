require 'digest/sha1'
require 'openssl'

class String

  def ^(other)
    raise ArgumentError, "Can't bitwise-XOR a String with a non-String" \
      unless other.kind_of? String
    raise ArgumentError, "Can't bitwise-XOR strings of different length" \
      unless self.length == other.length
    result = (0..self.length-1).collect { |i| self[i] ^ other[i] }
    result.pack("C*")
  end
end

class PaiementCic
  @@hmac_key = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" # clé extraite grâce à extract2HmacSha1.html fourni par le Crédit Mutuel
  cattr_accessor :hmac_key
  
  @@target_url = "https://ssl.paiement.cic-banques.fr/test/paiement.cgi" # "https://ssl.paiement.cic-banques.fr/paiement.cgi"
  cattr_accessor :target_url
  
  @@tpe = "123456"
  cattr_accessor :tpe
  
  @@societe = "masociete"
  cattr_accessor :societe
  
  def self.date_format
    "%d/%m/%Y:%H:%M:%S"
  end

  def self.config(amount_in_cents, reference)
    oa = ActiveSupport::OrderedHash.new
    oa["TPE"]         = tpe
    oa["date"]        = Time.now.strftime(date_format)
    oa["montant"]     =  ("%.2f" % (amount_in_cents/100.0)) + "EUR"
    oa["reference"]   = reference
    oa["texte-libre"] = ""
    oa["version"]     = "1.2open"
    oa["lgue"]      = "FR"
    oa["societe"]     = societe
    oa
  end

  def self.calculate_hmac(ordered_hash)
    data = ordered_hash.values.join("*") + "*"
    hmac(data)
  end
  
  def self.verify_hmac params
    tpe = params[:TPE]
    date = params[:date]
    montant = params[:montant]
    reference = params[:reference]
    mac = params[:MAC].downcase
    texte_libre = params['texte-libre']
    code_retour = params['code-retour']
    retour_plus = params['retourPLUS']
    version = "1.2open"

    data = retour_plus + [tpe, date, montant, reference, texte_libre, version, code_retour].join("+") + "+"

    mac == hmac(data)
  end
  
  def self.hmac(data)
    pass = "";
    k1 = [Digest::SHA1.hexdigest(pass)].pack("H*");
    l1 = k1.length

    k2 = [hmac_key].pack("H*")
    l2 = k2.length
    if (l1 > l2)
      k2 = k2.ljust(l1, 0.chr)
    elsif (l2 > l1)
      k1 = k1.ljust(l2, 0.chr)
    end
    xor_res = k1 ^ k2
    hmac_sha1(xor_res, data).downcase
  end

  def self.hmac_sha1(key, data)
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new("sha1"), key, data)
  end
end