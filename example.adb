-------------------------------------------------------------------------------
-- example.adb
--
-- Simple io_uring-based echo server based on Shuveb Hussain's excellent
-- guide at: https://unixism.net/loti/index.html
--
-- Copyright 2022 Jon Andrew
--
-- Some notes: We want to avoid any dynamic allocation, so set up a number of
-- fixed buffers ahead of time that we register with the kernel. This avoids
-- copies as well. We use parallel arrays:
--
-- Array 1: Requests
-- Array 2: Buffers
-- Array 3: iovec structures that point to the respective buffer.
--
-- Each request has an associated buffer pointed to by the respective iovec.
--
-- For the user data in each submission queue entry (sqe), we just pass the
-- index into the parallel arrays. This way we can easily get the request and
-- data when the completion entry comes back.
--
-- We maintain a list of free requests/buffers/iovecs which is just a stack of
-- free indices into the parallel array set. 
--
-- You'll probably need to increase the ulimit for MEMLOCK memory to run this,
--
-- try:
--  sudo prlimit -p "$$" --memlock=4000000:4000000
--
-- Alternatively, run as root or change the QUEUE_DEPTH to something much
-- smaller.
--
-------------------------------------------------------------------------------
with Ada.Text_IO;
with Ada.Unchecked_Conversion;
-- with GNAT.Ctrl_C;
with GNAT.OS_Lib;
with GNAT.Sockets;
with Interfaces;
with Interfaces.C;
with System.Address_Image;
with System.Storage_Elements;

with Liburing;

procedure Example is

    PORT : constant := 8069;

    Setup_Ret : Interfaces.C.int;

    Out_Of_Buffers_Exception : exception;
    Bad_Free_Exception : exception;

    -- uring params
    -- Will need to play with BUF_SIZE. Guessing that a page-sized entry (or
    -- multiple of page size) will offer the best performance, but who knows.
    QUEUE_DEPTH : constant := 256;
    PAGE_SIZE   : constant := 4096;
    BUF_SIZE    : constant := 1 * PAGE_SIZE;

    type Buffer_Index  is range 1..BUF_SIZE;
    type Request_Index is range 0..QUEUE_DEPTH-1;

    type RequestType is (EVENT_TYPE_ACCEPT, 
                         EVENT_TYPE_READ,
                         EVENT_TYPE_WRITE,
                         EVENT_TYPE_CLOSE);

    type Request is record
        Event_Type  : RequestType;
        Client_Socket : GNAT.Sockets.Socket_Type;
    end record;

    Ring : aliased Liburing.Ring;

    type Byte_Buf is array (Buffer_Index) of Interfaces.Unsigned_8
        with Convention => C, Alignment => PAGE_SIZE;

    ---------------------------------------------------------------------------
    -- Parallel request, buffer and iovec arrays:
    ---------------------------------------------------------------------------
    type Request_Array is array (Request_Index) of Request;

    -- Can have QUEUE_DEPTH operations in flight at any given time, so have a buffer
    -- set aside for each of them ahead of time.
    type Byte_Bufs is array (Request_Index) of Byte_Buf
        with Convention => C, Alignment => PAGE_SIZE;

    type IO_Vec_Arr is array (Request_Index) of aliased Liburing.IO_Vector
        with Convention => C;

    -- requests will have an index into the iovs array, which in turn will
    -- contain the address into the ByteBufs array.
    Requests : Request_Array;
    Bufs     : Byte_Bufs;
    iovs     : IO_Vec_Arr;

    Listen_Socket : GNAT.Sockets.Socket_Type;

    -- Since we aren't using malloc/free to allocate request & iovec storage,
    -- we need to keep a list of which buffer/request indices are free.
    -- This is managed as a stack for O(1) allocations/frees
    type Free_Lists is array (Request_Index) of Request_Index;
    Free_List     : Free_Lists;
    Free_List_Ptr : Integer := Natural(Request_Index'First) - 1;

    function To_File_Descriptor is new Ada.Unchecked_Conversion (Source => GNAT.Sockets.Socket_Type, Target => Interfaces.C.int);
    function To_Socket is new Ada.Unchecked_Conversion (Source => Interfaces.C.int, Target => GNAT.Sockets.Socket_Type);

    ---------------------------------------------------------------------------
    -- Alloc_Buf
    -- Return a free request/buffer/iovec index
    ---------------------------------------------------------------------------
    function Alloc_Buf return Request_Index is
        retIdx : Request_Index;
    begin
        if Free_List_Ptr < Integer(Request_Index'First) then
            raise Out_Of_Buffers_Exception;
        else
            retIdx := Request_Index(Free_List_Ptr);
            Free_List_Ptr := Free_List_Ptr - 1;
        end if;

        return Free_List(retIdx);
    end Alloc_Buf;

    ---------------------------------------------------------------------------
    -- Free_Buf
    -- Add a request/buffer/iovec to the freeList
    ---------------------------------------------------------------------------
    procedure Free_Buf (bufIdx : Request_Index) is
    begin
        if Free_List_Ptr > Integer(Request_Index'Last) then
            raise Bad_Free_Exception;
        else
            Free_List_Ptr := Free_List_Ptr + 1;
            Free_List(Request_Index(Free_List_Ptr)) := bufIdx;
        end if;
    end Free_Buf;

    ---------------------------------------------------------------------------
    -- Setup_Listening_Socket
    ---------------------------------------------------------------------------
    function Setup_Listening_Socket (Listen_Port : GNAT.Sockets.Port_Type) return GNAT.Sockets.Socket_Type is
        ret : GNAT.Sockets.Socket_Type;
    begin
        -- set up listening socket
        GNAT.Sockets.Create_Socket (ret, GNAT.Sockets.Family_Inet, GNAT.Sockets.Socket_Stream);
        GNAT.Sockets.Set_Socket_Option (ret, GNAT.Sockets.Socket_Level, (GNAT.Sockets.Reuse_Address, True));
        GNAT.Sockets.Bind_Socket (ret, (GNAT.Sockets.Family_Inet, GNAT.Sockets.Any_Inet_Addr, Listen_Port));
        GNAT.Sockets.Listen_Socket (ret, 10);
        return ret;
    end Setup_Listening_Socket;

    ---------------------------------------------------------------------------
    -- Add_Accept_Request
    ---------------------------------------------------------------------------
    procedure Add_Accept_Request (Server_Sock     : GNAT.Sockets.Socket_Type;
                                  Client_Addr     : access GNAT.Sockets.Sock_Addr_Type;
                                  Client_Addr_Len : access Interfaces.C.Unsigned) is
        sqe : access Liburing.Submission_Queue_Entry := Liburing.Get_Submission_Queue_Entry (Ring'Access);
        req : Request_Index := Alloc_Buf;
        ret : Interfaces.C.int;

        use Interfaces;
    begin
        Requests(req).Event_Type := EVENT_TYPE_ACCEPT;

        Liburing.Prep_Accept (sqe     => sqe,
                              fd      => Server_Sock,
                              addr    => Client_Addr,
                              addrLen => Client_Addr_Len,
                              flags   => 0);
        
        Liburing.Submission_Queue_Entry_Set_Data64 (sqe, Unsigned_64(req));

        -- Ret should be the number of entries we just submitted.
        ret := Liburing.Submit (Ring'Access);
    end Add_Accept_Request;

    ---------------------------------------------------------------------------
    -- Add_Recv_Request
    ---------------------------------------------------------------------------
    procedure Add_Read_Request (Client_Sock : GNAT.Sockets.Socket_Type) is
        sqe : access Liburing.Submission_Queue_Entry := Liburing.Get_Submission_Queue_Entry (Ring'Access);
        req : Request_Index := Alloc_Buf;
        ret : Interfaces.C.int;

        use Interfaces;
    begin
        -- tie the client socket fd to this request so we can reference it again.
        Requests(req).Event_Type := EVENT_TYPE_READ;
        Requests(req).Client_Socket := Client_Sock;

        Liburing.Prep_Read_Fixed (sqe       => sqe,
                                  fd        => To_File_Descriptor (Client_Sock),
                                  buf       => iovs(req).iov_base,
                                  nbytes    => Interfaces.C.unsigned(iovs(req).iov_len),
                                  offset    => 0,
                                  buf_index => Interfaces.C.int(req));

        Liburing.Submission_Queue_Entry_Set_Data64 (sqe, Unsigned_64(req));

        ret := Liburing.Submit (Ring'Access);
    end Add_Read_Request;

    ---------------------------------------------------------------------------
    -- Add_Write_Request
    ---------------------------------------------------------------------------
    procedure Add_Write_Request (Client_Sock : GNAT.Sockets.Socket_Type; src : String) is
        sqe : access Liburing.Submission_Queue_Entry := Liburing.Get_Submission_Queue_Entry (Ring'Access);
        req : Request_Index := Alloc_Buf;
        ret : Interfaces.C.int;
        dest : String(1..src'Length) with Address => iovs(req).iov_base;
        
        use Interfaces;
    begin
        -- Copy the source string into the write request buffer. Could get rid
        -- of this copy by re-using the buffer filled in by the read request.
        dest := src;

        Requests(req).Event_Type := EVENT_TYPE_WRITE;
        Requests(req).Client_Socket := Client_Sock;

        Liburing.Prep_Write_Fixed (sqe       => sqe,
                                   fd        => To_File_Descriptor (Client_Sock),
                                   buf       => iovs(req).iov_base,
                                   nbytes    => Interfaces.C.unsigned(src'Length),
                                   offset    => 0,
                                   buf_index => Interfaces.C.int(req));

        Liburing.Submission_Queue_Entry_Set_Data64 (sqe, Unsigned_64(req));

        ret := Liburing.Submit (Ring'Access);
    end Add_Write_Request;

    ---------------------------------------------------------------------------
    -- Add_Close_Request
    ---------------------------------------------------------------------------
    procedure Add_Close_Request (Client_Sock : GNAT.Sockets.Socket_Type) is
        sqe : access Liburing.Submission_Queue_Entry := Liburing.Get_Submission_Queue_Entry (Ring'Access);
        req : Request_Index := Alloc_Buf;
        ret : Interfaces.C.int;

        use Interfaces;
    begin
        Requests(req).Event_Type := EVENT_TYPE_CLOSE;

        Liburing.Prep_Close (sqe => sqe, sockfd => Client_Sock);

        Liburing.Submission_Queue_Entry_Set_Data64 (sqe, Unsigned_64(req));

        ret := Liburing.Submit (Ring'Access);
    end Add_Close_Request;

    ---------------------------------------------------------------------------
    -- Server_Loop
    ---------------------------------------------------------------------------
    procedure Server_Loop (Server_Sock : GNAT.Sockets.Socket_Type) is
        cqe           : access Liburing.Completion_Queue_Entry;
        clientAddr    : aliased GNAT.Sockets.Sock_Addr_Type;
        clientAddrLen : aliased Interfaces.C.Unsigned := clientAddr'Size;
        ret           : Interfaces.C.int;
        req           : Request_Index;

        use System.Storage_Elements;
        use Interfaces.C;
    begin
        Add_Accept_Request (Server_Sock, clientAddr'Access, clientAddrLen'Access);

        loop
            ret := Liburing.Wait_Completion_Queue_Entry (Ring'Access, cqe'Address);
            req := Request_Index(cqe.user_data);

            if ret < 0 then
                Ada.Text_IO.Put_Line ("Fatal: io_uring_wait_cqe" & ret'Image);
                GNAT.OS_Lib.OS_Exit (1);
            end if;

            if cqe.res < 0 then
                Ada.Text_IO.Put_Line ("Fatal: async request failed for event " &
                                      Requests(req).Event_Type'Image &
                                      ", error code was:" & cqe.res'Image);
                GNAT.OS_Lib.OS_Exit (1);
            end if;

            case Requests(req).Event_Type is
                when EVENT_TYPE_ACCEPT =>
                    Ada.Text_IO.Put_Line ("Accepted connection.");
                    Add_Accept_Request (Server_Sock, clientAddr'Access, clientAddrLen'Access);
                    
                    -- cqe.res has the FD of the client socket.
                    Add_Read_Request (To_Socket(cqe.res));

                when EVENT_TYPE_READ =>
                    Ada.Text_IO.Put ("Received" & cqe.res'Image & " bytes of data: ");

                    if cqe.res > 0 then
                        declare
                            msg : String(1..Integer(cqe.res)) with Address => iovs(req).iov_base;
                        begin
                            Ada.Text_IO.Put (msg);
                            Add_Write_Request (Requests(req).Client_Socket, msg);
                        end;
                    else
                        Ada.Text_IO.Put_Line ("");
                    end if;

                when EVENT_TYPE_WRITE =>
                    Ada.Text_IO.Put_Line ("Wrote" & cqe.res'Image & " bytes of data");
                    Add_Close_Request (Requests(req).Client_Socket);

                when EVENT_TYPE_CLOSE =>

                    Ada.Text_IO.Put_Line ("Closed connection.");
            end case;

            -- mark this request as processed.
            Free_Buf (req);
            Liburing.Completion_Queue_Entry_Seen (Ring'Access, cqe);
        end loop;
    end Server_Loop;

    use Interfaces.C;
begin

    -- GNAT.Ctrl_C.Install_Handler (Handle_Sigint'Access);

    -- setup IO buffers    
    for i in iovs'Range loop
        iovs(i).iov_base := Bufs(i)'Address;
        iovs(i).iov_len  := BUF_SIZE;

        -- all buffers are free to start.
        Free_Buf (i);
    end loop;

    Listen_Socket := Setup_Listening_Socket (PORT);

    Ada.Text_IO.Put_Line ("Listening on port " & PORT'Image & ", Ctrl+C to exit");

    Setup_Ret := Liburing.Queue_Init (QUEUE_DEPTH, Ring'Access, 0);

    if Setup_Ret /= 0 then
        Ada.Text_IO.Put_Line ("Fatal: io_uring_queue_init" & Setup_Ret'Image);
        return;
    end if;

    Setup_Ret := Liburing.Register_Buffers (Ring'Access, iovs(iovs'First)'Access, QUEUE_DEPTH);

    if Setup_Ret /= 0 then
        Ada.Text_IO.Put_Line ("Fatal: io_uring_register_buffers" & Setup_Ret'Image);
        return;
    end if;

    Server_Loop (Listen_Socket);

end Example;
