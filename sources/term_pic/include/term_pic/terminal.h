#pragma once

#include "term_pic/error.h"
#include "term_pic/pos.h"

namespace term_pic {
	bool supports_truecolor() noexcept;
	bool enable_vt100() noexcept;
	Res<Size> terminal_size() noexcept;
}
