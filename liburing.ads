-------------------------------------------------------------------------------
-- liburing.ads
--
-- Bindings to liburing. Many of the helper functions in liburing are inlined
-- in the liburing.h header and so have no exported symbols in liburing.a that
-- Ada code can call into directly. We use a wrapper file liburing-ada.c with
-- wrapper functions for those inlined calls.
--
-- Some additional low-level types used in certain system calls (__kernel_timespec,
-- sigset_t, iovec) are defined here as well, with Ada-ish names (Kernel_Timespec,
-- Signal_Set, IO_Vector).
--
-- Copyright 2022 Jon Andrew
-------------------------------------------------------------------------------
with GNAT.Sockets;
with Interfaces;
with Interfaces.C;
with Interfaces.C.Strings;
with System;

package liburing is

    IORING_SETUP_IOPOLL          : constant := (2 ** 0);
    IORING_SETUP_SQPOLL          : constant := (2 ** 1);
    IORING_SETUP_SQ_AFF          : constant := (2 ** 2);
    IORING_SETUP_CQSIZE          : constant := (2 ** 3);
    IORING_SETUP_CLAMP           : constant := (2 ** 4);
    IORING_SETUP_ATTACH_WQ       : constant := (2 ** 5);
    IORING_SETUP_R_DISABLED      : constant := (2 ** 6);
    IORING_SETUP_SUBMIT_ALL      : constant := (2 ** 7);

    IORING_FSYNC_DATASYNC        : constant := (2 ** 0);

    IORING_TIMEOUT_ABS           : constant := (2 ** 0);
    IORING_TIMEOUT_UPDATE        : constant := (2 ** 1);
    IORING_TIMEOUT_BOOTTIME      : constant := (2 ** 2);
    IORING_TIMEOUT_REALTIME      : constant := (2 ** 3);
    IORING_LINK_TIMEOUT_UPDATE   : constant := (2 ** 4);
    IORING_TIMEOUT_ETIME_SUCCESS : constant := (2 ** 5);

    SPLICE_F_FD_IN_FIXED         : constant := (2 ** 31);

    IORING_POLL_ADD_MULTI        : constant := (2 ** 0);
    IORING_POLL_UPDATE_EVENTS    : constant := (2 ** 1);
    IORING_POLL_UPDATE_USER_DATA : constant := (2 ** 2);

    IORING_CQE_F_BUFFER          : constant := (2 ** 0);
    IORING_CQE_F_MORE            : constant := (2 ** 1);
    IORING_CQE_F_MSG             : constant := (2 ** 2);

    IORING_OFF_SQ_RING           : constant := 0;
    IORING_OFF_CQ_RING           : constant := 16#8000000#;
    IORING_OFF_SQES              : constant := 16#10000000#;

    IORING_SQ_NEED_WAKEUP        : constant := (2 ** 0);
    IORING_SQ_CQ_OVERFLOW        : constant := (2 ** 1);

    IORING_CQ_EVENTFD_DISABLED   : constant := (2 ** 0);

    IORING_ENTER_GETEVENTS       : constant := (2 ** 0);
    IORING_ENTER_SQ_WAKEUP       : constant := (2 ** 1);
    IORING_ENTER_SQ_WAIT         : constant := (2 ** 2);
    IORING_ENTER_EXT_ARG         : constant := (2 ** 3);
    IORING_ENTER_REGISTERED_RING : constant := (2 ** 4);

    IORING_FEAT_SINGLE_MMAP      : constant := (2 ** 0);
    IORING_FEAT_NODROP           : constant := (2 ** 1);
    IORING_FEAT_SUBMIT_STABLE    : constant := (2 ** 2);
    IORING_FEAT_RW_CUR_POS       : constant := (2 ** 3);
    IORING_FEAT_CUR_PERSONALITY  : constant := (2 ** 4);
    IORING_FEAT_FAST_POLL        : constant := (2 ** 5);
    IORING_FEAT_POLL_32BITS      : constant := (2 ** 6);
    IORING_FEAT_SQPOLL_NONFIXED  : constant := (2 ** 7);
    IORING_FEAT_EXT_ARG          : constant := (2 ** 8);
    IORING_FEAT_NATIVE_WORKERS   : constant := (2 ** 9);
    IORING_FEAT_RSRC_TAGS        : constant := (2 ** 10);
    IORING_FEAT_CQE_SKIP         : constant := (2 ** 11);

    IORING_REGISTER_FILES_SKIP   : constant := (-2);

    IO_URING_OP_SUPPORTED        : constant := (2 ** 0);

    type anon1588_array1152 is array (0 .. 3) of aliased Interfaces.Unsigned_32;
    type anon1590_array1152 is array (0 .. 3) of aliased Interfaces.Unsigned_32;
    type anon1592_array1593 is array (0 .. 2) of aliased Interfaces.Unsigned_8;
    
    type anon1490_union1491 (discr : Interfaces.Unsigned_32 := 0) is record
        case discr is
            when 0 =>
                off : aliased Interfaces.Unsigned_64;
            when others =>
                addr2 : aliased Interfaces.Unsigned_64;
        end case;
    end record with Convention => C_Pass_By_Copy, Unchecked_Union => True;

    type anon1490_union1492 (discr : Interfaces.Unsigned_32 := 0) is record
        case discr is
            when 0 =>
                addr : aliased Interfaces.Unsigned_64;
            when others =>
                splice_off_in : aliased Interfaces.Unsigned_64;
        end case;
    end record with Convention => C_Pass_By_Copy, Unchecked_Union => True;
    
    type anon1490_union1493 (discr : Interfaces.Unsigned_32 := 0) is record
        case discr is
            when 0 =>
                rw_flags : aliased Interfaces.Integer_32;
            when 1 =>
                fsync_flags : aliased Interfaces.Unsigned_32;
            when 2 =>
                poll_events : aliased Interfaces.Unsigned_16;
            when 3 =>
                poll32_events : aliased Interfaces.Unsigned_32;
            when 4 =>
                sync_range_flags : aliased Interfaces.Unsigned_32;
            when 5 =>
                msg_flags : aliased Interfaces.Unsigned_32;
            when 6 =>
                timeout_flags : aliased Interfaces.Unsigned_32;
            when 7 =>
                accept_flags : aliased Interfaces.Unsigned_32;
            when 8 =>
                cancel_flags : aliased Interfaces.Unsigned_32;
            when 9 =>
                open_flags : aliased Interfaces.Unsigned_32;
            when 10 =>
                statx_flags : aliased Interfaces.Unsigned_32;
            when 11 =>
                fadvise_advice : aliased Interfaces.Unsigned_32;
            when 12 =>
                splice_flags : aliased Interfaces.Unsigned_32;
            when 13 =>
                rename_flags : aliased Interfaces.Unsigned_32;
            when 14 =>
                unlink_flags : aliased Interfaces.Unsigned_32;
            when others =>
                hardlink_flags : aliased Interfaces.Unsigned_32;
        end case;
    end record with Convention => C_Pass_By_Copy, Unchecked_Union => True;
    
    type anon1490_union1494 (discr : Interfaces.Unsigned_32 := 0) is record
        case discr is
            when 0 =>
                buf_index : aliased Interfaces.Unsigned_16;
            when others =>
                buf_group : aliased Interfaces.Unsigned_16;
        end case;
    end record
    with Convention => C_Pass_By_Copy, Unchecked_Union => True;
    
    type anon1490_union1495 (discr : Interfaces.Unsigned_32 := 0) is record
        case discr is
            when 0 =>
                splice_fd_in : aliased Interfaces.Integer_32;
            when others =>
                file_index   : aliased Interfaces.Unsigned_32;
        end case;
    end record with Convention => C_Pass_By_Copy, Unchecked_Union => True;

    type anon1490_array1496 is array (0 .. 1) of aliased Interfaces.Unsigned_64;

    type Submission_Queue_Entry is record
        opcode      : aliased Interfaces.Unsigned_8;
        flags       : aliased Interfaces.Unsigned_8;
        ioprio      : aliased Interfaces.Unsigned_16;
        fd          : aliased Interfaces.C.int;
        anon3044    : aliased anon1490_union1491;
        anon3048    : aliased anon1490_union1492;
        len         : aliased Interfaces.Unsigned_32;
        anon3067    : aliased anon1490_union1493;
        user_data   : aliased Interfaces.Unsigned_64;
        anon3072    : aliased anon1490_union1494;
        personality : aliased Interfaces.Unsigned_16;
        anon3077    : aliased anon1490_union1495;
        uu_pad2     : aliased anon1490_array1496;
    end record with Convention => C_Pass_By_Copy;

    type Completion_Queue_Entry is record
        user_data : aliased Interfaces.Unsigned_64;
        res       : aliased Interfaces.C.int;
        flags     : aliased Interfaces.C.unsigned;
    end record with Convention => C_Pass_By_Copy;

    type Submission_Queue is record
        khead         : access Interfaces.C.unsigned;
        ktail         : access Interfaces.C.unsigned;
        kring_mask    : access Interfaces.C.unsigned;
        kring_entries : access Interfaces.C.unsigned;
        kflags        : access Interfaces.C.unsigned;
        kdropped      : access Interfaces.C.unsigned;
        c_array       : access Interfaces.C.unsigned;
        sqes          : access Submission_Queue_Entry;
        sqe_head      : aliased Interfaces.C.unsigned;
        sqe_tail      : aliased Interfaces.C.unsigned;
        ring_sz       : aliased Interfaces.C.unsigned_long;
        ring_ptr      : System.Address;
        pad           : aliased anon1588_array1152;
    end record with Convention => C_Pass_By_Copy;

    type Completion_Queue is record
        khead         : access Interfaces.C.unsigned;
        ktail         : access Interfaces.C.unsigned;
        kring_mask    : access Interfaces.C.unsigned;
        kring_entries : access Interfaces.C.unsigned;
        kflags        : access Interfaces.C.unsigned;
        koverflow     : access Interfaces.C.unsigned;
        cqes          : access Completion_Queue_Entry;
        ring_sz       : aliased Interfaces.C.unsigned_long;
        ring_ptr      : System.Address;
        pad           : aliased anon1590_array1152;
    end record with Convention => C_Pass_By_Copy;

    type Ring is record
        sq            : aliased Submission_Queue;
        cq            : aliased Completion_Queue;
        flags         : aliased Interfaces.C.unsigned;
        ring_fd       : aliased Interfaces.C.int;
        features      : aliased Interfaces.C.unsigned;
        enter_ring_fd : aliased Interfaces.C.int;
        int_flags     : aliased Interfaces.Unsigned_8;
        pad           : aliased anon1592_array1593;
        pad2          : aliased Interfaces.C.unsigned;
    end record with Convention => C_Pass_By_Copy;

    type Sqring_Offsets is record
        head         : aliased Interfaces.Unsigned_32;
        tail         : aliased Interfaces.Unsigned_32;
        ring_mask    : aliased Interfaces.Unsigned_32;
        ring_entries : aliased Interfaces.Unsigned_32;
        flags        : aliased Interfaces.Unsigned_32;
        dropped      : aliased Interfaces.Unsigned_32;
        c_array      : aliased Interfaces.Unsigned_32;
        resv1        : aliased Interfaces.Unsigned_32;
        resv2        : aliased Interfaces.Unsigned_64;
    end record with Convention => C_Pass_By_Copy;

    type Cqring_Offsets is record
        head         : aliased Interfaces.Unsigned_32;
        tail         : aliased Interfaces.Unsigned_32;
        ring_mask    : aliased Interfaces.Unsigned_32;
        ring_entries : aliased Interfaces.Unsigned_32;
        overflow     : aliased Interfaces.Unsigned_32;
        cqes         : aliased Interfaces.Unsigned_32;
        flags        : aliased Interfaces.Unsigned_32;
        resv1        : aliased Interfaces.Unsigned_32;
        resv2        : aliased Interfaces.Unsigned_64;
    end record with Convention => C_Pass_By_Copy;

    type anon1504_array1505 is array (0 .. 2) of aliased Interfaces.Unsigned_32;

    type Params is record
        sq_entries     : aliased Interfaces.Unsigned_32;
        cq_entries     : aliased Interfaces.Unsigned_32;
        flags          : aliased Interfaces.Unsigned_32;
        sq_thread_cpu  : aliased Interfaces.Unsigned_32;
        sq_thread_idle : aliased Interfaces.Unsigned_32;
        features       : aliased Interfaces.Unsigned_32;
        wq_fd          : aliased Interfaces.Unsigned_32;
        resv           : aliased anon1504_array1505;
        sq_off         : aliased Sqring_Offsets;
        cq_off         : aliased Cqring_Offsets;
    end record with Convention => C_Pass_By_Copy;

    type Files_Update is record
        offset : aliased Interfaces.Unsigned_32;
        resv   : aliased Interfaces.Unsigned_32;
        fds    : aliased Interfaces.Unsigned_64;
    end record with Convention => C_Pass_By_Copy;

    type Rsrc_Register is record
        nr    : aliased Interfaces.Unsigned_32;
        resv  : aliased Interfaces.Unsigned_32;
        resv2 : aliased Interfaces.Unsigned_64;
        data  : aliased Interfaces.Unsigned_64;
        tags  : aliased Interfaces.Unsigned_64;
    end record with Convention => C_Pass_By_Copy;

    type Rsrc_Update is record
        offset : aliased Interfaces.Unsigned_32;
        resv   : aliased Interfaces.Unsigned_32;
        data   : aliased Interfaces.Unsigned_64;
    end record with Convention => C_Pass_By_Copy;

    type Rsrc_Update2 is record
        offset : aliased Interfaces.Unsigned_32;
        resv   : aliased Interfaces.Unsigned_32;
        data   : aliased Interfaces.Unsigned_64;
        tags   : aliased Interfaces.Unsigned_64;
        nr     : aliased Interfaces.Unsigned_32;
        resv2  : aliased Interfaces.Unsigned_32;
    end record with Convention => C_Pass_By_Copy;

    type Probe_Op is record
        op    : aliased Interfaces.Unsigned_8;
        resv  : aliased Interfaces.Unsigned_8;
        flags : aliased Interfaces.Unsigned_16;
        resv2 : aliased Interfaces.Unsigned_32;
    end record with Convention => C_Pass_By_Copy;

    type anon1514_array1505 is array (0 .. 2) of aliased Interfaces.Unsigned_32;
    type anon1514_array1515 is array (0 .. 0) of aliased Probe_Op;
    
    type Probe is record
        last_op : aliased Interfaces.Unsigned_8;
        ops_len : aliased Interfaces.Unsigned_8;
        resv    : aliased Interfaces.Unsigned_16;
        resv2   : aliased anon1514_array1505;
        ops     : aliased anon1514_array1515;
    end record with Convention => C_Pass_By_Copy;

    type anon1516_union1517 (discr : Interfaces.Unsigned_32 := 0) is record
        case discr is
            when 0 =>
                register_op : aliased Interfaces.Unsigned_8;
            when 1 =>
                sqe_op : aliased Interfaces.Unsigned_8;
            when others =>
                sqe_flags : aliased Interfaces.Unsigned_8;
        end case;
    end record
    with Convention => C_Pass_By_Copy, Unchecked_Union => True;
    
    type anon1516_array1505 is array (0 .. 2) of aliased Interfaces.Unsigned_32;
   
    type Restriction is record
        opcode   : aliased Interfaces.Unsigned_16;
        anon3232 : aliased anon1516_union1517;
        resv     : aliased Interfaces.Unsigned_8;
        resv2    : aliased anon1516_array1505;
    end record with Convention => C_Pass_By_Copy;

    type Get_Events_Arg is record
        sigmask    : aliased Interfaces.Unsigned_64;
        sigmask_sz : aliased Interfaces.Unsigned_32;
        pad        : aliased Interfaces.Unsigned_32;
        ts         : aliased Interfaces.Unsigned_64;
    end record with Convention => C_Pass_By_Copy;

    ---------------------------------------------------------------------------
    -- External types used for parameters to some of these subprograms
    ---------------------------------------------------------------------------
    type Sigset_Arr is array (0..15) of aliased Interfaces.C.unsigned_long;
    type Signal_Set is record
        val : aliased Sigset_Arr;
    end record with Convention => C_Pass_By_Copy;

    type Kernel_Timespec is record
        tv_sec  : aliased Long_Long_Integer;
        tv_nsec : aliased Long_Long_Integer;
    end record with Convention => C_Pass_By_Copy;

    type IO_Vector is record
        iov_base : System.Address;
        iov_len  : Interfaces.C.size_t;
    end record with Convention => C_Pass_By_Copy;

    type CPUset_Arr is array (0..15) of Interfaces.C.unsigned_long;
    type CPU_Set is record
        bits : aliased CPUset_Arr;
    end record with Convention => C_Pass_By_Copy;

    type Message_Header is record
        msg_name       : System.Address;
        msg_namelen    : aliased Interfaces.C.unsigned;
        msg_iov        : access IO_Vector;
        msg_iovlen     : aliased Interfaces.C.size_t;
        msg_control    : System.Address;
        msg_controllen : aliased Interfaces.C.size_t;
        msg_flags      : aliased Interfaces.C.int;
   end record with Convention => C_Pass_By_Copy;

    type Open_How is record
        flags   : aliased Interfaces.Unsigned_64;
        mode    : aliased Interfaces.Unsigned_64;
        resolve : aliased Interfaces.Unsigned_64;
    end record with Convention => C_Pass_By_Copy;

    ---------------------------------------------------------------------------
    -- Get_Probe_Ring
    ---------------------------------------------------------------------------
    function Get_Probe_Ring (r : access Ring) return access Probe
    with Import => True,
         Convention => C,
         External_Name => "io_uring_get_probe_ring";

    ---------------------------------------------------------------------------
    -- Get_Probe
    ---------------------------------------------------------------------------
    function Get_Probe return access Probe
    with Import => True,
         Convention => C,
         External_Name => "io_uring_get_probe";

    ---------------------------------------------------------------------------
    -- Free_Probe
    ---------------------------------------------------------------------------
    procedure Free_Probe (p : access Probe)
    with Import => True,
         Convention => C,
         External_Name => "io_uring_free_probe";

    ---------------------------------------------------------------------------
    -- Opcode_Supported
    ---------------------------------------------------------------------------
    function Opcode_Supported (p  : access constant Probe;
                               op : Interfaces.C.int) return Interfaces.C.int
    with Import => True,
         Convention => C,
         External_Name => "wrap_io_uring_opcode_supported";

    ---------------------------------------------------------------------------
    -- Init_Params
    ---------------------------------------------------------------------------
    function Queue_Init_Params (entries : Interfaces.C.unsigned;
                                r       : access Ring;
                                p       : access Params) return Interfaces.C.int
    with Import => True,
         Convention => C,
         External_Name => "io_uring_queue_init_params";

    ---------------------------------------------------------------------------
    -- Queue_Init
    ---------------------------------------------------------------------------
    function Queue_Init (entries : Interfaces.C.unsigned;
                         r       : access Ring;
                         flags   : Interfaces.C.unsigned) return Interfaces.C.int
    with Import => True,
         Convention => C,
         External_Name => "io_uring_queue_init";

    ---------------------------------------------------------------------------
    -- Queue_Mmap
    ---------------------------------------------------------------------------
    function Queue_Mmap (fd : Interfaces.C.int;
                         p  : access Params;
                         r  : access Ring) return Interfaces.C.int
    with Import => True,
         Convention => C,
         External_Name => "io_uring_queue_mmap";

    ---------------------------------------------------------------------------
    -- Ring_Dont_Fork
    ---------------------------------------------------------------------------
    function Ring_Dont_Fork (r : access Ring) return Interfaces.C.int
    with Import => True,
         Convention => C,
         External_Name => "io_uring_ring_dontfork";

    ---------------------------------------------------------------------------
    -- Queue_Exit
    ---------------------------------------------------------------------------
    procedure Queue_Exit (r : access Ring)
    with Import => True,
         Convention => C,
         External_Name => "io_uring_queue_exit";

    ---------------------------------------------------------------------------
    -- Peek_Batch_Completion_Queue_Entry
    ---------------------------------------------------------------------------
    function Peek_Batch_Completion_Queue_Entry (r : access Ring;
                                                cqes : System.Address;
                                                count : Interfaces.C.unsigned) return Interfaces.C.unsigned
    with Import => True,
         Convention => C,
         External_Name => "io_uring_peek_batch_cqe";

    ---------------------------------------------------------------------------
    -- Wait_Completion_Queue_Entries
    ---------------------------------------------------------------------------
    function Wait_Completion_Queue_Entries (r       : access Ring;
                                            cqe_ptr : System.Address;
                                            wait_nr : Interfaces.C.unsigned;
                                            ts      : access Kernel_Timespec;
                                            sigmask : access Signal_Set) return Interfaces.C.int
    with Import => True,
         Convention => C,
         External_Name => "io_uring_wait_cqes";

    ---------------------------------------------------------------------------
    -- Wait_Completion_Queue_Entry_Timeout
    -- @param cqe_ptr - Address of an access cqe type.
    ---------------------------------------------------------------------------
    function Wait_Completion_Queue_Entry_Timeout (r       : access Ring;
                                                  cqe_ptr : System.Address;
                                                  ts      : access Kernel_Timespec) return Interfaces.C.int
    with Import => True,
         Convention => C,
         External_Name => "io_uring_wait_cqe_timeout";

    ---------------------------------------------------------------------------
    -- Submit
    ---------------------------------------------------------------------------
    function Submit (r : access Ring) return Interfaces.C.int
    with Import => True,
         Convention => C,
         External_Name => "io_uring_submit";

    ---------------------------------------------------------------------------
    -- Submit_And_Wait
    ---------------------------------------------------------------------------
    function Submit_And_Wait (r : access Ring; wait_nr : Interfaces.C.unsigned) return Interfaces.C.int
    with Import => True,
         Convention => C,
         External_Name => "io_uring_submit_and_wait";

    ---------------------------------------------------------------------------
    -- Submit_And_Wait_Timeout
    ---------------------------------------------------------------------------
    function Submit_And_Wait_Timeout (r       : access Ring;
                                      cqe_ptr : System.Address;
                                      wait_nr : Interfaces.C.unsigned;
                                      ts      : access Kernel_Timespec;
                                      sigmask : access Signal_Set) return Interfaces.C.int
    with Import => True, 
         Convention => C, 
         External_Name => "io_uring_submit_and_wait_timeout";


    ---------------------------------------------------------------------------
    -- Register_Buffers
    ---------------------------------------------------------------------------
    function Register_Buffers (r         : access Ring;
                               iovecs    : access constant IO_Vector;
                               nr_iovecs : Interfaces.C.unsigned) return Interfaces.C.int
    with Import => True,
         Convention => C,
         External_Name => "io_uring_register_buffers";

    ---------------------------------------------------------------------------
    -- Register_Buffers_Tags
    ---------------------------------------------------------------------------
    function Register_Buffers_Tags (r      : access Ring;
                                    iovecs : access constant IO_Vector;
                                    tags   : access Interfaces.Unsigned_64;
                                    nr     : Interfaces.C.unsigned) return Interfaces.C.int
    with Import => True,
         Convention => C,
         External_Name => "io_uring_register_buffers_tags";

    ---------------------------------------------------------------------------
    -- Register_Buffers_Update_Tag
    ---------------------------------------------------------------------------
    function Register_Buffers_Update_Tag (r      : access Ring;
                                          off    : Interfaces.C.unsigned;
                                          iovecs : access constant IO_Vector;
                                          tags   : access Interfaces.Unsigned_64;
                                          nr     : Interfaces.C.unsigned) return Interfaces.C.int
    with Import => True, 
         Convention => C, 
         External_Name => "io_uring_register_buffers_update_tag";

    ---------------------------------------------------------------------------
    -- Unregister_Buffers
    ---------------------------------------------------------------------------
    function Unregister_Buffers (r : access Ring) return Interfaces.C.int
    with Import => True, 
         Convention => C, 
         External_Name => "io_uring_unregister_buffers";

    ---------------------------------------------------------------------------
    -- Register_Files
    ---------------------------------------------------------------------------
    function Register_Files (r        : access Ring;
                             files    : access Interfaces.C.int;
                             nr_files : Interfaces.C.unsigned) return Interfaces.C.int
    with Import => True, 
         Convention => C, 
         External_Name => "io_uring_register_files";

    ---------------------------------------------------------------------------
    -- Register_Files_Tags
    ---------------------------------------------------------------------------
    function Register_Files_Tags (r     : access Ring;
                                  files : access Interfaces.C.int;
                                  tags  : access Interfaces.Unsigned_64;
                                  nr    : Interfaces.C.unsigned) return Interfaces.C.int
    with Import => True, 
         Convention => C, 
         External_Name => "io_uring_register_files_tags";

    ---------------------------------------------------------------------------
    -- Register_Files_Update_Tag
    ---------------------------------------------------------------------------
    function register_files_update_tag (r        : access Ring;
                                        off      : Interfaces.C.unsigned;
                                        files    : access Interfaces.C.int;
                                        tags     : access Interfaces.Unsigned_64;
                                        nr_files : Interfaces.C.unsigned) return Interfaces.C.int
    with Import => True, 
            Convention => C, 
            External_Name => "io_uring_register_files_update_tag";

    ---------------------------------------------------------------------------
    -- Unregister_Files
    ---------------------------------------------------------------------------
    function unregister_files (r : access Ring) return Interfaces.C.int
    with Import => True, 
         Convention => C, 
         External_Name => "io_uring_unregister_files";

    ---------------------------------------------------------------------------
    -- Register_Files_Update
    ---------------------------------------------------------------------------
    function register_files_update (r        : access Ring;
                                    off      : Interfaces.C.unsigned;
                                    files    : access Interfaces.C.int;
                                    nr_files : Interfaces.C.unsigned) return Interfaces.C.int
    with Import => True, 
         Convention => C, 
         External_Name => "io_uring_register_files_update";

    ---------------------------------------------------------------------------
    -- Register_Eventfd
    ---------------------------------------------------------------------------
    function Register_Eventfd (r : access Ring; fd : Interfaces.C.int) return Interfaces.C.int
    with Import => True, 
         Convention => C, 
         External_Name => "io_uring_register_eventfd";

    ---------------------------------------------------------------------------
    -- Register_Eventfd_Async
    ---------------------------------------------------------------------------
    function Register_Eventfd_Async (r : access Ring; fd : Interfaces.C.int) return Interfaces.C.int
    with Import => True, 
         Convention => C, 
         External_Name => "io_uring_register_eventfd_async";

    ---------------------------------------------------------------------------
    -- Unregister_Eventfd
    ---------------------------------------------------------------------------
    function Unregister_Eventfd (r : access Ring) return Interfaces.C.int
    with Import => True, 
         Convention => C, 
         External_Name => "io_uring_unregister_eventfd";

    ---------------------------------------------------------------------------
    -- Register_Probe
    ---------------------------------------------------------------------------
    function Register_Probe (r  : access Ring;
                             p  : access Probe;
                             nr : Interfaces.C.unsigned) return Interfaces.C.int
    with Import => True, 
         Convention => C, 
         External_Name => "io_uring_register_probe";

    ---------------------------------------------------------------------------
    -- Register_Personality
    ---------------------------------------------------------------------------
    function Register_Personality (r : access Ring) return Interfaces.C.int
    with Import => True, 
         Convention => C, 
         External_Name => "io_uring_register_personality";

    ---------------------------------------------------------------------------
    -- Unregister_Personality
    ---------------------------------------------------------------------------
    function Unregister_Personality (r : access Ring; id : Interfaces.C.int) return Interfaces.C.int
    with Import => True, 
         Convention => C, 
         External_Name => "io_uring_unregister_personality";

    ---------------------------------------------------------------------------
    -- Register_Restrictions
    ---------------------------------------------------------------------------
    function Register_Restrictions (r      : access Ring;
                                    res    : access Restriction;
                                    nr_res : Interfaces.C.unsigned) return Interfaces.C.int
    with Import => True,
         Convention => C, 
         External_Name => "io_uring_register_restrictions";

    ---------------------------------------------------------------------------
    -- Enable_Rings
    ---------------------------------------------------------------------------
    function Enable_Rings (r : access Ring) return Interfaces.C.int
    with Import => True,
         Convention => C, 
         External_Name => "io_uring_enable_rings";

    ---------------------------------------------------------------------------
    -- Register_IOWQ_Affinity
    ---------------------------------------------------------------------------
    function Register_IOWQ_Affinity (r     : access Ring;
                                     cpusz : Interfaces.C.unsigned_long;
                                     mask  : access constant CPU_Set) return Interfaces.C.int
    with Import => True, 
         Convention => C, 
         External_Name => "io_uring_register_iowq_aff";

    ---------------------------------------------------------------------------
    -- Unregister_IOWQ_Affinity
    ---------------------------------------------------------------------------
    function Unregister_IOWQ_Affinity (r : access Ring) return Interfaces.C.int
    with Import => True, 
         Convention => C, 
         External_Name => "io_uring_unregister_iowq_aff";

    ---------------------------------------------------------------------------
    -- Register_IOWQ_Max_Workers
    ---------------------------------------------------------------------------
    function Register_IOWQ_Max_Workers (r : access Ring; values : access Interfaces.C.unsigned) return Interfaces.C.int
    with Import => True, 
         Convention => C, 
         External_Name => "io_uring_register_iowq_max_workers";

    ---------------------------------------------------------------------------
    -- Register_Ring_fd
    ---------------------------------------------------------------------------
    function Register_Ring_fd (r : access Ring) return Interfaces.C.int
    with Import => True, 
         Convention => C, 
         External_Name => "io_uring_register_ring_fd";

    ---------------------------------------------------------------------------
    -- Unregister_Ring_fd
    ---------------------------------------------------------------------------
    function Unregister_Ring_fd (r : access Ring) return Interfaces.C.int
    with Import => True, 
         Convention => C, 
         External_Name => "io_uring_unregister_ring_fd";

    ---------------------------------------------------------------------------
    -- Completion_Queue_Advance
    ---------------------------------------------------------------------------
    procedure Completion_Queue_Advance (r : access Ring; nr : Interfaces.C.unsigned)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_cq_advance";

    ---------------------------------------------------------------------------
    -- Completion_Queue_Entry_Seen
    ---------------------------------------------------------------------------
    procedure Completion_Queue_Entry_Seen (r : access Ring; cqe : access Completion_Queue_Entry)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_cqe_seen";

    ---------------------------------------------------------------------------
    -- Submission_Queue_Entry_Set_Data
    ---------------------------------------------------------------------------
    procedure Submission_Queue_Entry_Set_Data (sqe : access Submission_Queue_Entry; data : System.Address)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_sqe_set_data";

    ---------------------------------------------------------------------------
    -- Submission_Queue_Entry_Set_Data64
    ---------------------------------------------------------------------------
    procedure Submission_Queue_Entry_Set_Data64 (sqe : access Submission_Queue_Entry; data : Interfaces.Unsigned_64)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_sqe_set_data64";

    ---------------------------------------------------------------------------
    -- Completion_Queue_Entry_Get_Data
    ---------------------------------------------------------------------------
    function Completion_Queue_Entry_Get_Data (cqe : access constant Completion_Queue_Entry) return System.Address
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_cqe_get_data";

    ---------------------------------------------------------------------------
    -- Completion_Queue_Entry_Get_Data64
    ---------------------------------------------------------------------------
    function Completion_Queue_Entry_Get_Data64 (cqe : access constant Completion_Queue_Entry) return Interfaces.Unsigned_64
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_cqe_get_data64";

    ---------------------------------------------------------------------------
    -- Submission_Queue_Entry_Set_Flags
    ---------------------------------------------------------------------------
    procedure Submission_Queue_Entry_Set_Flags (sqe : access Submission_Queue_Entry; flags : Interfaces.C.unsigned)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_sqe_set_flags";


    ---------------------------------------------------------------------------
    -- Prep_RW
    ---------------------------------------------------------------------------
    procedure Prep_RW (op     : Interfaces.C.int;
                       sqe    : access Submission_Queue_Entry;
                       fd     : Interfaces.C.int;
                       addr   : System.Address;
                       len    : Interfaces.C.unsigned;
                       offset : Interfaces.Unsigned_64)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_rw";

    ---------------------------------------------------------------------------
    -- Prep_Splice
    ---------------------------------------------------------------------------
    procedure Prep_Splice (sqe          : access Submission_Queue_Entry;
                           fd_in        : Interfaces.C.int;
                           off_in       : Interfaces.Integer_64;
                           fd_out       : Interfaces.C.int;
                           off_out      : Interfaces.Integer_64;
                           nbytes       : Interfaces.C.unsigned;
                           splice_flags : Interfaces.C.unsigned)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_splice";

    ---------------------------------------------------------------------------
    -- Prep_Tee
    ---------------------------------------------------------------------------
    procedure Prep_Tee (sqe          : access Submission_Queue_Entry;
                        fd_in        : Interfaces.C.int;
                        fd_out       : Interfaces.C.int;
                        nbytes       : Interfaces.C.unsigned;
                        splice_flags : Interfaces.C.unsigned)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_tee";

    ---------------------------------------------------------------------------
    -- Prep_Readv
    ---------------------------------------------------------------------------
    procedure Prep_Readv (sqe     : access Submission_Queue_Entry;
                          fd      : Interfaces.C.int;
                          iovecs  : access constant IO_Vector;
                          nr_vecs : Interfaces.C.unsigned;
                          offset  : Interfaces.Unsigned_64)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_readv";

    ---------------------------------------------------------------------------
    -- Prep_Readv2
    ---------------------------------------------------------------------------
    procedure Prep_Readv2 (sqe : access Submission_Queue_Entry;
                           fd : Interfaces.C.int;
                           iovecs : access constant IO_Vector;
                           nr_vecs : Interfaces.C.unsigned;
                           offset : Interfaces.Unsigned_64;
                           flags : Interfaces.C.int)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_readv2";

    ---------------------------------------------------------------------------
    -- Prep_Read_Fixed
    ---------------------------------------------------------------------------
    procedure Prep_Read_Fixed (sqe       : access Submission_Queue_Entry;
                               fd        : Interfaces.C.int;
                               buf       : System.Address;
                               nbytes    : Interfaces.C.unsigned;
                               offset    : Interfaces.Unsigned_64;
                               buf_index : Interfaces.C.int)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_read_fixed";

    ---------------------------------------------------------------------------
    -- Prep_Writev
    ---------------------------------------------------------------------------
    procedure Prep_Writev (sqe     : access Submission_Queue_Entry;
                           fd      : Interfaces.C.int;
                           iovecs  : access constant IO_Vector;
                           nr_vecs : Interfaces.C.unsigned;
                           offset  : Interfaces.Unsigned_64)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_writev";

    ---------------------------------------------------------------------------
    -- Prep_Writev2
    ---------------------------------------------------------------------------
    procedure Prep_Writev2 (sqe     : access Submission_Queue_Entry;
                            fd      : Interfaces.C.int;
                            iovecs  : access constant IO_Vector;
                            nr_vecs : Interfaces.C.unsigned;
                            offset  : Interfaces.Unsigned_64;
                            flags   : Interfaces.C.int)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_writev2";

    ---------------------------------------------------------------------------
    -- Prep_Write_Fixed
    ---------------------------------------------------------------------------
    procedure Prep_Write_Fixed (sqe       : access Submission_Queue_Entry;
                                fd        : Interfaces.C.int;
                                buf       : System.Address;
                                nbytes    : Interfaces.C.unsigned;
                                offset    : Interfaces.Unsigned_64;
                                buf_index : Interfaces.C.int)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_write_fixed";

    ---------------------------------------------------------------------------
    -- Prep_Recvmsg
    ---------------------------------------------------------------------------
    procedure Prep_Recvmsg (sqe   : access Submission_Queue_Entry;
                            fd    : Interfaces.C.int;
                            msg   : access Message_Header;
                            flags : Interfaces.C.unsigned)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_recvmsg";

    ---------------------------------------------------------------------------
    -- Prep_Sendmsg
    ---------------------------------------------------------------------------
    procedure Prep_Sendmsg(sqe   : access Submission_Queue_Entry;
                           fd    : Interfaces.C.int;
                           msg   : access constant Message_Header;
                           flags : Interfaces.C.unsigned)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_sendmsg";

    ---------------------------------------------------------------------------
    -- Prep_Poll_Add
    ---------------------------------------------------------------------------
    procedure Prep_Poll_Add (sqe       : access Submission_Queue_Entry;
                             fd        : Interfaces.C.int;
                             poll_mask : Interfaces.C.unsigned)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_poll_add";

    ---------------------------------------------------------------------------
    -- Prep_Poll_Multishot
    ---------------------------------------------------------------------------
    procedure Prep_Poll_Multishot (sqe       : access Submission_Queue_Entry;
                                   fd        : Interfaces.C.int;
                                   poll_mask : Interfaces.C.unsigned)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_poll_multishot";

    ---------------------------------------------------------------------------
    -- Prep_Poll_Remove
    ---------------------------------------------------------------------------
    procedure Prep_Poll_Remove (sqe : access Submission_Queue_Entry; user_data : Interfaces.Unsigned_64)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_poll_remove";

    ---------------------------------------------------------------------------
    -- Prep_Poll_Update
    ---------------------------------------------------------------------------
    procedure Prep_Poll_Update (sqe           : access Submission_Queue_Entry;
                                old_user_data : Interfaces.Unsigned_64;
                                new_user_data : Interfaces.Unsigned_64;
                                poll_mask     : Interfaces.C.unsigned;
                                flags         : Interfaces.C.unsigned)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_poll_update";

    ---------------------------------------------------------------------------
    -- Prep_FSync
    ---------------------------------------------------------------------------
    procedure Prep_FSync (sqe         : access Submission_Queue_Entry;
                          fd          : Interfaces.C.int;
                          fsync_flags : Interfaces.C.unsigned)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_fsync";

    ---------------------------------------------------------------------------
    -- Prep_NOP
    ---------------------------------------------------------------------------
    procedure Prep_NOP (sqe : access Submission_Queue_Entry)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_nop";

    ---------------------------------------------------------------------------
    -- Prep_Timeout
    ---------------------------------------------------------------------------
    procedure Prep_Timeout (sqe   : access Submission_Queue_Entry;
                            ts    : access Kernel_Timespec;
                            count : Interfaces.C.unsigned;
                            flags : Interfaces.C.unsigned)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_timeout";

    ---------------------------------------------------------------------------
    -- Prep_Timeout_Remove
    ---------------------------------------------------------------------------
    procedure Prep_Timeout_Remove (sqe       : access Submission_Queue_Entry;
                                   user_data : Interfaces.Unsigned_64;
                                   flags     : Interfaces.C.unsigned)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_timeout_remove";

    ---------------------------------------------------------------------------
    -- Prep_Timeout_Update
    ---------------------------------------------------------------------------
    procedure Prep_Timeout_Update (sqe       : access Submission_Queue_Entry;
                                   ts        : access Kernel_Timespec;
                                   user_data : Interfaces.Unsigned_64;
                                   flags     : Interfaces.C.unsigned)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_timeout_update";

    ---------------------------------------------------------------------------
    -- Prep_Accept
    ---------------------------------------------------------------------------
    procedure Prep_Accept (sqe     : access Submission_Queue_Entry;
                           fd      : GNAT.Sockets.Socket_Type;
                           addr    : access GNAT.Sockets.Sock_Addr_Type;
                           addrlen : access Interfaces.C.Unsigned;
                           flags   : Interfaces.C.int)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_accept";

    ---------------------------------------------------------------------------
    -- Prep_Accept_Direct
    ---------------------------------------------------------------------------
    procedure Prep_Accept_Direct (sqe        : access Submission_Queue_Entry;
                                  fd         : Interfaces.C.int;
                                  addr       : access GNAT.Sockets.Sock_Addr_Type;
                                  addrlen    : access Interfaces.C.Unsigned;
                                  flags      : Interfaces.C.int;
                                  file_index : Interfaces.C.unsigned)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_accept_direct";

    ---------------------------------------------------------------------------
    -- Prep_Cancel
    ---------------------------------------------------------------------------
    procedure Prep_Cancel (sqe       : access Submission_Queue_Entry;
                           user_data : Interfaces.Unsigned_64;
                           flags     : Interfaces.C.int)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_cancel";

    ---------------------------------------------------------------------------
    -- Prep_Link_Timeout
    ---------------------------------------------------------------------------
    procedure Prep_Link_Timeout (sqe   : access Submission_Queue_Entry;
                                 ts    : access Kernel_Timespec;
                                 flags : Interfaces.C.unsigned)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_link_timeout";

    ---------------------------------------------------------------------------
    -- Prep_Connect
    ---------------------------------------------------------------------------
    procedure Prep_Connect (sqe : access Submission_Queue_Entry;
                            fd : Interfaces.C.int;
                            addr : access constant GNAT.Sockets.Sock_Addr_Type;
                            addrlen : Interfaces.C.Unsigned)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_connect";

    ---------------------------------------------------------------------------
    -- Prep_Files_Update
    ---------------------------------------------------------------------------
    procedure Prep_Files_Update (sqe    : access Submission_Queue_Entry;
                                 fds    : access Interfaces.C.int;
                                 nr_fds : Interfaces.C.unsigned;
                                 offset : Interfaces.C.int)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_files_update";

    ---------------------------------------------------------------------------
    -- Prep_FAllocate
    ---------------------------------------------------------------------------
    procedure Prep_FAllocate (sqe    : access Submission_Queue_Entry;
                              fd     : Interfaces.C.int;
                              mode   : Interfaces.C.int;
                              offset : Interfaces.Unsigned_64;
                              len    : Interfaces.Unsigned_64)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_fallocate";

    ---------------------------------------------------------------------------
    -- Prep_Open_At
    ---------------------------------------------------------------------------
    procedure Prep_Open_At (sqe   : access Submission_Queue_Entry;
                            dfd   : Interfaces.C.int;
                            path  : Interfaces.C.Strings.chars_ptr;
                            flags : Interfaces.C.int;
                            mode  : Interfaces.C.unsigned)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_openat";

    ---------------------------------------------------------------------------
    -- Prep_Open_At_Direct
    ---------------------------------------------------------------------------
    procedure Prep_Open_At_Direct (sqe        : access Submission_Queue_Entry;
                                   dfd        : Interfaces.C.int;
                                   path       : Interfaces.C.Strings.chars_ptr;
                                   flags      : Interfaces.C.int;
                                   mode       : Interfaces.C.unsigned;
                                   file_index : Interfaces.C.unsigned)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_openat_direct";

    ---------------------------------------------------------------------------
    -- Prep_Close
    ---------------------------------------------------------------------------
    procedure Prep_Close (sqe : access Submission_Queue_Entry; fd : Interfaces.C.int)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_close";

    ---------------------------------------------------------------------------
    -- Prep_Close_Direct
    ---------------------------------------------------------------------------
    procedure Prep_Close_Direct (sqe : access Submission_Queue_Entry; file_index : Interfaces.C.unsigned)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_close_direct";

    ---------------------------------------------------------------------------
    -- Prep_Read
    ---------------------------------------------------------------------------
    procedure Prep_Read (sqe    : access Submission_Queue_Entry;
                         fd     : Interfaces.C.int;
                         buf    : System.Address;
                         nbytes : Interfaces.C.unsigned;
                         offset : Interfaces.Unsigned_64)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_read";

    ---------------------------------------------------------------------------
    -- Prep_Write
    ---------------------------------------------------------------------------
    procedure prep_write (sqe    : access Submission_Queue_Entry;
                          fd     : Interfaces.C.int;
                          buf    : System.Address;
                          nbytes : Interfaces.C.unsigned;
                          offset : Interfaces.Unsigned_64)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_write";

    -- type statx is null record;   -- incomplete struct

    -- procedure prep_statx (sqe      : access Submission_Queue_Entry;
    --                       dfd      : Interfaces.C.int;
    --                       path     : Interfaces.C.Strings.chars_ptr;
    --                       flags    : Interfaces.C.int;
    --                       mask     : Interfaces.C.unsigned;
    --                       statxbuf : access statx)  -- ../liburing.h:580
    -- with Import => True, 
    --         Convention => C, 
    --         External_Name => "wrap_io_uring_prep_statx";

    ---------------------------------------------------------------------------
    -- Prep_FAdvise
    ---------------------------------------------------------------------------
    procedure Prep_FAdvise (sqe    : access Submission_Queue_Entry;
                            fd     : Interfaces.C.int;
                            offset : Interfaces.Unsigned_64;
                            len    : Interfaces.C.long;
                            advice : Interfaces.C.int)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_fadvise";

    ---------------------------------------------------------------------------
    -- Prep_MAdvise
    ---------------------------------------------------------------------------
    procedure Prep_MAdvise (sqe    : access Submission_Queue_Entry;
                            addr   : System.Address;
                            length : Interfaces.C.long;
                            advice : Interfaces.C.int)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_madvise";

    ---------------------------------------------------------------------------
    -- Prep_Send
    ---------------------------------------------------------------------------
    procedure Prep_Send (sqe    : access Submission_Queue_Entry;
                         sockfd : Interfaces.C.int;
                         buf    : System.Address;
                         len    : Interfaces.C.size_t;
                         flags  : Interfaces.C.int)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_send";

    ---------------------------------------------------------------------------
    -- Prep_Recv
    ---------------------------------------------------------------------------
    procedure Prep_Recv (sqe    : access Submission_Queue_Entry;
                         sockfd : Interfaces.C.int;
                         buf    : System.Address;
                         len    : Interfaces.C.size_t;
                         flags  : Interfaces.C.int)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_recv";

    ---------------------------------------------------------------------------
    -- Prep_Open_At2
    ---------------------------------------------------------------------------
    procedure Prep_Open_At2 (sqe  : access Submission_Queue_Entry;
                             dfd  : Interfaces.C.int;
                             path : Interfaces.C.Strings.chars_ptr;
                             how  : access Open_How)
    with Import => True,
         Convention => C,
         External_Name => "wrap_io_uring_prep_openat2";

    ---------------------------------------------------------------------------
    -- Prep_Open_At2_Direct
    ---------------------------------------------------------------------------
    procedure Prep_Open_At2_Direct (sqe        : access Submission_Queue_Entry;
                                    dfd        : Interfaces.C.int;
                                    path       : Interfaces.C.Strings.chars_ptr;
                                    how        : access Open_How;
                                    file_index : Interfaces.C.unsigned)
    with Import => True,
         Convention => C,
         External_Name => "wrap_io_uring_prep_openat2_direct";

    -- type epoll_event is null record;   -- incomplete struct

    -- procedure prep_epoll_ctl
    --     (sqe : access Submission_Queue_Entry;
    --     epfd : Interfaces.C.int;
    --     fd : Interfaces.C.int;
    --     op : Interfaces.C.int;
    --     ev : access epoll_event)  -- ../liburing.h:635
    -- with Import => True, 
    --         Convention => C, 
    --         External_Name => "wrap_io_uring_prep_epoll_ctl";

    ---------------------------------------------------------------------------
    -- Prep_Provide_Buffers
    ---------------------------------------------------------------------------
    procedure Prep_Provide_Buffers (sqe  : access Submission_Queue_Entry;
                                    addr : System.Address;
                                    len  : Interfaces.C.int;
                                    nr   : Interfaces.C.int;
                                    bgid : Interfaces.C.int;
                                    bid  : Interfaces.C.int)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_provide_buffers";

    ---------------------------------------------------------------------------
    -- Prep_Remove_Buffers
    ---------------------------------------------------------------------------
    procedure Prep_Remove_Buffers (sqe  : access Submission_Queue_Entry;
                                   nr   : Interfaces.C.int;
                                   bgid : Interfaces.C.int)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_remove_buffers";

    ---------------------------------------------------------------------------
    -- Prep_Shutdown
    ---------------------------------------------------------------------------
    procedure Prep_Shutdown (sqe : access Submission_Queue_Entry;
                             fd  : Interfaces.C.int;
                             how : Interfaces.C.int)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_shutdown";

    ---------------------------------------------------------------------------
    -- Prep_Unlink_At
    ---------------------------------------------------------------------------
    procedure Prep_Unlink_At (sqe   : access Submission_Queue_Entry;
                              dfd   : Interfaces.C.int;
                              path  : Interfaces.C.Strings.chars_ptr;
                              flags : Interfaces.C.int)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_unlinkat";

    ---------------------------------------------------------------------------
    -- Prep_Rename_At
    ---------------------------------------------------------------------------
    procedure Prep_Rename_At (sqe     : access Submission_Queue_Entry;
                              olddfd  : Interfaces.C.int;
                              oldpath : Interfaces.C.Strings.chars_ptr;
                              newdfd  : Interfaces.C.int;
                              newpath : Interfaces.C.Strings.chars_ptr;
                              flags   : Interfaces.C.int)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_renameat";

    ---------------------------------------------------------------------------
    -- Prep_Sync_File_Range
    ---------------------------------------------------------------------------
    procedure Prep_Sync_File_Range (sqe    : access Submission_Queue_Entry;
                                    fd     : Interfaces.C.int;
                                    len    : Interfaces.C.unsigned;
                                    offset : Interfaces.Unsigned_64;
                                    flags  : Interfaces.C.int)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_sync_file_range";

    ---------------------------------------------------------------------------
    -- Prep_Mkdir_At
    ---------------------------------------------------------------------------
    procedure Prep_Mkdir_At (sqe  : access Submission_Queue_Entry;
                             dfd  : Interfaces.C.int;
                             path : Interfaces.C.Strings.chars_ptr;
                             mode : Interfaces.C.unsigned)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_mkdirat";

    ---------------------------------------------------------------------------
    -- Prep_Symlink_At
    ---------------------------------------------------------------------------
    procedure Prep_Symlink_At (sqe      : access Submission_Queue_Entry;
                               target   : Interfaces.C.Strings.chars_ptr;
                               newdirfd : Interfaces.C.int;
                               linkpath : Interfaces.C.Strings.chars_ptr)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_symlinkat";

    ---------------------------------------------------------------------------
    -- Prep_Link_At
    ---------------------------------------------------------------------------
    procedure Prep_Link_At (sqe     : access Submission_Queue_Entry;
                            olddfd  : Interfaces.C.int;
                            oldpath : Interfaces.C.Strings.chars_ptr;
                            newdfd  : Interfaces.C.int;
                            newpath : Interfaces.C.Strings.chars_ptr;
                            flags   : Interfaces.C.int)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_linkat";

    ---------------------------------------------------------------------------
    -- 
    ---------------------------------------------------------------------------
    procedure Prep_Msg_Ring (sqe   : access Submission_Queue_Entry;
                             fd    : Interfaces.C.int;
                             len   : Interfaces.C.unsigned;
                             data  : Interfaces.Unsigned_64;
                             flags : Interfaces.C.unsigned)
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_prep_msg_ring";

    ---------------------------------------------------------------------------
    -- Submission_Queue_Ready
    ---------------------------------------------------------------------------
    function Submission_Queue_Ready (r : access constant Ring) return Interfaces.C.unsigned
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_sq_ready";

    ---------------------------------------------------------------------------
    -- Submission_Queue_Space_Left
    ---------------------------------------------------------------------------
    function Submission_Queue_Space_Left (r : access constant Ring) return Interfaces.C.unsigned
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_sq_space_left";

    ---------------------------------------------------------------------------
    -- Submission_Queue_Ring_Wait
    -- To be used when using SQPOLL - Allows caller to wait for free space in
    -- the SQ ring (i.e. kernel thread has consumed one or more entries)
    -- @return -EINVAL if kernel does not support this feature
    ---------------------------------------------------------------------------
    function Submission_Queue_Ring_Wait (r : access Ring) return Interfaces.C.int
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_sqring_wait";

    ---------------------------------------------------------------------------
    -- Completion_Queue_Ready
    -- @return number of unconsumed entries ready in the CQ ring
    ---------------------------------------------------------------------------
    function Completion_Queue_Ready (r : access constant Ring) return Interfaces.C.unsigned
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_cq_ready";

    ---------------------------------------------------------------------------
    -- Completion_Queue_Eventfd_Enabled
    -- @return True if eventfd notification is enabled
    ---------------------------------------------------------------------------
    function Completion_Queue_Eventfd_Enabled (r : access constant Ring) return Boolean
    with Import => True, 
         Convention => C,
         External_Name => "wrap_io_uring_cq_eventfd_enabled";

    ---------------------------------------------------------------------------
    -- Completion_Queue_Eventfd_Toggle
    ---------------------------------------------------------------------------
    function Completion_Queue_Eventfd_Toggle (r : access Ring; enabled : Boolean) return Interfaces.C.int
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_cq_eventfd_toggle";

    ---------------------------------------------------------------------------
    -- Wait_Completion_Queue_Entry_Number
    -- @return an IO completion, waiting for 'wait_nr' completions if one isn't
    -- readily available.
    -- @return 0 with cqe_ptr filled in on success, -errno on failure.
    ---------------------------------------------------------------------------
    function Wait_Completion_Queue_Entry_Number (r       : access Ring;
                                                 cqe_ptr : System.Address;
                                                 wait_nr : Interfaces.C.unsigned) return Interfaces.C.int
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_wait_cqe_nr";

    ---------------------------------------------------------------------------
    -- Peek_Completion_Queue_Entry
    -- @return an IO completion, if one is available. Returns 0 with cqe_ptr
    --  filled in on success, -errno on failure.
    -- @param cqe_ptr - address of an access to Completion_Queue_Entry type
    ---------------------------------------------------------------------------
    function Peek_Completion_Queue_Entry (r : access Ring; cqe_ptr : System.Address) return Interfaces.C.int
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_peek_cqe";

    ---------------------------------------------------------------------------
    -- Wait_Completion_Queue_Entry
    -- @return an IO completion, blocking if necessary. Returns 0 with cqe_ptr
    --  filled in on success, -errno on failure.
    ---------------------------------------------------------------------------
    function Wait_Completion_Queue_Entry (r : access Ring; cqe_ptr : System.Address) return Interfaces.C.int
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_wait_cqe";

    ---------------------------------------------------------------------------
    -- Get_Submission_Queue_Entry
    -- @return an SQE to fill. Returns a vacant sqe, or null if sq is full.
    ---------------------------------------------------------------------------
    function Get_Submission_Queue_Entry (r : access Ring) return access Submission_Queue_Entry
    with Import => True, 
         Convention => C, 
         External_Name => "wrap_io_uring_get_sqe";

end liburing;
