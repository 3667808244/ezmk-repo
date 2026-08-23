#pragma once

#include <cstdint>
#include <optional>
#include <stdint.h>
#include <string>

namespace term_pic {
	struct RgbColor {
		uint8_t r, g, b ;
	};

	RgbColor gray(uint8_t g) noexcept;
	RgbColor overlay(
		const RgbColor &raw,
		const RgbColor &mask,
		float alpha =  0.5
	) noexcept;
	RgbColor hsl(
		float h,
		float s,
		float l
	) noexcept;

	std::string gen_seq(
		const std::optional<RgbColor> &fg = std::nullopt,
		const std::optional<RgbColor> &bg = std::nullopt
	);
}
