#include "term_pic/image.h"
#include "term_pic/pos.h"
#include "term_pic/error.h"
#include "term_pic/color.h"
#include <optional>
#include <ostream>
#include <sstream>

namespace term_pic {
	RgbColor Image::_unchecked_get(const Pos &pos) const noexcept {
		return _grid[pos.y * _w + pos.x];
	}

	void Image::_unchecked_set(const Pos &pos, const RgbColor &c) noexcept {
		_grid[pos.y * _w + pos.x] = c;
	}

	Res<RgbColor> Image::get(const Pos &pos) const noexcept {
		if(pos.x >= _w || pos.y >= _h) {
			return Err(Error::OutOfRange);
		}
		return _unchecked_get(pos);
	}

	Res<void> Image::set(const Pos &pos, const RgbColor &c) noexcept {
		if(pos.x >= _w || pos.y >= _h) {
			return Err(Error::OutOfRange);
		}
		_unchecked_set(pos, c);
		return {};
	}

	void Image::draw(std::ostream &os) const noexcept {
		size_t x = 0, y = 0;
		std::ostringstream oss;
		if(_h % 2 == 1) {
			for (x = 0; x < _w; x++) {
				RgbColor c = _unchecked_get({x,y});
				oss << gen_seq(c) << "▄";
			}
			y++;
			oss << "\033[0m\n";
		}
		for(; y < _h; y+=2) {
			for (x = 0; x < _w; x++) {
				RgbColor uc = _unchecked_get({x, y});
				RgbColor dc = _unchecked_get({x, y+1});
				oss << gen_seq(dc, uc) << "▄";
			}
			oss << "\033[0m\n";
		}

		os << "\n" << oss.str() << std::flush;
	}
}
