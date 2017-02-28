# -*- encoding : utf-8 -*-
class SessionsController < BaseController
  skip_before_filter :authenticate
  layout null: true

  def new
  end

  def create
    begin
      administrator = Administrator.authenticate(club: @current_club, account: params[:account], password: params[:password])
      session[:administrator] = { id: administrator.id, name: administrator.name }
      redirect_to dashboard_path
    rescue AccountDoesNotExist
      redirect_to sign_in_path, alert: '账号不存在，请重试'
    rescue ProhibitedOperator
      redirect_to sign_in_path, alert: '账号被禁用，无法登录'
    rescue IncorrectPassword
      redirect_to sign_in_path, alert: '密码不正确，请重试'
    end
  end

  def destroy
    session[:administrator] = nil
    redirect_to sign_in_path
  end
end
