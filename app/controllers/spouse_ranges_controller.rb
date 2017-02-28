# -*- encoding : utf-8 -*-
class SpouseRangesController < BaseController
  before_action :find_employee, only: %w(new create truncate)
  before_action :find_spouse_range, only: %w(show edit update destroy)
  
  def index
    @spouse_ranges = @current_club.spouse_ranges.page(params[:page])
  end
  
  def new
    @spouse_range = SpouseRange.new_with_date(employee: @employee, started_at: params[:started_at], ended_at: params[:ended_at])
  end
  
  def edit
  end
  
  def create
    @spouse_range = @employee.spouse_ranges.new(spouse_range_params)
    if @spouse_range.save
      redirect_to @employee, notice: '操作成功'
    else
      render action: 'new'
    end
  end

  def destroy
    @spouse_range.destroy
    redirect_to @spouse_range.employee, notice: '操作成功'
  end
  
  def update
    if @spouse_range.update(spouse_range_params)
      redirect_to @spouse_range.employee, notice: '操作成功'
    else
      render action: 'edit'
    end
  end

  def truncate
    @employee.spouse_ranges.destroy_all
    redirect_to @employee, notice: '操作成功'
  end

  protected
    def spouse_range_params
      params.require(:spouse_range).permit!
    end

    def find_spouse_range
      @spouse_range = SpouseRange.find(params[:id])
    end

    def find_employee
      @employee = Employee.find(params[:employee_id])
    end
end