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

  #   'https://youtube.googleapis.com/youtube/v3/search?part=snippet&channelId=UCi6Nwwk1pAp7gYwe3is7Y0g&publishedAfter=2021-03-03T12%3A00%3A00.00000Z&key=[YOUR_API_KEY]' \

  @search_endpoint "/search"

  def check_for_new_videos() do
    case fetch_new_videos() do
      {:ok, _} = videos -> {:ok, get_video_attrs(videos)}
      {:error, _} = error -> IO.inspect(error)
    end
  end

  def get_video_attrs({:ok, %{"items" => items}}) do
    Enum.map(items, fn %{
                         "id" => %{"videoId" => video_id},
                         "snippet" => %{
                           "description" => description,
                           "title" => title,
                           "publishTime" => publish_time,
                           "thumbnails" => thumbnails
                         }
                       } ->
      %{
        title: title,
        description: description,
        publish_date: publish_time,
        yt_video_id: video_id,
        thumbnails: thumbnails,
        type: "classic"
      }
    end)
  end

  def fetch_new_videos() do
    part = "part=snippet"
    channel_id = "channelId=UCi6Nwwk1pAp7gYwe3is7Y0g"

    published_after_date =
      DateTime.utc_now()
      |> DateTime.add(-512_000, :second)
      |> DateTime.to_iso8601()

    published_after =
      %{"publishedAfter" => published_after_date}
      |> URI.encode_query()

    key = "key=" <> System.get_env("YOUTUBE_DATA_KEY")

    base = @youtube_api_base <> @search_endpoint

    endpoint = "?#{part}&#{channel_id}&#{published_after}&#{key}"

    url = base <> endpoint

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{body: body}} -> Jason.decode(body)
      {:error, _} = error -> error
    end
  end

  def search_video_from_id() do
  end
end
