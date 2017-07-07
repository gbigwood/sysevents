for app <- Application.spec(:sysevents,:applications) do
    Application.ensure_all_started(app)
end
Sysevents.start(nil,nil)
ExUnit.start()
