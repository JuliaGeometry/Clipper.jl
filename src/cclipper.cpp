#include "clipper.hpp"
#include "stdio.h"

extern "C" {
	//==============================================================
	// Static functions
	//==============================================================
	__declspec(dllexport) bool __cdecl orientation(ClipperLib::IntPoint** path, size_t count) {
		ClipperLib::Path v = ClipperLib::Path();
		for(size_t i = 0; i < count; i++) {
			v.emplace(v.end(), path[i]->X, path[i]->Y);
		}

		return ClipperLib::Orientation(v);
	}

	__declspec(dllexport) double __cdecl area(ClipperLib::IntPoint** path, size_t count) {
		ClipperLib::Path v = ClipperLib::Path();
		for(size_t i = 0; i < count; i++) {
			v.emplace(v.end(), path[i]->X, path[i]->Y);
		}

		return ClipperLib::Area(v);
	}

	//==============================================================
	// Clipper object
	//==============================================================
	__declspec(dllexport) ClipperLib::Clipper* __cdecl get_clipper() {
		return new ClipperLib::Clipper();
	}

	__declspec(dllexport) void __cdecl delete_clipper(ClipperLib::Clipper *ptr) {
		delete ptr;
	}

	__declspec(dllexport) bool __cdecl add_path(ClipperLib::Clipper *ptr, ClipperLib::IntPoint** path, size_t count, ClipperLib::PolyType polyType, bool closed) {
		ClipperLib::Path v = ClipperLib::Path();
		for(size_t i = 0; i < count; i++) {
			v.emplace(v.end(), path[i]->X, path[i]->Y);
		}

		bool result = false;

		try {
			result = ptr->AddPath(v, polyType, closed);
		} catch(ClipperLib::clipperException e) {
			printf(e.what());
		}

		return result;
	}

	__declspec(dllexport) bool __cdecl add_paths(ClipperLib::Clipper *ptr, ClipperLib::IntPoint*** paths, size_t* path_counts,
																									size_t count, ClipperLib::PolyType polyType, bool closed) {
		ClipperLib::Paths vs = ClipperLib::Paths();
		for(size_t i = 0; i < count; i++) {
			auto it = vs.emplace(vs.end());

			for(size_t j = 0; j < path_counts[i]; j++) {
				it->emplace(it->end(), paths[i][j]->X, paths[i][j]->Y);
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

	__declspec(dllexport) bool __cdecl execute(ClipperLib::Clipper *ptr, ClipperLib::ClipType clipType,
														ClipperLib::PolyFillType subjFillType, ClipperLib::PolyFillType clipFillType,
														void* outputArray, void(*append)(void* outputArray, size_t polyIndex, ClipperLib::IntPoint point)) {
		ClipperLib::PolyTree pt = ClipperLib::PolyTree();

		bool result = false;

		try {
			result = ptr->Execute(clipType, pt, subjFillType, clipFillType);
		} catch(ClipperLib::clipperException e) {
			printf(e.what());
		}

		if (!result)
			return false;

		ClipperLib::Paths paths = ClipperLib::Paths();
		ClipperLib::PolyTreeToPaths(pt, paths);

		for (size_t i = 0; i < paths.size(); i++) {
			for (auto &point: paths[i]) {
				append(outputArray, i, point);
			}
		}

		return true;
	}

	__declspec(dllexport) void __cdecl clear(ClipperLib::Clipper *ptr) {
		ptr->Clear();
	}

	__declspec(dllexport) ClipperLib::IntRect __cdecl get_bounds(ClipperLib::Clipper *ptr) {
		return ptr->GetBounds();
	}

	//==============================================================
	// ClipperOffset object
	//==============================================================
	__declspec(dllexport) ClipperLib::ClipperOffset* __cdecl get_clipper_offset(double miterLimit, double roundPrecision) {
		return new ClipperLib::ClipperOffset(miterLimit, roundPrecision);
	}

	__declspec(dllexport) void __cdecl delete_clipper_offset(ClipperLib::ClipperOffset *ptr) {
		delete ptr;
	}

	__declspec(dllexport) void __cdecl add_offset_path(ClipperLib::ClipperOffset *ptr, ClipperLib::IntPoint** path, size_t count,
																						ClipperLib::JoinType joinType, ClipperLib::EndType endType) {
		ClipperLib::Path v = ClipperLib::Path();
		for(size_t i = 0; i < count; i++) {
			v.emplace(v.end(), path[i]->X, path[i]->Y);
		}

		try {
			ptr->AddPath(v, joinType, endType);
		} catch(ClipperLib::clipperException e) {
			printf(e.what());
		}
	}

	__declspec(dllexport) void __cdecl add_offset_paths(ClipperLib::ClipperOffset *ptr, ClipperLib::IntPoint*** paths, size_t* path_counts,
																									size_t count, ClipperLib::JoinType joinType, ClipperLib::EndType endType) {
		ClipperLib::Paths vs = ClipperLib::Paths();
		for(size_t i = 0; i < count; i++) {
			auto it = vs.emplace(vs.end());

			for(size_t j = 0; j < path_counts[i]; j++) {
				it->emplace(it->end(), paths[i][j]->X, paths[i][j]->Y);
			}
		}

		try {
			ptr->AddPaths(vs, joinType, endType);
		} catch(ClipperLib::clipperException e) {
			printf(e.what());
		}
	}

	__declspec(dllexport) void __cdecl clear_offset(ClipperLib::ClipperOffset *ptr) {
		ptr->Clear();
	}


	__declspec(dllexport) void __cdecl execute_offset(ClipperLib::ClipperOffset *ptr, double delta,
														void* outputArray, void(*append)(void* outputArray, size_t polyIndex, ClipperLib::IntPoint point)) {
		ClipperLib::PolyTree pt = ClipperLib::PolyTree();

		try {
			ptr->Execute(pt, delta);
		} catch(ClipperLib::clipperException e) {
			printf(e.what());
		}

		ClipperLib::Paths paths = ClipperLib::Paths();
		ClipperLib::PolyTreeToPaths(pt, paths);

		for (size_t i = 0; i < paths.size(); i++) {
			for (auto &point: paths[i]) {
				append(outputArray, i, point);
			}
		}
	}
}
