class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def hello
    render html: "hello world"
  end



  # def show_stuff
  #   formatter.each do |item|
  #     item.['calls']['customer_name']
      
  #   end
  # end

  # def     @results = JSON.parse(open("https://api.callrail.com/v2/a/{account_id}/calls.json?date_range=recent").read)
  # end


end


