class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:show, :edit, :update, :terminate, :destroy]
  before_action :check_login
  authorize_resource

  def index
    # for phase 3 only
    if current_user.role?(:admin)
      @current_assignments = Assignment.current.chronological.paginate(page: params[:page]).per_page(10)
      @past_assignments = Assignment.past.chronological.paginate(page: params[:page]).per_page(10)
    elsif current_user.role?(:manager)
      @current_assignments = Assignment.current.chronological.for_store(current_user.current_assignment.store).paginate(page: params[:page]).per_page(10)
      @past_assignments = Assignment.past.chronological.for_store(current_user.current_assignment.store).paginate(page: params[:page]).per_page(10)
    else
      @current_assignments = Assignment.current.chronological.for_employee(current_user).paginate(page: params[:page]).per_page(10)
      @past_assignments = Assignment.past.chronological.for_employee(current_user).paginate(page: params[:page]).per_page(10)
    end
  end

  def show
    retrieve_assignment_shifts
  end

  def new
    @assignment = Assignment.new
    @assignment.employee_id = params[:employee_id] unless params[:employee_id].nil?
  end

  def create
    @assignment = Assignment.new(assignment_params)
    if @assignment.save
      redirect_to assignments_path, notice: "Successfully added the assignment."
    else
      render action: 'new'
    end
  end

  def terminate
    if @assignment.terminate
      redirect_to assignments_path, notice: "Assignment for #{@assignment.employee.proper_name} terminated."
    end
  end

  def edit
  end

  def update
    if @assignment.update_attributes(assignment_params)
      redirect_to assignments_path, notice: "Updated assignment #{@assignment.id} of #{@assignment.employee.proper_name} information."
    else
      render action: 'edit'
    end
  end

  def destroy
    @assignment.destroy
    redirect_to assignments_path, notice: "Removed assignment from the system."
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_assignment
    @assignment = Assignment.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def assignment_params
    params.require(:assignment).permit(:store_id, :pay_grade_id, :employee_id, :start_date)
  end

  def retrieve_assignment_shifts
    @shifts = @assignment.shifts.chronological.paginate(page: params[:page]).per_page(10)
  end

end

