set DEBUG ON

# Set working library.
set LIB work

if {$DEBUG == "ON"} {
    set VOPT_ARG "+acc"
    echo $VOPT_ARG
    set DB_SW "-debugdb"
} else {
    set DB_SW ""
}

quit -sim

vsim -voptargs=$VOPT_ARG $DB_SW -pedanticerrors -lib $LIB gelu_tb

if {$DEBUG == "ON"} {
    add log -r /*
}

run -a
