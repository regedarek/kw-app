# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_04_10_212028) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: :cascade do |t|
    t.string "commentable_type", null: false
    t.integer "commentable_id", null: false
    t.integer "user_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "competition_package_types", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "competition_record_id", null: false
    t.integer "cost", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "membership", default: false, null: false
  end

  create_table "competitions", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "edition_sym", null: false
    t.boolean "single", default: false, null: false
    t.boolean "team_name", default: false, null: false
    t.string "baner"
    t.string "rules"
    t.boolean "closed", default: false, null: false
    t.integer "limit", default: 0, null: false
    t.text "email_text", null: false
    t.boolean "matrimonial_office", default: false, null: false
    t.string "tshirt_url"
    t.string "organizer_email", default: "kw@kw.krakow.pl", null: false
    t.datetime "event_date"
    t.text "alert"
  end

  create_table "competiton_photo_sets", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contract_users", force: :cascade do |t|
    t.integer "contract_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contracts", force: :cascade do |t|
    t.string "title"
    t.string "state", default: "new", null: false
    t.integer "creator_id", null: false
    t.text "description"
    t.float "cost"
    t.integer "acceptor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "attachments"
  end

  create_table "donations", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "cost"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "display_name"
    t.index ["user_id"], name: "index_donations_on_user_id"
  end

  create_table "edition_categories", id: :serial, force: :cascade do |t|
    t.integer "edition_record_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "mandatory_fields", default: [], array: true
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "place"
    t.datetime "event_date"
    t.integer "manager_kw_id"
    t.string "participants"
    t.string "application_list_url"
    t.integer "price_for_members"
    t.integer "price_for_non_members"
    t.date "application_date"
    t.date "payment_date"
    t.string "account_number"
    t.string "event_rules_url"
    t.string "google_group_discussion_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
  end

  create_table "events_sign_ups", id: :serial, force: :cascade do |t|
    t.text "remarks"
    t.integer "competition_record_id", null: false
    t.string "participant_name_1"
    t.string "participant_name_2"
    t.string "participant_email_1"
    t.string "participant_email_2"
    t.string "participant_birth_year_1"
    t.string "participant_birth_year_2"
    t.string "participant_city_1"
    t.string "participant_city_2"
    t.string "participant_team_1"
    t.string "participant_team_2"
    t.string "participant_gender_1"
    t.string "participant_gender_2"
    t.integer "competition_package_type_1_id", null: false
    t.integer "competition_package_type_2_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "single", default: false, null: false
    t.integer "participant_kw_id_1"
    t.integer "participant_kw_id_2"
    t.string "team_name"
    t.string "participant_phone_1"
    t.string "participant_phone_2"
    t.integer "teammate_id"
    t.string "tshirt_size_1"
    t.string "tshirt_size_2"
  end

  create_table "hearts", id: :serial, force: :cascade do |t|
    t.integer "mountain_route_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mountain_route_id"], name: "index_hearts_on_mountain_route_id"
    t.index ["user_id"], name: "index_hearts_on_user_id"
  end

  create_table "items", id: :serial, force: :cascade do |t|
    t.string "display_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.boolean "rentable", default: false
    t.integer "owner", default: 0
    t.integer "cost", default: 0
    t.integer "rentable_id"
  end

  create_table "membership_fees", id: :serial, force: :cascade do |t|
    t.string "year"
    t.integer "cost", default: 100, null: false
    t.integer "kw_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.boolean "plastic", default: false, null: false
    t.index ["kw_id"], name: "index_membership_fees_on_kw_id"
  end

  create_table "mountain_routes", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.text "description"
    t.string "difficulty"
    t.string "partners"
    t.integer "rating"
    t.date "climbing_date"
    t.string "peak"
    t.string "time"
    t.integer "route_type", default: 0
    t.string "area"
    t.integer "length"
    t.string "mountains"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hidden", default: false, null: false
    t.string "attachments"
    t.integer "hearts_count", default: 0
    t.boolean "training", default: false, null: false
    t.index ["climbing_date"], name: "index_mountain_routes_on_climbing_date"
    t.index ["created_at"], name: "index_mountain_routes_on_created_at"
    t.index ["name", "route_type", "rating", "length", "created_at", "climbing_date"], name: "index_mountain_routes_complex"
    t.index ["user_id"], name: "index_mountain_routes_on_user_id"
  end

  create_table "participants", id: :serial, force: :cascade do |t|
    t.string "full_name"
    t.string "email", null: false
    t.string "phone"
    t.string "prefered_time", default: [], array: true
    t.text "equipment", default: [], array: true
    t.string "height"
    t.text "recommended_by", default: [], array: true
    t.integer "kw_id"
    t.integer "course_id", null: false
    t.date "birth_date"
    t.string "birth_place"
    t.string "pre_cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payments", id: :serial, force: :cascade do |t|
    t.boolean "cash", default: false
    t.string "dotpay_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "state", default: "unpaid"
    t.string "payable_type"
    t.integer "payable_id"
    t.string "payment_url"
    t.integer "cash_user_id"
    t.boolean "deleted", default: false, null: false
  end

  create_table "photo_competitions", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "closed", default: false, null: false
  end

  create_table "photo_requests", id: :serial, force: :cascade do |t|
    t.integer "edition_record_id", null: false
    t.integer "user_id", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file"
    t.integer "category_record_id", null: false
    t.string "area"
    t.string "title"
  end

  create_table "photos", id: :serial, force: :cascade do |t|
    t.string "file_filename"
    t.integer "file_size"
    t.string "file_content_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_fields", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "field_type"
    t.boolean "required"
    t.integer "product_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_type_id"], name: "index_product_fields_on_product_type_id"
  end

  create_table "product_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
  end

  create_table "profiles", id: :serial, force: :cascade do |t|
    t.integer "kw_id"
    t.date "birth_date"
    t.string "birth_place"
    t.string "pesel"
    t.string "city"
    t.string "postal_code"
    t.string "main_address"
    t.string "optional_address"
    t.text "recommended_by", default: [], array: true
    t.boolean "main_discussion_group", default: false
    t.text "sections", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "accepted", default: false
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone"
    t.text "acomplished_courses", default: [], array: true
    t.string "profession"
    t.date "application_date"
    t.boolean "added", default: false
    t.text "position", default: [], array: true
    t.date "date_of_death"
    t.text "remarks"
    t.integer "cost"
    t.integer "acceptor_id"
    t.boolean "plastic", default: false, null: false
    t.datetime "sent_at"
    t.datetime "accepted_at"
    t.index ["kw_id"], name: "index_profiles_on_kw_id", unique: true
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "coordinator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reservation_items", id: :serial, force: :cascade do |t|
    t.integer "item_id"
    t.integer "reservation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reservations", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "state", default: "reserved"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "start_date"
    t.date "end_date"
    t.text "remarks"
    t.boolean "canceled", default: false
    t.string "photos"
  end

  create_table "route_colleagues", id: :serial, force: :cascade do |t|
    t.integer "colleague_id"
    t.integer "mountain_route_id"
    t.index ["colleague_id", "mountain_route_id"], name: "index_route_colleagues_on_colleague_id_and_mountain_route_id", unique: true
  end

  create_table "snw_profiles", id: :serial, force: :cascade do |t|
    t.string "question_1"
    t.integer "question_2"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "strzelecki_sign_ups", id: :serial, force: :cascade do |t|
    t.string "name_1"
    t.string "email_1"
    t.boolean "single", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization_1"
    t.boolean "vege_1", default: false
    t.integer "birth_year_1"
    t.integer "gender_1", default: 0
    t.integer "package_type_1", default: 0
    t.text "remarks"
    t.string "name_2"
    t.string "birth_year_2"
    t.boolean "vege_2", default: false
    t.string "email_2"
    t.string "organization_2"
    t.string "city_1"
    t.string "city_2"
    t.integer "package_type_2", default: 0
    t.string "phone_1"
    t.string "phone_2"
    t.integer "gender_2"
    t.integer "tshirt_size_1"
    t.integer "tshirt_size_2"
  end

  create_table "supplementary_course_package_types", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "supplementary_course_record_id", null: false
    t.integer "cost", null: false
    t.boolean "increase_limit", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "supplementary_courses", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "place"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer "organizator_id"
    t.text "participants", default: [], array: true
    t.integer "price_kw"
    t.integer "price_non_kw"
    t.datetime "application_date"
    t.boolean "accepted", default: false
    t.text "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category", default: 0, null: false
    t.boolean "price", default: false, null: false
    t.integer "limit", default: 0, null: false
    t.boolean "one_day", default: true, null: false
    t.boolean "active", default: false, null: false
    t.boolean "open", default: true, null: false
    t.boolean "last_fee_paid", default: false, null: false
    t.boolean "cash", default: false, null: false
    t.string "baner"
    t.boolean "packages", default: false
    t.string "slug", null: false
    t.integer "kind", default: 0, null: false
    t.integer "payment_type", default: 0, null: false
    t.integer "expired_hours", default: 0, null: false
    t.boolean "reserve_list", default: false, null: false
    t.integer "baner_type", default: 0, null: false
    t.index ["slug"], name: "index_supplementary_courses_on_slug", unique: true
  end

  create_table "supplementary_sign_ups", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "course_id"
    t.integer "payment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "email"
    t.string "code", default: "a15088e83eb354d4", null: false
    t.integer "supplementary_course_package_type_id"
    t.datetime "expired_at"
    t.datetime "sent_at"
    t.integer "admin_id"
    t.index ["course_id", "user_id"], name: "index_supplementary_sign_ups_on_course_id_and_user_id", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.integer "kw_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.boolean "admin", default: false, null: false
    t.integer "warnings", default: 0
    t.string "phone"
    t.boolean "curator", default: false, null: false
    t.string "refresh_token"
    t.string "access_token"
    t.text "roles", default: [], array: true
    t.string "avatar"
    t.boolean "hide", default: false
    t.boolean "boars", default: true, null: false
    t.boolean "ski_hater", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "product_fields", "product_types"
end
