# -*- encoding : utf-8 -*-
class TitleRangesController < BaseController
  before_action :find_employee, only: %w(new create truncate)
  before_action :find_title_range, only: %w(show edit update destroy)
  
  def index
    @title_ranges = @current_club.title_ranges.page(params[:page])
  end
  
  def new
    @title_range = TitleRange.new_with_date(employee: @employee, started_at: params[:started_at], ended_at: params[:ended_at])
  end
  
  def edit
  end
  
  def create
    @title_range = @employee.title_ranges.new(title_range_params)
    if @title_range.save
      redirect_to @employee, notice: '操作成功'
    else
      render action: 'new'
    end
  end

  def destroy
    @title_range.destroy
    redirect_to @title_range.employee, notice: '操作成功'
  end
  
  def update
    if @title_range.update(title_range_params)
      redirect_to @title_range.employee, notice: '操作成功'
    else
      render action: 'edit'
    end
  end

  def truncate
    @employee.title_ranges.destroy_all
    redirect_to @employee, notice: '操作成功'
  end

  protected
    def title_range_params
      params.require(:title_range).permit!
    end

    def find_title_range
      @title_range = TitleRange.find(params[:id])
    end

    def find_employee
      @employee = Employee.find(params[:employee_id])
    end
end