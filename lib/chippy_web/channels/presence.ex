defmodule ChippyWeb.Presence do
  use Phoenix.Presence,
    otp_app: :chippy,
    pubsub_server: Chippy.PubSub
end