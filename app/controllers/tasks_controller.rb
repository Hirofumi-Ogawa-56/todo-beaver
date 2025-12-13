# app/controllers/tasks_controller.rb
class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_profile!
  before_action :set_task, only: %i[show edit update destroy]
  before_action :set_collections, only: %i[new create edit update]

  def index
    @view_mode = params[:view] == "calendar" ? "calendar" : "list"
    @all_profiles_mode = (params[:all_profiles] == "1")

    if @all_profiles_mode
      profile_ids = current_user.profiles.pluck(:id)

      assigned_task_ids =
        TaskAssignment.where(profile_id: profile_ids).select(:task_id)

      base_scope =
        Task.where(owner_profile_id: profile_ids)
            .or(Task.where(id: assigned_task_ids))
    else
      assigned_task_ids =
        TaskAssignment.where(profile_id: current_profile.id).select(:task_id)

      base_scope =
        Task.where(owner_profile_id: current_profile.id)
            .or(Task.where(id: assigned_task_ids))
    end

    if @view_mode == "calendar"
      setup_calendar(base_scope)
      render :calendar
    else
      @query = params[:q].to_s

      rel = apply_filter(base_scope)
      rel = rel.keyword_search(@query) if @query.present?
      rel = apply_column_filters(rel)

      @tasks =
        rel
          .includes(:team, :owner_profile, :assignees)
          .order(build_order_clause)
          .page(params[:page])
          .per(50)

      respond_to do |format|
        format.html          # 初回表示 / 通常遷移
        format.turbo_stream  # もっと見る用（.turbo_stream を付けて叩く）
      end
    end
  end

  def slot_tasks
    # date と hour は +N バッジ側からパラメータでもらう想定
    date =
      begin
        Date.parse(params[:date])
      rescue ArgumentError
        Time.zone.today.to_date
      end

    hour = params[:hour].to_i

    assigned_task_ids =
      TaskAssignment.where(profile_id: current_profile.id).select(:task_id)

    base_scope =
      Task.where(owner_profile_id: current_profile.id)
          .or(Task.where(id: assigned_task_ids))

    # その日のタスクだけざっくり絞る
    day_start = date.beginning_of_day.in_time_zone
    day_end   = date.end_of_day.in_time_zone

    tasks_for_day =
      base_scope
        .where(due_at: day_start..day_end)
        .includes(:team, :owner_profile, :assignees)

    # カレンダーと同じルール:
    # display_time = due_at - 1.hour の「時」が指定 hour と一致するもの
    @tasks_in_slot =
      tasks_for_day.select do |task|
        next false if task.due_at.blank?

        display_time = task.due_at - 1.hour
        display_time.hour == hour
      end

    @slot_date = date
    @slot_hour = hour

    # side-panel の turbo_frame に埋め込む想定なので layout なしでOK
    render layout: false
  end

  def show
  end

  def new
    tomorrow = 1.day.from_now.to_date

    @task = Task.new(
      status: :todo
    )

    @task.due_date = tomorrow
    @task.due_time = "23:30"

    @task.assignee_ids = [ current_profile.id ]
  end

  def create
    @task = Task.new(task_params)
    @task.owner_profile = current_profile
    @task.team          ||= current_profile.teams.first

    build_due_at_from_virtual_fields(@task)

    if @task.errors.any?
      set_collections
      render :new, status: :unprocessable_entity
      return
    end

    Task.transaction do
      if @task.save
        @task.update_tags_from_list!
      end
    end

    if @task.errors.empty?
      # ★ ここを変更
      redirect_to tasks_path, notice: "タスクを作成しました。"
    else
      set_collections
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    if @task.due_at.present?
      @task.due_date ||= @task.due_at.to_date
      @task.due_time ||= @task.due_at.strftime("%H:%M")
    end
  end

  def update
    @task.assign_attributes(task_params)

    # 期限系のフィールドが送られてきたときだけ due_at を組み立てる
    if task_params.key?(:due_date) || task_params.key?(:due_time)
      build_due_at_from_virtual_fields(@task)

      if @task.errors.any?
        set_collections
        render :edit, status: :unprocessable_entity
        return
      end
    end

    Task.transaction do
      if @task.save
        # tag_list が送られてきたときだけタグ再作成（一覧からの status 更新では呼ばれない）
        @task.update_tags_from_list! if task_params.key?(:tag_list)
      end
    end

    if @task.errors.empty?
      # ★ ここで分岐させる
      if turbo_frame_request?
        # ライトパネルからの更新 → そのままタスク詳細をライトパネルに表示
        redirect_to task_path(@task), notice: "タスクを更新しました。"
      else
        # 通常のページ（一覧など）からの更新 → 一覧へ戻る
        redirect_to tasks_path, notice: "タスクを更新しました。"
      end
    else
      set_collections
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    unless current_profile.teams.exists?(id: @task.team_id)
      redirect_to tasks_path, alert: "このタスクを削除する権限がありません。"
      return
    end

    @task.destroy
    redirect_to tasks_path, notice: "タスクを削除しました。"
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def set_collections
    @teams = current_profile.teams.order(:name)

    @assignee_candidates =
      Profile.joins(:team_memberships)
             .where(team_memberships: { team_id: @teams.ids })
             .distinct
             .order(:display_name, :label)
  end

  def task_params
    params.require(:task).permit(
      :title,
      :description,
      :status,
      :due_date,
      :due_time,
      :tag_list,
      assignee_ids: []
    )
  end

  def build_due_at_from_virtual_fields(task)
    date_str = task.due_date.presence
    time_str = task.due_time.presence

    if date_str.blank? && time_str.blank?
      task.due_at = nil
      return
    end

    if date_str.blank? || time_str.blank?
      task.errors.add(:base, "期限日と時間は両方入力するか、両方空にしてください")
      return
    end

    unless time_str =~ /\A\d{1,2}:(00|30)\z/
      task.errors.add(:due_time, "は 30分単位で HH:MM 形式で入力してください（例: 09:00, 13:30）")
      return
    end

    begin
      task.due_at = Time.zone.parse("#{date_str} #{time_str}")
    rescue ArgumentError
      task.errors.add(:base, "期限の形式が正しくありません")
    end
  end

  def apply_filter(scope)
    case params[:filter]
    when "today"
      scope.where(due_at: Time.current.all_day)
    when "this_week"
      scope.where(
        due_at: Time.current.beginning_of_week..Time.current.end_of_week
      )
    when "incomplete"
      scope.where.not(status: Task.statuses[:done])
    when "done"
      scope.done
    else
      scope
    end
  end

  def setup_calendar(scope)
    # ▼ 基準日（?date=YYYY-MM-DD があればそれ、なければ今日）
    @base_date =
      begin
        params[:date].present? ? Date.parse(params[:date]) : Time.zone.today.to_date
      rescue ArgumentError
        Time.zone.today.to_date
      end

    # ▼ 週の開始・終了（ここでは月曜はじまり）
    @week_start = @base_date.beginning_of_week(:monday)
    @week_end   = @week_start + 6.days

    # ビューで使う配列
    @calendar_days = (@week_start..@week_end).to_a

    # ▼ 時間軸（とりあえず 8:00〜23:00）
    @hours = (8..23).to_a

    # ▼ この週に「期限がある」タスクだけ取得
    @tasks_for_calendar =
      scope
        .where(due_at: @week_start.beginning_of_day..@week_end.end_of_day)
        .includes(:team, :owner_profile, :assignees)

    # ▼ [日付][時間] => [タスク...] なハッシュ
    slots = {}
    @calendar_days.each do |date|
      slots[date] = {}
      @hours.each { |h| slots[date][h] = [] }
    end

    @tasks_for_calendar.each do |task|
      next unless task.due_at

      date = task.due_at.to_date
      hour = task.due_at.hour

      next unless slots[date] && slots[date][hour]

      slots[date][hour] << task
    end

    @calendar_slots = slots
  end

  def apply_column_filters(scope)
    rel = scope

    # タイトルフィルタ
    if params[:title_contains].present?
      rel = rel.where("tasks.title ILIKE ?", "%#{params[:title_contains]}%")
    end

    # 期限フィルタ（特定の日付だけを表示）
    if params[:due_on].present?
      begin
        date = Date.parse(params[:due_on])
        rel = rel.where(due_at: date.beginning_of_day..date.end_of_day)
      rescue ArgumentError
        # 不正な日付は無視（何もしない）
      end
    end

    # ステータスフィルタ（自由記入：todo / in / done など部分一致）
    if params[:status_keyword].present?
      keyword = params[:status_keyword].to_s

      matched_keys =
        Task.statuses.keys.select { |k| k.include?(keyword) }

      if matched_keys.any?
        rel = rel.where(status: Task.statuses.values_at(*matched_keys))
      else
        # 何もマッチしない → 結果0件
        rel = rel.none
      end
    end

    # 担当者フィルタ（display_name 部分一致）
    if params[:assignee_keyword].present?
      profile_ids =
        Profile.where("display_name ILIKE ?", "%#{params[:assignee_keyword]}%")
               .pluck(:id)

      if profile_ids.any?
        task_ids =
          TaskAssignment.where(profile_id: profile_ids).select(:task_id)
        rel = rel.where(id: task_ids)
      else
        rel = rel.none
      end
    end

    # 作成者フィルタ（display_name 部分一致）
    if params[:owner_keyword].present?
      profile_ids =
        Profile.where("display_name ILIKE ?", "%#{params[:owner_keyword]}%")
               .pluck(:id)

      if profile_ids.any?
        rel = rel.where(owner_profile_id: profile_ids)
      else
        rel = rel.none
      end
    end

    rel
  end

  # ソート条件を組み立てる
  def build_order_clause
    # どのカラムでソートするか（許可リスト）
    column =
    case params[:sort]
    when "title"
        "tasks.title"
    when "due_at"
        "tasks.due_at"
    when "status"
        "tasks.status"
    when "owner"
        # 作成者（owner_profile の display_name）
        "(SELECT display_name FROM profiles " \
          "WHERE profiles.id = tasks.owner_profile_id LIMIT 1)"
    when "assignee"
        # 担当者（複数いる場合は一番小さい名前で代表させる）
        "(SELECT MIN(p.display_name) FROM task_assignments ta " \
          "JOIN profiles p ON p.id = ta.profile_id " \
          "WHERE ta.task_id = tasks.id)"
    else
        "tasks.due_at"  # デフォルト
    end

    # 昇順 or 降順（パラメータが変な値なら ASC に倒す）
    direction = params[:direction] == "desc" ? "DESC" : "ASC"

    # ついでに created_at も第2キーにしておくと安定
    Arel.sql("#{column} #{direction}, tasks.created_at ASC")
  end
end
