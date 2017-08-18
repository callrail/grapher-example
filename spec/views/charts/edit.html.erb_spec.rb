require 'rails_helper'

RSpec.describe "charts/edit", type: :view do
  before(:each) do
    @chart = assign(:chart, Chart.create!(
      :content => "MyText"
    ))
  end

  it "renders the edit chart form" do
    render

    assert_select "form[action=?][method=?]", chart_path(@chart), "post" do

      assert_select "textarea[name=?]", "chart[content]"
    end
  end
end
