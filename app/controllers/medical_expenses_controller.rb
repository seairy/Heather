# -*- encoding : utf-8 -*-
class MedicalExpensesController < BaseController
  before_action :find_employee, only: %w(new create)
  before_action :find_medical_expense, only: %w(show edit update destroy)
  
  def index
    @medical_expenses = @current_club.medical_expenses.page(params[:page])
  end
  
  def show
  end
  
  def new
    @medical_expense = MedicalExpense.new
  end
  
  def edit
  end
  
  def create
    @medical_expense = @employee.medical_expenses.new(medical_expense_params)
    if @medical_expense.save
      redirect_to @employee, notice: '操作成功'
    else
      render action: 'new'
    end
  end
  
  def update
    if @medical_expense.update(medical_expense_params)
      redirect_to @employee, notice: '操作成功'
    else
      render action: 'edit'
    end
  end

  protected
    def medical_expense_params
      params.require(:medical_expense).permit!
    end

    def find_medical_expense
      @medical_expense = MedicalExpense.find(params[:id])
    end

    def find_employee
      @employee = Employee.find(params[:employee_id])
    end
end