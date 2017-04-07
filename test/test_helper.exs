:application.start(:logger)
Logger.remove_backend(:console)
Logger.add_translator({Ink.FilterTranslator, :translate})
ExUnit.start(capture_log: true)
