LOCAL_DIR := $(GET_LOCAL_DIR)

LOCAL_COMPILEFLAGS := \
    -I$(LOCAL_DIR)/src/internal \
    -I$(LOCAL_DIR)/include \
    -I$(LOCAL_DIR)/third_party/include \

ifeq ($(ARCH),arm64)
MUSL_ARCH := aarch64
else ifeq ($(SUBARCH),x86-64)
MUSL_ARCH := x86_64
else
$(error Unsupported architecture $(ARCH) for musl build!)
endif

LOCAL_COMPILEFLAGS += -I$(LOCAL_DIR)/arch/$(MUSL_ARCH)

# The following are, more or less, from the upstream musl build.  The
# _XOPEN_SOURCE value in particular is taken from there, and is
# necessary for many POSIX declarations to be visible internally.  You
# can read about the semantics of it and the other feature test macros
# in |man 7 feature_test_macros| on Linux. musl exposes the minimum
# set of declarations or macro definitions allowed by those macros
# fairly carefully, and so also needs to undefine _ALL_SOURCE, so that
# it can define _BSD_SOURCE, _GNU_SOURCE, or _ALL_SOURCE in only
# certain source files.

# TODO(kulakowski) Clean up the junkier -Wno flags below.
LOCAL_CFLAGS := \
    -D_XOPEN_SOURCE=700 \
    -U_ALL_SOURCE \
    -Wno-sign-compare \
    -Wno-missing-braces \

ifeq ($(call TOBOOL,$(USE_CLANG)),true)
LOCAL_COMPILEFLAGS += -fno-stack-protector

# TODO(kulakowski) This is needed because clang, as an assembler,
# yells loudly about ununused options such as -finline which are
# currently unconditionally added to COMPILEFLAGS. Ideally these
# arguments would only be added to C or C++ targets.
LOCAL_COMPILEFLAGS += -Qunused-arguments

endif

# The upstream musl build uses this too.  It's necessary to avoid the
# compiler assuming things about library functions that might not be true.
# For example, without this, GCC assumes that calling free(PTR) doesn't
# need any stores to *PTR to have actually happened.
LOCAL_CFLAGS += -ffreestanding

LOCAL_SRCS := \
    $(LOCAL_DIR)/zircon/get_startup_handle.c \
    $(LOCAL_DIR)/zircon/internal.c \
    $(LOCAL_DIR)/zircon/thrd_get_zx_handle.c \
    $(LOCAL_DIR)/pthread/allocate.c \
    $(LOCAL_DIR)/pthread/pthread_atfork.c \
    $(LOCAL_DIR)/pthread/pthread_attr_destroy.c \
    $(LOCAL_DIR)/pthread/pthread_attr_get.c \
    $(LOCAL_DIR)/pthread/pthread_attr_init.c \
    $(LOCAL_DIR)/pthread/pthread_attr_setdetachstate.c \
    $(LOCAL_DIR)/pthread/pthread_attr_setguardsize.c \
    $(LOCAL_DIR)/pthread/pthread_attr_setinheritsched.c \
    $(LOCAL_DIR)/pthread/pthread_attr_setschedparam.c \
    $(LOCAL_DIR)/pthread/pthread_attr_setschedpolicy.c \
    $(LOCAL_DIR)/pthread/pthread_attr_setscope.c \
    $(LOCAL_DIR)/pthread/pthread_attr_setstacksize.c \
    $(LOCAL_DIR)/pthread/pthread_barrier_destroy.c \
    $(LOCAL_DIR)/pthread/pthread_barrier_init.c \
    $(LOCAL_DIR)/pthread/pthread_barrier_wait.c \
    $(LOCAL_DIR)/pthread/pthread_barrierattr_destroy.c \
    $(LOCAL_DIR)/pthread/pthread_barrierattr_init.c \
    $(LOCAL_DIR)/pthread/pthread_cancel.c \
    $(LOCAL_DIR)/pthread/pthread_cond_broadcast.c \
    $(LOCAL_DIR)/pthread/pthread_cond_destroy.c \
    $(LOCAL_DIR)/pthread/pthread_cond_init.c \
    $(LOCAL_DIR)/pthread/pthread_cond_signal.c \
    $(LOCAL_DIR)/pthread/pthread_cond_timedwait.c \
    $(LOCAL_DIR)/pthread/pthread_cond_wait.c \
    $(LOCAL_DIR)/pthread/pthread_condattr_destroy.c \
    $(LOCAL_DIR)/pthread/pthread_condattr_init.c \
    $(LOCAL_DIR)/pthread/pthread_condattr_setclock.c \
    $(LOCAL_DIR)/pthread/pthread_create.c \
    $(LOCAL_DIR)/pthread/pthread_detach.c \
    $(LOCAL_DIR)/pthread/pthread_equal.c \
    $(LOCAL_DIR)/pthread/pthread_getattr_np.c \
    $(LOCAL_DIR)/pthread/pthread_getconcurrency.c \
    $(LOCAL_DIR)/pthread/pthread_getcpuclockid.c \
    $(LOCAL_DIR)/pthread/pthread_getschedparam.c \
    $(LOCAL_DIR)/pthread/pthread_getspecific.c \
    $(LOCAL_DIR)/pthread/pthread_join.c \
    $(LOCAL_DIR)/pthread/pthread_key_create.c \
    $(LOCAL_DIR)/pthread/pthread_kill.c \
    $(LOCAL_DIR)/pthread/pthread_mutex_consistent.c \
    $(LOCAL_DIR)/pthread/pthread_mutex_destroy.c \
    $(LOCAL_DIR)/pthread/pthread_mutex_getprioceiling.c \
    $(LOCAL_DIR)/pthread/pthread_mutex_init.c \
    $(LOCAL_DIR)/pthread/pthread_mutex_lock.c \
    $(LOCAL_DIR)/pthread/pthread_mutex_setprioceiling.c \
    $(LOCAL_DIR)/pthread/pthread_mutex_timedlock.c \
    $(LOCAL_DIR)/pthread/pthread_mutex_trylock.c \
    $(LOCAL_DIR)/pthread/pthread_mutex_unlock.c \
    $(LOCAL_DIR)/pthread/pthread_mutexattr_destroy.c \
    $(LOCAL_DIR)/pthread/pthread_mutexattr_init.c \
    $(LOCAL_DIR)/pthread/pthread_mutexattr_setprotocol.c \
    $(LOCAL_DIR)/pthread/pthread_mutexattr_setrobust.c \
    $(LOCAL_DIR)/pthread/pthread_mutexattr_settype.c \
    $(LOCAL_DIR)/pthread/pthread_once.c \
    $(LOCAL_DIR)/pthread/pthread_rwlock_destroy.c \
    $(LOCAL_DIR)/pthread/pthread_rwlock_init.c \
    $(LOCAL_DIR)/pthread/pthread_rwlock_rdlock.c \
    $(LOCAL_DIR)/pthread/pthread_rwlock_timedrdlock.c \
    $(LOCAL_DIR)/pthread/pthread_rwlock_timedwrlock.c \
    $(LOCAL_DIR)/pthread/pthread_rwlock_tryrdlock.c \
    $(LOCAL_DIR)/pthread/pthread_rwlock_trywrlock.c \
    $(LOCAL_DIR)/pthread/pthread_rwlock_unlock.c \
    $(LOCAL_DIR)/pthread/pthread_rwlock_wrlock.c \
    $(LOCAL_DIR)/pthread/pthread_rwlockattr_destroy.c \
    $(LOCAL_DIR)/pthread/pthread_rwlockattr_init.c \
    $(LOCAL_DIR)/pthread/pthread_self.c \
    $(LOCAL_DIR)/pthread/pthread_setcancelstate.c \
    $(LOCAL_DIR)/pthread/pthread_setcanceltype.c \
    $(LOCAL_DIR)/pthread/pthread_setconcurrency.c \
    $(LOCAL_DIR)/pthread/pthread_setschedparam.c \
    $(LOCAL_DIR)/pthread/pthread_setschedprio.c \
    $(LOCAL_DIR)/pthread/pthread_setspecific.c \
    $(LOCAL_DIR)/pthread/pthread_sigmask.c \
    $(LOCAL_DIR)/pthread/pthread_spin_destroy.c \
    $(LOCAL_DIR)/pthread/pthread_spin_init.c \
    $(LOCAL_DIR)/pthread/pthread_spin_lock.c \
    $(LOCAL_DIR)/pthread/pthread_spin_trylock.c \
    $(LOCAL_DIR)/pthread/pthread_spin_unlock.c \
    $(LOCAL_DIR)/pthread/pthread_testcancel.c \
    $(LOCAL_DIR)/pthread/sem_destroy.c \
    $(LOCAL_DIR)/pthread/sem_getvalue.c \
    $(LOCAL_DIR)/pthread/sem_init.c \
    $(LOCAL_DIR)/pthread/sem_post.c \
    $(LOCAL_DIR)/pthread/sem_timedwait.c \
    $(LOCAL_DIR)/pthread/sem_trywait.c \
    $(LOCAL_DIR)/pthread/sem_unlink.c \
    $(LOCAL_DIR)/pthread/sem_wait.c \
    $(LOCAL_DIR)/src/complex/cabs.c \
    $(LOCAL_DIR)/src/complex/cabsf.c \
    $(LOCAL_DIR)/src/complex/cabsl.c \
    $(LOCAL_DIR)/src/complex/cacos.c \
    $(LOCAL_DIR)/src/complex/cacosf.c \
    $(LOCAL_DIR)/src/complex/cacosh.c \
    $(LOCAL_DIR)/src/complex/cacoshf.c \
    $(LOCAL_DIR)/src/complex/cacoshl.c \
    $(LOCAL_DIR)/src/complex/cacosl.c \
    $(LOCAL_DIR)/src/complex/carg.c \
    $(LOCAL_DIR)/src/complex/cargf.c \
    $(LOCAL_DIR)/src/complex/cargl.c \
    $(LOCAL_DIR)/src/complex/casin.c \
    $(LOCAL_DIR)/src/complex/casinf.c \
    $(LOCAL_DIR)/src/complex/casinh.c \
    $(LOCAL_DIR)/src/complex/casinhf.c \
    $(LOCAL_DIR)/src/complex/casinhl.c \
    $(LOCAL_DIR)/src/complex/casinl.c \
    $(LOCAL_DIR)/src/complex/catanh.c \
    $(LOCAL_DIR)/src/complex/catanhf.c \
    $(LOCAL_DIR)/src/complex/catanhl.c \
    $(LOCAL_DIR)/src/complex/ccos.c \
    $(LOCAL_DIR)/src/complex/ccosf.c \
    $(LOCAL_DIR)/src/complex/ccoshl.c \
    $(LOCAL_DIR)/src/complex/ccosl.c \
    $(LOCAL_DIR)/src/complex/cexpl.c \
    $(LOCAL_DIR)/src/complex/cimag.c \
    $(LOCAL_DIR)/src/complex/cimagf.c \
    $(LOCAL_DIR)/src/complex/cimagl.c \
    $(LOCAL_DIR)/src/complex/clog.c \
    $(LOCAL_DIR)/src/complex/clogf.c \
    $(LOCAL_DIR)/src/complex/clogl.c \
    $(LOCAL_DIR)/src/complex/conj.c \
    $(LOCAL_DIR)/src/complex/conjf.c \
    $(LOCAL_DIR)/src/complex/conjl.c \
    $(LOCAL_DIR)/src/complex/cpow.c \
    $(LOCAL_DIR)/src/complex/cpowf.c \
    $(LOCAL_DIR)/src/complex/cpowl.c \
    $(LOCAL_DIR)/src/complex/cproj.c \
    $(LOCAL_DIR)/src/complex/cprojf.c \
    $(LOCAL_DIR)/src/complex/cprojl.c \
    $(LOCAL_DIR)/src/complex/creal.c \
    $(LOCAL_DIR)/src/complex/crealf.c \
    $(LOCAL_DIR)/src/complex/creall.c \
    $(LOCAL_DIR)/src/complex/csin.c \
    $(LOCAL_DIR)/src/complex/csinf.c \
    $(LOCAL_DIR)/src/complex/csinhl.c \
    $(LOCAL_DIR)/src/complex/csinl.c \
    $(LOCAL_DIR)/src/complex/csqrtl.c \
    $(LOCAL_DIR)/src/complex/ctan.c \
    $(LOCAL_DIR)/src/complex/ctanf.c \
    $(LOCAL_DIR)/src/complex/ctanhl.c \
    $(LOCAL_DIR)/src/complex/ctanl.c \
    $(LOCAL_DIR)/src/conf/confstr.c \
    $(LOCAL_DIR)/src/conf/fpathconf.c \
    $(LOCAL_DIR)/src/conf/pathconf.c \
    $(LOCAL_DIR)/src/conf/sysconf.c \
    $(LOCAL_DIR)/src/ctype/__ctype_b_loc.c \
    $(LOCAL_DIR)/src/ctype/__ctype_get_mb_cur_max.c \
    $(LOCAL_DIR)/src/ctype/__ctype_tolower_loc.c \
    $(LOCAL_DIR)/src/ctype/__ctype_toupper_loc.c \
    $(LOCAL_DIR)/src/ctype/isalnum.c \
    $(LOCAL_DIR)/src/ctype/isalpha.c \
    $(LOCAL_DIR)/src/ctype/isascii.c \
    $(LOCAL_DIR)/src/ctype/isblank.c \
    $(LOCAL_DIR)/src/ctype/iscntrl.c \
    $(LOCAL_DIR)/src/ctype/isdigit.c \
    $(LOCAL_DIR)/src/ctype/isgraph.c \
    $(LOCAL_DIR)/src/ctype/islower.c \
    $(LOCAL_DIR)/src/ctype/isprint.c \
    $(LOCAL_DIR)/src/ctype/ispunct.c \
    $(LOCAL_DIR)/src/ctype/isspace.c \
    $(LOCAL_DIR)/src/ctype/isupper.c \
    $(LOCAL_DIR)/src/ctype/iswalnum.c \
    $(LOCAL_DIR)/src/ctype/iswalpha.c \
    $(LOCAL_DIR)/src/ctype/iswblank.c \
    $(LOCAL_DIR)/src/ctype/iswcntrl.c \
    $(LOCAL_DIR)/src/ctype/iswctype.c \
    $(LOCAL_DIR)/src/ctype/iswdigit.c \
    $(LOCAL_DIR)/src/ctype/iswgraph.c \
    $(LOCAL_DIR)/src/ctype/iswlower.c \
    $(LOCAL_DIR)/src/ctype/iswprint.c \
    $(LOCAL_DIR)/src/ctype/iswpunct.c \
    $(LOCAL_DIR)/src/ctype/iswspace.c \
    $(LOCAL_DIR)/src/ctype/iswupper.c \
    $(LOCAL_DIR)/src/ctype/iswxdigit.c \
    $(LOCAL_DIR)/src/ctype/isxdigit.c \
    $(LOCAL_DIR)/src/ctype/toascii.c \
    $(LOCAL_DIR)/src/ctype/tolower.c \
    $(LOCAL_DIR)/src/ctype/toupper.c \
    $(LOCAL_DIR)/src/ctype/towctrans.c \
    $(LOCAL_DIR)/src/ctype/wcswidth.c \
    $(LOCAL_DIR)/src/ctype/wctrans.c \
    $(LOCAL_DIR)/src/ctype/wcwidth.c \
    $(LOCAL_DIR)/src/dirent/alphasort.c \
    $(LOCAL_DIR)/src/dirent/scandir.c \
    $(LOCAL_DIR)/src/dirent/versionsort.c \
    $(LOCAL_DIR)/src/env/__environ.c \
    $(LOCAL_DIR)/src/env/__libc_start_main.c \
    $(LOCAL_DIR)/src/env/__stack_chk_fail.c \
    $(LOCAL_DIR)/src/env/clearenv.c \
    $(LOCAL_DIR)/src/env/getenv.c \
    $(LOCAL_DIR)/src/env/putenv.c \
    $(LOCAL_DIR)/src/env/setenv.c \
    $(LOCAL_DIR)/src/env/unsetenv.c \
    $(LOCAL_DIR)/src/errno/__errno_location.c \
    $(LOCAL_DIR)/src/errno/strerror.c \
    $(LOCAL_DIR)/src/exit/__cxa_thread_atexit.c \
    $(LOCAL_DIR)/src/exit/_Exit.c \
    $(LOCAL_DIR)/src/exit/abort.c \
    $(LOCAL_DIR)/src/exit/assert.c \
    $(LOCAL_DIR)/src/exit/at_quick_exit.c \
    $(LOCAL_DIR)/src/exit/atexit.c \
    $(LOCAL_DIR)/src/exit/exit.c \
    $(LOCAL_DIR)/src/exit/quick_exit.c \
    $(LOCAL_DIR)/src/fcntl/creat.c \
    $(LOCAL_DIR)/src/fenv/__flt_rounds.c \
    $(LOCAL_DIR)/src/fenv/fegetexceptflag.c \
    $(LOCAL_DIR)/src/fenv/feholdexcept.c \
    $(LOCAL_DIR)/src/fenv/fesetexceptflag.c \
    $(LOCAL_DIR)/src/fenv/fesetround.c \
    $(LOCAL_DIR)/src/fenv/feupdateenv.c \
    $(LOCAL_DIR)/src/internal/floatscan.c \
    $(LOCAL_DIR)/src/internal/intscan.c \
    $(LOCAL_DIR)/src/internal/libc.c \
    $(LOCAL_DIR)/src/internal/shgetc.c \
    $(LOCAL_DIR)/src/ipc/ftok.c \
    $(LOCAL_DIR)/src/ipc/msgctl.c \
    $(LOCAL_DIR)/src/ipc/msgget.c \
    $(LOCAL_DIR)/src/ipc/msgrcv.c \
    $(LOCAL_DIR)/src/ipc/msgsnd.c \
    $(LOCAL_DIR)/src/ipc/semctl.c \
    $(LOCAL_DIR)/src/ipc/semget.c \
    $(LOCAL_DIR)/src/ipc/semop.c \
    $(LOCAL_DIR)/src/ipc/semtimedop.c \
    $(LOCAL_DIR)/src/ipc/shmat.c \
    $(LOCAL_DIR)/src/ipc/shmctl.c \
    $(LOCAL_DIR)/src/ipc/shmdt.c \
    $(LOCAL_DIR)/src/ipc/shmget.c \
    $(LOCAL_DIR)/src/ldso/dlclose.c \
    $(LOCAL_DIR)/src/ldso/dlerror.c \
    $(LOCAL_DIR)/src/ldso/dlinfo.c \
    $(LOCAL_DIR)/src/legacy/cuserid.c \
    $(LOCAL_DIR)/src/legacy/daemon.c \
    $(LOCAL_DIR)/src/legacy/err.c \
    $(LOCAL_DIR)/src/legacy/euidaccess.c \
    $(LOCAL_DIR)/src/legacy/futimes.c \
    $(LOCAL_DIR)/src/legacy/getdtablesize.c \
    $(LOCAL_DIR)/src/legacy/getloadavg.c \
    $(LOCAL_DIR)/src/legacy/getpagesize.c \
    $(LOCAL_DIR)/src/legacy/getpass.c \
    $(LOCAL_DIR)/src/legacy/getusershell.c \
    $(LOCAL_DIR)/src/legacy/isastream.c \
    $(LOCAL_DIR)/src/legacy/lutimes.c \
    $(LOCAL_DIR)/src/legacy/ulimit.c \
    $(LOCAL_DIR)/src/legacy/utmpx.c \
    $(LOCAL_DIR)/src/linux/adjtime.c \
    $(LOCAL_DIR)/src/linux/cache.c \
    $(LOCAL_DIR)/src/linux/flock.c \
    $(LOCAL_DIR)/src/linux/sethostname.c \
    $(LOCAL_DIR)/src/linux/settimeofday.c \
    $(LOCAL_DIR)/src/linux/stime.c \
    $(LOCAL_DIR)/src/linux/utimes.c \
    $(LOCAL_DIR)/src/locale/__lctrans.c \
    $(LOCAL_DIR)/src/locale/__mo_lookup.c \
    $(LOCAL_DIR)/src/locale/bind_textdomain_codeset.c \
    $(LOCAL_DIR)/src/locale/c_locale.c \
    $(LOCAL_DIR)/src/locale/catclose.c \
    $(LOCAL_DIR)/src/locale/catgets.c \
    $(LOCAL_DIR)/src/locale/catopen.c \
    $(LOCAL_DIR)/src/locale/dcngettext.c \
    $(LOCAL_DIR)/src/locale/duplocale.c \
    $(LOCAL_DIR)/src/locale/freelocale.c \
    $(LOCAL_DIR)/src/locale/iconv.c \
    $(LOCAL_DIR)/src/locale/langinfo.c \
    $(LOCAL_DIR)/src/locale/locale_map.c \
    $(LOCAL_DIR)/src/locale/localeconv.c \
    $(LOCAL_DIR)/src/locale/newlocale.c \
    $(LOCAL_DIR)/src/locale/pleval.c \
    $(LOCAL_DIR)/src/locale/setlocale.c \
    $(LOCAL_DIR)/src/locale/strcoll.c \
    $(LOCAL_DIR)/src/locale/strfmon.c \
    $(LOCAL_DIR)/src/locale/strxfrm.c \
    $(LOCAL_DIR)/src/locale/textdomain.c \
    $(LOCAL_DIR)/src/locale/uselocale.c \
    $(LOCAL_DIR)/src/locale/wcscoll.c \
    $(LOCAL_DIR)/src/locale/wcsxfrm.c \
    $(LOCAL_DIR)/src/math/__expo2.c \
    $(LOCAL_DIR)/src/math/__expo2f.c \
    $(LOCAL_DIR)/src/math/__fpclassify.c \
    $(LOCAL_DIR)/src/math/__fpclassifyf.c \
    $(LOCAL_DIR)/src/math/__fpclassifyl.c \
    $(LOCAL_DIR)/src/math/__invtrigl.c \
    $(LOCAL_DIR)/src/math/__signbit.c \
    $(LOCAL_DIR)/src/math/__signbitf.c \
    $(LOCAL_DIR)/src/math/__signbitl.c \
    $(LOCAL_DIR)/src/math/acosh.c \
    $(LOCAL_DIR)/src/math/acoshf.c \
    $(LOCAL_DIR)/src/math/acoshl.c \
    $(LOCAL_DIR)/src/math/asinh.c \
    $(LOCAL_DIR)/src/math/asinhf.c \
    $(LOCAL_DIR)/src/math/asinhl.c \
    $(LOCAL_DIR)/src/math/atanh.c \
    $(LOCAL_DIR)/src/math/atanhf.c \
    $(LOCAL_DIR)/src/math/atanhl.c \
    $(LOCAL_DIR)/src/math/ceil.c \
    $(LOCAL_DIR)/src/math/ceilf.c \
    $(LOCAL_DIR)/src/math/copysign.c \
    $(LOCAL_DIR)/src/math/copysignf.c \
    $(LOCAL_DIR)/src/math/copysignl.c \
    $(LOCAL_DIR)/src/math/cosh.c \
    $(LOCAL_DIR)/src/math/coshf.c \
    $(LOCAL_DIR)/src/math/coshl.c \
    $(LOCAL_DIR)/src/math/cosl.c \
    $(LOCAL_DIR)/src/math/exp10.c \
    $(LOCAL_DIR)/src/math/exp10f.c \
    $(LOCAL_DIR)/src/math/exp10l.c \
    $(LOCAL_DIR)/src/math/fdim.c \
    $(LOCAL_DIR)/src/math/fdimf.c \
    $(LOCAL_DIR)/src/math/fdiml.c \
    $(LOCAL_DIR)/src/math/finite.c \
    $(LOCAL_DIR)/src/math/finitef.c \
    $(LOCAL_DIR)/src/math/floor.c \
    $(LOCAL_DIR)/src/math/floorf.c \
    $(LOCAL_DIR)/src/math/fmax.c \
    $(LOCAL_DIR)/src/math/fmaxf.c \
    $(LOCAL_DIR)/src/math/fmaxl.c \
    $(LOCAL_DIR)/src/math/fmin.c \
    $(LOCAL_DIR)/src/math/fminf.c \
    $(LOCAL_DIR)/src/math/fminl.c \
    $(LOCAL_DIR)/src/math/fmod.c \
    $(LOCAL_DIR)/src/math/fmodf.c \
    $(LOCAL_DIR)/src/math/frexp.c \
    $(LOCAL_DIR)/src/math/frexpf.c \
    $(LOCAL_DIR)/src/math/frexpl.c \
    $(LOCAL_DIR)/src/math/hypot.c \
    $(LOCAL_DIR)/src/math/hypotf.c \
    $(LOCAL_DIR)/src/math/hypotl.c \
    $(LOCAL_DIR)/src/math/ilogb.c \
    $(LOCAL_DIR)/src/math/ilogbf.c \
    $(LOCAL_DIR)/src/math/ilogbl.c \
    $(LOCAL_DIR)/src/math/ldexp.c \
    $(LOCAL_DIR)/src/math/ldexpf.c \
    $(LOCAL_DIR)/src/math/ldexpl.c \
    $(LOCAL_DIR)/src/math/lgamma.c \
    $(LOCAL_DIR)/src/math/lgammaf.c \
    $(LOCAL_DIR)/src/math/llround.c \
    $(LOCAL_DIR)/src/math/llroundf.c \
    $(LOCAL_DIR)/src/math/llroundl.c \
    $(LOCAL_DIR)/src/math/logb.c \
    $(LOCAL_DIR)/src/math/logbf.c \
    $(LOCAL_DIR)/src/math/logbl.c \
    $(LOCAL_DIR)/src/math/lround.c \
    $(LOCAL_DIR)/src/math/lroundf.c \
    $(LOCAL_DIR)/src/math/lroundl.c \
    $(LOCAL_DIR)/src/math/modf.c \
    $(LOCAL_DIR)/src/math/modff.c \
    $(LOCAL_DIR)/src/math/modfl.c \
    $(LOCAL_DIR)/src/math/nan.c \
    $(LOCAL_DIR)/src/math/nanf.c \
    $(LOCAL_DIR)/src/math/nanl.c \
    $(LOCAL_DIR)/src/math/nearbyint.c \
    $(LOCAL_DIR)/src/math/nearbyintf.c \
    $(LOCAL_DIR)/src/math/nearbyintl.c \
    $(LOCAL_DIR)/src/math/nextafter.c \
    $(LOCAL_DIR)/src/math/nextafterf.c \
    $(LOCAL_DIR)/src/math/nextafterl.c \
    $(LOCAL_DIR)/src/math/nexttoward.c \
    $(LOCAL_DIR)/src/math/nexttowardf.c \
    $(LOCAL_DIR)/src/math/nexttowardl.c \
    $(LOCAL_DIR)/src/math/remainder.c \
    $(LOCAL_DIR)/src/math/remainderf.c \
    $(LOCAL_DIR)/src/math/remquo.c \
    $(LOCAL_DIR)/src/math/remquof.c \
    $(LOCAL_DIR)/src/math/remquol.c \
    $(LOCAL_DIR)/src/math/rint.c \
    $(LOCAL_DIR)/src/math/rintf.c \
    $(LOCAL_DIR)/src/math/round.c \
    $(LOCAL_DIR)/src/math/roundf.c \
    $(LOCAL_DIR)/src/math/roundl.c \
    $(LOCAL_DIR)/src/math/scalbln.c \
    $(LOCAL_DIR)/src/math/scalblnf.c \
    $(LOCAL_DIR)/src/math/scalblnl.c \
    $(LOCAL_DIR)/src/math/scalbn.c \
    $(LOCAL_DIR)/src/math/scalbnf.c \
    $(LOCAL_DIR)/src/math/scalbnl.c \
    $(LOCAL_DIR)/src/math/signgam.c \
    $(LOCAL_DIR)/src/math/significand.c \
    $(LOCAL_DIR)/src/math/significandf.c \
    $(LOCAL_DIR)/src/math/sincosl.c \
    $(LOCAL_DIR)/src/math/sinh.c \
    $(LOCAL_DIR)/src/math/sinhf.c \
    $(LOCAL_DIR)/src/math/sinhl.c \
    $(LOCAL_DIR)/src/math/sinl.c \
    $(LOCAL_DIR)/src/math/tanh.c \
    $(LOCAL_DIR)/src/math/tanhf.c \
    $(LOCAL_DIR)/src/math/tanhl.c \
    $(LOCAL_DIR)/src/math/tanl.c \
    $(LOCAL_DIR)/src/math/tgamma.c \
    $(LOCAL_DIR)/src/math/tgammaf.c \
    $(LOCAL_DIR)/src/math/trunc.c \
    $(LOCAL_DIR)/src/math/truncf.c \
    $(LOCAL_DIR)/src/misc/a64l.c \
    $(LOCAL_DIR)/src/misc/basename.c \
    $(LOCAL_DIR)/src/misc/dirname.c \
    $(LOCAL_DIR)/src/misc/ffs.c \
    $(LOCAL_DIR)/src/misc/ffsl.c \
    $(LOCAL_DIR)/src/misc/ffsll.c \
    $(LOCAL_DIR)/src/misc/forkpty.c \
    $(LOCAL_DIR)/src/misc/get_current_dir_name.c \
    $(LOCAL_DIR)/src/misc/getauxval.c \
    $(LOCAL_DIR)/src/misc/getdomainname.c \
    $(LOCAL_DIR)/src/misc/gethostid.c \
    $(LOCAL_DIR)/src/misc/getopt.c \
    $(LOCAL_DIR)/src/misc/getopt_long.c \
    $(LOCAL_DIR)/src/misc/getpriority.c \
    $(LOCAL_DIR)/src/misc/getrlimit.c \
    $(LOCAL_DIR)/src/misc/getrusage.c \
    $(LOCAL_DIR)/src/misc/getsubopt.c \
    $(LOCAL_DIR)/src/misc/initgroups.c \
    $(LOCAL_DIR)/src/misc/issetugid.c \
    $(LOCAL_DIR)/src/misc/lockf.c \
    $(LOCAL_DIR)/src/misc/login_tty.c \
    $(LOCAL_DIR)/src/misc/mntent.c \
    $(LOCAL_DIR)/src/misc/openpty.c \
    $(LOCAL_DIR)/src/misc/ptsname.c \
    $(LOCAL_DIR)/src/misc/pty.c \
    $(LOCAL_DIR)/src/misc/setdomainname.c \
    $(LOCAL_DIR)/src/misc/setpriority.c \
    $(LOCAL_DIR)/src/misc/setrlimit.c \
    $(LOCAL_DIR)/src/misc/syslog.c \
    $(LOCAL_DIR)/src/misc/wordexp.c \
    $(LOCAL_DIR)/src/mman/madvise.c \
    $(LOCAL_DIR)/src/mman/mlock.c \
    $(LOCAL_DIR)/src/mman/mlockall.c \
    $(LOCAL_DIR)/src/mman/mmap.c \
    $(LOCAL_DIR)/src/mman/mprotect.c \
    $(LOCAL_DIR)/src/mman/msync.c \
    $(LOCAL_DIR)/src/mman/munlock.c \
    $(LOCAL_DIR)/src/mman/munlockall.c \
    $(LOCAL_DIR)/src/mman/munmap.c \
    $(LOCAL_DIR)/src/mman/posix_madvise.c \
    $(LOCAL_DIR)/src/mman/shm_open.c \
    $(LOCAL_DIR)/src/multibyte/btowc.c \
    $(LOCAL_DIR)/src/multibyte/c16rtomb.c \
    $(LOCAL_DIR)/src/multibyte/c32rtomb.c \
    $(LOCAL_DIR)/src/multibyte/internal.c \
    $(LOCAL_DIR)/src/multibyte/mblen.c \
    $(LOCAL_DIR)/src/multibyte/mbrlen.c \
    $(LOCAL_DIR)/src/multibyte/mbrtoc16.c \
    $(LOCAL_DIR)/src/multibyte/mbrtoc32.c \
    $(LOCAL_DIR)/src/multibyte/mbrtowc.c \
    $(LOCAL_DIR)/src/multibyte/mbsinit.c \
    $(LOCAL_DIR)/src/multibyte/mbsnrtowcs.c \
    $(LOCAL_DIR)/src/multibyte/mbsrtowcs.c \
    $(LOCAL_DIR)/src/multibyte/mbstowcs.c \
    $(LOCAL_DIR)/src/multibyte/mbtowc.c \
    $(LOCAL_DIR)/src/multibyte/wcrtomb.c \
    $(LOCAL_DIR)/src/multibyte/wcsnrtombs.c \
    $(LOCAL_DIR)/src/multibyte/wcsrtombs.c \
    $(LOCAL_DIR)/src/multibyte/wcstombs.c \
    $(LOCAL_DIR)/src/multibyte/wctob.c \
    $(LOCAL_DIR)/src/multibyte/wctomb.c \
    $(LOCAL_DIR)/src/network/accept.c \
    $(LOCAL_DIR)/src/network/dn_comp.c \
    $(LOCAL_DIR)/src/network/dn_expand.c \
    $(LOCAL_DIR)/src/network/dn_skipname.c \
    $(LOCAL_DIR)/src/network/dns_parse.c \
    $(LOCAL_DIR)/src/network/ent.c \
    $(LOCAL_DIR)/src/network/ether.c \
    $(LOCAL_DIR)/src/network/gai_strerror.c \
    $(LOCAL_DIR)/src/network/gethostbyaddr.c \
    $(LOCAL_DIR)/src/network/gethostbyaddr_r.c \
    $(LOCAL_DIR)/src/network/gethostbyname.c \
    $(LOCAL_DIR)/src/network/gethostbyname2.c \
    $(LOCAL_DIR)/src/network/gethostbyname2_r.c \
    $(LOCAL_DIR)/src/network/gethostbyname_r.c \
    $(LOCAL_DIR)/src/network/getifaddrs.c \
    $(LOCAL_DIR)/src/network/getnameinfo.c \
    $(LOCAL_DIR)/src/network/getservbyname.c \
    $(LOCAL_DIR)/src/network/getservbyname_r.c \
    $(LOCAL_DIR)/src/network/getservbyport.c \
    $(LOCAL_DIR)/src/network/getservbyport_r.c \
    $(LOCAL_DIR)/src/network/h_errno.c \
    $(LOCAL_DIR)/src/network/herror.c \
    $(LOCAL_DIR)/src/network/hstrerror.c \
    $(LOCAL_DIR)/src/network/htonl.c \
    $(LOCAL_DIR)/src/network/htons.c \
    $(LOCAL_DIR)/src/network/if_freenameindex.c \
    $(LOCAL_DIR)/src/network/if_indextoname.c \
    $(LOCAL_DIR)/src/network/if_nameindex.c \
    $(LOCAL_DIR)/src/network/if_nametoindex.c \
    $(LOCAL_DIR)/src/network/in6addr_any.c \
    $(LOCAL_DIR)/src/network/in6addr_loopback.c \
    $(LOCAL_DIR)/src/network/inet_addr.c \
    $(LOCAL_DIR)/src/network/inet_aton.c \
    $(LOCAL_DIR)/src/network/inet_legacy.c \
    $(LOCAL_DIR)/src/network/inet_ntoa.c \
    $(LOCAL_DIR)/src/network/inet_ntop.c \
    $(LOCAL_DIR)/src/network/inet_pton.c \
    $(LOCAL_DIR)/src/network/lookup_ipliteral.c \
    $(LOCAL_DIR)/src/network/lookup_name.c \
    $(LOCAL_DIR)/src/network/lookup_serv.c \
    $(LOCAL_DIR)/src/network/netlink.c \
    $(LOCAL_DIR)/src/network/netname.c \
    $(LOCAL_DIR)/src/network/ns_parse.c \
    $(LOCAL_DIR)/src/network/ntohl.c \
    $(LOCAL_DIR)/src/network/ntohs.c \
    $(LOCAL_DIR)/src/network/proto.c \
    $(LOCAL_DIR)/src/network/recv.c \
    $(LOCAL_DIR)/src/network/res_init.c \
    $(LOCAL_DIR)/src/network/res_mkquery.c \
    $(LOCAL_DIR)/src/network/res_msend.c \
    $(LOCAL_DIR)/src/network/res_query.c \
    $(LOCAL_DIR)/src/network/res_querydomain.c \
    $(LOCAL_DIR)/src/network/res_send.c \
    $(LOCAL_DIR)/src/network/res_state.c \
    $(LOCAL_DIR)/src/network/resolvconf.c \
    $(LOCAL_DIR)/src/network/send.c \
    $(LOCAL_DIR)/src/network/serv.c \
    $(LOCAL_DIR)/src/passwd/fgetgrent.c \
    $(LOCAL_DIR)/src/passwd/fgetpwent.c \
    $(LOCAL_DIR)/src/passwd/fgetspent.c \
    $(LOCAL_DIR)/src/passwd/getgr_a.c \
    $(LOCAL_DIR)/src/passwd/getgr_r.c \
    $(LOCAL_DIR)/src/passwd/getgrent.c \
    $(LOCAL_DIR)/src/passwd/getgrent_a.c \
    $(LOCAL_DIR)/src/passwd/getgrouplist.c \
    $(LOCAL_DIR)/src/passwd/getpw_a.c \
    $(LOCAL_DIR)/src/passwd/getpw_r.c \
    $(LOCAL_DIR)/src/passwd/getpwent.c \
    $(LOCAL_DIR)/src/passwd/getpwent_a.c \
    $(LOCAL_DIR)/src/passwd/getspent.c \
    $(LOCAL_DIR)/src/passwd/getspnam.c \
    $(LOCAL_DIR)/src/passwd/getspnam_r.c \
    $(LOCAL_DIR)/src/passwd/lckpwdf.c \
    $(LOCAL_DIR)/src/passwd/nscd_query.c \
    $(LOCAL_DIR)/src/passwd/putgrent.c \
    $(LOCAL_DIR)/src/passwd/putpwent.c \
    $(LOCAL_DIR)/src/passwd/putspent.c \
    $(LOCAL_DIR)/src/prng/__rand48_step.c \
    $(LOCAL_DIR)/src/prng/__seed48.c \
    $(LOCAL_DIR)/src/prng/drand48.c \
    $(LOCAL_DIR)/src/prng/lcong48.c \
    $(LOCAL_DIR)/src/prng/lrand48.c \
    $(LOCAL_DIR)/src/prng/mrand48.c \
    $(LOCAL_DIR)/src/prng/rand.c \
    $(LOCAL_DIR)/src/prng/rand_r.c \
    $(LOCAL_DIR)/src/prng/random.c \
    $(LOCAL_DIR)/src/prng/seed48.c \
    $(LOCAL_DIR)/src/prng/srand48.c \
    $(LOCAL_DIR)/src/process/execl.c \
    $(LOCAL_DIR)/src/process/execle.c \
    $(LOCAL_DIR)/src/process/execlp.c \
    $(LOCAL_DIR)/src/process/execv.c \
    $(LOCAL_DIR)/src/process/execve.c \
    $(LOCAL_DIR)/src/process/execvp.c \
    $(LOCAL_DIR)/src/process/fexecve.c \
    $(LOCAL_DIR)/src/process/fork.c \
    $(LOCAL_DIR)/src/process/posix_spawn.c \
    $(LOCAL_DIR)/src/process/posix_spawn_file_actions_addclose.c \
    $(LOCAL_DIR)/src/process/posix_spawn_file_actions_adddup2.c \
    $(LOCAL_DIR)/src/process/posix_spawn_file_actions_addopen.c \
    $(LOCAL_DIR)/src/process/posix_spawn_file_actions_destroy.c \
    $(LOCAL_DIR)/src/process/posix_spawn_file_actions_init.c \
    $(LOCAL_DIR)/src/process/posix_spawnattr_destroy.c \
    $(LOCAL_DIR)/src/process/posix_spawnattr_getflags.c \
    $(LOCAL_DIR)/src/process/posix_spawnattr_getpgroup.c \
    $(LOCAL_DIR)/src/process/posix_spawnattr_getsigdefault.c \
    $(LOCAL_DIR)/src/process/posix_spawnattr_getsigmask.c \
    $(LOCAL_DIR)/src/process/posix_spawnattr_init.c \
    $(LOCAL_DIR)/src/process/posix_spawnattr_sched.c \
    $(LOCAL_DIR)/src/process/posix_spawnattr_setflags.c \
    $(LOCAL_DIR)/src/process/posix_spawnattr_setpgroup.c \
    $(LOCAL_DIR)/src/process/posix_spawnattr_setsigdefault.c \
    $(LOCAL_DIR)/src/process/posix_spawnattr_setsigmask.c \
    $(LOCAL_DIR)/src/process/posix_spawnp.c \
    $(LOCAL_DIR)/src/process/system.c \
    $(LOCAL_DIR)/src/process/vfork.c \
    $(LOCAL_DIR)/src/process/wait.c \
    $(LOCAL_DIR)/src/process/waitid.c \
    $(LOCAL_DIR)/src/process/waitpid.c \
    $(LOCAL_DIR)/src/regex/fnmatch.c \
    $(LOCAL_DIR)/src/regex/glob.c \
    $(LOCAL_DIR)/third_party/tre/regcomp.c \
    $(LOCAL_DIR)/third_party/tre/regerror.c \
    $(LOCAL_DIR)/third_party/tre/regexec.c \
    $(LOCAL_DIR)/third_party/tre/tre-mem.c \
    $(LOCAL_DIR)/src/sched/affinity.c \
    $(LOCAL_DIR)/src/sched/sched_cpucount.c \
    $(LOCAL_DIR)/src/sched/sched_get_priority_max.c \
    $(LOCAL_DIR)/src/sched/sched_getcpu.c \
    $(LOCAL_DIR)/src/sched/sched_getparam.c \
    $(LOCAL_DIR)/src/sched/sched_getscheduler.c \
    $(LOCAL_DIR)/src/sched/sched_rr_get_interval.c \
    $(LOCAL_DIR)/src/sched/sched_setparam.c \
    $(LOCAL_DIR)/src/sched/sched_setscheduler.c \
    $(LOCAL_DIR)/src/sched/sched_yield.c \
    $(LOCAL_DIR)/src/setjmp/longjmp.c \
    $(LOCAL_DIR)/src/setjmp/setjmp.c \
    $(LOCAL_DIR)/src/signal/getitimer.c \
    $(LOCAL_DIR)/src/signal/kill.c \
    $(LOCAL_DIR)/src/signal/killpg.c \
    $(LOCAL_DIR)/src/signal/psiginfo.c \
    $(LOCAL_DIR)/src/signal/psignal.c \
    $(LOCAL_DIR)/src/signal/raise.c \
    $(LOCAL_DIR)/src/signal/setitimer.c \
    $(LOCAL_DIR)/src/signal/sigaction.c \
    $(LOCAL_DIR)/src/signal/sigaddset.c \
    $(LOCAL_DIR)/src/signal/sigaltstack.c \
    $(LOCAL_DIR)/src/signal/sigandset.c \
    $(LOCAL_DIR)/src/signal/sigdelset.c \
    $(LOCAL_DIR)/src/signal/sigemptyset.c \
    $(LOCAL_DIR)/src/signal/sigfillset.c \
    $(LOCAL_DIR)/src/signal/sighold.c \
    $(LOCAL_DIR)/src/signal/sigignore.c \
    $(LOCAL_DIR)/src/signal/siginterrupt.c \
    $(LOCAL_DIR)/src/signal/sigisemptyset.c \
    $(LOCAL_DIR)/src/signal/sigismember.c \
    $(LOCAL_DIR)/src/signal/signal.c \
    $(LOCAL_DIR)/src/signal/sigorset.c \
    $(LOCAL_DIR)/src/signal/sigpause.c \
    $(LOCAL_DIR)/src/signal/sigpending.c \
    $(LOCAL_DIR)/src/signal/sigprocmask.c \
    $(LOCAL_DIR)/src/signal/sigqueue.c \
    $(LOCAL_DIR)/src/signal/sigrelse.c \
    $(LOCAL_DIR)/src/signal/sigrtmax.c \
    $(LOCAL_DIR)/src/signal/sigrtmin.c \
    $(LOCAL_DIR)/src/signal/sigset.c \
    $(LOCAL_DIR)/src/signal/sigsuspend.c \
    $(LOCAL_DIR)/src/signal/sigtimedwait.c \
    $(LOCAL_DIR)/src/signal/sigwait.c \
    $(LOCAL_DIR)/src/signal/sigwaitinfo.c \
    $(LOCAL_DIR)/src/stat/futimesat.c \
    $(LOCAL_DIR)/src/stat/lchmod.c \
    $(LOCAL_DIR)/src/stat/mkfifoat.c \
    $(LOCAL_DIR)/src/stat/mknodat.c \
    $(LOCAL_DIR)/src/stat/statvfs.c \
    $(LOCAL_DIR)/src/stdio/__fclose_ca.c \
    $(LOCAL_DIR)/src/stdio/__fdopen.c \
    $(LOCAL_DIR)/src/stdio/__fmodeflags.c \
    $(LOCAL_DIR)/src/stdio/__fopen_rb_ca.c \
    $(LOCAL_DIR)/src/stdio/__lockfile.c \
    $(LOCAL_DIR)/src/stdio/__overflow.c \
    $(LOCAL_DIR)/src/stdio/__stdio_close.c \
    $(LOCAL_DIR)/src/stdio/__stdio_exit.c \
    $(LOCAL_DIR)/src/stdio/__stdio_read.c \
    $(LOCAL_DIR)/src/stdio/__stdio_seek.c \
    $(LOCAL_DIR)/src/stdio/__stdio_write.c \
    $(LOCAL_DIR)/src/stdio/__stdout_write.c \
    $(LOCAL_DIR)/src/stdio/__string_read.c \
    $(LOCAL_DIR)/src/stdio/__toread.c \
    $(LOCAL_DIR)/src/stdio/__towrite.c \
    $(LOCAL_DIR)/src/stdio/__uflow.c \
    $(LOCAL_DIR)/src/stdio/asprintf.c \
    $(LOCAL_DIR)/src/stdio/clearerr.c \
    $(LOCAL_DIR)/src/stdio/dprintf.c \
    $(LOCAL_DIR)/src/stdio/ext.c \
    $(LOCAL_DIR)/src/stdio/ext2.c \
    $(LOCAL_DIR)/src/stdio/fclose.c \
    $(LOCAL_DIR)/src/stdio/feof.c \
    $(LOCAL_DIR)/src/stdio/ferror.c \
    $(LOCAL_DIR)/src/stdio/fflush.c \
    $(LOCAL_DIR)/src/stdio/fgetc.c \
    $(LOCAL_DIR)/src/stdio/fgetln.c \
    $(LOCAL_DIR)/src/stdio/fgetpos.c \
    $(LOCAL_DIR)/src/stdio/fgets.c \
    $(LOCAL_DIR)/src/stdio/fgetwc.c \
    $(LOCAL_DIR)/src/stdio/fgetws.c \
    $(LOCAL_DIR)/src/stdio/fileno.c \
    $(LOCAL_DIR)/src/stdio/flockfile.c \
    $(LOCAL_DIR)/src/stdio/fmemopen.c \
    $(LOCAL_DIR)/src/stdio/fopen.c \
    $(LOCAL_DIR)/src/stdio/fprintf.c \
    $(LOCAL_DIR)/src/stdio/fputc.c \
    $(LOCAL_DIR)/src/stdio/fputs.c \
    $(LOCAL_DIR)/src/stdio/fputwc.c \
    $(LOCAL_DIR)/src/stdio/fputws.c \
    $(LOCAL_DIR)/src/stdio/fread.c \
    $(LOCAL_DIR)/src/stdio/freopen.c \
    $(LOCAL_DIR)/src/stdio/fscanf.c \
    $(LOCAL_DIR)/src/stdio/fseek.c \
    $(LOCAL_DIR)/src/stdio/fsetpos.c \
    $(LOCAL_DIR)/src/stdio/ftell.c \
    $(LOCAL_DIR)/src/stdio/ftrylockfile.c \
    $(LOCAL_DIR)/src/stdio/funlockfile.c \
    $(LOCAL_DIR)/src/stdio/fwide.c \
    $(LOCAL_DIR)/src/stdio/fwprintf.c \
    $(LOCAL_DIR)/src/stdio/fwrite.c \
    $(LOCAL_DIR)/src/stdio/fwscanf.c \
    $(LOCAL_DIR)/src/stdio/getc.c \
    $(LOCAL_DIR)/src/stdio/getc_unlocked.c \
    $(LOCAL_DIR)/src/stdio/getchar.c \
    $(LOCAL_DIR)/src/stdio/getchar_unlocked.c \
    $(LOCAL_DIR)/src/stdio/getdelim.c \
    $(LOCAL_DIR)/src/stdio/getline.c \
    $(LOCAL_DIR)/src/stdio/gets.c \
    $(LOCAL_DIR)/src/stdio/getw.c \
    $(LOCAL_DIR)/src/stdio/getwc.c \
    $(LOCAL_DIR)/src/stdio/getwchar.c \
    $(LOCAL_DIR)/src/stdio/ofl.c \
    $(LOCAL_DIR)/src/stdio/ofl_add.c \
    $(LOCAL_DIR)/src/stdio/open_memstream.c \
    $(LOCAL_DIR)/src/stdio/open_wmemstream.c \
    $(LOCAL_DIR)/src/stdio/pclose.c \
    $(LOCAL_DIR)/src/stdio/perror.c \
    $(LOCAL_DIR)/src/stdio/popen.c \
    $(LOCAL_DIR)/src/stdio/printf.c \
    $(LOCAL_DIR)/src/stdio/putc.c \
    $(LOCAL_DIR)/src/stdio/putc_unlocked.c \
    $(LOCAL_DIR)/src/stdio/putchar.c \
    $(LOCAL_DIR)/src/stdio/putchar_unlocked.c \
    $(LOCAL_DIR)/src/stdio/puts.c \
    $(LOCAL_DIR)/src/stdio/putw.c \
    $(LOCAL_DIR)/src/stdio/putwc.c \
    $(LOCAL_DIR)/src/stdio/putwchar.c \
    $(LOCAL_DIR)/src/stdio/remove.c \
    $(LOCAL_DIR)/src/stdio/rewind.c \
    $(LOCAL_DIR)/src/stdio/scanf.c \
    $(LOCAL_DIR)/src/stdio/setbuf.c \
    $(LOCAL_DIR)/src/stdio/setbuffer.c \
    $(LOCAL_DIR)/src/stdio/setlinebuf.c \
    $(LOCAL_DIR)/src/stdio/setvbuf.c \
    $(LOCAL_DIR)/src/stdio/snprintf.c \
    $(LOCAL_DIR)/src/stdio/sprintf.c \
    $(LOCAL_DIR)/src/stdio/sscanf.c \
    $(LOCAL_DIR)/src/stdio/stderr.c \
    $(LOCAL_DIR)/src/stdio/stdin.c \
    $(LOCAL_DIR)/src/stdio/stdout.c \
    $(LOCAL_DIR)/src/stdio/swprintf.c \
    $(LOCAL_DIR)/src/stdio/swscanf.c \
    $(LOCAL_DIR)/src/stdio/tempnam.c \
    $(LOCAL_DIR)/src/stdio/tmpfile.c \
    $(LOCAL_DIR)/src/stdio/tmpnam.c \
    $(LOCAL_DIR)/src/stdio/ungetc.c \
    $(LOCAL_DIR)/src/stdio/ungetwc.c \
    $(LOCAL_DIR)/src/stdio/vasprintf.c \
    $(LOCAL_DIR)/src/stdio/vdprintf.c \
    $(LOCAL_DIR)/src/stdio/vfprintf.c \
    $(LOCAL_DIR)/src/stdio/vfscanf.c \
    $(LOCAL_DIR)/src/stdio/vfwprintf.c \
    $(LOCAL_DIR)/src/stdio/vfwscanf.c \
    $(LOCAL_DIR)/src/stdio/vprintf.c \
    $(LOCAL_DIR)/src/stdio/vscanf.c \
    $(LOCAL_DIR)/src/stdio/vsnprintf.c \
    $(LOCAL_DIR)/src/stdio/vsprintf.c \
    $(LOCAL_DIR)/src/stdio/vsscanf.c \
    $(LOCAL_DIR)/src/stdio/vswprintf.c \
    $(LOCAL_DIR)/src/stdio/vswscanf.c \
    $(LOCAL_DIR)/src/stdio/vwprintf.c \
    $(LOCAL_DIR)/src/stdio/vwscanf.c \
    $(LOCAL_DIR)/src/stdio/wprintf.c \
    $(LOCAL_DIR)/src/stdio/wscanf.c \
    $(LOCAL_DIR)/src/stdlib/abs.c \
    $(LOCAL_DIR)/src/stdlib/atof.c \
    $(LOCAL_DIR)/src/stdlib/atoi.c \
    $(LOCAL_DIR)/src/stdlib/atol.c \
    $(LOCAL_DIR)/src/stdlib/atoll.c \
    $(LOCAL_DIR)/src/stdlib/bsearch.c \
    $(LOCAL_DIR)/src/stdlib/div.c \
    $(LOCAL_DIR)/src/stdlib/ecvt.c \
    $(LOCAL_DIR)/src/stdlib/fcvt.c \
    $(LOCAL_DIR)/src/stdlib/gcvt.c \
    $(LOCAL_DIR)/src/stdlib/imaxabs.c \
    $(LOCAL_DIR)/src/stdlib/imaxdiv.c \
    $(LOCAL_DIR)/src/stdlib/labs.c \
    $(LOCAL_DIR)/src/stdlib/ldiv.c \
    $(LOCAL_DIR)/src/stdlib/llabs.c \
    $(LOCAL_DIR)/src/stdlib/lldiv.c \
    $(LOCAL_DIR)/src/stdlib/strtod.c \
    $(LOCAL_DIR)/src/stdlib/strtol.c \
    $(LOCAL_DIR)/src/stdlib/wcstod.c \
    $(LOCAL_DIR)/src/stdlib/wcstol.c \
    $(LOCAL_DIR)/src/temp/__randname.c \
    $(LOCAL_DIR)/src/temp/mkdtemp.c \
    $(LOCAL_DIR)/src/temp/mkostemp.c \
    $(LOCAL_DIR)/src/temp/mkostemps.c \
    $(LOCAL_DIR)/src/temp/mkstemp.c \
    $(LOCAL_DIR)/src/temp/mkstemps.c \
    $(LOCAL_DIR)/src/temp/mktemp.c \
    $(LOCAL_DIR)/src/termios/cfgetospeed.c \
    $(LOCAL_DIR)/src/termios/cfmakeraw.c \
    $(LOCAL_DIR)/src/termios/cfsetospeed.c \
    $(LOCAL_DIR)/src/termios/tcdrain.c \
    $(LOCAL_DIR)/src/termios/tcflow.c \
    $(LOCAL_DIR)/src/termios/tcflush.c \
    $(LOCAL_DIR)/src/termios/tcgetattr.c \
    $(LOCAL_DIR)/src/termios/tcgetsid.c \
    $(LOCAL_DIR)/src/termios/tcsendbreak.c \
    $(LOCAL_DIR)/src/termios/tcsetattr.c \
    $(LOCAL_DIR)/src/thread/__timedwait.c \
    $(LOCAL_DIR)/src/thread/__tls_get_addr.c \
    $(LOCAL_DIR)/src/thread/__wait.c \
    $(LOCAL_DIR)/src/thread/call_once.c \
    $(LOCAL_DIR)/src/thread/cnd_broadcast.c \
    $(LOCAL_DIR)/src/thread/cnd_destroy.c \
    $(LOCAL_DIR)/src/thread/cnd_init.c \
    $(LOCAL_DIR)/src/thread/cnd_signal.c \
    $(LOCAL_DIR)/src/thread/cnd_timedwait.c \
    $(LOCAL_DIR)/src/thread/cnd_wait.c \
    $(LOCAL_DIR)/src/thread/mtx_destroy.c \
    $(LOCAL_DIR)/src/thread/mtx_init.c \
    $(LOCAL_DIR)/src/thread/mtx_lock.c \
    $(LOCAL_DIR)/src/thread/mtx_timedlock.c \
    $(LOCAL_DIR)/src/thread/mtx_trylock.c \
    $(LOCAL_DIR)/src/thread/mtx_unlock.c \
    $(LOCAL_DIR)/src/thread/safestack.c \
    $(LOCAL_DIR)/src/thread/thrd_create.c \
    $(LOCAL_DIR)/src/thread/thrd_detach.c \
    $(LOCAL_DIR)/src/thread/thrd_exit.c \
    $(LOCAL_DIR)/src/thread/thrd_join.c \
    $(LOCAL_DIR)/src/thread/thrd_sleep.c \
    $(LOCAL_DIR)/src/thread/thrd_yield.c \
    $(LOCAL_DIR)/src/thread/tss_create.c \
    $(LOCAL_DIR)/src/thread/tss_delete.c \
    $(LOCAL_DIR)/src/thread/tss_set.c \
    $(LOCAL_DIR)/src/time/__asctime.c \
    $(LOCAL_DIR)/src/time/__map_file.c \
    $(LOCAL_DIR)/src/time/__month_to_secs.c \
    $(LOCAL_DIR)/src/time/__secs_to_tm.c \
    $(LOCAL_DIR)/src/time/__tm_to_secs.c \
    $(LOCAL_DIR)/src/time/__tz.c \
    $(LOCAL_DIR)/src/time/__year_to_secs.c \
    $(LOCAL_DIR)/src/time/asctime.c \
    $(LOCAL_DIR)/src/time/asctime_r.c \
    $(LOCAL_DIR)/src/time/clock.c \
    $(LOCAL_DIR)/src/time/clock_getcpuclockid.c \
    $(LOCAL_DIR)/src/time/clock_getres.c \
    $(LOCAL_DIR)/src/time/clock_gettime.c \
    $(LOCAL_DIR)/src/time/clock_nanosleep.c \
    $(LOCAL_DIR)/src/time/clock_settime.c \
    $(LOCAL_DIR)/src/time/ctime.c \
    $(LOCAL_DIR)/src/time/ctime_r.c \
    $(LOCAL_DIR)/src/time/difftime.c \
    $(LOCAL_DIR)/src/time/ftime.c \
    $(LOCAL_DIR)/src/time/getdate.c \
    $(LOCAL_DIR)/src/time/gettimeofday.c \
    $(LOCAL_DIR)/src/time/gmtime.c \
    $(LOCAL_DIR)/src/time/gmtime_r.c \
    $(LOCAL_DIR)/src/time/localtime.c \
    $(LOCAL_DIR)/src/time/localtime_r.c \
    $(LOCAL_DIR)/src/time/mktime.c \
    $(LOCAL_DIR)/src/time/nanosleep.c \
    $(LOCAL_DIR)/src/time/strftime.c \
    $(LOCAL_DIR)/src/time/strptime.c \
    $(LOCAL_DIR)/src/time/time.c \
    $(LOCAL_DIR)/src/time/timegm.c \
    $(LOCAL_DIR)/src/time/times.c \
    $(LOCAL_DIR)/src/time/timespec_get.c \
    $(LOCAL_DIR)/src/time/utime.c \
    $(LOCAL_DIR)/src/time/wcsftime.c \
    $(LOCAL_DIR)/src/unistd/_exit.c \
    $(LOCAL_DIR)/src/unistd/acct.c \
    $(LOCAL_DIR)/src/unistd/alarm.c \
    $(LOCAL_DIR)/src/unistd/ctermid.c \
    $(LOCAL_DIR)/src/unistd/fchdir.c \
    $(LOCAL_DIR)/src/unistd/gethostname.c \
    $(LOCAL_DIR)/src/unistd/getlogin.c \
    $(LOCAL_DIR)/src/unistd/getlogin_r.c \
    $(LOCAL_DIR)/src/unistd/nice.c \
    $(LOCAL_DIR)/src/unistd/pause.c \
    $(LOCAL_DIR)/src/unistd/posix_close.c \
    $(LOCAL_DIR)/src/unistd/setpgrp.c \
    $(LOCAL_DIR)/src/unistd/sleep.c \
    $(LOCAL_DIR)/src/unistd/tcgetpgrp.c \
    $(LOCAL_DIR)/src/unistd/tcsetpgrp.c \
    $(LOCAL_DIR)/src/unistd/ttyname.c \
    $(LOCAL_DIR)/src/unistd/ualarm.c \
    $(LOCAL_DIR)/src/unistd/usleep.c \
    $(LOCAL_DIR)/stubs/idstubs.c \
    $(LOCAL_DIR)/third_party/complex/__cexp.c \
    $(LOCAL_DIR)/third_party/complex/__cexpf.c \
    $(LOCAL_DIR)/third_party/complex/catan.c \
    $(LOCAL_DIR)/third_party/complex/catanf.c \
    $(LOCAL_DIR)/third_party/complex/catanl.c \
    $(LOCAL_DIR)/third_party/complex/ccosh.c \
    $(LOCAL_DIR)/third_party/complex/ccoshf.c \
    $(LOCAL_DIR)/third_party/complex/cexp.c \
    $(LOCAL_DIR)/third_party/complex/cexpf.c \
    $(LOCAL_DIR)/third_party/complex/csinh.c \
    $(LOCAL_DIR)/third_party/complex/csinhf.c \
    $(LOCAL_DIR)/third_party/complex/csqrt.c \
    $(LOCAL_DIR)/third_party/complex/csqrtf.c \
    $(LOCAL_DIR)/third_party/complex/ctanh.c \
    $(LOCAL_DIR)/third_party/complex/ctanhf.c \
    $(LOCAL_DIR)/third_party/math/__cos.c \
    $(LOCAL_DIR)/third_party/math/__cosdf.c \
    $(LOCAL_DIR)/third_party/math/__cosl.c \
    $(LOCAL_DIR)/third_party/math/__polevll.c \
    $(LOCAL_DIR)/third_party/math/__rem_pio2.c \
    $(LOCAL_DIR)/third_party/math/__rem_pio2_large.c \
    $(LOCAL_DIR)/third_party/math/__rem_pio2f.c \
    $(LOCAL_DIR)/third_party/math/__rem_pio2l.c \
    $(LOCAL_DIR)/third_party/math/__sin.c \
    $(LOCAL_DIR)/third_party/math/__sindf.c \
    $(LOCAL_DIR)/third_party/math/__sinl.c \
    $(LOCAL_DIR)/third_party/math/__tan.c \
    $(LOCAL_DIR)/third_party/math/__tandf.c \
    $(LOCAL_DIR)/third_party/math/__tanl.c \
    $(LOCAL_DIR)/third_party/math/acos.c \
    $(LOCAL_DIR)/third_party/math/acosf.c \
    $(LOCAL_DIR)/third_party/math/asin.c \
    $(LOCAL_DIR)/third_party/math/asinf.c \
    $(LOCAL_DIR)/third_party/math/atan.c \
    $(LOCAL_DIR)/third_party/math/atan2.c \
    $(LOCAL_DIR)/third_party/math/atan2f.c \
    $(LOCAL_DIR)/third_party/math/atanf.c \
    $(LOCAL_DIR)/third_party/math/cbrt.c \
    $(LOCAL_DIR)/third_party/math/cbrtf.c \
    $(LOCAL_DIR)/third_party/math/cbrtl.c \
    $(LOCAL_DIR)/third_party/math/cos.c \
    $(LOCAL_DIR)/third_party/math/cosf.c \
    $(LOCAL_DIR)/third_party/math/erf.c \
    $(LOCAL_DIR)/third_party/math/erff.c \
    $(LOCAL_DIR)/third_party/math/erfl.c \
    $(LOCAL_DIR)/third_party/math/exp.c \
    $(LOCAL_DIR)/third_party/math/exp2.c \
    $(LOCAL_DIR)/third_party/math/exp2f.c \
    $(LOCAL_DIR)/third_party/math/expf.c \
    $(LOCAL_DIR)/third_party/math/expm1.c \
    $(LOCAL_DIR)/third_party/math/expm1f.c \
    $(LOCAL_DIR)/third_party/math/fma.c \
    $(LOCAL_DIR)/third_party/math/fmaf.c \
    $(LOCAL_DIR)/third_party/math/fmal.c \
    $(LOCAL_DIR)/third_party/math/j0.c \
    $(LOCAL_DIR)/third_party/math/j0f.c \
    $(LOCAL_DIR)/third_party/math/j1.c \
    $(LOCAL_DIR)/third_party/math/j1f.c \
    $(LOCAL_DIR)/third_party/math/jn.c \
    $(LOCAL_DIR)/third_party/math/jnf.c \
    $(LOCAL_DIR)/third_party/math/lgamma_r.c \
    $(LOCAL_DIR)/third_party/math/lgammaf_r.c \
    $(LOCAL_DIR)/third_party/math/lgammal.c \
    $(LOCAL_DIR)/third_party/math/log.c \
    $(LOCAL_DIR)/third_party/math/log10.c \
    $(LOCAL_DIR)/third_party/math/log10f.c \
    $(LOCAL_DIR)/third_party/math/log1p.c \
    $(LOCAL_DIR)/third_party/math/log1pf.c \
    $(LOCAL_DIR)/third_party/math/log2.c \
    $(LOCAL_DIR)/third_party/math/log2f.c \
    $(LOCAL_DIR)/third_party/math/logf.c \
    $(LOCAL_DIR)/third_party/math/pow.c \
    $(LOCAL_DIR)/third_party/math/powf.c \
    $(LOCAL_DIR)/third_party/math/powl.c \
    $(LOCAL_DIR)/third_party/math/scalb.c \
    $(LOCAL_DIR)/third_party/math/scalbf.c \
    $(LOCAL_DIR)/third_party/math/sin.c \
    $(LOCAL_DIR)/third_party/math/sincos.c \
    $(LOCAL_DIR)/third_party/math/sincosf.c \
    $(LOCAL_DIR)/third_party/math/sinf.c \
    $(LOCAL_DIR)/third_party/math/tan.c \
    $(LOCAL_DIR)/third_party/math/tanf.c \
    $(LOCAL_DIR)/third_party/math/tgammal.c \
    $(LOCAL_DIR)/third_party/smoothsort/qsort.c \

# These refer to access.
#    $(LOCAL_DIR)/pthread/sem_open.c \
#    $(LOCAL_DIR)/src/legacy/ftw.c \
#    $(LOCAL_DIR)/src/misc/nftw.c \

# These refer to __crypt_*, __des_setkey, and __do_des, which we do not have.
#    $(LOCAL_DIR)/src/crypt/crypt.c \
#    $(LOCAL_DIR)/src/crypt/crypt_r.c \
#    $(LOCAL_DIR)/src/crypt/encrypt.c \

ifeq ($(ARCH),arm64)
LOCAL_SRCS += \
    $(LOCAL_DIR)/src/fenv/aarch64/fenv.c \
    $(LOCAL_DIR)/src/ldso/aarch64/tlsdesc.S \
    $(LOCAL_DIR)/src/math/aarch64/fabs.S \
    $(LOCAL_DIR)/src/math/aarch64/fabsf.S \
    $(LOCAL_DIR)/src/math/aarch64/sqrt.S \
    $(LOCAL_DIR)/src/math/aarch64/sqrtf.S \
    $(LOCAL_DIR)/src/math/ceill.c \
    $(LOCAL_DIR)/src/math/fabsl.c \
    $(LOCAL_DIR)/src/math/floorl.c \
    $(LOCAL_DIR)/src/math/fmodl.c \
    $(LOCAL_DIR)/src/math/llrint.c \
    $(LOCAL_DIR)/src/math/llrintf.c \
    $(LOCAL_DIR)/src/math/llrintl.c \
    $(LOCAL_DIR)/src/math/lrint.c \
    $(LOCAL_DIR)/src/math/lrintf.c \
    $(LOCAL_DIR)/src/math/lrintl.c \
    $(LOCAL_DIR)/src/math/remainderl.c \
    $(LOCAL_DIR)/src/math/rintl.c \
    $(LOCAL_DIR)/src/math/sqrtl.c \
    $(LOCAL_DIR)/src/math/truncl.c \
    $(LOCAL_DIR)/src/setjmp/aarch64/longjmp.S \
    $(LOCAL_DIR)/src/setjmp/aarch64/setjmp.S \
    $(LOCAL_DIR)/third_party/math/acosl.c \
    $(LOCAL_DIR)/third_party/math/asinl.c \
    $(LOCAL_DIR)/third_party/math/atan2l.c \
    $(LOCAL_DIR)/third_party/math/atanl.c \
    $(LOCAL_DIR)/third_party/math/exp2l.c \
    $(LOCAL_DIR)/third_party/math/expl.c \
    $(LOCAL_DIR)/third_party/math/expm1l.c \
    $(LOCAL_DIR)/third_party/math/log10l.c \
    $(LOCAL_DIR)/third_party/math/log1pl.c \
    $(LOCAL_DIR)/third_party/math/log2l.c \
    $(LOCAL_DIR)/third_party/math/logl.c \

else ifeq ($(SUBARCH),x86-64)
LOCAL_SRCS += \
    $(LOCAL_DIR)/src/fenv/x86_64/fenv.c \
    $(LOCAL_DIR)/src/ldso/x86_64/tlsdesc.S \
    $(LOCAL_DIR)/src/math/x86_64/__invtrigl.S \
    $(LOCAL_DIR)/src/math/x86_64/acosl.S \
    $(LOCAL_DIR)/src/math/x86_64/asinl.S \
    $(LOCAL_DIR)/src/math/x86_64/atan2l.S \
    $(LOCAL_DIR)/src/math/x86_64/atanl.S \
    $(LOCAL_DIR)/src/math/x86_64/ceill.S \
    $(LOCAL_DIR)/src/math/x86_64/exp2l.S \
    $(LOCAL_DIR)/src/math/x86_64/expl.S \
    $(LOCAL_DIR)/src/math/x86_64/expm1l.S \
    $(LOCAL_DIR)/src/math/x86_64/fabs.S \
    $(LOCAL_DIR)/src/math/x86_64/fabsf.S \
    $(LOCAL_DIR)/src/math/x86_64/fabsl.S \
    $(LOCAL_DIR)/src/math/x86_64/floorl.S \
    $(LOCAL_DIR)/src/math/x86_64/fmodl.S \
    $(LOCAL_DIR)/src/math/x86_64/llrint.S \
    $(LOCAL_DIR)/src/math/x86_64/llrintf.S \
    $(LOCAL_DIR)/src/math/x86_64/llrintl.S \
    $(LOCAL_DIR)/src/math/x86_64/log10l.S \
    $(LOCAL_DIR)/src/math/x86_64/log1pl.S \
    $(LOCAL_DIR)/src/math/x86_64/log2l.S \
    $(LOCAL_DIR)/src/math/x86_64/logl.S \
    $(LOCAL_DIR)/src/math/x86_64/lrint.S \
    $(LOCAL_DIR)/src/math/x86_64/lrintf.S \
    $(LOCAL_DIR)/src/math/x86_64/lrintl.S \
    $(LOCAL_DIR)/src/math/x86_64/remainderl.S \
    $(LOCAL_DIR)/src/math/x86_64/rintl.S \
    $(LOCAL_DIR)/src/math/x86_64/sqrt.S \
    $(LOCAL_DIR)/src/math/x86_64/sqrtf.S \
    $(LOCAL_DIR)/src/math/x86_64/sqrtl.S \
    $(LOCAL_DIR)/src/math/x86_64/truncl.S \
    $(LOCAL_DIR)/src/setjmp/x86_64/longjmp.S \
    $(LOCAL_DIR)/src/setjmp/x86_64/setjmp.S \

else
error Unsupported architecture for musl build!

endif

# Include src/string sources
include $(LOCAL_DIR)/src/string/rules.mk

# Include jemalloc for our malloc implementation
include $(LOCAL_DIR)/../jemalloc/rules.mk


# shared library (which is also the dynamic linker)
MODULE := system/ulib/c
MODULE_TYPE := userlib
MODULE_COMPILEFLAGS := $(LOCAL_COMPILEFLAGS)
MODULE_CFLAGS := $(LOCAL_CFLAGS)
MODULE_SRCS := $(LOCAL_SRCS)

MODULE_LIBS := system/ulib/zircon
MODULE_STATIC_LIBS := system/ulib/runtime

# At link time and in DT_SONAME, musl is known as libc.so.  But the
# (only) place it needs to be installed at runtime is where the
# PT_INTERP strings embedded in executables point, which is ld.so.1.
MODULE_EXPORT := so
MODULE_SO_NAME := c
MODULE_SO_INSTALL_NAME := lib/$(USER_SHARED_INTERP)

MODULE_SRCS += \
    $(LOCAL_DIR)/stubs/iostubs.c \
    $(LOCAL_DIR)/stubs/socketstubs.c \
    $(LOCAL_DIR)/arch/$(MUSL_ARCH)/dl-entry.S \
    $(LOCAL_DIR)/ldso/dlstart.c \
    $(LOCAL_DIR)/ldso/dynlink.c \
    $(LOCAL_DIR)/ldso/dynlink-sancov.S \

MODULE_SRCS += \
    $(LOCAL_DIR)/sanitizers/__asan_early_init.c \
    $(LOCAL_DIR)/sanitizers/asan-stubs.c \
    $(LOCAL_DIR)/sanitizers/hooks.c \
    $(LOCAL_DIR)/sanitizers/log.c \

# There is no '#if __has_feature(coverage)', so this file has to be
# excluded from the build entirely when not in use.
ifeq ($(call TOBOOL,$(USE_SANCOV)),true)
MODULE_SRCS += $(LOCAL_DIR)/sanitizers/sancov-stubs.S
endif

include make/module.mk


# build a fake library to build crt1.o separately

MODULE := system/ulib/c.crt
MODULE_TYPE := userlib
MODULE_COMPILEFLAGS := $(LOCAL_COMPILEFLAGS)
MODULE_CFLAGS := $(LOCAL_CFLAGS)

MODULE_SRCS := $(LOCAL_DIR)/arch/$(MUSL_ARCH)/crt1.S

# where our object files will end up
LOCAL_OUT := $(BUILDDIR)/system/ulib/c.crt/$(LOCAL_DIR)
LOCAL_CRT1_OBJ := $(LOCAL_OUT)/arch/$(MUSL_ARCH)/crt1.S.o

# install it globally
$(call copy-dst-src,$(USER_CRT1_OBJ),$(LOCAL_CRT1_OBJ))

include make/module.mk
