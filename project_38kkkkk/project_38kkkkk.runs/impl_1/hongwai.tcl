proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000

start_step init_design
set rc [catch {
  create_msg_db init_design.pb
  debug::add_scope template.lib 1
  set_property design_mode GateLvl [current_fileset]
  set_property webtalk.parent_dir D:/5Project/PYNQ/Air-conditioning-infrared-remote-control/project_38kkkkk/project_38kkkkk.cache/wt [current_project]
  set_property parent.project_path D:/5Project/PYNQ/Air-conditioning-infrared-remote-control/project_38kkkkk/project_38kkkkk.xpr [current_project]
  set_property ip_repo_paths {
  d:/5Project/PYNQ/Air-conditioning-infrared-remote-control/project_38kkkkk/project_38kkkkk.cache/ip
  D:/5Project/PYNQ/Air-conditioning-infrared-remote-control/ip_repo_IR_1.1/IR_1.1
  D:/5Project/PYNQ/Air-conditioning-infrared-remote-control/ip_repo_IR/IR_1.0
} [current_project]
  set_property ip_output_repo d:/5Project/PYNQ/Air-conditioning-infrared-remote-control/project_38kkkkk/project_38kkkkk.cache/ip [current_project]
  add_files -quiet D:/5Project/PYNQ/Air-conditioning-infrared-remote-control/project_38kkkkk/project_38kkkkk.runs/synth_1/hongwai.dcp
  read_xdc D:/5Project/PYNQ/Air-conditioning-infrared-remote-control/project_38kkkkk/project_38kkkkk.srcs/constrs_1/new/123.xdc
  link_design -top hongwai -part xc7z020clg400-1
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
}

start_step opt_design
set rc [catch {
  create_msg_db opt_design.pb
  catch {write_debug_probes -quiet -force debug_nets}
  opt_design 
  write_checkpoint -force hongwai_opt.dcp
  catch {report_drc -file hongwai_drc_opted.rpt}
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
}

start_step place_design
set rc [catch {
  create_msg_db place_design.pb
  catch {write_hwdef -file hongwai.hwdef}
  place_design 
  write_checkpoint -force hongwai_placed.dcp
  catch { report_io -file hongwai_io_placed.rpt }
  catch { report_utilization -file hongwai_utilization_placed.rpt -pb hongwai_utilization_placed.pb }
  catch { report_control_sets -verbose -file hongwai_control_sets_placed.rpt }
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
}

start_step route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force hongwai_routed.dcp
  catch { report_drc -file hongwai_drc_routed.rpt -pb hongwai_drc_routed.pb }
  catch { report_timing_summary -warn_on_violation -max_paths 10 -file hongwai_timing_summary_routed.rpt -rpx hongwai_timing_summary_routed.rpx }
  catch { report_power -file hongwai_power_routed.rpt -pb hongwai_power_summary_routed.pb }
  catch { report_route_status -file hongwai_route_status.rpt -pb hongwai_route_status.pb }
  catch { report_clock_utilization -file hongwai_clock_utilization_routed.rpt }
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
}

