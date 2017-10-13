class ChartsController < ApplicationController
  before_action :set_chart, only: [:show, :edit, :update, :destroy]

  # GET /charts
  # GET /charts.json
  def index
    # Time series JSON Ping
    @calls = JSON.parse(RestClient.get("https://api.callrail.com/v2/a/170499692/calls/timeseries.json?company_id=385497224&start_date=2017-06-14&end_date=2017-09-14&fields=total_calls,missed_calls", {Authorization: "Token token=#{ENV['CR_API_KEY']}"}))
    @data = @calls['data']
    @total_calls = @data.map { |c| [c["date"], c["total_calls"]] }
    @missed_calls = @data.map { |c| [c["date"], c["missed_calls"]] }
    @line_chart_data = [
      {name: "Total Calls", data: @total_calls},
      {name: "Missed Calls", data: @missed_calls}
    ]

    # Summary Data JSON Ping - First Time vs Repeat Callers
    @first_time_summary = JSON.parse(RestClient.get("https://api.callrail.com/v2/a/170499692/calls/summary.json?company_id=385497224&start_date=2017-06-14&end_date=2017-09-14&group_by=source&first_time_callers=true", {Authorization: "Token token=#{ENV['CR_API_KEY']}"}))
    @repeat_callers_summary = JSON.parse(RestClient.get("https://api.callrail.com/v2/a/170499692/calls/summary.json?company_id=385497224&start_date=2017-06-14&end_date=2017-09-14&group_by=source&first_time_callers=false", {Authorization: "Token token=#{ENV['CR_API_KEY']}"}))
    @first_time_callers = @first_time_summary['grouped_results']
    @first_sources = @first_time_callers.map { |c| [c["key"], c["total_calls"]] }
    @repeat_callers = @repeat_callers_summary['grouped_results']
    @repeat_sources = @repeat_callers.map { |c| [c["key"], c["total_calls"]] }
    @bar_chart_data = [
      {name: "First Time Callers", data: @first_sources},
      {name: "Repeat Callers", data: @repeat_sources}
    ]

    # Summary Data, Keywords
    @keywords = JSON.parse(RestClient.get("https://api.callrail.com/v2/a/266101466/calls/summary.json?company_id=297407543&start_date=2017-06-14&end_date=2017-09-14&group_by=keywords", {Authorization: "Token token=#{ENV['CR_API_KEY']}"}))
    # create array of arrays of Keywords and associated number of calls
    @kw_array = @keywords['grouped_results']
    @kws = @kw_array.map { |c| [c['key'], c['total_calls']] }
    # Sort array of arrays by number of calls
    @sorted = @kws.sort {|a,b| b[1] <=> a[1]}
    # report the top 4 sources and combine the rest into "other" array,
    # excluding calls with "nil" keywords
    @other = []
    @pie_chart_kws_data = []
    @sorted[1..4].each do |kw|
      @pie_chart_kws_data << kw
    end
    @sorted[5..-1].each do |kw|
      @other << kw[1][1]
    end
    @other_arr = ["other", @other.sum]
    @pie_chart_kws_data << @other_arr
  end

  # GET /charts/1
  # GET /charts/1.json
  def show
  end

  # GET /charts/new
  def new
    @chart = Chart.new
  end

  # GET /charts/1/edit
  def edit
  end

  # POST /charts
  # POST /charts.json
  def create
    @chart = Chart.new(chart_params)

    respond_to do |format|
      if @chart.save
        format.html { redirect_to @chart, notice: 'Chart was successfully created.' }
        format.json { render :show, status: :created, location: @chart }
      else
        format.html { render :new }
        format.json { render json: @chart.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /charts/1
  # PATCH/PUT /charts/1.json
  def update
    respond_to do |format|
      if @chart.update(chart_params)
        format.html { redirect_to @chart, notice: 'Chart was successfully updated.' }
        format.json { render :show, status: :ok, location: @chart }
      else
        format.html { render :edit }
        format.json { render json: @chart.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /charts/1
  # DELETE /charts/1.json
  def destroy
    @chart.destroy
    respond_to do |format|
      format.html { redirect_to charts_url, notice: 'Chart was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chart
      @chart = Chart.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def chart_params
      params.require(:chart).permit(:content)
    end
end
