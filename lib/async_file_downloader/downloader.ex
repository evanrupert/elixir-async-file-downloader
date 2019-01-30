defmodule AsyncFileDownloader.Downloader do
  def download_file(url, destination) do
    # Download content from the url
    with {:ok, resp} <- HTTPoison.get(url) do
      write_resp_to_file(resp, url, destination)
    else
      # If there is an error getting the url then return an error with additional information
      {:error, msg} ->
        {:error, msg, url, destination}
    end
  end

  def read_urls_from_file(filename) do
    {:ok, bin} = File.read(filename)

    String.split(bin, "\n")
  end

  defp write_resp_to_file(resp, url, destination) do
    filename = Path.basename(url)
    dest = Path.join(destination, filename)

    # Attempt to write the response to the given destination
    with :ok <- File.write(dest, resp.body) do
      {:ok, filename}
    else
      # If there is an error writting to the file, then return an error with additional information
      {:error, msg} ->
        {:error, msg, url, destination}
    end
  end
end
