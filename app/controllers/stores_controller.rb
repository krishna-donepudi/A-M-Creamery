class StoresController < ApplicationController

  before_action :set_store, only: [:show, :edit, :update, :destroy, :store_payroll]
  before_action :check_login
  authorize_resource

  def store_payroll
    sd = params[:start_date].nil? ? 2.weeks.ago.to_date : params[:start_date].to_date
    ed = params[:end_date].nil? ? Date.today.to_date : params[:end_date].to_date
    date_range = DateRange.new(sd, ed)
    calc = PayrollCalculator.new(date_range)
    @payroll = calc.create_payrolls_for(@store).sort_by{|p| p.employee.proper_name}
    @total_hours = @payroll.map{|p| p.hours}.reduce(:+)
    @total_pay = @payroll.map{|p| p.pay_earned}.reduce(:+)

  end

  def index
    # get data on all stores and paginate the output to 10 per page
    @active_stores = Store.active.alphabetical.paginate(page: params[:page]).per_page(10)
    @inactive_stores = Store.inactive.alphabetical.paginate(page: params[:ipage]).per_page(10)
  end

  def show
    @current_managers = @store.assignments.current.map{|a| a.employee}.sort_by{|e| e.name}.select{|e| e.role == 'manager'}
    @current_employees = @store.assignments.current.map{|a| a.employee}.sort_by{|e| e.name}
    @shifts = @store.shifts.all
    @past_shifts = @store.shifts.for_past_days(7).paginate(page: params[:page]).per_page(10)
    @upcoming_shifts = @store.shifts.for_next_days(8).paginate(page: params[:ipage]).per_page(10)
  end

  def new
    @store = Store.new
  end

  def edit
  end

  def create
    @store = Store.new(store_params)
    if @store.save
      redirect_to @store, notice: "Successfully added #{@store.name} to the system."
    else
      render action: 'new'
    end
  end

  def update
    if @store.update_attributes(store_params)
      redirect_to @store, notice: "Updated store information for #{@store.name}."
    else
      render action: 'edit'
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_store
    @store = Store.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def store_params
    params.require(:store).permit(:name, :street, :city, :phone, :state, :zip, :active)
  end

end
