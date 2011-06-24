require 'digest/sha1'
require 'openssl'

class String

  def ^(other)
    raise ArgumentError, "Can't bitwise-XOR a String with a non-String" \
      unless other.kind_of? String
    raise ArgumentError, "Can't bitwise-XOR strings of different length" \
      unless self.length == other.length
    result = (0..self.length-1).collect { |i| self[i].ord ^ other[i].ord }
    result.pack("C*")
  end
end

class PaiementCic
  @@version = "3.0" # clé extraite grâce à extract2HmacSha1.html fourni par le Crédit Mutuel
  cattr_accessor :version

  @@hmac_key = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" # clé extraite grâce à extract2HmacSha1.html fourni par le Crédit Mutuel
  cattr_accessor :hmac_key
  
  @@target_url = "https://paiement.creditmutuel.fr/test/paiement.cgi" # "https://ssl.paiement.cic-banques.fr/paiement.cgi"
  cattr_accessor :target_url
  
  @@tpe = "123456"
  cattr_accessor :tpe
  
  @@societe = "masociete"
  cattr_accessor :societe
  
  @@url_ok = ""
  cattr_accessor :url_ok

  def self.date_format
    "%d/%m/%Y:%H:%M:%S"
  end

  def self.config(amount_in_cents, reference)
    oa = ActiveSupport::OrderedHash.new
    oa["version"]     = "3.0"
    oa["TPE"]         = tpe
    oa["date"]        = Time.now.strftime(date_format)
    oa["montant"]     =  ("%.2f" % amount_in_cents) + "EUR"
    oa["reference"]   = reference
    oa["texte-libre"] = ""
    oa["lgue"]      = "FR"
    oa["societe"]     = societe
    oa["mail"]        = ""
    oa
  end

  def self.mac_string params
    hmac_key = PaiementCic.new
    mac_string = [hmac_key.tpe, params["date"], params['montant'], params['reference'], params['texte-libre'], hmac_key.version, params['code-retour'], params['cvx'], params['vld'], params['brand'], params['status3ds'], params['numauto'], params['motifrefus'], params['originecb'], params['bincb'], params['hpancb'], params['ipclient'], params['originetr'], params['veres'], params['pares']].join('*') + "*"
  end

  def self.verify_hmac params
    hmac_key = PaiementCic.new
    mac_string = [hmac_key.tpe, params["date"], params['montant'], params['reference'], params['texte-libre'], hmac_key.version, params['code-retour'], params['cvx'], params['vld'], params['brand'], params['status3ds'], params['numauto'], params['motifrefus'], params['originecb'], params['bincb'], params['hpancb'], params['ipclient'], params['originetr'], params['veres'], params['pares']].join('*') + "*"

    hmac_key.valid_hmac?(mac_string, params['MAC'])
  end
	
  # Check if the HMAC matches the HMAC of the data string
	def valid_hmac?(mac_string, sent_mac)
		computeHMACSHA1(mac_string) == sent_mac.downcase
	end
	
  # Return the HMAC for a data string
	def computeHMACSHA1(data)
		hmac_sha1(usable_key(self), data).downcase
	end
  
  def hmac_sha1(key, data)
		length = 64

		if (key.length > length) 
			key = [Digest::SHA1.hexdigest(key)].pack("H*")
		end

		key  = key.ljust(length, 0.chr)
		ipad = ''.ljust(length, 54.chr)
		opad = ''.ljust(length, 92.chr)

		k_ipad = key ^ ipad
		k_opad = key ^ opad

		#Digest::SHA1.hexdigest(k_opad + [Digest::SHA1.hexdigest(k_ipad + sData)].pack("H*"))
	  OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new("sha1"), key, data)
	end

  private
	# Return the key to be used in the hmac function
	def usable_key(payement)

		hex_string_key  = payement.hmac_key[0..37]
		hex_final   = payement.hmac_key[38..40] + "00";

		cca0 = hex_final[0].ord

		if cca0 > 70 && cca0 < 97
			hex_string_key += (cca0 - 23).chr + hex_final[1..2]
		elsif hex_final[1..2] == "M" 
			hex_string_key += hex_final[0..1] + "0" 
		else 
			hex_string_key += hex_final[0..2]
		end

		[hex_string_key].pack("H*")
	end
end
