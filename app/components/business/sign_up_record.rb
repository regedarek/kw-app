module Business
  class SignUpRecord < ActiveRecord::Base
    acts_as_messageable
    include Workflow
    self.table_name = 'business_sign_ups'

    has_paper_trail

    before_create :set_code

    validates :rodo, acceptance: true
    validates :rules, acceptance: true
    validates :data, acceptance: true
    validates :name, :phone, :email, presence: true

    belongs_to :user, class_name: 'Db::User', foreign_key: :user_id
    belongs_to :course, class_name: 'Business::CourseRecord', foreign_key: :course_id
    belongs_to :package_type, class_name: 'Business::PackageTypeRecord', foreign_key: :business_course_package_type_id

    has_one :list, class_name: 'Business::ListRecord', foreign_key: :sign_up_id, dependent: :destroy

    has_many :conversation_items, as: :messageable, class_name: '::Messaging::ConversationItemRecord', :dependent => :destroy
    has_many :conversations, :through => :conversation_items, :dependent => :destroy

    has_many :emails, as: :mailable, class_name: 'EmailCenter::EmailRecord', dependent: :destroy
    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'
    has_many :payments, as: :payable, dependent: :destroy, class_name: 'Db::Payment'

    def mailboxer_email(object)
      #Check if an email should be sent for that object
      #if true
      return email
      #if false
      #return nil
    end

    def display_name
      return name
    end

    def payment_type
      course.payment_type
    end

    def init_conversation(recipients, msg_body, subject, sanitize_text=true, attachment=nil, message_timestamp = Time.now)
      convo = Mailboxer::ConversationBuilder.new({
        :subject    => subject,
        :created_at => message_timestamp,
        :updated_at => message_timestamp
      }).build

      message = Mailboxer::MessageBuilder.new({
        :sender       => self,
        :conversation => convo,
        :recipients   => recipients,
        :body         => msg_body,
        :subject      => subject,
        :attachment   => attachment,
        :created_at   => message_timestamp,
        :updated_at   => message_timestamp
      }).build

      conversations << convo
    end

    def first_payment
      payments.order(created_at: :asc).first
    end

    def second_payment
      return nil unless payments.count > 1

      payments.order(created_at: :asc).last
    end

    def start_date
      return Time.current unless course && course.start_date
      return Time.current unless course.start_date

      course.start_date
    end

    workflow_column :state
    workflow do
      state :new do
        event :accept, transitions_to: :accepted
      end
      state :accepted
    end

    def description
      "Kurs Szkoły Alpinizmu: #{course.name} - #{course.start_date} - Opłata od #{name}"
    end

    private

    def set_code
      self.code = loop do
        random_token = SecureRandom.hex(8)
        break random_token unless ::Business::SignUpRecord.exists?(code: random_token)
      end
    end
  end
end
