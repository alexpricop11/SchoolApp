import asyncio
from sqlalchemy import select
from config.database import async_session_maker
from app.users.models.teacher_subjects import TeacherClassSubject
from app.schedule.models import Schedule


async def check():
    print('Starting check...')
    try:
        async with async_session_maker() as s:
            # Check teacher_class_subjects
            print('Querying teacher_class_subjects...')
            r = await s.execute(select(TeacherClassSubject))
            rows = list(r.scalars().all())
            print(f'\n📊 TeacherClassSubject rows: {len(rows)}')
            for row in rows[:5]:
                print(f'  teacher={row.teacher_id}, class={row.class_id}, subject={row.subject_id}')

            # Check schedules
            print('\nQuerying schedules...')
            r2 = await s.execute(select(Schedule))
            sched = list(r2.scalars().all())
            print(f'\n📊 Schedule rows: {len(sched)}')
            for sch in sched[:5]:
                print(f'  teacher={sch.teacher_id}, class={sch.class_id}, subject={sch.subject_id}')
    except Exception as e:
        print(f'ERROR: {e}')
        import traceback
        traceback.print_exc()


if __name__ == '__main__':
    print('Script starting...')
    asyncio.run(check())
    print('Script finished.')
