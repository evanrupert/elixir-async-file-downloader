# ==========EXAMPLE 1==============
# spawn(fn ->
#   Process.sleep(1000)
#   IO.puts "Hello, Process!"
# end)

# IO.puts "Hello, World!"

# IO.read(:line)

# ============EXAMPLE 2============
# pid = spawn(fn ->
#   receive do
#     msg ->
#       IO.puts "Recieved message: '#{msg}'"
#   end
# end)

# IO.puts "Hello, World!"
# send(pid, "Hello, Process!")

# IO.read(:line)

#===============EXAMPLE 3============
# defmodule MyModule do
#   def listen_for_messages do
#     receive do
#       {from, msg} ->
#         IO.puts "Recieved message: '#{msg}' from process: '#{inspect from}'"
#         listen_for_messages()
#     end
#   end
# end

# pid = spawn(MyModule, :listen_for_messages, [])

# (0..10)
# |> Enum.each(fn i ->
#   Process.sleep(500)
#   send(pid, {self(), "Hello for the #{i}th time"})
# end)

# IO.read(:line)

#==============EXAMPLE 4============
# defmodule MyModule do
#   def listen_for_messages do
#     receive do
#       {from, msg} ->
#         IO.puts "Received message: '#{msg}' from process: '#{inspect from}'"
#         listen_for_messages()
#     end
#   end

#   def relay_messages(to) do
#     receive do
#       {from, msg} ->
#         IO.puts "Relaying message: '#{msg}', diagram: '#{inspect from}' -> '#{inspect self()}(self)' -> '#{inspect to}'"
#         send(to, {self(), msg})
#         relay_messages(to)
#     end
#   end
# end

# receiver = spawn(MyModule, :listen_for_messages, [])

# relay = spawn(MyModule, :relay_messages, [receiver])

# IO.puts "Hello, World!"

# (0..10)
# |> Enum.each(fn i ->
#   Process.sleep(1000)
#   send(relay, {self(), "Hello for the #{i}th time"})
# end)

# IO.read(:line)
