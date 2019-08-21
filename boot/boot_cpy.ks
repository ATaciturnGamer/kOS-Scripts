core:part:getmodule("kOSProcessor"):DOEVENT("Open Terminal").

function download {
    parameter fname.

    IF NOT EXISTS(fname) AND HOMECONNECTION:ISCONNECTED {
	       COPYPATH("0:"+fname, "1:").
    }
}
download("lib/lib_stage.ks").
download("lib/lib_vec.ks").
download("launch.ks").
download("execMnv.ks").
download("pid_test1.ks").
