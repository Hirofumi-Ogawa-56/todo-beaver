# app/controllers/tasks_controller.rb
class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_profile!
  before_action :set_task, only: %i[show edit update destroy]
  before_action :set_collections, only: %i[new create edit update]

  def index
    @view_mode = params[:view] == "calendar" ? "calendar" : "list"

    assigned_task_ids =
      TaskAssignment.where(profile_id: current_profile.id).select(:task_id)

    base_scope =
      Task.where(owner_profile_id: current_profile.id)
          .or(Task.where(id: assigned_task_ids))

    if @view_mode == "calendar"
      # ← カレンダーモードのときはこちら
      setup_calendar(base_scope)
      render :calendar
    else
      # ← それ以外（リストモード）はこれまで通り
      @tasks =
        apply_filter(base_scope)
          .includes(:team, :owner_profile, :assignees)
          .order(Arel.sql("COALESCE(tasks.due_at, tasks.created_at) ASC"))
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

    # ここで due_at 周りのエラーをチェックしておく
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
      redirect_to @task, notice: "タスクを作成しました。"
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

    # 👇 期限系のフィールドが送られてきたときだけ due_at を組み立てる
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
      redirect_to tasks_path, notice: "ステータスを更新しました。"
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
end
