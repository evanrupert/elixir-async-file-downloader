defmodule AsyncFileDownloader do
  alias AsyncFileDownloader.{CLI, Downloader}

  require Logger

  @restart_wait 500

  def main(args \\ []) do
    # Parse program arugments and print error if improper
    with {:ok, parameters} <- CLI.parse(args) do
      # Read all urls from the given filename
      urls = Downloader.read_urls_from_file(parameters.filename)

      download_files(urls, parameters)
    else
      {:error, msg} ->
        IO.puts(msg)
        System.stop(0)
    end
  end

  defp download_files(urls, parameters) do
    # Start the thread/process to wait for the specified amount of time
    # then alert the main process
    start_timer(parameters.timeout)

    # Map over the list of urls starting a download process for each one
    urls
    |> Enum.each(fn url ->
      start_download_process(url, parameters.destination)
    end)

    # Wait for respones from the processes
    watch_for_responses()
  end

  defp start_timer(timeout) do
    # Save the pid of the current process to be used later
    home = self()

    # Spawn a process that will sleep then send a ':stop' message to the main process
    spawn(fn ->
      Process.sleep(timeout * 1000)
      send(home, :stop)
    end)
  end

  defp start_download_process(url, destination) do
    # Save the pid of the current process to be used later
    home = self()

    # Start a process to download the file then send the result back to the main process
    spawn(fn ->
      Logger.debug "Started process to download: #{url}"
      result = Downloader.download_file(url, destination)

      # Sent result back home
      send(home, result)
    end)
  end

  defp watch_for_responses do
    receive do
      # If received the stop message from the timer process
      # then print a log and kill the whole application
      :stop ->
        Logger.info("Recieved kill cmd from timer... ending process...")
        System.stop()

      # If received an :ok and a filename
      # then print a log and start watching again
      {:ok, filename} ->
        Logger.info("Successfuly downloaded file: '#{filename}'")
        watch_for_responses()

      # If recieved an error message
      # then print logs and restart the individual download process and start watching again
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
