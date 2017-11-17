class ChartsController < ApplicationController
  # GET /charts
  # GET /charts.json
  def index
    @params = params
    @line_chart_data = calls_by_date_data
    @bar_chart_data = first_vs_repeat_data
    @pie_chart_data = pie_chart_data
  end

  private


  def calls_by_date_data
    response = api_request(:timeseries, {fields: 'total_calls,missed_calls'})
    data = response['data']
    total_calls = data.map { |day| [day["date"], day["total_calls"]] }
    missed_calls = data.map { |day| [day["date"], day["missed_calls"]] }

    [
      { name: "Total Calls", data: total_calls },
      { name: "Missed Calls", data: missed_calls }
    ]
  end

  def first_vs_repeat_data
    response = api_request(:summary, {group_by: 'source', fields: 'first_time_callers'})
    results = extract_and_sort_results(response).take(5)

    first_timers = results.map { |c| [c["key"], c["first_time_callers"]] }
    repeat_callers = results.map { |c| [c["key"], c["total_calls"] - c["first_time_callers"]] }

    [
      { name: "Repeat Callers", data: repeat_callers },
      { name: "First Time Callers", data: first_timers }
    ]
  end

  def pie_chart_data
    response = api_request(:summary, {group_by: 'keywords'})
    results = extract_and_sort_results(response)

    total_other = results.drop(4).map {|row| row['total_calls']}.sum
    pie_segments = results.take(4)
    pie_segments << { "key" => "Other", "total_calls" => total_other }

    pie_segments.map { |segment| [segment['key'], segment['total_calls']] }
  end

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

  def extract_and_sort_results(api_response)
    # extract grouped results
    # filter out outbound and nil
    results = api_response['grouped_results'].reject do |row|
      row["key"] == "Outbound Call" || row["key"].nil?
    end
    # sort by total calls in descending order
    results.sort_by { |row| row['total_calls'] }.reverse
  end

end
