class HomeController < ApplicationController
  def index
    unless current_user.nil?
      if current_user.role?(:employee)
        redirect_to employee_path(current_user)
      elsif current_user.role?(:manager)
        redirect_to store_path(current_user.current_assignment.store)
      elsif current_user.role?(:admin)
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
    @shifts = current_user.store.shifts.pending unless current_user.store.nil?
  end

  def search
    redirect_back(fallback_location: home_path) if params[:query].blank?
    @query = params[:query]
    @employees = Employee.search(@query)
    @total_hits = @employees.size
  end
  
end