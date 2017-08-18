require 'rails_helper'

RSpec.describe "charts/index", type: :view do
  before(:each) do
    assign(:charts, [
      Chart.create!(
        :content => "MyText"
      ),
      Chart.create!(
        :content => "MyText"
      )
    ])
  end

  it "renders a list of charts" do
    render
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
