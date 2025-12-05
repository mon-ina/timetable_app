# app/controllers/timetables_controller.rb
class TimetablesController < ApplicationController
  before_action :require_any_login
  before_action :require_teacher, only: [:edit_modal, :update_subject]

  def index
    @grade = params[:grade].present? ? params[:grade].to_i : 1

    today = Date.today
    week_offset = params[:week_offset].to_i || 0

    # week_offset を -1〜1 の範囲に制限
    week_offset = -1 if week_offset < -1
    week_offset = 1 if week_offset > 1

    @week_start = today.beginning_of_week + (week_offset * 7)

    # その週のデータを取得
    @timetables = Timetable.includes(:subject)
      .where(week_start_date: @week_start, grade: @grade)
      .order(:day_of_week, :period)
    
    # データが無ければデフォルトの時間割を作成
    if @timetables.empty?
      create_default_timetable(@week_start, @grade)
      @timetables = Timetable.includes(:subject)
        .where(week_start_date: @week_start, grade: @grade)
        .order(:day_of_week, :period)
    end
    
    @week_offset = week_offset
  end

  def edit_modal
    @grade = params[:grade].to_i
    @week_offset = params[:week_offset].to_i
    
    today = Date.today
    @week_start = today.beginning_of_week + (@week_offset * 7)
    
    Rails.logger.info "=" * 50
    Rails.logger.info "Edit modal - Week start: #{@week_start}, Grade: #{@grade}"
    
    @timetables = Timetable.includes(:subject)
      .where(week_start_date: @week_start, grade: @grade)
      .order(:day_of_week, :period)
    
    Rails.logger.info "Found #{@timetables.count} timetables"
    
    # データが無ければデフォルトの時間割を作成
    if @timetables.empty?
      Rails.logger.info "Creating default timetable..."
      create_default_timetable(@week_start, @grade)
      @timetables = Timetable.includes(:subject)
        .where(week_start_date: @week_start, grade: @grade)
        .order(:day_of_week, :period)
      Rails.logger.info "Created #{@timetables.count} timetables"
    end
    
    @timetables.each do |t|
      Rails.logger.info "  Day: #{t.day_of_week}, Period: #{t.period}, Subject: #{t.subject&.name}, Changed: #{!t.base_subject}"
    end
    Rails.logger.info "=" * 50
    
    # 学年ごとの科目リスト
    subject_names = if @grade == 1
      [
        "-",
        "テクノロジ・ハードウェア分野Ⅰ","C言語基礎Ⅰ","WebデザインⅠ",
        "ストラテジ分野Ⅰ","データベース技術Ⅰ","HTML・CSSⅠ",
        "マネジメント分野Ⅰ","総合実践Ⅰ","Ruby基礎Ⅰ",
        "グループマネジメントⅠ","カラーマネジメントⅠ","JavaScriptⅠ",
        "国家試験対策Ⅰ","制作演習Ⅰ","ビジネススキルⅠ"
      ]
    else
      [
        "-",
        "グループマネジメントⅡ","WebデザインⅢ","WebデザインⅣ",
        "JavaScriptⅡ","国家試験対策Ⅲ","総合実践Ⅲ",
        "PythonⅠ","制作演習Ⅱ","キャリア演習Ⅱ","企業講演会Ⅱ",
        "RailsⅠ/AndroidⅠ","RailsⅡ/AndroidⅡ"
      ]
    end
    
    # "-" 以外の科目だけSubjectから取得
    @all_subjects = Subject.where(name: subject_names.reject { |n| n == "-" }).order(:name)
    
    render partial: 'edit_modal', locals: { timetables: @timetables, all_subjects: @all_subjects, grade: @grade }
  end
  
  def update_subject
    @timetable = Timetable.find(params[:id])
    
    # "-"が選択された場合はsubject_idをnilに
    subject_id = params[:subject_id].present? ? params[:subject_id] : nil
    is_exam = params[:is_exam] == "true" || params[:is_exam] == true
    
    # 試験の場合は科目名に「【試験】」をプレフィックスとして付ける
    if is_exam && subject_id.present?
      subject = Subject.find(subject_id)
      exam_subject = Subject.find_or_create_by!(name: "【試験】#{subject.name}")
      subject_id = exam_subject.id
    end
    
    @timetable.update(
      subject_id: subject_id,
      base_subject: false
    )
    
    is_exam_result = @timetable.subject&.name&.start_with?("【試験】") || false
    
    render json: { 
      success: true, 
      subject_name: @timetable.subject&.name || "-",
      is_changed: !@timetable.base_subject,
      is_exam: is_exam_result
    }
  end

  def edit_default_modal
    @grade = params[:grade].to_i
    @semester = params[:semester].to_i # 1: 前期, 2: 後期
    
    @default_timetables = DefaultTimetable.includes(:subject)
      .where(grade: @grade, semester: @semester)
      .order(:day_of_week, :period)
    
    # 学年ごとの科目リスト
    subject_names = if @grade == 1
      [
        "-",
        "テクノロジ・ハードウェア分野Ⅰ","C言語基礎Ⅰ","WebデザインⅠ",
        "ストラテジ分野Ⅰ","データベース技術Ⅰ","HTML・CSSⅠ",
        "マネジメント分野Ⅰ","総合実践Ⅰ","Ruby基礎Ⅰ",
        "グループマネジメントⅠ","カラーマネジメントⅠ","JavaScriptⅠ",
        "国家試験対策Ⅰ","制作演習Ⅰ","ビジネススキルⅠ"
      ]
    else
      [
        "-",
        "グループマネジメントⅡ","WebデザインⅢ","WebデザインⅣ",
        "JavaScriptⅡ","国家試験対策Ⅲ","総合実践Ⅲ",
        "PythonⅠ","制作演習Ⅱ","キャリア演習Ⅱ","企業講演会Ⅱ",
        "RailsⅠ/AndroidⅠ","RailsⅡ/AndroidⅡ"
      ]
    end
    
    @all_subjects = Subject.where(name: subject_names.reject { |n| n == "-" }).order(:name)
    
    render partial: 'edit_default_modal', locals: { 
      default_timetables: @default_timetables, 
      all_subjects: @all_subjects, 
      grade: @grade,
      semester: @semester
    }
  end
end

  private

  # 教員 or 生徒がログインしていればOK
  def require_any_login
    unless session[:role] == 'teacher' || session[:role] == 'student'
      redirect_to login_path, alert: "ログインが必要です"
    end
  end

  # 教員のみ
  def require_teacher
    unless session[:role] == 'teacher'
      redirect_to timetables_path, alert: "教員のみ編集可能です"
    end
  end

  # デフォルトの時間割を作成（前期・後期を自動判定）
  def create_default_timetable(week_start, grade)
    # 4月〜9月は前期、10月〜3月は後期
    is_first_half = week_start.month >= 4 && week_start.month <= 9
    semester = is_first_half ? 1 : 2
    
    # デフォルト時間割から取得
    default_timetables = DefaultTimetable.where(grade: grade, semester: semester)
    
    default_timetables.each do |default_tt|
      Timetable.create!(
        grade: grade,
        week_start_date: week_start,
        day_of_week: default_tt.day_of_week,
        period: default_tt.period,
        subject: default_tt.subject,
        base_subject: true
      )
    end
    
    semester_name = is_first_half ? "前期" : "後期"
    Rails.logger.info "Created timetable from defaults (#{semester_name}) for week: #{week_start}, grade: #{grade}"
  end

  