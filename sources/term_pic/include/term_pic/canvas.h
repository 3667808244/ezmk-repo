#pragma once

#include "term_pic/color.h"
#include "term_pic/image.h"
#include "term_pic/pos.h"
#include <cstddef>
#include <ostream>

namespace term_pic{
	class Canvas {
		protected:
			Image _image;

			void _unchecked_overlay_pixel(
				const Pos &pos,
				const RgbColor &color,
				float alpha
			) noexcept;

			void _get_image_size(size_t &w, size_t &h) const noexcept;
		public:
			Canvas(const Size &size, const RgbColor &bg) : _image(size, bg) {}

			Image &image_ref() noexcept { return _image; }

			void clear() noexcept { _image.clear(); }
			void draw(std::ostream &os = std::cout) const noexcept { _image.draw(os); }
			RgbColor get_bg() const noexcept { return _image.get_bg(); }
			void set_bg(const RgbColor &bg) noexcept { _image.set_bg(bg); }

			void draw_pixel(
				const Pos &pos,
				const RgbColor &color,
				float alpha = 1.0f
			) noexcept;

			void draw_line(
				Pos start,
				Pos end,
				const RgbColor &color,
				float alpha = 1.0f
			) noexcept;

			void draw_rect(
				const Pos &start,
				const Pos &end,
				const RgbColor &color,
				float alpha = 1.0f,
				bool fill = true
			) noexcept;

			void draw_circle(
				const Pos &center,
				float radius,
				const RgbColor &color,
				float alpha = 1.0f,
				bool fill = true
			) noexcept;

			void draw_image(
				const Pos &offset,
				const Image &image,
				float alpha = 1.0f
			) noexcept;

			void draw_uint(
				const Pos &pos,
				unsigned int num,
				const RgbColor &color,
				float alpha = 1.0f
			) noexcept;

			void fill(
				const RgbColor &color,
				float alpha = 1.0
			) noexcept;
	};
}
