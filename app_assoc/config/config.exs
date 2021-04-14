import Config

config :app_assoc, Friends.Repo,
  database: "app_assoc_repo",
  username: "postgres",
  password: "stefan1202",
  hostname: "localhost"

config :app_assoc, ecto_repos: [ Friends.Repo ]
