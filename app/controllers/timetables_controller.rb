class TimetablesController < ApplicationController
  before_action :require_any_login

  def index
    @grade = params[:grade].present? ? params[:grade].to_i : 1

    today = Date.today
    week_offset = params[:week_offset].to_i || 0

    # week_offset を -1〜1 の範囲に制限
    week_offset = -1 if week_offset < -1
    week_offset = 1 if week_offset > 1

    @week_start = today.beginning_of_week + (week_offset * 7)

    @timetables = Timetable.includes(:subject)
                           .where(week_start_date: @week_start, grade: @grade)
                           .order(:day_of_week, :period)

    @week_offset = week_offset
  end

  private

  # 教員 or 生徒がログインしていればOK
  def require_any_login
    unless session[:role] == 'teacher' || session[:role] == 'student'
      redirect_to login_path, alert: "ログインが必要です"
    end
  end
end
