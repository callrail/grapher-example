class ChartsController < ApplicationController
  # GET /charts
  # GET /charts.json
  def index
    @params = params
    @line_chart_data = calls_by_date_data
    @bar_chart_data = first_vs_repeat_data
    @pie_chart_kws_data = generate_pie_chart_data
  end

  def sorter(kw_array)
    kw_array = kw_array.reject { |c| c["key"].nil? }
    kws = kw_array.map { |c| [c['key'], c['total_calls']] }
    sorted = kws.sort {|a,b| b[1] <=> a[1]}
    sorted_data = sorted.take(4)
    other = sorted.drop(4)
    other_arr = ["other", other.sum { |o| o[1] }]
    sorted_data << other_arr
  end

  def calls_by_date
    render json: calls_by_date_data
  end

  def calls_by_date_data
    date_range = params[:date_range]
    tag = params[:tag]
    calls = api_request(:timeseries, {fields: 'total_calls,missed_calls'})
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
    tag = params[:tag]
    callers = api_request(:summary, {group_by: 'source', fields: 'first_time_callers'})

    # summary("https://api.callrail.com/v2/a/#{ENV['ACCT_ID']}/calls/summary.json?company_id=#{ENV['COM_ID']}&date_range=#{date_range}&group_by=source&fields=first_time_callers")
    results = callers['grouped_results'].reject { |c| c["key"] == "Outbound Call" || c["key"].nil? }
    results = top_five(results)
    first_timers = results.map { |c| [c["key"], c["first_time_callers"]] }
    repeat_callers = results.map { |c| [c["key"], c["total_calls"] - c["first_time_callers"]]}
    bar_chart_data = [
      {name: "Repeat Callers", data: repeat_callers},
      {name: "First Time Callers", data: first_timers}
    ]
  end

  def top_five(mapped)
    high_five = mapped.sort {|a,b| b['total_calls'] <=> a['total_calls']}
    high_five.take(5)
  end

  def generate_pie_chart
    render json: generate_pie_chart_data
  end

  def generate_pie_chart_data
    date_range = params[:date_range]
    keywords = api_request(:summary, {group_by: 'keywords'})
    # create array of arrays of Keywords and associated number of calls
    unsorted = keywords['grouped_results']
    sorter(unsorted)
  end

  def tag_data
    tag = params[:tag]
    tags = api_request(:summary, {group_by: 'keywords', tags: [tag]})
    # summary("https://api.callrail.com/v2/a/#{ENV['ACCT_ID']}/calls/summary.json?company_id=#{ENV['COM_ID']}}&date_range=#{date_range}&group_by=keywords&tags[]=#{tag}")
    results = tags['grouped_results']
    render json: sorter(results)
  end

private

  # endpoint: "summary" or "timeseries"
  # query: hash of URL params for this request
  def api_request(endpoint, query)
    query[:company_id] = ENV['COM_ID']
    query[:date_range] = params[:date_range]
    query[:tags] = params[:tag]

    JSON.parse(
      RestClient.get(
        "https://api.callrail.com/v2/a/#{ENV['ACCT_ID']}/calls/#{endpoint}.json",
        params: query,
        Authorization: "Token token=#{ENV['CR_API_KEY']}"
      )
    )
  end


  # needs to be able to change from "timeseries" to "summary"
  def summary_api_route
    # date_range = params[:date_range]
    # JSON.parse(RestClient.get("https://api.callrail.com/v2/a/#{ENV['ACCT_ID']}/calls/summary.json?company_id=#{ENV['COM_ID']}}&date_range=#{date_range}&group_by=keywords", {Authorization: "Token token=#{ENV['CR_API_KEY']}"}))
    api_request(:summary, {group_by: 'keywords'})
  end

  def timeseries_api_route
    # JSON.parse(RestClient.get("https://api.callrail.com/v2/a/#{ENV['ACCT_ID']}/calls/timeseries.json?company_id=#{ENV['COM_ID']}&fields=total_calls,missed_calls&date_range=#{date_range}", {Authorization: "Token token=#{ENV['CR_API_KEY']}"}))
    api_request(:timeseries, {fields: 'total_calls,missed_calls', group_by: 'something'})
  end

  # create 3 methods that handles the API endpoint stuff.
  # summary stuff
  # time stuff
  # HTTP heavy lifting


  # "summary" needs to provide grouping options and field options
  # needs to be able to omit or include "tag" url info


end
