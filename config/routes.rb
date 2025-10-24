Rails.application.routes.draw do
  # ログイン関係
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  post 'guest_login', to: 'sessions#guest_login'
  delete 'logout', to: 'sessions#destroy'

  # 時間割（閲覧用）
  resources :timetables, only: [:index]

  # 科目（教員用編集）
  resources :subjects, only: [:new, :create, :edit, :update, :destroy]

  # トップページを時間割に
  root 'timetables#index'
end
