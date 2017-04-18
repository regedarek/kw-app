class AddTimestampsToMountainRoutes < ActiveRecord::Migration[5.0]
  def up
    add_column :mountain_routes, :created_at, :datetime, default: Time.now
    add_column :mountain_routes, :updated_at, :datetime, default: Time.now
    Db::Activities::MountainRoute.find_each do |m|
      m.update(created_at: m.climbing_date, updated_at: m.climbing_date)
    end
    change_column_null :mountain_routes, :created_at, false
    change_column_null :mountain_routes, :updated_at, false
  end

  def down
    remove_column :mountain_routes, :created_at
    remove_column :mountain_routes, :updated_at
  end
end
