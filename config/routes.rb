Rails.application.routes.draw do
  # ログイン関連
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  post "guest_login", to: "sessions#guest_login"
  delete "logout", to: "sessions#destroy"

  # ルートパス
  root "sessions#new"

  # 時間割
  resources :timetables, only: [:index] do
    collection do
      get :edit_modal
      get :edit_default_modal  # デフォルト時間割編集モーダル
    end
    member do
      patch :update_subject
    end
  end
  
  # デフォルト時間割
  resources :default_timetables, only: [] do
    member do
      patch :update_subject  # デフォルト時間割の科目更新
    end
  end
  
  # お知らせ
  resources :announcements, only: [:index, :create] do
    collection do
      get :unread_count
    end
    member do
      post :mark_as_read
    end
  end
end