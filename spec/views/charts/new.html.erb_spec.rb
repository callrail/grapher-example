require 'rails_helper'

RSpec.describe "charts/new", type: :view do
  before(:each) do
    assign(:chart, Chart.new(
      :content => "MyText"
    ))
  end

  it "renders new chart form" do
    render

    assert_select "form[action=?][method=?]", charts_path, "post" do

      assert_select "textarea[name=?]", "chart[content]"
    end
  end
end
