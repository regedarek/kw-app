module UserManagement
  class UserApplication
    class << self
      def create(form:, photo:, course_cert:)
        return Failure.new(:invalid, form: form) if form.invalid?

        profile = Db::Profile.create(
          first_name: form.first_name,
          last_name: form.last_name,
          email: form.email,
          locale: form.locale,
          phone: form.phone,
          gender: form.gender,
          birth_date: form.birth_date,
          birth_place: form.birth_place,
          city: form.city,
          postal_code: form.postal_code,
          main_address: form.main_address,
          optional_address: form.optional_address,
          recommended_by: form.recommended_by,
          acomplished_courses: form.acomplished_courses,
          main_discussion_group: form.main_discussion_group,
          sections: form.sections,
          position: ['candidate'],
          cost: UserManagement::ApplicationCost.for(profile: form).sum,
          plastic: form.plastic
        )
        profile.update(photo: photo) if photo
        profile.update(course_cert: course_cert) if course_cert
        profile.create_payment(dotpay_id: SecureRandom.hex(13))
        if profile.acomplished_courses.include?('list')
          ProfileMailer.list(profile).deliver_later
        end
        return Success.new
      end
    end
  end
end
