#pragma once

#include <array>
#include <bitset>
#include <string>

namespace term_pic::num_font {
	using signal_char_t = std::array<std::bitset<3>,5>;

	static std::bitset<3> row(const char *s) {
		return std::bitset<3>(std::string(s), 0, 3, ' ', '#');
	}

	static signal_char_t n_0 = {
		row("###"),
		row("# #"),
		row("# #"),
		row("# #"),
		row("###"),
	};

	static signal_char_t n_1 = {
		row(" # "),
		row("## "),
		row(" # "),
		row(" # "),
		row("###"),
	};

	static signal_char_t n_2 = {
		row("###"),
		row("  #"),
		row("###"),
		row("#  "),
		row("###"),
	};

	static signal_char_t n_3 = {
		row("###"),
		row("  #"),
		row("###"),
		row("  #"),
		row("###"),
	};

	static signal_char_t n_4 = {
		row("# #"),
		row("# #"),
		row("###"),
		row("  #"),
		row("  #"),
	};

	static signal_char_t n_5 = {
		row("###"),
		row("#  "),
		row("###"),
		row("  #"),
		row("###"),
	};

	static signal_char_t n_6 = {
		row("###"),
		row("#  "),
		row("###"),
		row("# #"),
		row("###"),
	};

	static signal_char_t n_7 = {
		row("###"),
		row("  #"),
		row("  #"),
		row("  #"),
		row("  #"),
	};

	static signal_char_t n_8 = {
		row("###"),
		row("# #"),
		row("###"),
		row("# #"),
		row("###"),
	};

	static signal_char_t n_9 = {
		row("###"),
		row("# #"),
		row("###"),
		row("  #"),
		row("###"),
	};

	static std::array<signal_char_t, 10> num_font = {
		n_0, n_1, n_2, n_3, n_4,
		n_5, n_6, n_7, n_8, n_9
	};
}
