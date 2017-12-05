class ChartsController < ApplicationController

  def index
    @params = params
    @line_chart_data = calls_by_date_data
    @bar_chart_data = first_vs_repeat_data
    @pie_chart_data = pie_chart_data
  end

  private

  # This method gathers the data for the "Calls By Date" graph. It sends an API request to
  # the `timeseries` endpoint and includes the `total_calls` and `missed_calls` fields.
  #
  # For each series, this method returns an array of arrays containing a date and the number
  # of calls for both missed calls and total calls.
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

  # This method gathers the data used in the "First Time vs Repeat Callers" graph. It sends an
  # API request to the `summary` endpoint and groups the data by source, includes the
  # `first_time_callers` field. This method limits the number of results to the top 5 most
  # called Tracking Phone Numbers in the specified time frame (see extract_and_sort method
  # below).
  #
  # For each series, returns an array of arrays containing the name of the Tracking
  # Phone Number and the number of calls placed to that Tracking Phone Number.
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

  # This method gathers the data used in the "Calls By Keyword" graph. This sends an API request
  # to the `summary` endpoint and groups the data by keywords. The variable `pie_segments` takes
  # the top 4 keywords with the most calls, and returns an array. The variable `total_other`
  # returns the number of phone calls for all other keywords not in the top 4, which is then
  # assigned as the total number of calls for the "Other" key.
  #
  # For each series, it returns an array of arrays containing the name of the top 4 keywords
  # and "Other", as well as the total number of phone calls for each keyword.
  def pie_chart_data
    response = api_request(:summary, {group_by: 'keywords'})
    results = extract_and_sort_results(response)

    total_other = results.drop(4).map {|row| row['total_calls']}.sum
    pie_segments = results.take(4)
    pie_segments << { "key" => "Other", "total_calls" => total_other }

    pie_segments.map { |segment| [segment['key'], segment['total_calls']] }
  end

  # This method is what is used to make API requests. We have broken the API call down into two
  # parts, the endpoint and the query. The endpoint in our examples are either `summary` or
  # `timeseries`. The query is a hash of URL params for the request. Some query parameters are
  # passed in by the method calling this function, then additional parameters that are standard
  # to all charts are added.
  #
  # Example: the `pie_chart_data` method above calls `api_response` and passes in `group_by` as
  # a query parameter.
  #
  # The full URL of the API call from:
  #   api_request(:summary, {group_by: 'keywords'})
  #   https://api.callrail.com/v2/a/{account_id}/calls/summary.json?company_id={company_id}&group_by=keywords
  #
  # Returns the API response, as a parsed object.
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

  # This method is used to filter our API response and remove the outbound calls and any calls
  # that have a `nil` key. After filtering, we sort by the number of `total_calls`, greatest
  # to fewest via the `.reverse` method.
  #
  # Returns a reverse sorted array of results.
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
