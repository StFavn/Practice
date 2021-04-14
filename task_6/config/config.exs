import Config

config :task_6, Users.Repo,
  database: "task_6_repo",
  username: "postgres",
  password: "stefan1202",
  hostname: "localhost"

config :task_6, ecto_repos: [ Users.Repo ]
