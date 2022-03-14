// Thin wrapper for inlined functions from liburing that aren't exported as
// symbols in liburing.a
#include <liburing.h>

int wrap_io_uring_opcode_supported(const struct io_uring_probe *p, int op)
{
	return io_uring_opcode_supported(p, op);
}

void wrap_io_uring_cq_advance(struct io_uring *ring, unsigned nr)
{
	io_uring_cq_advance(ring, nr);
}

void wrap_io_uring_cqe_seen(struct io_uring *ring, struct io_uring_cqe *cqe)
{
	io_uring_cqe_seen(ring, cqe);
}

void wrap_io_uring_sqe_set_data(struct io_uring_sqe *sqe, void *data)
{
	io_uring_sqe_set_data(sqe, data);
}

void *wrap_io_uring_cqe_get_data(const struct io_uring_cqe *cqe)
{
	return io_uring_cqe_get_data(cqe);
}

void wrap_io_uring_sqe_set_data64(struct io_uring_sqe *sqe, __u64 data)
{
	io_uring_sqe_set_data64(sqe, data);
}

__u64 wrap_io_uring_cqe_get_data64(const struct io_uring_cqe *cqe)
{
	return io_uring_cqe_get_data64(cqe);
}

void wrap_io_uring_sqe_set_flags(struct io_uring_sqe *sqe, unsigned flags)
{
	io_uring_sqe_set_flags(sqe, flags);
}

void wrap_io_uring_prep_rw(int op, struct io_uring_sqe *sqe, int fd,
				    const void *addr, unsigned len,
				    __u64 offset)
{
	io_uring_prep_rw(op, sqe, fd, addr, len, offset);
}

void wrap_io_uring_prep_splice(struct io_uring_sqe *sqe,
					int fd_in, int64_t off_in,
					int fd_out, int64_t off_out,
					unsigned int nbytes,
					unsigned int splice_flags)
{
	io_uring_prep_splice(sqe, fd_in, off_in, fd_out, off_out, nbytes, splice_flags);
}

void wrap_io_uring_prep_tee(struct io_uring_sqe *sqe,
				     int fd_in, int fd_out,
				     unsigned int nbytes,
				     unsigned int splice_flags)
{
	io_uring_prep_tee(sqe, fd_in, fd_out, nbytes, splice_flags);
}

void wrap_io_uring_prep_readv(struct io_uring_sqe *sqe, int fd,
				       const struct iovec *iovecs,
				       unsigned nr_vecs, __u64 offset)
{
	io_uring_prep_readv(sqe, fd, iovecs, nr_vecs, offset);
}

void wrap_io_uring_prep_readv2(struct io_uring_sqe *sqe, int fd,
				       const struct iovec *iovecs,
				       unsigned nr_vecs, __u64 offset, int flags)
{
	io_uring_prep_readv2(sqe, fd, iovecs, nr_vecs, offset, flags);
}

void wrap_io_uring_prep_read_fixed(struct io_uring_sqe *sqe, int fd,
					    void *buf, unsigned nbytes,
					    __u64 offset, int buf_index)
{
	io_uring_prep_read_fixed(sqe, fd, buf, nbytes, offset, buf_index);
}

void wrap_io_uring_prep_writev(struct io_uring_sqe *sqe, int fd,
					const struct iovec *iovecs,
					unsigned nr_vecs, __u64 offset)
{
	io_uring_prep_writev(sqe, fd, iovecs, nr_vecs, offset);
}

void wrap_io_uring_prep_writev2(struct io_uring_sqe *sqe, int fd,
				       const struct iovec *iovecs,
				       unsigned nr_vecs, __u64 offset, int flags)
{
	io_uring_prep_writev2(sqe, fd, iovecs, nr_vecs, offset, flags);
}

void wrap_io_uring_prep_write_fixed(struct io_uring_sqe *sqe, int fd,
					     const void *buf, unsigned nbytes,
					     __u64 offset, int buf_index)
{
    io_uring_prep_write_fixed(sqe, fd, buf, nbytes, offset, buf_index);
}

void wrap_io_uring_prep_recvmsg(struct io_uring_sqe *sqe, int fd,
					 struct msghdr *msg, unsigned flags)
{
	io_uring_prep_recvmsg(sqe, fd, msg, flags);
}

void wrap_io_uring_prep_sendmsg(struct io_uring_sqe *sqe, int fd,
					 const struct msghdr *msg, unsigned flags)
{
	io_uring_prep_sendmsg(sqe, fd, msg, flags);
}

void wrap_io_uring_prep_poll_add(struct io_uring_sqe *sqe, int fd,
					  unsigned poll_mask)
{
	io_uring_prep_poll_add(sqe, fd, poll_mask);
}

void wrap_io_uring_prep_poll_multishot(struct io_uring_sqe *sqe,
						int fd, unsigned poll_mask)
{
	io_uring_prep_poll_multishot(sqe, fd, poll_mask);
}

void wrap_io_uring_prep_poll_remove(struct io_uring_sqe *sqe,
					     __u64 user_data)
{
	io_uring_prep_poll_remove(sqe, user_data);
}

void wrap_io_uring_prep_poll_update(struct io_uring_sqe *sqe,
					     __u64 old_user_data,
					     __u64 new_user_data,
					     unsigned poll_mask, unsigned flags)
{
	io_uring_prep_poll_update(sqe, old_user_data, new_user_data, poll_mask, flags);
}

void wrap_io_uring_prep_fsync(struct io_uring_sqe *sqe, int fd,
				       unsigned fsync_flags)
{
	io_uring_prep_fsync(sqe, fd, fsync_flags);
}

void wrap_io_uring_prep_nop(struct io_uring_sqe *sqe)
{
	io_uring_prep_nop(sqe);
}

void wrap_io_uring_prep_timeout(struct io_uring_sqe *sqe,
					 struct __kernel_timespec *ts,
					 unsigned count, unsigned flags)
{
	io_uring_prep_timeout(sqe, ts, count, flags);
}

void wrap_io_uring_prep_timeout_remove(struct io_uring_sqe *sqe,
						__u64 user_data, unsigned flags)
{
	io_uring_prep_timeout_remove(sqe, user_data, flags);
}

void wrap_io_uring_prep_timeout_update(struct io_uring_sqe *sqe,
						struct __kernel_timespec *ts,
						__u64 user_data, unsigned flags)
{
	io_uring_prep_timeout_update(sqe, ts, user_data, flags);
}

void wrap_io_uring_prep_accept(struct io_uring_sqe *sqe, int fd,
					struct sockaddr *addr,
					socklen_t *addrlen, int flags)
{
	io_uring_prep_accept(sqe, fd, addr, addrlen, flags);
}

/* accept directly into the fixed file table */
void wrap_io_uring_prep_accept_direct(struct io_uring_sqe *sqe, int fd,
					       struct sockaddr *addr,
					       socklen_t *addrlen, int flags,
					       unsigned int file_index)
{
	io_uring_prep_accept_direct(sqe, fd, addr, addrlen, flags, file_index);
}

void wrap_io_uring_prep_cancel(struct io_uring_sqe *sqe,
					__u64 user_data, int flags)
{
	io_uring_prep_cancel(sqe, user_data, flags);
}

void wrap_io_uring_prep_link_timeout(struct io_uring_sqe *sqe,
					      struct __kernel_timespec *ts,
					      unsigned flags)
{
	io_uring_prep_link_timeout(sqe, ts, flags);
}

void wrap_io_uring_prep_connect(struct io_uring_sqe *sqe, int fd,
					 const struct sockaddr *addr,
					 socklen_t addrlen)
{
	io_uring_prep_connect(sqe, fd, addr, addrlen);
}

void wrap_io_uring_prep_files_update(struct io_uring_sqe *sqe,
					      int *fds, unsigned nr_fds,
					      int offset)
{
	io_uring_prep_files_update(sqe, fds, nr_fds, offset);
}

void wrap_io_uring_prep_fallocate(struct io_uring_sqe *sqe, int fd,
					   int mode, off_t offset, off_t len)
{
    io_uring_prep_fallocate(sqe, fd, mode, offset, len);
}

void wrap_io_uring_prep_openat(struct io_uring_sqe *sqe, int dfd,
					const char *path, int flags, mode_t mode)
{
	io_uring_prep_openat(sqe, dfd, path, flags, mode);
}

void wrap_io_uring_prep_openat_direct(struct io_uring_sqe *sqe,
					       int dfd, const char *path,
					       int flags, mode_t mode,
					       unsigned file_index)
{
	io_uring_prep_openat_direct(sqe, dfd, path, flags, mode, file_index);
}


void wrap_io_uring_prep_close(struct io_uring_sqe *sqe, int fd)
{
	io_uring_prep_close(sqe, fd);
}

void wrap_io_uring_prep_close_direct(struct io_uring_sqe *sqe,
					      unsigned file_index)
{
	io_uring_prep_close_direct(sqe, file_index);
}

void wrap_io_uring_prep_read(struct io_uring_sqe *sqe, int fd,
				      void *buf, unsigned nbytes, __u64 offset)
{
	io_uring_prep_read(sqe, fd, buf, nbytes, offset);
}

void wrap_io_uring_prep_write(struct io_uring_sqe *sqe, int fd,
				       const void *buf, unsigned nbytes, __u64 offset)
{
	io_uring_prep_write(sqe, fd, buf, nbytes, offset);
}

struct statx;
void wrap_io_uring_prep_statx(struct io_uring_sqe *sqe, int dfd,
				const char *path, int flags, unsigned mask,
				struct statx *statxbuf)
{
	io_uring_prep_statx(sqe, dfd, path, flags, mask, statxbuf);
}

void wrap_io_uring_prep_fadvise(struct io_uring_sqe *sqe, int fd,
					 __u64 offset, off_t len, int advice)
{
	io_uring_prep_fadvise(sqe, fd, offset, len, advice);
}

void wrap_io_uring_prep_madvise(struct io_uring_sqe *sqe, void *addr,
					 off_t length, int advice)
{
	io_uring_prep_madvise(sqe, addr, length, advice);
}

void wrap_io_uring_prep_send(struct io_uring_sqe *sqe, int sockfd,
				      const void *buf, size_t len, int flags)
{
	io_uring_prep_send(sqe, sockfd, buf, len, flags);
}

void wrap_io_uring_prep_recv(struct io_uring_sqe *sqe, int sockfd,
				      void *buf, size_t len, int flags)
{
	io_uring_prep_recv(sqe, sockfd, buf, len, flags);
}

void wrap_io_uring_prep_openat2(struct io_uring_sqe *sqe, int dfd,
					const char *path, struct open_how *how)
{
	io_uring_prep_openat2(sqe, dfd, path, how);
}

void wrap_io_uring_prep_openat2_direct(struct io_uring_sqe *sqe,
						int dfd, const char *path,
						struct open_how *how,
						unsigned file_index)
{
	io_uring_prep_openat2_direct(sqe, dfd, path, how, file_index);
}

struct epoll_event;
void wrap_io_uring_prep_epoll_ctl(struct io_uring_sqe *sqe, int epfd,
					   int fd, int op,
					   struct epoll_event *ev)
{
	io_uring_prep_epoll_ctl(sqe, epfd, fd, op, ev);
}

void wrap_io_uring_prep_provide_buffers(struct io_uring_sqe *sqe,
						 void *addr, int len, int nr,
						 int bgid, int bid)
{
    io_uring_prep_provide_buffers(sqe, addr, len, nr, bgid, bid);
}

void wrap_io_uring_prep_remove_buffers(struct io_uring_sqe *sqe,
						int nr, int bgid)
{
	io_uring_prep_rw(IORING_OP_REMOVE_BUFFERS, sqe, nr, NULL, 0, 0);
	sqe->buf_group = (__u16) bgid;
}

void wrap_io_uring_prep_shutdown(struct io_uring_sqe *sqe, int fd,
					  int how)
{
	io_uring_prep_rw(IORING_OP_SHUTDOWN, sqe, fd, NULL, (__u32) how, 0);
}

void wrap_io_uring_prep_unlinkat(struct io_uring_sqe *sqe, int dfd,
					  const char *path, int flags)
{
	io_uring_prep_rw(IORING_OP_UNLINKAT, sqe, dfd, path, 0, 0);
	sqe->unlink_flags = (__u32) flags;
}

void wrap_io_uring_prep_renameat(struct io_uring_sqe *sqe, int olddfd,
					  const char *oldpath, int newdfd,
					  const char *newpath, int flags)
{
	io_uring_prep_rw(IORING_OP_RENAMEAT, sqe, olddfd, oldpath, (__u32) newdfd,
				(uint64_t) (uintptr_t) newpath);
	sqe->rename_flags = (__u32) flags;
}

void wrap_io_uring_prep_sync_file_range(struct io_uring_sqe *sqe,
						 int fd, unsigned len,
						 __u64 offset, int flags)
{
	io_uring_prep_sync_file_range(sqe, fd, len, offset, flags);
}

void wrap_io_uring_prep_mkdirat(struct io_uring_sqe *sqe, int dfd,
					const char *path, mode_t mode)
{
	io_uring_prep_mkdirat(sqe, dfd, path, mode);
}

void wrap_io_uring_prep_symlinkat(struct io_uring_sqe *sqe,
					const char *target, int newdirfd, const char *linkpath)
{
	io_uring_prep_symlinkat(sqe, target, newdirfd, linkpath);
}

void wrap_io_uring_prep_linkat(struct io_uring_sqe *sqe, int olddfd,
					const char *oldpath, int newdfd,
					const char *newpath, int flags)
{
	io_uring_prep_linkat(sqe, olddfd, oldpath, newdfd, newpath, flags);
}

void wrap_io_uring_prep_msg_ring(struct io_uring_sqe *sqe, int fd,
					  unsigned int len, __u64 data,
					  unsigned int flags)
{
	io_uring_prep_msg_ring(sqe, fd, len, data, flags);
}

unsigned wrap_io_uring_sq_ready(const struct io_uring *ring)
{
    return io_uring_sq_ready(ring);
}

unsigned wrap_io_uring_sq_space_left(const struct io_uring *ring)
{
	return io_uring_sq_space_left(ring);
}

int wrap_io_uring_sqring_wait(struct io_uring *ring)
{
	return io_uring_sqring_wait(ring);
}

unsigned wrap_io_uring_cq_ready(const struct io_uring *ring)
{
	return io_uring_cq_ready(ring);
}

bool wrap_io_uring_cq_eventfd_enabled(const struct io_uring *ring)
{
	return io_uring_cq_eventfd_enabled(ring);
}

int wrap_io_uring_cq_eventfd_toggle(struct io_uring *ring, bool enabled)
{
	return io_uring_cq_eventfd_toggle(ring, enabled);
}

int wrap_io_uring_wait_cqe_nr(struct io_uring *ring, struct io_uring_cqe **cqe_ptr, unsigned wait_nr)
{
	return io_uring_wait_cqe_nr(ring, cqe_ptr, wait_nr);
}

int wrap_io_uring_peek_cqe(struct io_uring *ring, struct io_uring_cqe **cqe_ptr)
{
	return io_uring_peek_cqe(ring, cqe_ptr);
}

int wrap_io_uring_wait_cqe(struct io_uring *ring, struct io_uring_cqe **cqe_ptr)
{
	return io_uring_wait_cqe(ring, cqe_ptr);
}

struct io_uring_sqe *wrap_io_uring_get_sqe(struct io_uring *ring)
{
	return io_uring_get_sqe(ring);
}