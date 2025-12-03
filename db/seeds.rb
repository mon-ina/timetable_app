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
  "PythonⅠ","制作演習Ⅱ","キャリア演習Ⅱ","企業講演会Ⅱ",
  "RailsⅠ/AndroidⅠ","RailsⅡ/AndroidⅡ"
]

subjects_2 = {}
subjects_2_names.each do |name|
  subjects_2[name] = Subject.find_or_create_by!(name: name)
end

# --- デフォルト時間割データ ---
timetable_first_half_1 = [
  ["テクノロジ・ハードウェア分野Ⅰ","C言語基礎Ⅰ","WebデザインⅠ"], # 月
  ["ストラテジ分野Ⅰ","データベース技術Ⅰ","HTML・CSSⅠ"], # 火
  ["マネジメント分野Ⅰ","総合実践Ⅰ","Ruby基礎Ⅰ"], # 水
  ["グループマネジメントⅠ","カラーマネジメントⅠ","JavaScriptⅠ"], # 木
  ["国家試験対策Ⅰ","制作演習Ⅰ"] # 金
]

timetable_last_half_1 = [
  ["テクノロジ・ハードウェア分野Ⅰ","C言語基礎Ⅰ","WebデザインⅠ"], # 月
  ["ストラテジ分野Ⅰ","データベース技術Ⅰ","HTML・CSSⅠ"], # 火
  ["マネジメント分野Ⅰ","総合実践Ⅰ","Ruby基礎Ⅰ"], # 水
  ["グループマネジメントⅠ","カラーマネジメントⅠ","JavaScriptⅠ"], # 木
  ["Ruby基礎Ⅰ","Ruby基礎Ⅰ"] # 金
]

timetable_first_half_2 = [
  ["グループマネジメントⅡ","WebデザインⅢ","WebデザインⅣ"],
  ["JavaScriptⅡ","国家試験対策Ⅲ","総合実践Ⅲ"],
  ["PythonⅠ","制作演習Ⅱ","キャリア演習Ⅱ"],
  ["企業講演会Ⅱ","WebデザインⅢ","JavaScriptⅡ"],
  ["RailsⅠ/AndroidⅠ","RailsⅠ/AndroidⅠ"]
]

timetable_last_half_2 = [
  ["グループマネジメントⅡ","WebデザインⅢ","WebデザインⅣ"],
  ["JavaScriptⅡ","国家試験対策Ⅲ","総合実践Ⅲ"],
  ["PythonⅠ","制作演習Ⅱ","キャリア演習Ⅱ"],
  ["企業講演会Ⅱ","WebデザインⅢ","JavaScriptⅡ"],
  ["RailsⅡ/AndroidⅡ","RailsⅡ/AndroidⅡ"]
]

# --- 先週・今週・来週の3週分のデータを作成（前期・後期は作成時に判定） ---
# このseedは初期データ作成用なので、ここでは作成しない
# 実際のデータはコントローラーで週ごとに自動生成される

puts "✅ Seed completed! 1年科目: #{subjects_1.count}, 2年科目: #{subjects_2.count}"