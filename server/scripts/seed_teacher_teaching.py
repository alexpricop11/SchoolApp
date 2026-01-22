"""Seed teacher teaching assignments + schedules.

Usage:
  python scripts/seed_teacher_teaching.py --teacher <teacher_uuid> --class <class_uuid> --subject <subject_uuid>

Optionally pass multiple --class/--subject pairs.

This script:
- Inserts TeacherClassSubject (teacher_id, class_id, subject_id)
- Inserts at least 1 Schedule row if none exist for that triple

It is safe to run multiple times (idempotent-ish).
"""

import argparse
import os
import sys
import uuid

from sqlalchemy import text


def main() -> int:
    sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

    parser = argparse.ArgumentParser()
    parser.add_argument('--teacher', required=True)
    parser.add_argument('--class', dest='classes', action='append', required=True)
    parser.add_argument('--subject', dest='subjects', action='append', required=True)
    args = parser.parse_args()

    teacher_id = uuid.UUID(args.teacher)
    class_ids = [uuid.UUID(x) for x in args.classes]
    subject_ids = [uuid.UUID(x) for x in args.subjects]

    if len(class_ids) != len(subject_ids):
        print('You must provide the same number of --class and --subject arguments.')
        return 2

    from config.database import AsyncSession

    async def run():
        async with AsyncSession() as session:
            for class_id, subject_id in zip(class_ids, subject_ids):
                print(f'== Ensure teaching triple teacher={teacher_id} class={class_id} subject={subject_id} ==')

                # upsert teacher_class_subjects
                res = await session.execute(
                    text('''
                        SELECT 1 FROM teacher_class_subjects
                        WHERE teacher_id=:t AND class_id=:c AND subject_id=:s
                    '''),
                    {'t': teacher_id, 'c': class_id, 's': subject_id},
                )
                if res.first() is None:
                    await session.execute(
                        text('''
                            INSERT INTO teacher_class_subjects (id, teacher_id, class_id, subject_id)
                            VALUES (:id, :t, :c, :s)
                        '''),
                        {'id': uuid.uuid4(), 't': teacher_id, 'c': class_id, 's': subject_id},
                    )
                    print('  + inserted teacher_class_subjects')
                else:
                    print('  = teacher_class_subjects already exists')

                # ensure at least one schedule row for that triple
                res = await session.execute(
                    text('''
                        SELECT id FROM schedules
                        WHERE teacher_id=:t AND class_id=:c AND subject_id=:s
                        LIMIT 1
                    '''),
                    {'t': teacher_id, 'c': class_id, 's': subject_id},
                )
                if res.first() is None:
                    await session.execute(
                        text('''
                            INSERT INTO schedules (id, day_of_week, period_number, start_time, end_time, room, class_id, subject_id, teacher_id)
                            VALUES (:id, 'MONDAY', 1, '08:00', '08:45', NULL, :c, :s, :t)
                        '''),
                        {'id': uuid.uuid4(), 't': teacher_id, 'c': class_id, 's': subject_id},
                    )
                    print('  + inserted 1 schedule (MONDAY period 1)')
                else:
                    print('  = schedule already exists for this triple')

            await session.commit()
            print('✅ done')

    import asyncio

    asyncio.run(run())
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
