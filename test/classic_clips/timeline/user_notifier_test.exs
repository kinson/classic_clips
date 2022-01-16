defmodule ClassicClips.Timeline.UserNotifierTest do
  use ExUnit.Case, async: true
  import Swoosh.TestAssertions

  alias ClassicClips.Timeline.UserNotifier

  test "deliver_new_matchup/1" do
    user = %{name: "Alice", email: "alice@example.com"}

    UserNotifier.deliver_new_matchup(user)

    assert_email_sent(
      subject: "Welcome to Phoenix, Alice!",
      to: {"Alice", "alice@example.com"},
      text_body: ~r/Hello, Alice/
    )
  end
end
