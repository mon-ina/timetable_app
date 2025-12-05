# db/seeds.rb
Timetable.destroy_all
Subject.destroy_all
DefaultTimetable.destroy_all

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
  "PythonⅠ","制作演習Ⅱ","キャリア演習Ⅱ","企業講演会Ⅱ",
  "RailsⅠ/AndroidⅠ","RailsⅡ/AndroidⅡ"
]

subjects_2 = {}
subjects_2_names.each do |name|
  subjects_2[name] = Subject.find_or_create_by!(name: name)
end

# --- デフォルト時間割データ ---
default_timetables = {
  # 1年前期
  1 => {
    1 => [
      ["テクノロジ・ハードウェア分野Ⅰ","C言語基礎Ⅰ","WebデザインⅠ"], # 月
      ["ストラテジ分野Ⅰ","データベース技術Ⅰ","HTML・CSSⅠ"], # 火
      ["マネジメント分野Ⅰ","総合実践Ⅰ","Ruby基礎Ⅰ"], # 水
      ["グループマネジメントⅠ","カラーマネジメントⅠ","JavaScriptⅠ"], # 木
      ["国家試験対策Ⅰ","制作演習Ⅰ"] # 金
    ],
    # 1年後期
    2 => [
      ["テクノロジ・ハードウェア分野Ⅰ","C言語基礎Ⅰ","WebデザインⅠ"], # 月
      ["ストラテジ分野Ⅰ","データベース技術Ⅰ","HTML・CSSⅠ"], # 火
      ["マネジメント分野Ⅰ","総合実践Ⅰ","Ruby基礎Ⅰ"], # 水
      ["グループマネジメントⅠ","カラーマネジメントⅠ","JavaScriptⅠ"], # 木
      ["Ruby基礎Ⅰ","Ruby基礎Ⅰ"] # 金
    ]
  },
  # 2年前期
  2 => {
    1 => [
      ["グループマネジメントⅡ","WebデザインⅢ","WebデザインⅣ"],
      ["JavaScriptⅡ","国家試験対策Ⅲ","総合実践Ⅲ"],
      ["PythonⅠ","制作演習Ⅱ","キャリア演習Ⅱ"],
      ["企業講演会Ⅱ","WebデザインⅢ","JavaScriptⅡ"],
      ["RailsⅠ/AndroidⅠ","RailsⅠ/AndroidⅠ"]
    ],
    # 2年後期
    2 => [
      ["グループマネジメントⅡ","WebデザインⅢ","WebデザインⅣ"],
      ["JavaScriptⅡ","国家試験対策Ⅲ","総合実践Ⅲ"],
      ["PythonⅠ","制作演習Ⅱ","キャリア演習Ⅱ"],
      ["企業講演会Ⅱ","WebデザインⅢ","JavaScriptⅡ"],
      ["RailsⅡ/AndroidⅡ","RailsⅡ/AndroidⅡ"]
    ]
  }
}

# デフォルト時間割を作成
[1, 2].each do |grade|
  [1, 2].each do |semester|
    timetable_data = default_timetables[grade][semester]
    subjects = grade == 1 ? subjects_1 : subjects_2
    
    (1..5).each do |day|
      timetable_data[day-1].each_with_index do |subject_name, index|
        DefaultTimetable.create!(
          grade: grade,
          semester: semester,
          day_of_week: day,
          period: index + 1,
          subject: subjects[subject_name]
        )
      end
    end
  end
end

puts "✅ Seed completed!"
puts "✅ 1年科目: #{subjects_1.count}, 2年科目: #{subjects_2.count}"
puts "✅ デフォルト時間割: #{DefaultTimetable.count}件"