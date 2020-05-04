class EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :edit, :update, :destroy, :generate_payroll]
  before_action :check_login
  authorize_resource

  def generate_payroll
    dates = DateRange.new(Date.today.to_date, 7.days.ago.to_date)
    payrollcalc = PayrollCalculator.new(dates)
    @payroll = payrollcalc.create_payroll_record_for(@employee)
  end

  def index
    # for phase 3 only
    if current_user.role?(:admin)
      @active_managers = Employee.managers.active.alphabetical.paginate(page: params[:page]).per_page(10)
      @active_employees = Employee.regulars.active.alphabetical.paginate(page: params[:page]).per_page(10)
      @inactive_employees = Employee.inactive.alphabetical.paginate(page: params[:page]).per_page(10)
    elsif current_user.role?(:manager)
      @active_managers = Employee.managers.active.alphabetical.select{|e| e.current_assignment.nil? ? false : e.current_assignment.store == current_user.current_assignment.store}
      @active_employees = Employee.regulars.active.alphabetical.select{|e| e.current_assignment.nil? ? false : e.current_assignment.store == current_user.current_assignment.store}
      @inactive_employees = Employee.regulars.inactive.alphabetical.select{|e| e.current_assignment.nil? ? false : e.current_assignment.store == current_user.current_assignment.store}
    end
  end

  def show
    dates = DateRange.new(Date.today.to_date, 7.days.ago.to_date)
    payrollcalc = PayrollCalculator.new(dates)
    @payroll = payrollcalc.create_payroll_record_for(@employee)
    retrieve_employee_assignments
    retrieve_employee_shifts
  end

  def new
    @employee = Employee.new
  end

  def edit
  end

  def create
    @employee = Employee.new(employee_params)
    if @employee.save
      redirect_to @employee, notice: "Successfully added #{@employee.proper_name} as an employee."
    else
      render action: 'new'
    end
  end

  def update
    if @employee.update_attributes(employee_params)
      redirect_to @employee, notice: "Updated #{@employee.proper_name}'s information."
    else
      render action: 'edit'
    end
  end


  def destroy
    if @employee.destroy
      redirect_to employees_url, notice: "Successfully removed #{@employee.proper_name} from the AMC system."
    else
      flash.now.alert = "Could not delete employee, was made inactive instead."
      render action: 'show'
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_employee
    @employee = Employee.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def employee_params
    params.require(:employee).permit(:first_name, :last_name, :username, :ssn, :phone, :date_of_birth, :role, :active, :password, :password_confirmation)
  end

  def retrieve_employee_assignments
    @current_assignment = @employee.current_assignment
    @previous_assignments = @employee.assignments.to_a - [@current_assignment]
  end

  def retrieve_employee_shifts
    @shifts = @employee.shifts.all
    @previous_shifts = @employee.shifts.for_past_days(7)
    @upcoming_shifts = @employee.shifts.for_next_days(8)
    @pending_shifts_today = @employee.shifts.pending.for_date(Date.current)
    @started_shifts_today = @employee.shifts.started.for_date(Date.current)
  end

end
