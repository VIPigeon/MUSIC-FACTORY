from pathlib import Path
import re

REQUIRE_RE = re.compile(r'^\s*require\s*\(\s*"([^"]+)"\s*\)\s*$', re.MULTILINE)

visited = set()


def expand_file(path: Path) -> str:
    path = path.resolve()

    if path in visited:
        return ""

    visited.add(path)

    text = path.read_text(encoding="utf-8")
    result = []

    for line in text.splitlines():
        m = REQUIRE_RE.match(line)

        if m:
            module_name = m.group(1)
            module_path = path.parent / f"{module_name}.lua"

            if not module_path.exists():
                raise FileNotFoundError(f"Не найден файл: {module_path}")

            result.append(f"-- BEGIN {module_name}.lua")
            result.append(expand_file(module_path))
            result.append(f"-- END {module_name}.lua")
        else:
            result.append(line)

    return "\n".join(result)


if __name__ == "__main__":
    input_file = Path("main.lua")
    output_file = Path("combined.lua")

    output_file.write_text(expand_file(input_file), encoding="utf-8")

    print(f"Готово: {output_file}")