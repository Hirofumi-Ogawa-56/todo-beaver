# app/controllers/works_controller.rb
class WorksController < ApplicationController
  before_action :set_work, only: %i[show edit update destroy]

  def index
    @works = current_profile.works.order(created_at: :desc)
  end

  def new
    @work = current_profile.works.build(work_type: :document)
  end

  def create
    @work = current_profile.works.build(work_params)
    if @work.save
      redirect_to works_path, notice: "ワークスを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # set_workで取得済み
  end

  def update
    if @work.update(work_params)
      redirect_to works_path, notice: "ワークスを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @work.destroy
    redirect_to works_path, notice: "ワークスを削除しました"
  end

  private

  def set_work
    @work = current_profile.works.find(params[:id])
  end

  def work_params
    params.require(:work).permit(:title, :body, :work_type, :status, :team_id)
  end
end
