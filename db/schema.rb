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

ActiveRecord::Schema.define(version: 20180112215613) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "auction_products", force: :cascade do |t|
    t.string   "name"
    t.integer  "auction_id"
    t.integer  "price"
    t.text     "description"
    t.boolean  "sold"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "auctions", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "archived",    default: false
  end

  create_table "competition_package_types", force: :cascade do |t|
    t.string   "name",                                  null: false
    t.integer  "competition_record_id",                 null: false
    t.integer  "cost",                                  null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "membership",            default: false, null: false
  end

  create_table "competitions", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "edition_sym",                 null: false
    t.boolean  "single",      default: false, null: false
    t.boolean  "team_name",   default: false, null: false
    t.string   "baner_url"
    t.string   "rules"
  end

  create_table "courses", force: :cascade do |t|
    t.string   "title",       null: false
    t.text     "description"
    t.string   "instructor"
    t.integer  "cost",        null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "events", force: :cascade do |t|
    t.string   "name"
    t.string   "place"
    t.datetime "event_date"
    t.integer  "manager_kw_id"
    t.string   "participants"
    t.string   "application_list_url"
    t.integer  "price_for_members"
    t.integer  "price_for_non_members"
    t.date     "application_date"
    t.date     "payment_date"
    t.string   "account_number"
    t.string   "event_rules_url"
    t.string   "google_group_discussion_url"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.text     "description"
  end

  create_table "events_sign_ups", force: :cascade do |t|
    t.text     "remarks"
    t.integer  "competition_record_id",                         null: false
    t.string   "participant_name_1"
    t.string   "participant_name_2"
    t.string   "participant_email_1"
    t.string   "participant_email_2"
    t.string   "participant_birth_year_1"
    t.string   "participant_birth_year_2"
    t.string   "participant_city_1"
    t.string   "participant_city_2"
    t.string   "participant_team_1"
    t.string   "participant_team_2"
    t.string   "participant_gender_1"
    t.string   "participant_gender_2"
    t.integer  "competition_package_type_1_id",                 null: false
    t.integer  "competition_package_type_2_id"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.boolean  "single",                        default: false, null: false
    t.integer  "participant_kw_id_1"
    t.integer  "participant_kw_id_2"
    t.string   "team_name"
    t.string   "participant_phone_1"
    t.string   "participant_phone_2"
  end

  create_table "items", force: :cascade do |t|
    t.string   "display_name"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.text     "description"
    t.boolean  "rentable",     default: false
    t.integer  "owner",        default: 0
    t.integer  "cost",         default: 0
    t.integer  "rentable_id"
  end

  create_table "mas_sign_ups", force: :cascade do |t|
    t.string   "first_name_1"
    t.string   "first_name_2"
    t.string   "email_1"
    t.string   "email_2"
    t.string   "organization_1"
    t.string   "organization_2"
    t.string   "city_1"
    t.string   "city_2"
    t.integer  "package_type_1"
    t.integer  "package_type_2"
    t.integer  "gender_1"
    t.integer  "gender_2"
    t.string   "phone_1"
    t.string   "phone_2"
    t.integer  "tshirt_size_1"
    t.integer  "tshirt_size_2"
    t.text     "remarks"
    t.integer  "birth_year_1"
    t.integer  "birth_year_2"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "kw_id_1"
    t.integer  "kw_id_2"
    t.string   "name"
    t.string   "last_name_1"
    t.string   "last_name_2"
  end

  create_table "membership_fees", force: :cascade do |t|
    t.string   "year"
    t.integer  "cost",       default: 100, null: false
    t.integer  "kw_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["kw_id"], name: "index_membership_fees_on_kw_id", using: :btree
  end

  create_table "mountain_routes", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "description"
    t.string   "difficulty"
    t.string   "partners"
    t.integer  "rating"
    t.date     "climbing_date"
    t.string   "peak"
    t.string   "time"
    t.integer  "route_type",    default: 0
    t.string   "area"
    t.integer  "length"
    t.string   "mountains"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.boolean  "hidden",        default: false, null: false
  end

  create_table "participants", force: :cascade do |t|
    t.string   "full_name"
    t.string   "email",                       null: false
    t.string   "phone"
    t.string   "prefered_time",  default: [],              array: true
    t.text     "equipment",      default: [],              array: true
    t.string   "height"
    t.text     "recommended_by", default: [],              array: true
    t.integer  "kw_id"
    t.integer  "course_id",                   null: false
    t.date     "birth_date"
    t.string   "birth_place"
    t.string   "pre_cost"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "payments", force: :cascade do |t|
    t.boolean  "cash",         default: false
    t.string   "dotpay_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",        default: "unpaid"
    t.string   "payable_type"
    t.integer  "payable_id"
  end

  create_table "peaks", force: :cascade do |t|
    t.string  "name"
    t.integer "valley_id"
  end

  create_table "product_fields", force: :cascade do |t|
    t.string   "name"
    t.string   "field_type"
    t.boolean  "required"
    t.integer  "product_type_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["product_type_id"], name: "index_product_fields_on_product_type_id", using: :btree
  end

  create_table "product_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.text   "description"
  end

  create_table "profiles", force: :cascade do |t|
    t.integer  "kw_id"
    t.date     "birth_date"
    t.string   "birth_place"
    t.string   "pesel"
    t.string   "city"
    t.string   "postal_code"
    t.string   "main_address"
    t.string   "optional_address"
    t.text     "recommended_by",        default: [],                 array: true
    t.boolean  "main_discussion_group", default: false
    t.text     "sections",              default: [],                 array: true
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "accepted",              default: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone"
    t.text     "acomplished_courses",   default: [],                 array: true
    t.string   "profession"
    t.date     "application_date"
    t.boolean  "added",                 default: false
    t.text     "position",              default: [],                 array: true
    t.date     "date_of_death"
    t.text     "remarks"
    t.integer  "cost"
    t.index ["kw_id"], name: "index_profiles_on_kw_id", unique: true, using: :btree
  end

  create_table "reservation_items", force: :cascade do |t|
    t.integer  "item_id"
    t.integer  "reservation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reservations", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "state",      default: "reserved"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.date     "start_date"
    t.date     "end_date"
    t.text     "remarks"
    t.boolean  "canceled",   default: false
  end

  create_table "route_colleagues", force: :cascade do |t|
    t.integer "colleague_id"
    t.integer "mountain_route_id"
  end

  create_table "strzelecki_sign_ups", force: :cascade do |t|
    t.string   "name_1"
    t.string   "email_1"
    t.boolean  "single",         default: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "organization_1"
    t.boolean  "vege_1",         default: false
    t.integer  "birth_year_1"
    t.integer  "gender_1",       default: 0
    t.integer  "package_type_1", default: 0
    t.text     "remarks"
    t.string   "name_2"
    t.string   "birth_year_2"
    t.boolean  "vege_2",         default: false
    t.string   "email_2"
    t.string   "organization_2"
    t.string   "city_1"
    t.string   "city_2"
    t.integer  "package_type_2", default: 0
    t.string   "phone_1"
    t.string   "phone_2"
    t.integer  "gender_2"
    t.integer  "tshirt_size_1"
    t.integer  "tshirt_size_2"
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "kw_id"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.boolean  "admin",                  default: false, null: false
    t.integer  "warnings",               default: 0
    t.string   "phone"
    t.boolean  "curator",                default: false, null: false
    t.string   "refresh_token"
    t.string   "access_token"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "valleys", force: :cascade do |t|
    t.string "name"
  end

  add_foreign_key "product_fields", "product_types"
end
