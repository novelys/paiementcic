# Paiement CIC

Paiement CIC is a plugin to ease credit card payment with the CIC / Crédit Mutuel banks system version 3.0.
It's a Ruby on Rails port of the connexion kits published by the bank.

* The Plugin [site](http://github.com/novelys/cicpayment)
* The banks payment [site](http://www.cmcicpaiement.fr)


## INSTALL

    script/plugin install git://github.com/novelys/paiementcic.git

or, in your Gemfile

    gem 'paiement_cic', :git => 'git://github.com/novelys/paiementcic.git', :branch => 'gem'

## USAGE

### in environment.rb :

    # here the hmac key calculated with the js calculator given by CIC
    PaiementCic.hmac_key = "########################################"
    # Here the TPE number
    PaiementCic.tpe = "#######"
    # Here the Merchant name
    PaiementCic.societe = "xxxxxxxxxxxxx"

### in development.rb :

    PaiementCic.target_url = "https://ssl.paiement.cic-banques.fr/test/paiement.cgi" # or https://paiement.creditmutuel.fr/test/paiement.cgi

### in production.rb :

    PaiementCic.target_url = "https://ssl.paiement.cic-banques.fr/paiement.cgi" # or https://paiement.creditmutuel.fr/paiement.cgi

### in order controller :

    helper :'paiement_cic/form'

### in the payment by card view :

    - form_tag PaiementCic.target_url do
      = paiement_cic_hidden_fields(@order, @order_transaction, :url_retour => edit_order_url(order), :url_retour_ok => bank_ok_order_transaction_url(order_transaction), :url_retour_err => bank_err_order_transaction_url(order_transaction))
      = submit_tag "Accéder au site de la banque", :style => "font-weight: bold;"
      = image_tag "reassuring_pictograms.jpg", :alt => "Pictogrammes rassurants", :style => "width: 157px;"

### in a controller for call back from the bank :

    class OrderTransactionsController < ApplicationController

      protect_from_forgery :except => [:bank_callback]

      def bank_callback
        if PaiementCic.verify_hmac(params)
          order_transaction = OrderTransaction.find_by_reference params[:reference], :last
          order = order_transaction.order

          code_retour = params['code-retour']

          if code_retour == "Annulation"
            order.cancel!
            order.update_attribute :description, "Paiement refusé par la banque."

          elsif code_retour == "payetest"
            order.pay!
            order.update_attribute :description, "TEST accepté par la banque."
            order_transaction.update_attribute :test, true

          elsif code_retour == "paiement"
            order.pay!
            order.update_attribute :description, "Paiement accepté par la banque."
            order_transaction.update_attribute :test, false
          end

          order_transaction.update_attribute :success, true
      
          receipt = "0"
        else
          order.transaction_declined!
          order.update_attribute :description, "Document Falsifie."
          order_transaction.update_attribute :success, false

          receipt = "1\n#{PaiementCic.mac_string}"
        end
        render :text => "Pragma: no-cache\nContent-type: text/plain\n\nversion=2\ncdr=#{receipt}"
      end

      def bank_ok
        @order_transaction = OrderTransaction.find params[:id]
        @order = @order_transaction.order
        @order.pay!
      end

      def bank_err
        order_transaction = OrderTransaction.find params[:id]
        order = order_transaction.order
        order.cancel!
      end
    end



## License
Copyright (c) 2008-2009 Novelys Team, released under the MIT license
