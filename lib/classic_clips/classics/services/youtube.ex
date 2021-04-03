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
    Enum.filter(items, fn %{"id" => %{"kind" => kind}} ->
      kind == "youtube#video"
    end)
    |> Enum.map(fn %{
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
    max_results = "maxResults=50"

    one_day = 24 * 60 * 60

    published_after_date =
      DateTime.utc_now()
      |> DateTime.add(-1 * one_day * 4, :second)
      |> DateTime.to_iso8601()

    published_after =
      %{"publishedAfter" => published_after_date}
      |> URI.encode_query()

    key = "key=" <> System.get_env("YOUTUBE_DATA_KEY")

    base = @youtube_api_base <> @search_endpoint

    endpoint = "?#{part}&#{channel_id}&#{published_after}&#{max_results}&#{key}"

    url = base <> endpoint

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{body: body}} -> Jason.decode(body)
      {:error, _} = error -> error
    end
  end

  def search_video_from_id() do
  end

  def get_video_id(url) do
    case String.contains?(url, "https://youtu.be/") do
      true -> short_url_id(url)
      false -> standard_url_id(url)
    end
  end

  def short_url_id(url) do
    String.replace(url, "https://youtu.be/", "") |> String.replace(~r/\?t=.*/, "")
  end

  def standard_url_id(url) do
    case Regex.run(~r/v=.*?&/, url) do
      nil -> ""
      [match] -> String.trim_leading(match, "v=") |> String.trim_trailing("&")
    end
  end
end
