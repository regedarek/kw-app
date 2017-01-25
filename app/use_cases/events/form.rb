module Events
  class Form
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :name, :place, :event_date, :manager_kw_id, :participants, :application_list_url,
                  :price_for_members, :price_for_non_members, :application_date, :payment_date,
                  :account_number, :event_rules_url, :google_group_discussion_url

    validates :name, :place, :event_date, :application_list_url, :google_group_discussion_url, :application_date,
      presence: true 

    def self.model_name
      ActiveModel::Name.new(self, nil, "Event")
    end

    def persisted?
      false
    end

    def params
      HashWithIndifferentAccess.new(
        name: name, place: place, event_date: event_date, participants: participants,
        application_list_url: application_list_url, price_for_members: price_for_members, price_for_non_members: price_for_non_members,
        application_date: application_date, payment_date: payment_date, account_number: account_number, event_rules_url: event_rules_url,
        google_group_discussion_url: google_group_discussion_url
      )
    end
  end
end
