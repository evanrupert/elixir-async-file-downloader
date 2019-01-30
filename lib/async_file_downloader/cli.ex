defmodule AsyncFileDownloader.CLI do
  @timeout_default "180"

  def parse(args) do
    with {flags, argv, _} <- OptionParser.parse(args, strict: [timeout: :iteger]),
         [filename | [dest | _]] <- argv do
      {timeout, _} = Integer.parse(Keyword.get(flags, :timeout, @timeout_default))

      {:ok,
       %{
         filename: filename,
         destination: dest,
         timeout: timeout
       }}
    else
      l when is_list(l) ->
        {:error, "Inproper number of arguments"}

      _ ->
        {:error, "Error parsing arguments"}
    end
  end
end
