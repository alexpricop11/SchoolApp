import os
import sys
import uuid

from sqlalchemy import text

# Allow running as: python scripts/debug_teacher_schedule.py <teacher_uuid>


def main() -> int:
    if len(sys.argv) < 2:
        print('Usage: python scripts/debug_teacher_schedule.py <teacher_uuid>')
        return 2

    teacher_id = uuid.UUID(sys.argv[1])

    # Local imports after sys.path is set
    sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

    from config.database import AsyncSession  # sessionmaker

    async def run():
        async with AsyncSession() as session:
            print(f'== Debug for teacher_id={teacher_id} ==')

            # 1) teacher exists?
            res = await session.execute(
                text('SELECT user_id FROM teachers WHERE user_id = :tid'),
                {'tid': teacher_id},
            )
            print('teachers row exists:', res.first() is not None)

            # 2) homeroom classes
            res = await session.execute(
                text('SELECT id, name FROM classes WHERE teacher_id = :tid ORDER BY name'),
                {'tid': teacher_id},
            )
            homeroom = res.fetchall()
            print(f'homeroom classes count={len(homeroom)}')
            for row in homeroom[:10]:
                print('  -', row)

            # 3) schedules
            res = await session.execute(
                text('SELECT id, day_of_week, period_number, class_id, subject_id FROM schedules WHERE teacher_id = :tid ORDER BY day_of_week, period_number'),
                {'tid': teacher_id},
            )
            schedules = res.fetchall()
            print(f'schedules count={len(schedules)}')
            for row in schedules[:10]:
                print('  -', row)

            # 4) teacher_class_subjects
            res = await session.execute(
                text('SELECT class_id, subject_id FROM teacher_class_subjects WHERE teacher_id = :tid'),
                {'tid': teacher_id},
            )
            tcs = res.fetchall()
            print(f'teacher_class_subjects count={len(tcs)}')
            for row in tcs[:20]:
                print('  -', row)

    import asyncio

    asyncio.run(run())
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
