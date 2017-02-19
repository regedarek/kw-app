task :reset_passwords => :environment do
  Db::User.find_each do |user|
    user.send_reset_password_instructions
  end
end
