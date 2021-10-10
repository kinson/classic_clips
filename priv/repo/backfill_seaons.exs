alias ClassicClips.BigBeef.{Beef, Season}
alias ClassicClips.Repo

import Ecto.Query

season_20 = Season.changeset(%Season{}, %{
  year_start: 2020,
  year_end: 2021,
  name: "'20 - '21"
})
|> Repo.insert!(returning: true)

season_21 = Season.changeset(%Season{}, %{
  year_start: 2021,
  year_end: 2022,
  name: "'21 - '22"
})
|> Repo.insert!(returning: true)

from(b in Beef, where: b.beef_count > 0)
|> Repo.update_all(set: [season_id: season_20.id])

