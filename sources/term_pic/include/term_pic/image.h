#pragma once

#include <algorithm>
#include <cstddef>
#include <iostream>
#include <optional>
#include <vector>
#include "term_pic/color.h"
#include "term_pic/error.h"
#include "term_pic/pos.h"

namespace term_pic {
	class Image {
		protected:
			std::vector<term_pic::RgbColor> _grid;
			size_t _w, _h;
			RgbColor _bg;

			RgbColor _unchecked_get(const Pos &pos) const noexcept;
			void _unchecked_set(const Pos &pos, const RgbColor &c) noexcept;
			
		public:
			Image(
				const Size &size,
				const RgbColor &bg = { 255, 255, 255 }
			): _w(size.w), _h(size.h), _bg(bg) {
				_grid.resize(_w * _h, _bg);
			}

			void resize(
				size_t w, size_t h,
				const std::optional<RgbColor> &bg = std::nullopt
			) noexcept {
				if(bg) {
					_bg = bg.value();
				}
				_w = w;
				_h = h;
				_grid.resize(_w * _h, _bg);
			}

			Res<RgbColor> get(const Pos &pos) const noexcept;
			Res<void> set(const Pos &pos, const RgbColor &c) noexcept;

			void draw(std::ostream &os = std::cout) const noexcept;
			void clear() noexcept {
				std::fill(_grid.begin(), _grid.end(), _bg);
			}

			RgbColor get_bg() const noexcept { return _bg; }
			void set_bg(const RgbColor &bg) noexcept { _bg = bg; }

			Size size() const noexcept {
				return { _w, _h };
			}

			friend class Canvas;
	};
}
