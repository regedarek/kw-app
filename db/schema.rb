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

ActiveRecord::Schema.define(version: 2019_08_14_111833) do

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
    t.boolean "accept_first", default: false, null: false
    t.datetime "close_payment"
  end

  create_table "competiton_photo_sets", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contract_events", force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "contract_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contract_users", force: :cascade do |t|
    t.integer "contract_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contractors", force: :cascade do |t|
    t.string "name"
    t.string "nip"
    t.text "description"
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
    t.integer "document_type"
    t.date "document_date"
    t.integer "group_type"
    t.integer "financial_type"
    t.date "period_date"
    t.integer "contractor_id"
    t.integer "event_id"
    t.integer "substantive_type"
    t.integer "payout_type"
    t.datetime "preclosed_date"
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

  create_table "emails", force: :cascade do |t|
    t.string "message_id", null: false
    t.datetime "delivered_at"
    t.integer "mailable_id", null: false
    t.string "mailable_type", null: false
    t.string "state", default: "sent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "sent_at"
    t.datetime "expired_at"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
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

  create_table "library_authors", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "library_item_authors", force: :cascade do |t|
    t.integer "item_id"
    t.integer "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id", "author_id"], name: "index_library_item_authors_on_item_id_and_author_id", unique: true
  end

  create_table "library_item_tags", force: :cascade do |t|
    t.integer "item_id"
    t.integer "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "library_items", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "attachments"
    t.integer "area_id"
    t.integer "doc_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "item_id"
    t.boolean "reading_room"
    t.string "autors"
    t.date "publishment_at"
    t.string "number"
    t.string "slug", null: false
  end

  create_table "library_tags", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_id"
    t.integer "type"
  end

  create_table "management_cases", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "state", default: "draft", null: false
    t.text "destrciption"
    t.integer "creator_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "attachments"
    t.string "number"
    t.boolean "hidden", default: false, null: false
    t.string "doc_url"
    t.boolean "hide_votes", default: false, null: false
    t.date "acceptance_date"
    t.index ["slug"], name: "index_management_cases_on_slug", unique: true
  end

  create_table "management_informations", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "url"
    t.integer "news_type", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "management_votes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "case_id", null: false
    t.boolean "approved", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "decision"
  end

  create_table "membership_fees", id: :serial, force: :cascade do |t|
    t.string "year"
    t.integer "cost", null: false
    t.integer "kw_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.boolean "plastic", default: false, null: false
    t.index ["kw_id"], name: "index_membership_fees_on_kw_id"
  end

  create_table "meteoblue_records", force: :cascade do |t|
    t.date "time", null: false
    t.integer "pictocode"
    t.float "temperature_max"
    t.float "temperature_min"
    t.float "temperature_mean"
    t.float "felttemperature_max"
    t.float "felttemperature_min"
    t.integer "winddirection"
    t.integer "precipitation_probability"
    t.string "rainspot"
    t.integer "predictability_class"
    t.integer "predictability"
    t.float "precipitation"
    t.float "snowfraction"
    t.integer "sealevelpressure_max"
    t.integer "sealevelpressure_min"
    t.integer "sealevelpressure_mean"
    t.float "windspeed_max"
    t.float "windspeed_mean"
    t.float "windspeed_min"
    t.integer "relativehumidity_max"
    t.integer "relativehumidity_min"
    t.integer "relativehumidity_mean"
    t.float "convective_precipitation"
    t.float "precipitation_hours"
    t.float "humiditygreater90_hours"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["time"], name: "index_meteoblue_records_on_time", unique: true
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
    t.string "slug"
    t.index ["climbing_date"], name: "index_mountain_routes_on_climbing_date", order: :desc
    t.index ["slug"], name: "index_mountain_routes_on_slug", unique: true
    t.index ["user_id"], name: "index_mountain_routes_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "recipient_id"
    t.integer "actor_id"
    t.datetime "read_at"
    t.string "action"
    t.integer "notifiable_id", null: false
    t.string "notifiable_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state", default: "unpaid"
    t.string "payable_type"
    t.integer "payable_id"
    t.string "payment_url"
    t.integer "cash_user_id"
    t.boolean "deleted", default: false, null: false
    t.datetime "refunded_at"
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

  create_table "profile_lists", force: :cascade do |t|
    t.text "description"
    t.integer "section_type", null: false
    t.integer "acceptor_id"
    t.boolean "accepted", default: false, null: false
    t.integer "profile_id", null: false
    t.string "attachments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "project_users", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "user_id"], name: "index_project_users_on_project_id_and_user_id", unique: true
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "coordinator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "needed_knowledge"
    t.text "benefits"
    t.text "estimated_time"
    t.string "attachments"
    t.text "know_how"
    t.string "state", default: "draft"
    t.string "slug"
    t.index ["slug"], name: "index_projects_on_slug", unique: true
  end

  create_table "reservation_items", id: :serial, force: :cascade do |t|
    t.integer "item_id"
    t.integer "reservation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "shmu_diagrams", force: :cascade do |t|
    t.datetime "diagram_time"
    t.string "place"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.text "email_remarks"
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
    t.string "code", default: "924dd11384eeb715", null: false
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
    t.string "slug"
    t.boolean "climbing_boars", default: true, null: false
    t.text "description"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
  end

  create_table "weather_records", force: :cascade do |t|
    t.string "place"
    t.float "temp"
    t.float "daily_snow"
    t.float "all_snow"
    t.integer "snow_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "product_fields", "product_types"
end
