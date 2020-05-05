class HomeController < ApplicationController
  def index
    unless current_user.nil?
      redirect_to dashboard_path
    end
  end

  def about
  end

  def contact
  end

  def privacy
  end

  def dashboard
    @stores = Store.active.alphabetical
    unless current_user.role?(:admin)
      @employees = Employee.active.regulars.alphabetical.select{|e| e.current_assignment.nil? ? false : e.current_assignment.store == current_user.current_assignment.store}
      @shifts = Shift.for_store(current_user.current_assignment.store).finished.select{ |s| !s.report_completed? }
    end
    dates = DateRange.new(Date.today.to_date, 7.days.ago.to_date)
    payrollcalc = PayrollCalculator.new(dates)
    @payroll = payrollcalc.create_payroll_record_for(current_user)
    @upcoming_shifts = current_user.shifts.for_next_days(8)
    @pending_shifts_today = current_user.shifts.pending.for_date(Date.current)
    @started_shifts_today = current_user.shifts.started.for_date(Date.current)
  end

  def search
    redirect_back(fallback_location: home_path) if params[:query].blank?
    @query = params[:query]
    if current_user.role?(:admin)
      @employees = Employee.search(@query)
    elsif current_user.role?(:manager)
      @employees = current_user.current_assignment.store.employees.search(@query)
    end
    @total_hits = @employees.size
  end
  
end