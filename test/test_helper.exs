for app <- Application.spec(:sysevents,:applications) do
    Application.ensure_all_started(app)
end
Sysevents.start(nil,nil)  # Unfortunately starts once for all tests :| maybe this is ok in elixir
ExUnit.start()
