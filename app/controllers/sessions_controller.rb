class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(account_name: params[:account_name])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to timetables_path, notice: "ログインしました"
    else
      flash.now[:alert] = "アカウント名またはパスワードが違います"
      render :new, status: :unprocessable_entity
    end
  end

  def guest_login
    # ゲスト（生徒）扱いとして session にroleを保存
    session[:role] = "student"
    redirect_to timetables_path, notice: "生徒としてログインしました"
  end

  def destroy
    session.delete(:user_id)
    session.delete(:role)
    redirect_to login_path, notice: "ログアウトしました"
  end
end
