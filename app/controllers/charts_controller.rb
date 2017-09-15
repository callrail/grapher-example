class ChartsController < ApplicationController
  before_action :set_chart, only: [:show, :edit, :update, :destroy]

  # GET /charts
  # GET /charts.json
  def index
    @calls = JSON.parse(RestClient.get("https://api.callrail.com/v2/a/170499692/calls/timeseries.json?company_id=763484074&start_date=2017-08-14&end_date=2017-09-14", {Authorization: "Token token=#{ENV['CR_API_KEY']}"}))
    @data = @calls['data']
    @formatted_data = @data.map { |c| [c["date"], c["total_calls"]] }
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
