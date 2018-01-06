module Events
  class Form
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :name, :place, :event_date, :manager_kw_id, :participants, :application_list_url,
                  :price_for_members, :price_for_non_members, :application_date, :payment_date,
                  :account_number, :event_rules_url, :google_group_discussion_url, :description

    validates :name, :place, :event_date, presence: true 

    def self.model_name
      ActiveModel::Name.new(self, nil, "Event")
    end

    def persisted?
      false
    end

    def params
      parsed_event_date = event_date.present? ? Chronic.parse(event_date).in_time_zone('Warsaw') : nil
      parsed_payment_date = payment_date.present? ? Chronic.parse(payment_date).in_time_zone('Warsaw') : nil
      parsed_application_date = application_date.present? ? Chronic.parse(application_date).in_time_zone('Warsaw') : nil
      HashWithIndifferentAccess.new(
        name: name, place: place, event_date: parsed_event_date, participants: participants,
        application_list_url: application_list_url, price_for_members: price_for_members, price_for_non_members: price_for_non_members,
        application_date: parsed_application_date, payment_date: parsed_payment_date,
        account_number: account_number, event_rules_url: event_rules_url,
        google_group_discussion_url: google_group_discussion_url, description: description
      )
    end
  end
end
