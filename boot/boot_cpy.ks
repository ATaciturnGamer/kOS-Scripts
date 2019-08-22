core:part:getmodule("kOSProcessor"):DOEVENT("Open Terminal").

function download {
    parameter fname.

    IF NOT EXISTS(fname) AND HOMECONNECTION:ISCONNECTED {
		COPYPATH("0:"+fname, "1:"+fname).
		print "Downloading: "+fname.
    }
}
download("lib/lib_stage.ks").
download("lib/lib_vec.ks").
download("lib/lib_mnv.ks").
download("launch.ks").
download("land.ks").
download("execMnv.ks").
download("pid_test1.ks").
