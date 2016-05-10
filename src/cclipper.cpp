#include "clipper.hpp"
#include "stdio.h"

#if defined _WIN32 || defined __CYGWIN__
	#ifdef __GNUC__
		#define CDECL __attribute__ ((cdecl))
		#define DLL_PUBLIC __attribute__ ((dllexport))
	#else
		#define CDECL __cdecl
		#define DLL_PUBLIC __declspec(dllexport)
	#endif
#else
	#define CDECL __attribute__ ((cdecl))
	#if __GNUC__ >= 4
		#define DLL_PUBLIC __attribute__ ((visibility ("default")))
	#else
		#define DLL_PUBLIC
	#endif
#endif

extern "C" {
	//==============================================================
	// Static functions
	//==============================================================
	DLL_PUBLIC bool CDECL orientation(ClipperLib::IntPoint* path, size_t count) {
		ClipperLib::Path v = ClipperLib::Path();
		for(size_t i = 0; i < count; i++) {
			v.emplace(v.end(), path[i].X, path[i].Y);
		}

		return ClipperLib::Orientation(v);
	}

	DLL_PUBLIC double CDECL area(ClipperLib::IntPoint* path, size_t count) {
		ClipperLib::Path v = ClipperLib::Path();
		for(size_t i = 0; i < count; i++) {
			v.emplace(v.end(), path[i].X, path[i].Y);
		}

		return ClipperLib::Area(v);
	}

	//==============================================================
	// Clipper object
	//==============================================================
	DLL_PUBLIC ClipperLib::Clipper* CDECL get_clipper() {
		return new ClipperLib::Clipper();
	}

	DLL_PUBLIC void CDECL delete_clipper(ClipperLib::Clipper *ptr) {
		delete ptr;
	}

	DLL_PUBLIC bool CDECL add_path(ClipperLib::Clipper *ptr, ClipperLib::IntPoint* path, size_t count, ClipperLib::PolyType polyType, bool closed) {
		ClipperLib::Path v = ClipperLib::Path();
		for(size_t i = 0; i < count; i++) {
			v.emplace(v.end(), path[i].X, path[i].Y);
		}

		bool result = false;

		try {
			result = ptr->AddPath(v, polyType, closed);
		} catch(ClipperLib::clipperException e) {
			printf(e.what());
		}

		return result;
	}

	DLL_PUBLIC bool CDECL add_paths(ClipperLib::Clipper *ptr, ClipperLib::IntPoint** paths, size_t* path_counts,
																	size_t count, ClipperLib::PolyType polyType, bool closed) {
		ClipperLib::Paths vs = ClipperLib::Paths();
		for(size_t i = 0; i < count; i++) {
			auto it = vs.emplace(vs.end());

			for(size_t j = 0; j < path_counts[i]; j++) {
				it->emplace(it->end(), paths[i][j].X, paths[i][j].Y);
			}
		}

		bool result = false;

		try {
			result = ptr->AddPaths(vs, polyType, closed);
		} catch(ClipperLib::clipperException e) {
			printf(e.what());
		}

		return result;
	}

	DLL_PUBLIC bool CDECL execute(ClipperLib::Clipper *ptr, ClipperLib::ClipType clipType,
																ClipperLib::PolyFillType subjFillType, ClipperLib::PolyFillType clipFillType,
																void* outputArray, void(*append)(void* outputArray, size_t polyIndex, ClipperLib::IntPoint point)) {
		ClipperLib::Paths paths = ClipperLib::Paths();

		bool result = false;

		try {
			result = ptr->Execute(clipType, paths, subjFillType, clipFillType);
		} catch(ClipperLib::clipperException e) {
			printf(e.what());
		}

		if (!result)
			return false;

		for (size_t i = 0; i < paths.size(); i++) {
			for (auto &point: paths[i]) {
				append(outputArray, i, point);
			}
		}

		return true;
	}

	DLL_PUBLIC void CDECL clear(ClipperLib::Clipper *ptr) {
		ptr->Clear();
	}

	DLL_PUBLIC ClipperLib::IntRect CDECL get_bounds(ClipperLib::Clipper *ptr) {
		return ptr->GetBounds();
	}

	//==============================================================
	// ClipperOffset object
	//==============================================================
	DLL_PUBLIC ClipperLib::ClipperOffset* CDECL get_clipper_offset(double miterLimit, double roundPrecision) {
		return new ClipperLib::ClipperOffset(miterLimit, roundPrecision);
	}

	DLL_PUBLIC void CDECL delete_clipper_offset(ClipperLib::ClipperOffset *ptr) {
		delete ptr;
	}

	DLL_PUBLIC void CDECL add_offset_path(ClipperLib::ClipperOffset *ptr, ClipperLib::IntPoint* path, size_t count,
																				ClipperLib::JoinType joinType, ClipperLib::EndType endType) {
		ClipperLib::Path v = ClipperLib::Path();
		for(size_t i = 0; i < count; i++) {
			v.emplace(v.end(), path[i].X, path[i].Y);
		}

		try {
			ptr->AddPath(v, joinType, endType);
		} catch(ClipperLib::clipperException e) {
			printf(e.what());
		}
	}

	DLL_PUBLIC void CDECL add_offset_paths(ClipperLib::ClipperOffset *ptr, ClipperLib::IntPoint** paths, size_t* path_counts,
																				size_t count, ClipperLib::JoinType joinType, ClipperLib::EndType endType) {
		ClipperLib::Paths vs = ClipperLib::Paths();
		for(size_t i = 0; i < count; i++) {
			auto it = vs.emplace(vs.end());

			for(size_t j = 0; j < path_counts[i]; j++) {
				it->emplace(it->end(), paths[i][j].X, paths[i][j].Y);
			}
		}

		try {
			ptr->AddPaths(vs, joinType, endType);
		} catch(ClipperLib::clipperException e) {
			printf(e.what());
		}
	}

	DLL_PUBLIC void CDECL clear_offset(ClipperLib::ClipperOffset *ptr) {
		ptr->Clear();
	}


	DLL_PUBLIC void CDECL execute_offset(ClipperLib::ClipperOffset *ptr, double delta,
																			void* outputArray, void(*append)(void* outputArray, size_t polyIndex, ClipperLib::IntPoint point)) {
		ClipperLib::Paths paths = ClipperLib::Paths();

		try {
			ptr->Execute(paths, delta);
		} catch(ClipperLib::clipperException e) {
			printf(e.what());
		}

		for (size_t i = 0; i < paths.size(); i++) {
			for (auto &point: paths[i]) {
				append(outputArray, i, point);
			}
		}
	}
}
