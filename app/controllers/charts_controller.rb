class ChartsController < ApplicationController
  # GET /charts
  # GET /charts.json
  def index
    @line_chart_data = calls_by_date_data
    @bar_chart_data = first_vs_repeat_data
    @pie_chart_kws_data = generate_pie_chart_data
  end

  def calls_by_date
    render json: calls_by_date_data
  end

  def calls_by_date_data
    date_range = params[:date_range]
    calls = summary("https://api.callrail.com/v2/a/#{ENV['ACCT_ID']}/calls/timeseries.json?company_id=#{ENV['COM_ID']}&fields=total_calls,missed_calls&date_range=#{date_range}")
    data = calls['data']
    total_calls = data.map { |c| [c["date"], c["total_calls"]] }
    missed_calls = data.map { |c| [c["date"], c["missed_calls"]] }
    line_chart_data = [
      {name: "Total Calls", data: total_calls},
      {name: "Missed Calls", data: missed_calls}
    ]
  end

  def first_vs_repeat
    render json: first_vs_repeat_data
  end

  def first_vs_repeat_data
    date_range = params[:date_range]
    callers = summary("https://api.callrail.com/v2/a/#{ENV['ACCT_ID']}/calls/summary.json?company_id=#{ENV['COM_ID']}&date_range=#{date_range}&group_by=source&fields=first_time_callers")
    results = callers['grouped_results'].reject { |c| c["key"] == "Outbound Call" || c["key"].nil? }
    results = top_five(results)
    first_timers = results.map { |c| [c["key"], c["first_time_callers"]] }
    repeat_callers = results.map { |c| [c["key"], c["total_calls"] - c["first_time_callers"]]}
    bar_chart_data = [
      {name: "Repeat Callers", data: repeat_callers},
      {name: "First Time Callers", data: first_timers}
    ]
  end

# how do I handle cases where the top 5 is different for first time vs repeat callers?
  def top_five(mapped)
    high_five = mapped.sort {|a,b| b['total_calls'] <=> a['total_calls']}
    high_five.take(5)
  end

  def generate_pie_chart
    render json: generate_pie_chart_data
  end

  def generate_pie_chart_data
    date_range = params[:date_range]
    keywords = summary("https://api.callrail.com/v2/a/#{ENV['ACCT_ID']}/calls/summary.json?company_id=#{ENV['COM_ID']}&date_range=#{date_range}&group_by=keywords")
    # create array of arrays of Keywords and associated number of calls
    unsorted = keywords['grouped_results']
    sorter(unsorted)
  end

  def sorter(kw_array)
    # Sanitize response by removing "nil" keyword from the results
    kw_array = kw_array.reject { |c| c["key"].nil? }
    kws = kw_array.map { |c| [c['key'], c['total_calls']] }
    # Sort array of arrays by number of calls
    sorted = kws.sort {|a,b| b[1] <=> a[1]}
    # report the top 4 sources and combine the rest into "other" array
    other = []
    sorted_data = []
    sorted[0..3].each do |kw|
      sorted_data << kw
    end
    sorted[4..-1].each do |kw|
      other << kw[1][1]
    end
    other_arr = ["other", other.sum]
    sorted_data << other_arr
  end

  def tag_data
    tag = params[:tag]
    tags = summary("https://api.callrail.com/v2/a/#{ENV['ACCT_ID']}/calls/summary.json?company_id=#{ENV['COM_ID']}&start_date=2017-06-14&end_date=2017-09-14&group_by=keywords&tags[]=#{tag}")
    results = tags['grouped_results']
    render json: sorter(results)
  end

  # def dater
  #   case date_range
  #     when 'recent'
  #       date_range = 'recent'
  #     when 'today'
  #        date_range = 'today'
  #     when 'yesterday'
  #       date_range = 'yesterday'
  #     when 'last 7 days'
  #       date_range = 'last_7_days'
  #     when 'last 30 days'
  #       date_range = 'last_30_days'
  #     when 'this month'
  #       date_range = 'this_month'
  #     when 'last month'
  #       date_range = 'last_month'
  #   end

private

  def summary(url)
    JSON.parse(RestClient.get(url, {Authorization: "Token token=#{ENV['CR_API_KEY']}"}))
  end
end
