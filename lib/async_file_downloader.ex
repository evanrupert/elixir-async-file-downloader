defmodule AsyncFileDownloader do
  alias AsyncFileDownloader.{CLI, Downloader}

  require Logger

  @restart_wait 500

  def main(args \\ []) do
    with {:ok, parameters} <- CLI.parse(args) do
      urls = Downloader.read_urls_from_file(parameters.filename)
      download_files(urls, parameters)
    else
      {:error, msg} ->
        IO.puts(msg)
        System.stop(0)
    end
  end

  defp download_files(urls, parameters) do
    start_timer(parameters.timeout)

    urls
    |> Enum.each(fn url ->
      start_download_process(url, parameters.destination)
    end)

    watch_for_responses()
  end

  defp start_timer(timeout) do
    home = self()

    spawn(fn ->
      Process.sleep(timeout * 1000)
      send(home, :stop)
    end)
  end

  defp start_download_process(url, destination) do
    home = self()

    spawn(fn ->
      Logger.debug "Started process to download: #{url}"
      result = Downloader.download_file(url, destination)

      send(home, result)
    end)
  end

  defp watch_for_responses do
    receive do
      :stop ->
        Logger.info("Recieved kill cmd from timer... ending process...")
        System.stop()

      {:ok, filename} ->
        Logger.info("Successfuly downloaded file: '#{filename}'")
        watch_for_responses()

      {:error, msg, url, destination} ->
        Logger.error("Recieved error: '#{inspect msg}' when attempting download of: '#{url}'")
        Logger.error("Waiting #{@restart_wait} milliseconds and restarting")

        spawn(fn ->
          Process.sleep(@restart_wait)
          start_download_process(url, destination)
        end)

        watch_for_responses()
    end
  end
end
