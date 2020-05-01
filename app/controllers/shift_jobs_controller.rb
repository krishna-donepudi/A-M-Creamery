class ShiftJobsController < ApplicationController
  before_action :set_shift_job, only: [:show, :edit, :update, :destroy]
  before_action :check_login
  authorize_resource

  def create
    @shift_job = ShiftJob.new(shift_job_params)
    if @shift_job.save
      redirect_to @shift_job.shift, notice: "Successfully added a #{@shift_job.job.name} job to shift #{@shift_job.shift.id}."
    else
      @shift = Shift.find(params[:shift_job][:shift_id])
      render action: 'new'
    end
  end

  def new
    @shift_job = ShiftJob.new
    @shift = Shift.find(params[:shift_id])
  end

  def destroy
    @shift_job.destroy
    redirect_to @shift_job.shift, notice: "Successfully removed #{@shift_job.job.name} from shift #{@shift_job.shift.id}"
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_shift_job
    @shift_job = ShiftJob.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def shift_job_params
    params.require(:shift_job).permit(:shift_id, :job_id)
  end
end