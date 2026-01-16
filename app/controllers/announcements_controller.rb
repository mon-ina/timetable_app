# app/controllers/announcements_controller.rb
class AnnouncementsController < ApplicationController
    before_action :require_any_login
    before_action :require_teacher, only: [:create]
    
    # お知らせ一覧を取得（JSON）
    def index
      grade = params[:grade].to_i
      announcements = Announcement.for_grade(grade).recent_first
      
      # 生徒の場合は未読情報も含める
      if session[:role] == 'student'
        session_id = session.id.to_s
        data = announcements.map do |announcement|
          {
            id: announcement.id,
            title: announcement.title,
            content: announcement.content,
            published_at: announcement.published_at.strftime('%Y年%m月%d日 %H:%M'),
            is_read: announcement.read_by?(session_id)
          }
        end
      else
        # 教員の場合は既読情報不要
        data = announcements.map do |announcement|
          {
            id: announcement.id,
            title: announcement.title,
            content: announcement.content,
            published_at: announcement.published_at.strftime('%Y年%m月%d日 %H:%M'),
            is_read: true
          }
        end
      end
      
      render json: { announcements: data }
    end
    
    # 未読件数を取得（JSON）
    def unread_count
      grade = params[:grade].to_i
      
      if session[:role] == 'student'
        session_id = session.id.to_s
        all_announcements = Announcement.for_grade(grade)
        read_ids = AnnouncementRead.where(
          announcement_id: all_announcements.pluck(:id),
          student_session_id: session_id
        ).pluck(:announcement_id)
        
        unread = all_announcements.count - read_ids.count
      else
        unread = 0
      end
      
      render json: { unread_count: unread }
    end
    
    # お知らせを既読にする
    def mark_as_read
      announcement = Announcement.find(params[:id])
      
      if session[:role] == 'student'
        session_id = session.id.to_s
        announcement.mark_as_read!(session_id)
      end
      
      render json: { success: true }
    end
    
    # お知らせ作成
    def create
      announcement = Announcement.new(announcement_params)
      announcement.published_at = Time.current
      
      if announcement.save
        render json: { success: true, message: 'お知らせを作成しました' }
      else
        render json: { success: false, errors: announcement.errors.full_messages }, status: :unprocessable_entity
      end
    end
    
    private
    
    def announcement_params
      params.require(:announcement).permit(:title, :content, :grade)
    end
    
    def require_any_login
      unless session[:role] == 'teacher' || session[:role] == 'student'
        redirect_to login_path, alert: "ログインが必要です"
      end
    end
    
    def require_teacher
      unless session[:role] == 'teacher'
        head :forbidden
      end
    end
  end