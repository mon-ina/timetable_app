# db/seeds.rb
Timetable.destroy_all
Subject.destroy_all

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

# --- デフォルト時間割データ ---
timetable_1 = [
  ["テクノロジ・ハードウェア分野Ⅰ","C言語基礎Ⅰ","WebデザインⅠ"], # 月
  ["ストラテジ分野Ⅰ","データベース技術Ⅰ","HTML・CSSⅠ"], # 火
  ["マネジメント分野Ⅰ","総合実践Ⅰ","Ruby基礎Ⅰ"], # 水
  ["グループマネジメントⅠ","カラーマネジメントⅠ","JavaScriptⅠ"], # 木
  ["国家試験対策Ⅰ","制作演習Ⅰ","ビジネススキルⅠ"] # 金
]

timetable_2 = [
  ["グループマネジメントⅡ","WebデザインⅢ","WebデザインⅣ"],
  ["JavaScriptⅡ","国家試験対策Ⅲ","総合実践Ⅲ"],
  ["PythonⅠ","制作演習Ⅱ","キャリア演習Ⅱ"],
  ["企業講演会Ⅱ","WebデザインⅢ","JavaScriptⅡ"],
  ["総合実践Ⅲ","制作演習Ⅱ","キャリア演習Ⅱ"]
]

# --- 先週・今週・来週の3週分 ---
(-1..1).each do |offset|
  week_start = Date.today.beginning_of_week(:monday) + offset.weeks

  # 1年
  (1..5).each do |day|
    (1..3).each do |period|
      Timetable.create!(
        grade: 1,
        week_start_date: week_start,
        day_of_week: day,
        period: period,
        subject: subjects_1[timetable_1[day-1][period-1]]
      )
    end
  end

  # 2年
  (1..5).each do |day|
    (1..3).each do |period|
      Timetable.create!(
        grade: 2,
        week_start_date: week_start,
        day_of_week: day,
        period: period,
        subject: subjects_2[timetable_2[day-1][period-1]]
      )
    end
  end
end

puts "✅ Seed completed! 1年科目: #{subjects_1.count}, 2年科目: #{subjects_2.count}"
