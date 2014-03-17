#encoding: utf-8

class PaiementSettings

  def initialize
    @settings = {}
  end

  def load_settings
    load_yaml_config
  end

  def load_params(payment)
    required_params(payment)
    optionnal_params(payment)
  end

private
  def optionnal_params(payment)
    @settings ||= {}
    @settings.update(:texte_libre => (payment[:text_libre] || ""))
    @settings.update(:lgue        => (payment[:lgue]        || "FR"))
    @settings.update(:mail        => (payment[:mail]       || ""))
  end

  def required_params(payment)

    @settings ||= {}

    if payment[:montant]
      @settings.update(:montant => ("%.2f" % payment[:montant]) + "EUR")
    else
      raise "PaiementCic error ! Missing required parameter :montant"
    end

    if payment[:reference]
      @settings.update(:reference => payment[:reference])
    else
      raise "PaiementCic error ! Missing required parameter :reference"
    end

  end

  def load_yaml_config
    @settings ||= {}
    begin
      config = YAML::load_file(File.join(Rails.root, 'config', 'paiement_cic.yml'))
    rescue
      raise "PaiementCic error ! Invalid or missing /config/paiement_cic.yml config file"
    end

    env = Rails.env

    settings = {
      :tpe            => config[env]['tpe'],
      :version        => config[env]['version'],
      :societe        => config[env]['societe'],
      :hmac_key       => config[env]['hmac_key'],
      :target_url     => config[env]['target_url'],
      :url_retour     => config[env]['url_retour'],
      :url_retour_ok  => config[env]['url_retour_ok'],
      :url_retour_err => config[env]['url_retour_err']
    }

    settings.each do |key, value|
      if value
        @settings.update(key => value)
      else
        raise "PaiementCic error ! Missing parameter :#{key} in /config/paiement_cic.yml config file"
      end
    end

  end

end
