#include "term_pic/color.h"
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <optional>
#include <string>

namespace term_pic {
	RgbColor gray(uint8_t g) noexcept {
		return {g, g, g};
	}

	RgbColor overlay(
		const RgbColor &raw,
		const RgbColor &mask,
		float alpha
	) noexcept {
		uint8_t r, g, b;
		alpha = std::clamp(alpha, 0.0f, 1.0f);
		r = raw.r * (1.0f - alpha) + mask.r * alpha;
		g = raw.g * (1.0f - alpha) + mask.g * alpha;
		b = raw.b * (1.0f - alpha) + mask.b * alpha;

		return { r, g, b };
	}

	RgbColor hsl(float h, float s, float l) noexcept {
		h = std::fmod(h, 360.0f);
		if (h < 0) h += 360.0f;
		s = std::clamp(s, 0.0f, 1.0f);
		l = std::clamp(l, 0.0f, 1.0f);

		float c = (1.0f - std::fabs(2.0f * l - 1.0f)) * s;
		float hp = h / 60.0f;
		float x = c * (1.0f - std::fabs(std::fmod(hp, 2.0f) - 1.0f));
		float m = l - c / 2.0f;

		float r, g, b;
		if (hp < 1)      { r = c; g = x; b = 0; }
		else if (hp < 2) { r = x; g = c; b = 0; }
		else if (hp < 3) { r = 0; g = c; b = x; }
		else if (hp < 4) { r = 0; g = x; b = c; }
		else if (hp < 5) { r = x; g = 0; b = c; }
		else             { r = c; g = 0; b = x; }

		return {
			static_cast<uint8_t>(std::lround((r + m) * 255.0f)),
			static_cast<uint8_t>(std::lround((g + m) * 255.0f)),
			static_cast<uint8_t>(std::lround((b + m) * 255.0f))
		};
	}

	std::string gen_seq(
		const std::optional<RgbColor> &fg,
		const std::optional<RgbColor> &bg
	) {
		if(!fg && !bg){
			return "\033[0m";
		}
		
		std::string fg_str, bg_str;
		fg_str.reserve(20);
		bg_str.reserve(20);
		
		if (fg) {
			fg_str += "\033[38;2;";
			fg_str += std::to_string(fg->r);
			fg_str += ";";
			fg_str += std::to_string(fg->g);
			fg_str += ";";
			fg_str += std::to_string(fg->b);
			fg_str += "m";
		}
		if (bg) {
			bg_str += "\033[48;2;";
			bg_str += std::to_string(bg->r);
			bg_str += ";";
			bg_str += std::to_string(bg->g);
			bg_str += ";";
			bg_str += std::to_string(bg->b);
			bg_str += "m";
		}

		return fg_str + bg_str;
	}
}
