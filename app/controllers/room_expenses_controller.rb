# -*- encoding : utf-8 -*-
class RoomExpensesController < BaseController
  before_action :find_employee, only: %w(new create)
  before_action :find_room_expense, only: %w(show edit update destroy)
  
  def index
    @room_expenses = @current_club.room_expenses.page(params[:page])
  end
  
  def new
    @room_expense = RoomExpense.new
  end
  
  def edit
  end
  
  def create
    @room_expense = @employee.room_expenses.new(room_expense_params)
    if @room_expense.save
      redirect_to @employee, notice: '操作成功'
    else
      render action: 'new'
    end
  end

  def destroy
    @room_expense.destroy
    redirect_to @room_expense.employee, notice: '操作成功'
  end
  
  def update
    if @room_expense.update(room_expense_params)
      redirect_to @room_expense.employee, notice: '操作成功'
    else
      render action: 'edit'
    end
  end

  protected
    def room_expense_params
      params.require(:room_expense).permit!
    end

    def find_room_expense
      @room_expense = RoomExpense.find(params[:id])
    end

    def find_employee
      @employee = Employee.find(params[:employee_id])
    end
end