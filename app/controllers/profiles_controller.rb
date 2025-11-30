# app/controllers/profiles_controller.rb
class ProfilesController < ApplicationController
  # 　全アクションの前に行うログインチェック。
  # 未ログインなら Devise がログイン画面へリダイレクトする。
  before_action :authenticate_user!

  # show, edit, update, destroy アクションの前だけ、共通処理として set_profile を実行する。
  # 対象となる @profile を事前に取得しておくためのフック。
  before_action :set_profile, only: %i[show edit update destroy]

  # switchだけCSRFチェックをスキップ
  skip_before_action :verify_authenticity_token, only: :switch

  def index # 一覧画面
    # ログイン中のユーザーが持つ全プロフィールを、作成日時の昇順で取り出して @profiles に格納。
    @profiles = current_user.profiles.order(created_at: :asc)
  end

  def show # 詳細表示
  end

  def new # 新規作成フォーム表示用
    # ログイン中ユーザーに紐づく新しい Profile オブジェクトを生成し、@profile に代入。
    @profile = current_user.profiles.build
  end

  def create # 新規プロファイルの保存処理を行う
    # 送信されたパラメータ（profile_params）を使い、ログイン中ユーザーに紐づく Profile オブジェクトを生成。
    @profile = current_user.profiles.build(profile_params)
    if @profile.save
      # 作成したプロファイルの詳細ページ（/profiles/:id）にリダイレクトし、フラッシュメッセージを表示。
      redirect_to @profile, notice: "プロフィールを作成しました"
    else
      # new テンプレートを再表示し、HTTPステータスを 422（Unprocessable Entity）として返す。
      render :new, status: :unprocessable_entity
    end
  end

  def edit # 既存プロフィールの編集フォーム。
  end

  def update # プロフィールの更新処理
    if @profile.update(profile_params)
      # 更新成功時、詳細ページにリダイレクトし、フラッシュメッセージを表示。
      redirect_to @profile, notice: "プロフィールを更新しました"
    else
      # edit テンプレートを再表示し、HTTPステータス 422 で返す。
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy # プロファイル削除
    # ログイン中ユーザーが持つプロフィール数が 1件以下（=最後の1つ）かどうか
    if current_user.profiles.count <= 1
      redirect_to profiles_path, alert: "最後のプロフィールは削除できません"
    else
      @profile.destroy
      redirect_to profiles_path, notice: "プロフィールを削除しました"
    end
  end

  def switch # プロファイル切替
    # URLの :id から、そのユーザーが持つ profiles の中から対象を検索。
    profile = current_user.profiles.find(params[:profile_id])
    # セッションに current_profile_id を保存し、「今後はこのプロフィールを current_profile として扱う」 ことを記憶させる。
    session[:current_profile_id] = profile.id
    # 直前に居たページにリダイレクトする（Referer がない場合は /profiles へ）。
    redirect_back fallback_location: profiles_path
  end

  private

  # show, edit, update, destroy 前に呼ばれる 共通のプロフィール取得メソッド の開始。
  def set_profile
    # ログイン中ユーザーが持つ profiles の中から、URLの :id に対応する1件を取得して @profile にセット。
    # 他人のプロフィールは取得できないのでアクセス制御にもなっている。
    @profile = current_user.profiles.find(params[:id])
  end

  # Strong Parameters（ストロングパラメータ）定義用メソッドの開始。フォームから受け取るパラメータを制限する役割。
  def profile_params
    # params[:profile] を必須とし、その中の name と theme だけを許可する。
    # それ以外の値は無視され、マスアサインメント脆弱性を防ぐ。
    params.require(:profile).permit(:label, :display_name, :theme)
  end
end
