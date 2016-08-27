module Payments
  class Fee
    include ActiveModel::Model
    include ActiveModel::Validations

    CLIENT_ID = '447543'
    URLC = 'http://kw-krakow.herokuapp.com/api/payments/status'
    DEFAULT_BACK_URL = 'http://kw-krakow.herokuapp.com'

    attr_accessor :email, :url, :urlc, :control, :amount, :currency, :description, :url
    validates :email, :amount, :description, presence: true

    def to_h
      {
        client_id: CLIENT_ID,
        amount: amount,
        currency: currency || 'PLN',
        description: description,
        channel_groups: 'K,P',
        url: url || DEFAULT_BACK_URL,
        urlc: URLC,
        control: control || '',
        email: email
      }
    end
  end
end
