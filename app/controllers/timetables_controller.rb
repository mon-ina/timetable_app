class TimetablesController < ApplicationController
  #before_action :require_login

  def index
    @grade = params[:grade].present? ? params[:grade].to_i : 1

    today = Date.today
    week_offset = params[:week_offset].to_i || 0
    @week_start = today.beginning_of_week + (week_offset * 7)

    @timetables = Timetable.includes(:subject)
                           .where(week_start_date: @week_start, grade: @grade)
                           .order(:day_of_week, :period)
  end

  private

  def require_login
    redirect_to login_path unless session[:user_id]
  end
end
