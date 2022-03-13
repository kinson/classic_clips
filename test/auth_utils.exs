defmodule AuthUtilsTest do
  use ClassicClips.DataCase

  describe "sign" do
    test "creates signature" do
      keys = %{
        consumer_key: "xvz1evFS4wEEPTGEFPHBog",
        consumer_secret: "kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw",
        token: "370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb",
        token_secret: "LswwdoUaIvS8ltyTt5jkRh4J50vUPVVHtR2YPi5kE"
      }

      url = "https://api.twitter.com/1.1/statuses/update.json"

      nonce = "kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg"
      timestamp = "1318622958"

      params = %{
        "include_entities" => "true",
        "status" => "Hello Ladies + Gentlemen, a signed OAuth request!"
      }

      expected_signing_key =
        "kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw&LswwdoUaIvS8ltyTt5jkRh4J50vUPVVHtR2YPi5kE"

      expected_signature_base_string =
        "POST&https%3A%2F%2Fapi.twitter.com%2F1.1%2Fstatuses%2Fupdate.json&include_entities%3Dtrue%26oauth_consumer_key%3Dxvz1evFS4wEEPTGEFPHBog%26oauth_nonce%3DkYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1318622958%26oauth_token%3D370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb%26oauth_version%3D1.0%26status%3DHello%2520Ladies%2520%252B%2520Gentlemen%252C%2520a%2520signed%2520OAuth%2520request%2521"

      expected_signature = "hCtSmYh+iHYCEqBWrE7C7hYmtUk="

      assert {^expected_signing_key, ^expected_signature_base_string, ^expected_signature,
              oauth_params} =
               AuthUtils.sign(
                 keys,
                 url,
                 params,
                 nonce,
                 timestamp
               )

      assert AuthUtils.auth_header(expected_signature, oauth_params)
             |> String.starts_with?("OAuth oauth_signature=\"#{expected_signature}\"")
    end
  end
end
