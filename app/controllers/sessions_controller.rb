class SessionsController < ApplicationController
  def new
  end

  def create
    # 教員ログインのみ
    user = User.find_by(account_name: params[:account_name])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      session[:role] = user.role
      redirect_to timetables_path
    else
      flash.now[:alert] = "アカウント名orパスワードが間違っています"
      render :new
    end
  end

  def guest_login
    # 生徒用ゲストログイン
    session[:user_id] = nil
    session[:role] = 'student'
    redirect_to timetables_path
  end

  def destroy
    session[:user_id] = nil
    session[:role] = nil
    redirect_to login_path
  end
end
