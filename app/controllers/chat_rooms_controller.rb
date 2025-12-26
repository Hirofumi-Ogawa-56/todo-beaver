# app/controllers/chat_rooms_controller.rb
class ChatRoomsController < ApplicationController
  before_action :set_chat_room, only: %i[show edit update]

  def index
    @chat_rooms = current_profile.chat_rooms.order(updated_at: :desc)
  end

  def show
    @chat_rooms = current_profile.chat_rooms.order(updated_at: :desc)
    @messages = @chat_room.messages.includes(:author_profile, :reactions).order(created_at: :asc)
    @new_message = @chat_room.messages.build
  end

  def new
    @chat_room = ChatRoom.new
    set_selection_candidates

    # チーム管理画面と同じ仕組み：クエリパラメータがあれば検索する
    if params[:invite_token].present?
      @found_profile = Profile.find_by(join_token: params[:invite_token])
    end
  end

  def search_profile
    @profile = Profile.find_by(join_token: params[:invite_token])
    respond_to do |format|
      format.turbo_stream
    end
  end

  def create
      @chat_room = ChatRoom.new(chat_room_params)
      @chat_room.creator_profile = current_profile

      # 1. 保存とメンバー登録を一気に試行
      success = ChatRoom.transaction do
        @chat_room.save!
        # 自分をメンバーに追加
        @chat_room.chat_members.create!(profile: current_profile)

        # 招待メンバー（チェックボックス + ID検索）を合算
        all_invited_ids = [ params[:profile_ids], params[:searched_profile_ids] ].flatten.compact.uniq
        all_invited_ids.each do |p_id|
          @chat_room.chat_members.create!(profile_id: p_id)
        end
        true
      end rescue false # save! 等で失敗した場合は false を返す

      # 2. 結果に応じたレスポンス
      if success
        respond_to do |format|
          format.turbo_stream do
            set_selection_candidates
            render turbo_stream: [
              turbo_stream.append("side-panel-frame", "<script>window.top.location.href='#{chat_room_path(@chat_room)}'</script>"),
              turbo_stream.replace("side-panel-frame", partial: "chat_rooms/form", locals: { chat_room: @chat_room })
            ]
          end
          format.html { redirect_to chat_room_path(@chat_room), notice: "ルームを作成しました" }
        end
      else
        set_selection_candidates
        render :new, status: :unprocessable_entity
      end
    end

  def edit
    set_selection_candidates
  end

  def update
      if @chat_room.update(chat_room_params)
        # 成功時に必要なデータを再取得
        set_selection_candidates

        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              # locals で明示的に変数を渡すことで、_form 内の @team_members の nil エラーを防ぎます
              turbo_stream.replace("side-panel-frame",
                partial: "chat_rooms/form",
                locals: {
                  chat_room: @chat_room,
                  team_members: @team_members,
                  past_contacts: @past_contacts
                }
              ),
              turbo_stream.append("side-panel-frame", "<script>window.top.location.href='#{chat_room_path(@chat_room)}'</script>")
            ]
          end
          format.html { redirect_to chat_room_path(@chat_room), notice: "更新しました" }
        end
      else
        set_selection_candidates
        render :edit, status: :unprocessable_entity
      end
    end

  private

  def set_selection_candidates
    # チームメンバー：重複を排除し、チーム情報を一括取得
    @team_members = Profile.joins(:team_memberships)
                          .where(team_memberships: { team_id: current_profile.teams.pluck(:id) })
                          .where.not(id: current_profile.id)
                          .includes(:primary_team, :teams) # 所属表示のためのプリロード
                          .distinct

    # 過去のコンタクト：チームメンバー以外
    my_room_ids = current_profile.chat_members.pluck(:chat_room_id)
    @past_contacts = Profile.joins(:chat_members)
                            .where(chat_members: { chat_room_id: my_room_ids })
                            .where.not(id: current_profile.id)
                            .where.not(id: @team_members.pluck(:id))
                            .includes(:primary_team, :teams)
                            .distinct
  end

  def set_chat_room
    @chat_room = current_profile.chat_rooms.find_by(id: params[:id])
    redirect_to chat_rooms_path if @chat_room.nil?
  end

  def chat_room_params
    params.require(:chat_room).permit(:name, :description, :avatar, profile_ids: [])
  end
end
