#pragma once

#include <cstddef>
#include <expected>
#include <string>

namespace term_pic {
	enum class Error : size_t{
		OutOfRange = 0,
		NotTerminal = 1
	};
	
	template<typename T>
	using Res = std::expected<T, Error>;
	using Err = std::unexpected<Error>;

	std::string to_string(term_pic::Error e) noexcept;
}
