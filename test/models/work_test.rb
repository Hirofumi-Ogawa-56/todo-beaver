# test/models/work_test.rb
require "test_helper"

class WorkTest < ActiveSupport::TestCase
  setup do
    # モデルテストでは sign_in は不要（エラーになります）
    @work = works(:one)
  end

  # テスト内容...
end
