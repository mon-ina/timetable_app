# app/controllers/default_timetables_controller.rb
class DefaultTimetablesController < ApplicationController
    before_action :require_teacher
  
    def update_subject
      @default_timetable = DefaultTimetable.find(params[:id])
      
      # "-"が選択された場合はsubject_idをnilに
      subject_id = params[:subject_id].present? ? params[:subject_id] : nil
      
      @default_timetable.update(subject_id: subject_id)
      
      # デフォルト時間割を変更したら、該当する期間の既存の週の時間割も更新
      update_existing_timetables(@default_timetable, subject_id)
      
      render json: { 
        success: true, 
        subject_name: @default_timetable.subject&.name || "-"
      }
    end
  
    private
  
    def require_teacher
      unless session[:role] == 'teacher'
        redirect_to timetables_path, alert: "教員のみ編集可能です"
      end
    end
  
    def update_existing_timetables(default_timetable, subject_id)
      grade = default_timetable.grade
      semester = default_timetable.semester
      day_of_week = default_timetable.day_of_week
      period = default_timetable.period
      
      # 該当する期間（前期: 4-9月、後期: 10-3月）の全ての週の時間割を更新
      # ただし、base_subject が true（デフォルトのまま変更されていない）もののみ更新
      
      # 前期: 4-9月、後期: 10-3月
      if semester == 1
        # 前期の月
        months = [4, 5, 6, 7, 8, 9]
      else
        # 後期の月（10-12月と1-3月）
        months = [10, 11, 12, 1, 2, 3]
      end
      
      # 該当する週の時間割を取得
      timetables = Timetable.where(
        grade: grade,
        day_of_week: day_of_week,
        period: period,
        base_subject: true  # デフォルトのまま（ユーザーが変更していない）もののみ
      )
      
      # 該当する期間の週のみをフィルタリング
      timetables_to_update = timetables.select do |tt|
        months.include?(tt.week_start_date.month)
      end
      
      # 一括更新
      timetables_to_update.each do |tt|
        tt.update(subject_id: subject_id)
      end
      
      Rails.logger.info "Updated #{timetables_to_update.count} existing timetables for grade #{grade}, semester #{semester}, day #{day_of_week}, period #{period}"
    end
  end