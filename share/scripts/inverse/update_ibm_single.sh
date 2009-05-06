#! /bin/bash

if [ "$1" = "--help" ]; then
   echo This script implemtents the function update
   echo for the Inverse Boltzmann Method for a single pair
   echo Usage: ${0##*/} step_nr
   echo Needs:  run_or_exit, \$SOURCE_WRAPPER, update_POT.pl
   exit 0
fi

[[ -n "$1" ]] || die "${0##*/}: Missing argument"

update_POT="$($SOURCE_WRAPPER update ibm_pot)" || die "${0##*/}: $SOURCE_WRAPPER update ibm_pot failed" 
shift_DPOT="$($SOURCE_WRAPPER shift dpotnb)" || die "${0##*/}: $SOURCE_WRAPPER shift dpotnb failed" 

scheme=( $($csg_get  .do_potential ) )
scheme_nr=$(( ( $1 - 1 ) % ${#scheme[@]} ))
name=$($csg_get name)

if [ "${scheme[$scheme_nr]}" = 1 ]; then
   log "Update potential ${name} : yes"
   #update ibm
   run_or_exit ${update_POT} ${name}.dist.tgt ${name}.dist.new ${name}.pot.cur ${name}.dpot.tmp
   run_or_exit ${shift_DPOT} ${name}.dpot.tmp ${name}.dpot.new
else
   log "Update potential ${name} : no"
   awk -v step=$($csg_get step) -v start=$($csg_get min) -v end=$($csg_get max) \
     'BEGIN{x=start;while(x<end+step){print x,0.0,"i";x+=step;}}' > ${name}.dpot.new \
      || die "${0##*/}: awk failed"
fi