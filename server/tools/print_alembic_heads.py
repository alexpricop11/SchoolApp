import re
from pathlib import Path

vers = Path(__file__).resolve().parents[1] / 'alembic' / 'versions'
rev_re = re.compile(r"^revision\s*:?\s*['\"]([^'\"]+)['\"]", re.M)
down_re = re.compile(r"^down_revision\s*:?\s*(.+)$", re.M)

def parse_down(val: str):
    val = val.strip()
    if val in {'None', 'null'}:
        return []
    if val.startswith('('):
        return re.findall(r"['\"]([^'\"]+)['\"]", val)
    m = re.search(r"['\"]([^'\"]+)['\"]", val)
    return [m.group(1)] if m else []

revs = {}
downs = {}
for f in vers.glob('*.py'):
    txt = f.read_text(encoding='utf-8')
    m = rev_re.search(txt)
    if not m:
        continue
    r = m.group(1)
    revs[r] = f.name
    dm = down_re.search(txt)
    downs[r] = parse_down(dm.group(1)) if dm else []

all_down = {d for lst in downs.values() for d in lst}
heads = [r for r in revs if r not in all_down]
print('HEADS:', heads)
print('Count:', len(heads))
for h in heads:
    print(f"- {h} ({revs[h]}) down={downs.get(h)}")
