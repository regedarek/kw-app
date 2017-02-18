module UserManagement
  class RegisterUser
    class << self
      def register(form:)
        return Failure.new(:invalid, form: form) if !form.valid?

        generated_password = Devise.friendly_token.first(4)
        user = Db::User.new(
          kw_id: form.kw_id,
          first_name: form.first_name,
          last_name: form.last_name,
          email: form.email,
          phone: form.phone,
          password: generated_password
        )
        profile = Db::Profile.new(
          kw_id: form.kw_id,
          pesel: form.pesel,
          birth_date: form.birth_date,
          birth_place: form.birth_place,
          pesel: form.pesel,
          city: form.city,
          postal_code: form.postal_code,
          main_address: form.main_address,
          optional_address: form.optional_address,
          recommended_by: form.recommended_by,
          acomplished_courses: form.acomplished_courses,
          main_discussion_group: form.main_discussion_group,
          sections: form.sections
        )

        if user.save && profile.save
          RegistrationMailer.welcome(user, generated_password).deliver_later
        else
          form.errors.messages.merge!(user.errors.messages)
          form.errors.messages.merge!(profile.errors.messages)
          return Failure.new(:invalid, form: form)
        end

        return Success.new
      end
    end
  end
end
