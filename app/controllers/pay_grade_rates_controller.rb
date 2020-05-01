class PayGradeRatesController < ApplicationController
  before_action :check_login
  authorize_resource
  
  def create
    @pay_grade_rate = PayGradeRate.new(pay_grade_rate_params)
    if @pay_grade_rate.save
      redirect_to @pay_grade_rate.pay_grade, notice: "Successfully added the pay grade rate."
    else
      @pay_grade = PayGrade.find(params[:pay_grade_rate][:pay_grade])
      render action: 'new'
    end
  end

	def new
    @pay_grade_rate = PayGradeRate.new
    @pay_grade = PayGrade.find(params[:pay_grade_id])
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def pay_grade_rate_params
    params.require(:pay_grade_rate).permit(:pay_grade_id, :rate, :start_date)
  end
	
  
end
