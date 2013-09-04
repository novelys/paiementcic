#encoding: utf-8
require 'digest/sha1'
require 'openssl'
require 'paiement_settings'
require "view_helpers/form_helpers"

ActionView::Base.send :include, FormHelpers

class PaiementCic < PaiementSettings

  cattr_accessor :target_url, :version, :hmac_key, :tpe, :societe, :url_retour, :url_retour_ok, :url_retour_err, :societe
  attr_accessor :date, :montant, :reference, :texte_libre, :lgue, :mail

  @@tpe            = ""
  @@version        = ""
  @@societe        = ""
  @@hmac_key       = ""
  @@target_url     = ""
  @@url_retour     = ""
  @@url_retour_ok  = ""
  @@url_retour_err = ""

  def initialize

    settings = self.load_settings

    @@tpe            = settings[:tpe]
    @@version        = settings[:version]
    @@societe        = settings[:societe]
    @@hmac_key       = settings[:hmac_key]
    @@target_url     = settings[:target_url]
    @@url_retour     = settings[:url_retour]
    @@url_retour_ok  = settings[:url_retour_ok]
    @@url_retour_err = settings[:url_retour_err]

  end

  def request(payment)

    params = self.load_params(payment)

    @date        = Time.now.strftime(self.date_format)
    @montant     = params[:montant]
    @reference   = params[:reference]

    @texte_libre = params[:text_libre]
    @lgue        = params[:lgue]
    @mail        = params[:mail]

    return self
  end

  def response(params)

    if verify_hmac(params)

      if params['code-retour'] == "Annulation"
        params.update(:success => false)

      elsif params['code-retour'] == "payetest"
        params.update(:success => true)

      elsif params['code-retour'] == "paiement"
        params.update(:success => true)
      end

    else
      params.update(:success => false)
    end

  end

  def self.mac_string params
    hmac_key = PaiementCic.new
    mac_string = [hmac_key.tpe, params['date'], params['montant'], params['reference'], params['texte-libre'], hmac_key.version, params['code-retour'], params['cvx'], params['vld'], params['brand'], params['status3ds'], params['numauto'], params['motifrefus'], params['originecb'], params['bincb'], params['hpancb'], params['ipclient'], params['originetr'], params['veres'], params['pares']].join('*') + "*"
  end

  def verify_hmac params
    mac_string = [self.tpe, params['date'], params['montant'], params['reference'], params['texte-libre'], self.version, params['code-retour'], params['cvx'], params['vld'], params['brand'], params['status3ds'], params['numauto'], params['motifrefus'], params['originecb'], params['bincb'], params['hpancb'], params['ipclient'], params['originetr'], params['veres'], params['pares']].join('*') + "*"

    params['MAC'] ? hmac = params['MAC'] : hmac = ""
    self.valid_hmac?(hmac)
  end

  # Check if the HMAC matches the HMAC of the data string
	def valid_hmac?(sent_mac)
		hmac_token == sent_mac.downcase
	end

  # Return the HMAC for a data string
	def hmac_token

    chaine = [self.tpe,
        self.date,
        self.montant,
        self.reference,
        self.texte_libre,
        self.version,
        self.lgue,
        self.societe,
        "", "", "", "", "", "", "", "", "", "", ""
    ].join("*")


		hmac_sha1(usable_key(self.hmac_key), chaine).downcase
	end

protected
  def date_format
    "%d/%m/%Y:%H:%M:%S"
  end

  def hmac_sha1(key, data)
    length = 64

    if (key.length > length)
      key = [Digest::SHA1.hexdigest(key)].pack("H*")
    end

    key  = key.ljust(length, 0.chr)
    ipad = ''.ljust(length, 54.chr)
    opad = ''.ljust(length, 92.chr)

    k_ipad = compute(key, ipad)
    k_opad = compute(key, opad)

    OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new("sha1"), key, data)
  end

private
	# Return the key to be used in the hmac method
	def usable_key(hmac_key)

		hex_string_key  = hmac_key[0..37]
		hex_final   = hmac_key[38..40] + "00";

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

  def compute(key, pad)
    raise ArgumentError, "Can't bitwise-XOR a String with a non-String" \
      unless pad.kind_of? String
    raise ArgumentError, "Can't bitwise-XOR strings of different length" \
      unless key.length == pad.length

    result = (0..key.length-1).collect { |i| key[i].ord ^ pad[i].ord }
    result.pack("C*")
  end
end
