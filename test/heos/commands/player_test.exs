defmodule Heos.Commands.PlayerTest do
  use ExUnit.Case, async: true

  alias Heos.Commands.Player
  alias Heos.Connection

  setup do
    {:ok, conn} = Connection.start_link(host: :dummy)
    :ok = Connection.connect(conn)

    # on_exit(fn ->
    #   Connection.disconnect(conn)
    #   Connection.stop(conn)
    # end)

    {:ok, conn: conn, player_id: 1}
  end

  describe "Commands.Player.get_players/1" do
    test "get them all", ctx do
      assert Player.get_players(ctx.conn) ==
               {:ok,
                [
                  %{
                    "name" => "player name 1",
                    "pid" => 1,
                    "gid" => "group id",
                    "model" => "player model 1",
                    "version" => "player version 1",
                    "network" => "wired",
                    "lineout" => 0,
                    "control" => "control option",
                    "serial" => "serial number"
                  },
                  %{
                    "name" => "player name 2",
                    "pid" => 2,
                    "gid" => "group id",
                    "model" => "player model 2",
                    "version" => "player version 2",
                    "network" => "wired",
                    "lineout" => 0,
                    "control" => "control option",
                    "serial" => "serial number"
                  }
                ]}
    end
  end

  describe "Commands.Player.get_player_info/2" do
    test "get info", ctx do
      assert Player.get_player_info(ctx.conn, ctx.player_id) ==
               {:ok,
                %{
                  "name" => "player name 1",
                  "pid" => ctx.player_id,
                  "gid" => "group id",
                  "model" => "player model 1",
                  "version" => "player version 1",
                  "network" => "wired",
                  "lineout" => 0,
                  "control" => "control option",
                  "serial" => "serial number"
                }}
    end
  end

  describe "Commands.Player.get_play_state/2" do
    test "get state", ctx do
      assert Player.get_play_state(ctx.conn, ctx.player_id) == {:ok, :stop}
    end
  end

  describe "Commands.Player.set_play_state/3" do
    test "set state", ctx do
      assert Player.set_play_state(ctx.conn, ctx.player_id, :stop) == {:ok, :stop}
    end
  end

  describe "Commands.Player.get_now_playing_media/2" do
    test "get now playing", ctx do
      assert Player.get_now_playing_media(ctx.conn, ctx.player_id) ==
               {:ok,
                %{
                  "type" => "song",
                  "song" => "song name",
                  "album" => "album name",
                  "artist" => "artist name",
                  "image_url" => "image url",
                  "mid" => "media id",
                  "qid" => "queue id",
                  "sid" => "source_id",
                  "album_id" => "Album Id"
                }}
    end
  end

  describe "Commands.Player.get_volume/2" do
    test "get volume", ctx do
      assert Player.get_volume(ctx.conn, ctx.player_id) == {:ok, 50}
    end
  end

  describe "Commands.Player.set_volume/2" do
    test "set volume", ctx do
      assert Player.set_volume(ctx.conn, ctx.player_id, 40) == {:ok, 40}
    end
  end
end
