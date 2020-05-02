defmodule Heos.Commands.SystemTest do
  use ExUnit.Case, async: true

  alias Heos.Commands.System
  alias Heos.Connection

  setup do
    {:ok, conn} = Connection.start_link(host: :dummy)
    :ok = Connection.connect(conn)

    # on_exit(fn ->
    #   Connection.disconnect(conn)
    #   Connection.stop(conn)
    # end)

    {:ok, conn: conn}
  end

  describe "Commands.System.register_for_change_events/2" do
    test "just enable", ctx do
      assert System.register_for_change_events(ctx.conn, :on) == {:ok, :on}
    end

    test "just disable", ctx do
      assert System.register_for_change_events(ctx.conn, :off) == {:ok, :off}
    end

    test "no on will give off", ctx do
      assert System.register_for_change_events(ctx.conn, :unknown) == {:ok, :off}
    end
  end

  describe "Commands.System.heart_beat/1" do
    test "heart beat", cxt do
      assert System.heart_beat(cxt.conn) == :ok
    end
  end

  describe "Commands.System.reboot/1" do
    test "reboot", cxt do
      assert System.reboot(cxt.conn) == :ok
    end
  end

  describe "Commands.System.pretty_json_response/2" do
    test "just disable", ctx do
      assert System.prettify_json_response(ctx.conn, :off) == {:ok, :off}
    end

    test "only off can be used", ctx do
      assert System.prettify_json_response(ctx.conn, :on) == {:error, :only_off_supported}
      assert System.prettify_json_response(ctx.conn, :unknown) == {:error, :only_off_supported}
      assert System.prettify_json_response(ctx.conn, "off") == {:error, :only_off_supported}
    end
  end
end
