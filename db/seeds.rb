# db/seeds.rb

Subject.destroy_all
Timetable.destroy_all

# --- 1年科目 ---
subjects_1_names = [
  "テクノロジ・ハードウェア分野Ⅰ","C言語基礎Ⅰ","WebデザインⅠ",
  "ストラテジ分野Ⅰ","データベース技術Ⅰ","HTML・CSSⅠ",
  "マネジメント分野Ⅰ","総合実践Ⅰ","Ruby基礎Ⅰ",
  "グループマネジメントⅠ","カラーマネジメントⅠ","JavaScriptⅠ",
  "国家試験対策Ⅰ","制作演習Ⅰ","ビジネススキルⅠ"
]

subjects_1 = {}
subjects_1_names.each do |name|
  subjects_1[name] = Subject.find_or_create_by!(name: name)
end

# --- 2年科目 ---
subjects_2_names = [
  "グループマネジメントⅡ","WebデザインⅢ","WebデザインⅣ",
  "JavaScriptⅡ","国家試験対策Ⅲ","総合実践Ⅲ",
  "PythonⅠ","制作演習Ⅱ","キャリア演習Ⅱ","企業講演会Ⅱ"
]

subjects_2 = {}
subjects_2_names.each do |name|
  subjects_2[name] = Subject.find_or_create_by!(name: name)
end

# --- 固定の週開始日（例: 2025年10月20日） ---
week_start = Date.parse("2025-10-20").beginning_of_week

# --- 1年時間割 ---
timetable_1 = [
  ["テクノロジ・ハードウェア分野Ⅰ","C言語基礎Ⅰ","WebデザインⅠ"], # 月
  ["ストラテジ分野Ⅰ","データベース技術Ⅰ","HTML・CSSⅠ"], # 火
  ["マネジメント分野Ⅰ","総合実践Ⅰ","Ruby基礎Ⅰ"], # 水
  ["グループマネジメントⅠ","カラーマネジメントⅠ","JavaScriptⅠ"], # 木
  ["国家試験対策Ⅰ","制作演習Ⅰ","ビジネススキルⅠ"] # 金
]

(1..5).each do |day|
  (1..3).each do |period|
    subject_name = timetable_1[day-1][period-1]
    Timetable.create!(
      grade: 1,
      week_start_date: week_start,
      day_of_week: day,
      period: period,
      subject: subjects_1[subject_name]
    )
  end
end

# --- 2年時間割 ---
timetable_2 = [
  ["グループマネジメントⅡ","WebデザインⅢ","WebデザインⅣ"],
  ["JavaScriptⅡ","国家試験対策Ⅲ","総合実践Ⅲ"],
  ["PythonⅠ","制作演習Ⅱ","キャリア演習Ⅱ"],
  ["企業講演会Ⅱ","WebデザインⅢ","JavaScriptⅡ"],
  ["総合実践Ⅲ","制作演習Ⅱ","キャリア演習Ⅱ"]
]

(1..5).each do |day|
  (1..3).each do |period|
    subject_name = timetable_2[day-1][period-1]
    Timetable.create!(
      grade: 2,
      week_start_date: week_start,
      day_of_week: day,
      period: period,
      subject: subjects_2[subject_name]
    )
  end
end

puts "Seed completed! 1年科目: #{subjects_1.count}, 2年科目: #{subjects_2.count}"
