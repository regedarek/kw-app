require 'results'

module Admin
  class Items
    def initialize(allowed_params)
      @allowed_params = allowed_params
    end

    def create
      if form.valid?
        item = Db::Item.new(form.params)
        item.save
        Success.new
      else
        Failure.new(:invalid, form: form)
      end
    end

    def update(item_id)
      if form.valid?
        item = Db::Item.find(item_id)
        item.update(form.params)
        Success.new
      else
        Failure.new(:invalid, form: form)
      end
    end

    def self.destroy(item_id)
      item = Db::Item.find(item_id)
      if item.destroy
        Success.new
      else
        Failure.new(:failure)
      end
    end

    def form
      @form ||= Admin::ItemsForm.new(@allowed_params)
    end
  end
end
