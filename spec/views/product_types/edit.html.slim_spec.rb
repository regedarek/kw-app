require 'rails_helper'

RSpec.describe "product_types/edit", type: :view do
  before(:each) do
    @product_type = assign(:product_type, ProductType.create!(
      :name => "MyString"
    ))
  end

  it "renders the edit product_type form" do
    render

    assert_select "form[action=?][method=?]", product_type_path(@product_type), "post" do

      assert_select "input#product_type_name[name=?]", "product_type[name]"
    end
  end
end
