defmodule AuthUtils do
  def sign(keys, url, params \\ %{}, nonce \\ nonce(), timestamp \\ timestamp()) do
    %{
      consumer_key: consumer_key,
      consumer_secret: consumer_secret,
      token: token,
      token_secret: token_secret
    } = keys

    encoded_consumer_secret = percent_encode(consumer_secret)
    encoded_token_secret = percent_encode(token_secret)

    signing_key = encoded_consumer_secret <> "&" <> encoded_token_secret

    oauth_params = get_oauth_params(consumer_key, token, nonce, timestamp)

    encoded_params =
      params
      |> Map.merge(oauth_params)
      |> Enum.map(fn {key, value} ->
        percent_encode(key) <> "=" <> percent_encode(value)
      end)
      |> Enum.join("&")
      |> percent_encode()

    signature_base_string = "POST&" <> percent_encode(url) <> "&" <> encoded_params

    signature =
      :crypto.mac(:hmac, :sha, signing_key, signature_base_string)
      |> Base.encode64()

    {signing_key, signature_base_string, signature, oauth_params}
  end

  def auth_header(oauth_signature, params) do
    tokens =
      params
      |> Map.put("oauth_signature", oauth_signature)
      |> Enum.filter(fn {key, _value} ->
        String.starts_with?(key, "oauth_")
      end)
      |> Enum.sort(fn {a, _}, {b, _} ->
        a <= b
      end)
      |> Enum.map_join(", ", fn {key, value} ->
        ~s(#{key}="#{value}")
      end)

    "OAuth #{tokens}"
  end

  defp percent_encode(str), do: URI.encode(str, &URI.char_unreserved?/1)

  defp get_oauth_params(consumer_key, oauth_token, nonce, timestamp) do
    %{
      "oauth_consumer_key" => consumer_key,
      "oauth_nonce" => nonce,
      "oauth_signature_method" => "HMAC-SHA1",
      "oauth_timestamp" => timestamp,
      "oauth_token" => oauth_token,
      "oauth_version" => "1.0"
    }
  end

  defp nonce() do
    :crypto.strong_rand_bytes(24)
    |> Base.encode64()
  end

  defp timestamp() do
    {megasec, sec, _microsec} = :os.timestamp()
    seconds = megasec * 1_000_000 + sec

    to_string(seconds)
  end
end
