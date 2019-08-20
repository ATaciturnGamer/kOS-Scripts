function autoStage {
	list ENGINES in engine_list.
    for eng in engine_list {
      if eng:FLAMEOUT{
        stage.
        wait until STAGE:READY.
		PRINT "AUTOSTAGE "+STAGE:NUMBER at (0,6+STAGE:NUMBER).
        return true.
      }
    }
	return false.
}