module UserManagement
  class Reactivate
    class << self
      def create(form:)
        return Failure.new(:invalid, form: form) if form.invalid?

        profile = Db::Profile.first_or_initialize(email: form.email).update(
          first_name: form.first_name,
          last_name: form.last_name,
          email: form.email,
          phone: form.phone,
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
          sections: form.sections,
          position: ['candidate'],
          cost: UserManagement::ApplicationCost.for(profile: form).sum
        )
        return Success.new
      end
    end
  end
end
