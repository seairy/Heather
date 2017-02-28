# -*- encoding : utf-8 -*-
class EmployeesController < BaseController
  before_action :find_employee, only: %w(show edit update destroy payroll)
  
  def index
    @employees = Employee.order(created_at: :desc).page(params[:page])
  end
  
  def show
  end
  
  def new
    @employee = Employee.new
  end
  
  def edit
  end
  
  def create
    @employee = Employee.new(employee_params)
    if @employee.save
      redirect_to @employee, notice: '操作成功'
    else
      render action: 'new'
    end
  end
  
  def update
    if @employee.update(employee_params)
      redirect_to @employee, notice: '操作成功'
    else
      render action: 'edit'
    end
  end

  def destroy
    @employee.destroy
    redirect_to employees_path, notice: '操作成功'
  end

  def payroll
  end

  protected
    def employee_params
      params.require(:employee).permit!
    end

    def find_employee
      @employee = Employee.find(params[:id])
    end
end