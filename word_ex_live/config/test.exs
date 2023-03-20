import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :word_ex_live, WordExLiveWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "jhL/qp8zyu/rtMaY7fx4H3+HzxJJuNeCoa4YRHri+Jspy8Js98jZdfrQ5QM5g9na",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
