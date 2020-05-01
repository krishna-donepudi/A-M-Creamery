class PayrollsController < ApplicationController
  def store_pay_form
    @store = Store.find(params[:id])
  end

  private
  def payroll_params
    params.require(:payroll).permit(:store_id, :start_date, :end_date)
  end

end