class HomeController < ApplicationController
  def index
    unless current_user.nil?
      if current_user.role?(:employee)
        redirect_to employee_path(current_user)
      else
        redirect_to dashboard_path
      end
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
  end

  def search
    redirect_back(fallback_location: home_path) if params[:query].blank?
    @query = params[:query]
    @employees = Employee.search(@query)
    @total_hits = @employees.size
  end
  
end