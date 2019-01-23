module Db
  class Profile < ActiveRecord::Base
    RECOMMENDED_BY = %w(google facebook friends festival poster course)
    POSITION = %w(candidate regular honorable_kw honorable_pza management senior instructor canceled stj)
    SECTIONS = %w(snw sww stj gtw kts)
    ACOMPLISHED_COURSES = %w(basic_kw basic basic_without_second second second_winter cave cave_kw ski list blank instructors other_club)

    has_one :payment, as: :payable, dependent: :destroy
    has_many :membership_fees, foreign_key: :kw_id, primary_key: :kw_id, class_name: 'Db::Membership::Fee'
    belongs_to :user, foreign_key: :kw_id, primary_key: :kw_id

    validates :email, uniqueness: true, allow_blank: true, allow_nil: true
    validates :kw_id, uniqueness: true, allow_blank: true, allow_nil: true
    validate :kw_id_accepted

    ransacker :recommended_by do
      Arel.sql("array_to_string(recommended_by, ',')")
    end
    ransacker :position do
      Arel.sql("array_to_string(position, ',')")
    end
    ransacker :sections do
      Arel.sql("array_to_string(sections, ',')")
    end
    ransacker :acomplished_courses do
      Arel.sql("array_to_string(acomplished_courses, ',')")
    end
    ransacker :full_name do |parent|
      Arel::Nodes::NamedFunction.new('CONCAT_WS', [
        Arel::Nodes.build_quoted(' '), parent.table[:first_name], parent.table[:last_name]
      ])
    end

    def kw_id_accepted
      if kw_id.present? && !accepted
        errors.add(:kw_id, "nie może być podany jeżeli nie zaakceptowano profilu")
      end
    end

    def display_name
      "#{first_name} #{last_name}"
    end

    def payment_type
      :fees
    end

    def description
      "Wpisowe oraz składka członkowska za rok #{::Membership::Activement.new.payment_year} od #{first_name} #{last_name}."
    end
  end
end
