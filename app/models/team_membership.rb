# app/models/team_membership.rb
class TeamMembership < ApplicationRecord
  belongs_to :team
  belongs_to :profile

  validates :profile_id, uniqueness: { scope: :team_id }
  # role はとりあえず任意。あとで "owner", "member" など enum にしてもOK
end
