class PayGradesController < ApplicationController
  before_action :set_pay_grade, only: [:show, :edit, :update]
  before_action :check_login
	authorize_resource
	
	def index
    # get data on all shifts and paginate the output to 10 per page
    @pay_grades_active = PayGrade.active.alphabetical.paginate(page: params[:page]).per_page(10)
    @pay_grades_inactive = PayGrade.inactive.alphabetical.paginate(page: params[:page]).per_page(10)
  end

  def show
    @pay_grade_rates = @pay_grade.pay_grade_rates.chronological
	end
	
	def new
    @pay_grade = PayGrade.new
	end
	
	def edit
  end

  def create
    @pay_grade = PayGrade.new(pay_grade)
    if @pay_grade.save
      redirect_to @pay_grade, notice: "Successfully added a #{@oay_grade.level} pay grade to the system."
    else
      render action: 'new'
    end
	end

	def update
    if @pay_grade.update_attributes(pay_grade_params)
      redirect_to @pay_grade, notice: "Updated pay grade information for pay grade #{@pay_grade.id}."
    else
      render action: 'edit'
    end
	end
	
	private
  # Use callbacks to share common setup or constraints between actions.
  def set_pay_grade
    @pay_grade = PayGrade.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def pay_grade_params
    params.require(:pay_grade).permit(:level, :active)
  end
	
end