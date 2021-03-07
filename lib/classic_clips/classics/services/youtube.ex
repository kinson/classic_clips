defmodule ClassicClips.Classics.Services.Youtube do
  # search periodically for new no dunks videos

  # when a new one is added, save the details
  # title
  # description
  # id
  # length
  # thumbnail url
  # link
  # published at

  # whenever a new clip is created,
  # look up the id in the classics
  # table, add fk
  @youtube_api_base "https://youtube.googleapis.com/youtube/v3"

  @search_endpoint "/search?"

  def check_for_new_videos() do
    part = "part=snippet"
    channel_id = "channelId=UCi6Nwwk1pAp7gYwe3is7Y0g"

    published_after_date =
      DateTime.utc_now()
      |> DateTime.add(-7200, :second)
      |> DateTime.to_string()

    published_after =
      "publishedAfter=#{published_after_date}"
      |> URI.encode()

    key = "key=" <> System.get_env("YOUTUBE_DATA_KEY")

    base = @youtube_api_base <> @search_endpoint

    endpoint = "?#{part}&#{channel_id}&#{published_after}&#{key}"

    url = base <> endpoint

    HTTPoison.get(url)
  end

  def search_video_from_id() do
  end
end
