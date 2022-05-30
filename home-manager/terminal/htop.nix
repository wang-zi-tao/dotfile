{ config, pkgs, lib, ... }:
let formatMeters = side: meters: {
  "column_meters_${side}" = builtins.concatMap (lib.attrsets.mapAttrsToList (x: _: x)) meters;
  "column_meter_modes_${side}" = builtins.concatMap (lib.attrsets.mapAttrsToList (_: y: y)) meters;
}; in
{
  programs.htop = {
    enable = true;
    settings = {
      htop_version = "3.1.1";
      config_reader_min_version = 2;
      sort_key = 46;
      sort_direction = -1;
      tree_sort_key = 0;
      tree_sort_direction = 1;
      hide_kernel_threads = 1;
      hide_userland_threads = 1;
      shadow_other_users = 0;
      show_thread_names = 1;
      show_program_path = 0;
      highlight_base_name = 1;
      highlight_deleted_exe = 1;
      highlight_megabytes = 1;
      highlight_threads = 1;
      highlight_changes = 0;
      highlight_changes_delay_secs = 5;
      find_comm_in_cmdline = 1;
      strip_exe_from_cmdline = 1;
      show_merged_command = 1;
      tree_view = 0;
      tree_view_always_by_pid = 0;
      all_branches_collapsed = 0;
      header_margin = 1;
      detailed_cpu_time = 1;
      cpu_count_from_one = 1;
      show_cpu_usage = 1;
      show_cpu_frequency = 1;
      show_cpu_temperature = 1;
      degree_fahrenheit = 0;
      update_process_names = 0;
      account_guest_in_cpu_meter = 0;
      color_scheme = 5;
      enable_mouse = 1;
      delay = 15;
      hide_function_bar = 2;
      header_layout = "three_33_34_33";
      fields = with config.lib.htop.fields; [
        PID
        123
        USER
        STATE
        M_SIZE
        M_RESIDENT
        40
        UTIME
        STIME
        PERCENT_CPU
        PERCENT_MEM
        IO_READ_RATE
        COMM
      ];
    } // (with config.lib.htop;
      formatMeters "0" [
        (bar "LeftCPUs4")
        (bar "RightCPUs4")
      ]) // (with config.lib.htop;
      formatMeters "1" [
        (bar "CPU")
        (bar "MemorySwap")
        (text "Systemd")
        (text "Tasks")
      ]) // (with config.lib.htop;
      formatMeters "2" [
        (text "DiskIO")
        (text "NetworkIO")
        (text "PressureStallCPUSome")
        (text "LoadAverage")
      ]);
  };
}
