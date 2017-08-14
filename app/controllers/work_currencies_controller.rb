# -*- encoding : utf-8 -*-
class WorkCurrenciesController < BaseController
  skip_before_action :check_if_work_currencies_empty, only: [:bulk_new, :bulk_create]

  def bulk_new
    @custom_form = BulkCreateWorkCurrency.new
  end

  def bulk_create
    if (@custom_form = BulkCreateWorkCurrency.new(bulk_create_work_currency_params)).valid?
      WorkCurrency.bulk_create(administrator: @current_administrator, currency_ids: @custom_form.currency_ids)
      redirect_to dashboard_path
    else
      render action: 'bulk_new'
    end
  end

  protected
    def bulk_create_work_currency_params
      params.require(:bulk_create_work_currency).permit!
    end
end