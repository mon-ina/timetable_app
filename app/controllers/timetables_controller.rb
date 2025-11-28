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
    
    @timetables = Timetable.includes(:subject)
      .where(week_start_date: @week_start, grade: @grade)
      .order(:day_of_week, :period)
    
    # 学年ごとの科目リスト
    subject_names = if @grade == 1
      [
        "テクノロジ・ハードウェア分野Ⅰ","C言語基礎Ⅰ","WebデザインⅠ",
        "ストラテジ分野Ⅰ","データベース技術Ⅰ","HTML・CSSⅠ",
        "マネジメント分野Ⅰ","総合実践Ⅰ","Ruby基礎Ⅰ",
        "グループマネジメントⅠ","カラーマネジメントⅠ","JavaScriptⅠ",
        "国家試験対策Ⅰ","制作演習Ⅰ","ビジネススキルⅠ"
      ]
    else
      [
        "グループマネジメントⅡ","WebデザインⅢ","WebデザインⅣ",
        "JavaScriptⅡ","国家試験対策Ⅲ","総合実践Ⅲ",
        "PythonⅠ","制作演習Ⅱ","キャリア演習Ⅱ","企業講演会Ⅱ",
        "RailsⅠ/AndroidⅠ","RailsⅡ/AndroidⅡ"
      ]
    end
    
    @all_subjects = Subject.where(name: subject_names).order(:name)
    
    render partial: 'edit_modal', locals: { timetables: @timetables, all_subjects: @all_subjects, grade: @grade }
  end

  def update_subject
    @timetable = Timetable.find(params[:id])
    
    # "-"が選択された場合はsubject_idをnilに
    subject_id = params[:subject_id].present? ? params[:subject_id] : nil
    is_exam = params[:is_exam] == "true" || params[:is_exam] == true
    
    # 試験の場合は科目名に「【試験】」をプレフィックスとして付ける
    # base_subjectをfalseにして変更済みとマーク
    if is_exam && subject_id.present?
      # 既存の科目名を取得
      subject = Subject.find(subject_id)
      # 「【試験】科目名」という名前の科目を作成または取得
      exam_subject = Subject.find_or_create_by!(name: "【試験】#{subject.name}")
      subject_id = exam_subject.id
    end
    
    @timetable.update(
      subject_id: subject_id,
      base_subject: false  # 変更されたのでfalseに
    )
    
    # 試験かどうかを科目名から判断
    is_exam_result = @timetable.subject&.name&.start_with?("【試験】") || false
    
    render json: { 
      success: true, 
      subject_name: @timetable.subject&.name || "-",
      is_changed: !@timetable.base_subject,
      is_exam: is_exam_result
    }
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

  # デフォルトの時間割を作成
  def create_default_timetable(week_start, grade)
    # デフォルト時間割データ
    timetable_data = if grade == 1
      [
        ["テクノロジ・ハードウェア分野Ⅰ","C言語基礎Ⅰ","WebデザインⅠ"], # 月
        ["ストラテジ分野Ⅰ","データベース技術Ⅰ","HTML・CSSⅠ"], # 火
        ["マネジメント分野Ⅰ","総合実践Ⅰ","Ruby基礎Ⅰ"], # 水
        ["グループマネジメントⅠ","カラーマネジメントⅠ","JavaScriptⅠ"], # 木
        ["国家試験対策Ⅰ","制作演習Ⅰ"] # 金
      ]
    else
      [
        ["グループマネジメントⅡ","WebデザインⅢ","WebデザインⅣ"],
        ["JavaScriptⅡ","国家試験対策Ⅲ","総合実践Ⅲ"],
        ["PythonⅠ","制作演習Ⅱ","キャリア演習Ⅱ"],
        ["企業講演会Ⅱ","WebデザインⅢ","JavaScriptⅡ"],
        ["RailsⅠ/AndroidⅠ","RailsⅠ/AndroidⅠ"]
      ]
    end

    # 科目を取得
    subject_names = if grade == 1
      [
        "テクノロジ・ハードウェア分野Ⅰ","C言語基礎Ⅰ","WebデザインⅠ",
        "ストラテジ分野Ⅰ","データベース技術Ⅰ","HTML・CSSⅠ",
        "マネジメント分野Ⅰ","総合実践Ⅰ","Ruby基礎Ⅰ",
        "グループマネジメントⅠ","カラーマネジメントⅠ","JavaScriptⅠ",
        "国家試験対策Ⅰ","制作演習Ⅰ","ビジネススキルⅠ"
      ]
    else
      [
        "グループマネジメントⅡ","WebデザインⅢ","WebデザインⅣ",
        "JavaScriptⅡ","国家試験対策Ⅲ","総合実践Ⅲ",
        "PythonⅠ","制作演習Ⅱ","キャリア演習Ⅱ","企業講演会Ⅱ",
        "RailsⅠ/AndroidⅠ","RailsⅡ/AndroidⅡ"
      ]
    end

    subjects = {}
    subject_names.each do |name|
      subjects[name] = Subject.find_or_create_by!(name: name)
    end

    # 時間割を作成
    (1..5).each do |day|
      timetable_data[day-1].each_with_index do |subject_name, index|
        Timetable.create!(
          grade: grade,
          week_start_date: week_start,
          day_of_week: day,
          period: index + 1,
          subject: subjects[subject_name],
          base_subject: true
        )
      end
    end

    Rails.logger.info "Created default timetable for week: #{week_start}, grade: #{grade}"
  end
end