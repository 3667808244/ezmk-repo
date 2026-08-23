#include "term_pic/error.h"

#include <cstddef>
#include <string>
#include <vector>

namespace term_pic {
	std::string to_string(term_pic::Error e) noexcept{
		const static std::vector<std::string> s = {
			"Out of Range",
			"Not a Terminal",
		};
		size_t i = static_cast<size_t>(e);
		if(i >= s.size()) {
			return "";
		}
		return s[i];
	}
}
