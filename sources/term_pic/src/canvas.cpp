#pragma once

#include "term_pic/canvas.h"
#include "term_pic/color.h"
#include "term_pic/num_font.h"
#include <algorithm>
#include <cmath>
#include <cstddef>
#include <cstdint>
#include <string>

namespace term_pic {

	void Canvas::_get_image_size(size_t &w, size_t &h) const noexcept{
		Size size = _image.size();
		w = size.w;
		h = size.h;
	}

	void Canvas::_unchecked_overlay_pixel(
		const Pos &pos,
		const RgbColor &color,
		float alpha
	) noexcept {
		_image._unchecked_set(pos, overlay(_image._unchecked_get(pos), color, alpha));
	}

	void Canvas::draw_pixel(
		const Pos &pos,
		const RgbColor &color,
		float alpha
	) noexcept {
		size_t w, h;
		_get_image_size(w, h);
		if (pos.x >= w || pos.y >= h) {
			return;
		}
		_unchecked_overlay_pixel(pos, color, alpha);
	}

	void Canvas::draw_line(
		Pos start,
		Pos end,
		const RgbColor &color,
		float alpha
	) noexcept {
		int x0 = static_cast<int>(start.x), y0 = static_cast<int>(start.y);
		int x1 = static_cast<int>(end.x), y1 = static_cast<int>(end.y);
		int dx = std::abs(x1 - x0), sx = x0 < x1 ? 1 : -1;
		int dy = -std::abs(y1 - y0), sy = y0 < y1 ? 1 : -1;
		int err = dx + dy;

		size_t w, h;
		_get_image_size(w, h);
		for(;;) {
			if(x0 >= 0 && y0 >= 0
				&& static_cast<size_t>(x0) < w
				&& static_cast<size_t>(y0) < h
			) {
				_unchecked_overlay_pixel(
					{ static_cast<size_t>(x0), static_cast<size_t>(y0) },
					color,
					alpha
				);
			}
			if(x0 == x1 && y0 == y1) {
				break;
			}
			int e2 = 2 * err;
			if(e2 >= dy) { err += dy; x0 += sx; }
			if(e2 <= dx) { err += dx; y0 += sy; }
		}
	}

	void Canvas::draw_rect(
		const Pos &start,
		const Pos &end,
		const RgbColor &color,
		float alpha,
		bool fill
	) noexcept {
		size_t x0 = std::min(start.x, end.x), x1 = std::max(start.x, end.x);
		size_t y0 = std::min(start.y, end.y), y1 = std::max(start.y, end.y);

		size_t w, h;
		_get_image_size(w, h);
		if(x0 >= w || y0 >= h) {
			return;
		}
		x1 = std::min(x1, w - 1);
		y1 = std::min(y1, h - 1);

		if(fill) {
			for(size_t y = y0; y <= y1; y++) {
				for(size_t x = x0; x <= x1; x++) {
					_unchecked_overlay_pixel({ x, y }, color, alpha);
				}
			}
		} else {
			for(size_t x = x0; x <= x1; x++) {
				_unchecked_overlay_pixel({ x, y0 }, color, alpha);
				_unchecked_overlay_pixel({ x, y1 }, color, alpha);
			}
			for(size_t y = y0 + 1; y < y1; y++) {
				_unchecked_overlay_pixel({ x0, y }, color, alpha);
				_unchecked_overlay_pixel({ x1, y }, color, alpha);
			}
		}
	}

	void Canvas::draw_circle(
		const Pos &center,
		float radius,
		const RgbColor &color,
		float alpha,
		bool fill
	) noexcept {
		int cx = static_cast<int>(center.x);
		int cy = static_cast<int>(center.y);
		int r = static_cast<int>(radius);

		size_t w, h;
		_get_image_size(w, h);
		auto safe_overlay = [&](int px, int py) noexcept {
			if(px >= 0 && py >= 0
				&& static_cast<size_t>(px) < w
				&& static_cast<size_t>(py) < h
			) {
				_unchecked_overlay_pixel(
					{ static_cast<size_t>(px), static_cast<size_t>(py) },
					color,
					alpha
				);
			}
		};

		if(fill) {
			for(int y = -r; y <= r; y++) {
				int dx = static_cast<int>(std::lround(std::sqrt(
					static_cast<float>(r) * r - static_cast<float>(y) * y
				)));
				for(int x = -dx; x <= dx; x++) {
					safe_overlay(cx + x, cy + y);
				}
			}
			return;
		}

		int x = 0, y = r;
		int d = 3 - 2 * r;
		auto plot = [&](int px, int py) noexcept {
			safe_overlay(cx + px, cy + py);
		};
		while(y >= x) {
			plot(x, y);                     plot(x, -y);
			plot(-x, y);                    plot(-x, -y);
			plot(y, x);                     plot(y, -x);
			plot(-y, x);                    plot(-y, -x);
			x++;
			if(d < 0) {
				d += 4 * x + 6;
			} else {
				y--;
				d += 4 * (x - y) + 10;
			}
		}
	}

	void Canvas::draw_image(
		const Pos &offset,
		const Image &image,
		float alpha
	) noexcept {
		Size size = image.size();
		size_t w, h;
		_get_image_size(w, h);
		for(size_t y = 0; y < size.h; y++) {
			for(size_t x = 0; x < size.w; x++) {
				size_t px = offset.x + x, py = offset.y + y;
				if(px < offset.x || py < offset.y) {
					continue;
				}
				if(px >= w || py >= h) {
					continue;
				}
				_unchecked_overlay_pixel(
					{ px, py },
					image._unchecked_get({ x, y }),
					alpha
				);
			}
		}
	}

	void Canvas::draw_uint(
		const Pos &pos,
		unsigned int num,
		const RgbColor &color,
		float alpha
	) noexcept {
		std::string digits = std::to_string(num);
		Pos p = pos;
		size_t w, h;
		_get_image_size(w, h);
		for(char ch : digits) {
			const num_font::signal_char_t &fc = num_font::num_font[ch - '0'];
			for(size_t y = 0; y < 5; y++) {
				for(size_t x = 0; x < 3; x++) {
					if(fc[y].test(2 - x)) {
						size_t px = p.x + x, py = p.y + y;
						if(px >= p.x && py >= p.y && px < w && py < h) {
							_unchecked_overlay_pixel({ px, py }, color, alpha);
						}
					}
				}
			}
			p.x += 4;
		}
	}

	void Canvas::fill(
		const RgbColor &color,
		float alpha
	) noexcept {
		for(RgbColor &c : _image._grid) {
			c = overlay(c, color, alpha);
		}
	}
}
