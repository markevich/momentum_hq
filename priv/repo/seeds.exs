# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     MomentumHq.Repo.insert!(%MomentumHqSomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

MomentumHq.Repo.insert!(%MomentumHqUsers.User{
  id: "20f0782c-78b5-4904-9b4d-069d60221a7f",
  telegram_id: 123
})
