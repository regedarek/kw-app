module Business
  class ListRecord < ActiveRecord::Base
    self.table_name = 'business_lists'

    has_paper_trail

    belongs_to :sign_up, class_name: '::Business::SignUpRecord', foreign_key: :sign_up_id

    validates :description, :sign_up_id, presence: true
    validates :sign_up_id, uniqueness: { message: 'zostało już przez Ciebie wysłane' }
  end
end
