class ShiftsController < ApplicationController
  before_action :set_shift, only: [:show, :edit, :update, :destroy, :clock_in, :clock_out]
  before_action :check_login
	authorize_resource
	
	def index
    # get data on all shifts and paginate the output to 10 per page
    if current_user.role?(:admin)
      @past_shifts = Shift.past.chronological.paginate(page: params[:page]).per_page(10)
      @upcoming_shifts = Shift.upcoming.chronological.paginate(page: params[:ipage]).per_page(10)
    elsif current_user.role?(:manager)
      @past_shifts = Shift.past.chronological.for_store(current_user.current_assignment.store).paginate(page: params[:page]).per_page(10)
      @upcoming_shifts = Shift.upcoming.chronological.for_store(current_user.current_assignment.store).paginate(page: params[:ipage]).per_page(10)
    else
      @past_shifts = Shift.past.chronological.for_employee(current_user).paginate(page: params[:page]).per_page(10)
      @upcoming_shifts = Shift.upcoming.chronological.for_employee(current_user).paginate(page: params[:ipage]).per_page(10)
    end
  end

	def show
    @shift_jobs = @shift.shift_jobs
	end
	
	def new
    @shift = Shift.new
    @shift.assignment_id = params[:assignment_id] unless params[:assignment_id].nil?
    if current_user.role?(:manager)
      @assignments = current_user.current_assignment.store.assignments.current.chronological
      @assign_names = @assignments.map{|x| [x.employee.name, x.id]}
    else
      @assignments = Assignment.all.current.chronological
      @assign_names = @assignments.map{|x| [x.employee.name, x.id]}
    end
	end
	
  def edit
    if current_user.role?(:manager)
      @assignments = current_user.current_assignment.store.assignments.current.chronological
      @assign_names = @assignments.map{|x| [x.employee.name, x.id]}
    else
      @assignments = Assignment.all.current.chronological
      @assign_names = @assignments.map{|x| [x.employee.name, x.id]}
    end
  end

  def create
    @shift = Shift.new(shift_params)
    if @shift.save
      redirect_to @shift, notice: "Successfully added a #{@shift.status} shift for #{@shift.employee.name} to the system."
    else
      render action: 'new'
    end
	end

	def update
    if @shift.update_attributes(shift_params)
      redirect_to @shift, notice: "Updated shift information for shift #{@shift.id}."
    else
      render action: 'edit'
    end
  end

  def clock_in
    @new_time = TimeClock.new(@shift)
    @new_time.start_shift_at(Time.now)
    redirect_to @shift.employee
  end

  def clock_out
    @new_time = TimeClock.new(@shift)
    @new_time.end_shift_at(Time.now)
    redirect_to @shift.employee
  end
  
  def destroy
    if @shift.destroy
      redirect_to shifts_url, notice: "Successfully removed #{@shift.id} from the AMC system."
    else
      flash.now.alert = "Shift cannot be deleted if it is finished"
      redirect_to shifts_url
    end
  end

	
	private
  # Use callbacks to share common setup or constraints between actions.
  def set_shift
    @shift = Shift.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def shift_params
    params.require(:shift).permit(:assignment_id, :date, :start_time, :end_time, :notes, :status)
  end
	
end
