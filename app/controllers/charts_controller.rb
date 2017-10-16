class ChartsController < ApplicationController
  # GET /charts
  # GET /charts.json
  def index
    @line_chart_data = calls_by_date
    @pie_chart_kws_data = generate_pie_chart
    @bar_chart_data = first_vs_repeat

  end

  def first_vs_repeat
    first_time_summary = summary("https://api.callrail.com/v2/a/170499692/calls/summary.json?company_id=385497224&start_date=2017-06-14&end_date=2017-09-14&group_by=source&first_time_callers=true")
    repeat_callers_summary = summary("https://api.callrail.com/v2/a/170499692/calls/summary.json?company_id=385497224&start_date=2017-06-14&end_date=2017-09-14&group_by=source&first_time_callers=false")
    first_time_callers = first_time_summary['grouped_results']
    first_sources = first_time_callers.map { |c| [c["key"], c["total_calls"]] }
    repeat_callers = repeat_callers_summary['grouped_results']
    repeat_sources = repeat_callers.map { |c| [c["key"], c["total_calls"]] }
    bar_chart_data = [
      {name: "First Time Callers", data: first_sources},
      {name: "Repeat Callers", data: repeat_sources}
    ]
  end

  def generate_pie_chart
    keywords = summary("https://api.callrail.com/v2/a/266101466/calls/summary.json?company_id=297407543&start_date=2017-06-14&end_date=2017-09-14&group_by=keywords")
    # create array of arrays of Keywords and associated number of calls
    kw_array = keywords['grouped_results']
    kws = kw_array.map { |c| [c['key'], c['total_calls']] }
    # Sort array of arrays by number of calls
    sorted = kws.sort {|a,b| b[1] <=> a[1]}
    # report the top 4 sources and combine the rest into "other" array,
    # excluding calls with "nil" keywords
    other = []
    pie_chart_kws_data = []
    sorted[1..4].each do |kw|
      pie_chart_kws_data << kw
    end
    sorted[5..-1].each do |kw|
      other << kw[1][1]
    end
    other_arr = ["other", other.sum]
    pie_chart_kws_data << other_arr
    pie_chart_kws_data
  end

  def calls_by_date
    calls = summary("https://api.callrail.com/v2/a/170499692/calls/timeseries.json?company_id=385497224&start_date=2017-06-14&end_date=2017-09-14&fields=total_calls,missed_calls")
    data = calls['data']
    total_calls = data.map { |c| [c["date"], c["total_calls"]] }
    missed_calls = data.map { |c| [c["date"], c["missed_calls"]] }
    line_chart_data = [
      {name: "Total Calls", data: total_calls},
      {name: "Missed Calls", data: missed_calls}
    ]
  end

  def tagdata
    tag = params[:tag]
    @tags = summary("https://api.callrail.com/v2/a/266101466/calls/summary.json?company_id=297407543&start_date=2017-06-14&end_date=2017-09-14&group_by=keywords&tags[]=#{tag}")
    render json: @tags
  end

private
  def summary(url)
    JSON.parse(RestClient.get(url, {Authorization: "Token token=#{ENV['CR_API_KEY']}"}))
  end
end
