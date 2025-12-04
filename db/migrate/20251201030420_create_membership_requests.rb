class CreateMembershipRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :membership_requests do |t|
      # 申請を出した側のプロフィール
      t.references :requester_profile, null: false, foreign_key: { to_table: :profiles }

      # 相手のプロフィール（Team -> Profile 招待で使う）
      t.references :target_profile, foreign_key: { to_table: :profiles }

      # 対象チーム（Profile -> Team 申請で使う）
      t.references :team, foreign_key: true

      # 方向: profile_to_team / team_to_profile
      t.integer :direction, null: false, default: 0

      # 状態: pending / approved / rejected / canceled
      t.integer :status, null: false, default: 0

      # メッセージ（任意）
      t.text :message

      t.timestamps
    end

    # 「同じ内容の pending 申請を二重で作らない」ためのインデックス（とりあえず方向も含めておく）
    add_index :membership_requests,
              [ :requester_profile_id, :target_profile_id, :team_id, :direction ],
              name: "idx_membership_requests_uniqueness"
  end
end
