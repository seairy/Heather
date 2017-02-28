# -*- encoding : utf-8 -*-
class TravelExpensesController < BaseController
  before_action :find_employee, only: %w(new create)
  before_action :find_travel_expense, only: %w(show edit update destroy)
  
  def index
    @travel_expenses = @current_club.travel_expenses.page(params[:page])
  end
  
  def show
  end
  
  def new
    @travel_expense = TravelExpense.new
  end
  
  def edit
  end
  
  def create
    @travel_expense = @employee.travel_expenses.new(travel_expense_params)
    if @travel_expense.save
      redirect_to @employee, notice: '操作成功'
    else
      render action: 'new'
    end
  end
  
  def update
    if @travel_expense.update(travel_expense_params)
      redirect_to @travel_expense.employee, notice: '操作成功'
    else
      render action: 'edit'
    end
  end

  protected
    def travel_expense_params
      params.require(:travel_expense).permit!
    end

    def find_travel_expense
      @travel_expense = TravelExpense.find(params[:id])
    end

    def find_employee
      @employee = Employee.find(params[:employee_id])
    end
end