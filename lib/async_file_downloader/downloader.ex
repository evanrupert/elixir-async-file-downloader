defmodule AsyncFileDownloader.Downloader do
  def download_file(url, destination) do
    with {:ok, resp} <- HTTPoison.get(url) do
      write_resp_to_file(resp, url, destination)
    else
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

    with :ok <- File.write(dest, resp.body) do
      {:ok, filename}
    else
      {:error, msg} ->
        {:error, msg, url, destination}
    end
  end
end
