class AddDocUrlToMarketingSponsorshipRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :marketing_sponsorship_requests, :doc_url, :string
  end
end
