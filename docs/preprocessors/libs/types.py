from typing import Any, Dict, List, Optional


class MdChapter:
    def __init__(self, data: Dict[str, Any]):
        self._data = data

    @property
    def name(self) -> str:
        return self._data["name"]

    @name.setter
    def name(self, value: str):
        self._data["name"] = value

    @property
    def content(self) -> str:
        return self._data["content"]

    @content.setter
    def content(self, value: str):
        self._data["content"] = value

    @property
    def number(self) -> List[int]:
        return self._data["number"]

    @number.setter
    def number(self, value: List[int]):
        self._data["number"] = value

    @property
    def sub_items(self) -> List[Any]:
        return self._data["sub_items"]

    @sub_items.setter
    def sub_items(self, value: List[Any]):
        self._data["sub_items"] = value

    @property
    def path(self) -> str:
        return self._data["path"]

    @path.setter
    def path(self, value: str):
        self._data["path"] = value

    @property
    def source_path(self) -> str:
        return self._data["source_path"]

    @source_path.setter
    def source_path(self, value: str):
        self._data["source_path"] = value

    @property
    def parent_names(self) -> List[Any]:
        return self._data["parent_names"]

    @parent_names.setter
    def parent_names(self, value: List[Any]):
        self._data["parent_names"] = value


class MdSection:
    def __init__(self, data: Dict[str, Any]):
        self._data = data

    @property
    def chapter(self) -> Optional[MdChapter]:
        if "Chapter" in self._data:
            return MdChapter(self._data["Chapter"])
        return None

    @property
    def part_title(self) -> Optional[str]:
        return self._data.get("PartTitle")


class MdBook:
    def __init__(self, data: Dict[str, Any]):
        self._data = data

    @property
    def sections(self) -> List[MdSection]:
        return [MdSection(section) for section in self._data.get("sections", [])]

    @sections.setter
    def sections(self, value: List[Dict[str, Any]]):
        self._data["sections"] = value

    @property
    def non_exhaustive(self) -> Any:
        return self._data["__non_exhaustive"]

    @non_exhaustive.setter
    def non_exhaustive(self, value: Any):
        self._data["__non_exhaustive"] = value


__all__ = ["MdBook", "MdChapter", "MdSection"]
