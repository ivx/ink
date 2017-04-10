:application.start(:logger)
Logger.remove_backend(:console)
ExUnit.start(capture_log: true)
