#include "term_pic/terminal.h"

#include <cstdio>
#include <cstring>
#include <poll.h>
#include <sys/ioctl.h>
#include <termios.h>
#include <unistd.h>

namespace term_pic {

namespace {

	struct RawModeGuard {
		int fd;
		termios saved;
		bool ok;

		explicit RawModeGuard(int fd) noexcept
			: fd(fd), saved{}, ok(tcgetattr(fd, &saved) == 0) {}

		RawModeGuard(const RawModeGuard &) = delete;
		RawModeGuard &operator=(const RawModeGuard &) = delete;

		bool enter() noexcept {
			if(!ok) {
				return false;
			}
			termios raw = saved;
			raw.c_lflag &= ~(ICANON | ECHO | ISIG);
			raw.c_iflag &= ~(ICRNL | IEXTEN);
			raw.c_cc[VMIN] = 0;
			raw.c_cc[VTIME] = 0;
			return tcsetattr(fd, TCSANOW, &raw) == 0;
		}

		~RawModeGuard() noexcept {
			if(ok) {
				tcsetattr(fd, TCSANOW, &saved);
			}
		}
	};

	bool query_terminal(
		const char *seq,
		char *buf,
		size_t n,
		int timeout_ms
	) noexcept {
		if(!isatty(STDIN_FILENO) || !isatty(STDOUT_FILENO) || n == 0) {
			return false;
		}
		RawModeGuard guard(STDIN_FILENO);
		if(!guard.enter()) {
			return false;
		}
		tcflush(STDIN_FILENO, TCIFLUSH);
		std::fputs(seq, stdout);
		std::fflush(stdout);

		size_t total = 0;
		while(total + 1 < n && timeout_ms > 0) {
			pollfd pfd{ STDIN_FILENO, POLLIN, 0 };
			int rc = poll(&pfd, 1, timeout_ms);
			if(rc <= 0) {
				break;
			}
			ssize_t len = ::read(STDIN_FILENO, buf + total, n - 1 - total);
			if(len <= 0) {
				break;
			}
			total += static_cast<size_t>(len);
		}
		buf[total] = '\0';
		return total > 0;
	}

}

	bool supports_truecolor() noexcept {
		char buf[64];
		if(!query_terminal("\033]11;?\033\\", buf, sizeof buf, 200)) {
			return false;
		}
		const char *p = std::strstr(buf, "rgb:");
		return p != nullptr && std::strchr(p, '/') != nullptr;
	}

	bool enable_vt100() noexcept {
		char buf[64];
		if(!query_terminal("\033[0c", buf, sizeof buf, 200)) {
			return false;
		}
		if(buf[0] != '\033' || buf[1] != '[' || buf[2] != '?') {
			return false;
		}
		std::fputs("\033[?1h", stdout);
		std::fflush(stdout);
		return true;
	}

	Res<Size> terminal_size() noexcept {
		if(!isatty(STDIN_FILENO) || !isatty(STDOUT_FILENO)) {
			return Err(Error::NotTerminal);
		}
		winsize ws{};
		if(::ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws) != 0
			|| ws.ws_col == 0 || ws.ws_row == 0
		) {
			return Err(Error::NotTerminal);
		}
		return Size{ ws.ws_col, ws.ws_row };
	}

}
