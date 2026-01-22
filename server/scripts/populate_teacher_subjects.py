"""
Populate teacher_class_subjects for a teacher.

This script was initially schedule-driven, but in a fresh DB schedules may be empty.

Behavior (in order):
1) If teacher has schedules, derive unique (class_id, subject_id) from schedules.
2) Otherwise, assign a default subject to each homeroom class (classes.teacher_id == teacher_id).

Config via env vars:
- TEACHER_EMAIL: default 'prof@example.com'
- DEFAULT_SUBJECT_NAME: default 'Informatica' (fallback to first subject in DB)

Run:
  python scripts/populate_teacher_subjects.py
"""

import asyncio
import os

# IMPORTANT: import models to ensure SQLAlchemy relationships are registered
# When running scripts standalone (outside FastAPI), mappers may fail to configure otherwise.
from app.school.models import School  # noqa: F401
from app.users.models import User  # noqa: F401
from app.users.models.teachers import Teacher  # noqa: F401
from app.users.models.students import Student  # noqa: F401
from app.classes.models import Class  # noqa: F401
from app.subject.models import Subject  # noqa: F401
from app.schedule.models import Schedule  # noqa: F401
from app.users.models.teacher_subjects import TeacherClassSubject  # noqa: F401
# Relationship targets (ensure mapper can resolve names)
from app.homework.models import Homework  # noqa: F401
from app.material.models import Material  # noqa: F401
from app.attendance.models import Attendance  # noqa: F401
from app.grade.models import GradeModel  # noqa: F401
from app.notification.models import Notification  # noqa: F401

from sqlalchemy import select

from config.database import AsyncSession


async def populate():
    teacher_email = os.getenv('TEACHER_EMAIL', 'prof@example.com')
    default_subject_name = os.getenv('DEFAULT_SUBJECT_NAME', 'Informatica')
    create_schedule = os.getenv('CREATE_SCHEDULE', '0') == '1'

    print(f'🔧 populate_teacher_subjects: TEACHER_EMAIL={teacher_email} DEFAULT_SUBJECT_NAME={default_subject_name} CREATE_SCHEDULE={create_schedule}')

    async with AsyncSession() as session:
        # Find teacher user
        result = await session.execute(select(User).where(User.email == teacher_email))
        prof_user = result.scalar_one_or_none()

        if not prof_user:
            # helpful diagnostics
            any_user = (await session.execute(select(User).limit(5))).scalars().all()
            print(f"❌ Teacher '{teacher_email}' not found!")
            print(f"   Sample users in DB (first 5 emails): {[getattr(u,'email',None) for u in any_user]}")
            return

        teacher_id = prof_user.id
        print(f"✅ Found teacher: {prof_user.username} (ID: {teacher_id})")

        # 1) Try schedule-driven mapping
        sched_result = await session.execute(select(Schedule).where(Schedule.teacher_id == teacher_id))
        schedules = list(sched_result.scalars().all())
        print(f"📅 Found {len(schedules)} schedule entries for this teacher")

        pairs = set()
        for sch in schedules:
            if sch.class_id and sch.subject_id:
                pairs.add((sch.class_id, sch.subject_id))

        if not pairs:
            # 2) Fallback: assign default subject to homeroom classes
            # Pick default subject by name (case-insensitive contains), else first subject
            subj_res = await session.execute(
                select(Subject).where(Subject.name.ilike(f"%{default_subject_name}%"))
            )
            default_subj = subj_res.scalar_one_or_none()
            if not default_subj:
                any_res = await session.execute(select(Subject).order_by(Subject.name.asc()).limit(1))
                default_subj = any_res.scalar_one_or_none()

            subjects_count = (await session.execute(select(Subject))).scalars().all()
            print(f"📚 Subjects in DB count={len(subjects_count)}")

            if not default_subj:
                print('❌ No subjects in DB. Create subjects first.')
                return

            print(f"📘 Using default subject: {default_subj.name} ({default_subj.id})")

            classes_res = await session.execute(select(Class).where(Class.teacher_id == teacher_id))
            homeroom_classes = list(classes_res.scalars().all())
            print(f"🏫 Found {len(homeroom_classes)} homeroom classes")

            for c in homeroom_classes:
                pairs.add((c.id, default_subj.id))

        print(f"🔗 Found {len(pairs)} unique (class, subject) pairs")

        inserted = 0
        for class_id, subject_id in pairs:
            existing = await session.execute(
                select(TeacherClassSubject).where(
                    TeacherClassSubject.teacher_id == teacher_id,
                    TeacherClassSubject.class_id == class_id,
                    TeacherClassSubject.subject_id == subject_id,
                )
            )
            if existing.scalar_one_or_none():
                print(f"  ⏭️  Already exists: class={class_id}, subject={subject_id}")
                continue

            session.add(
                TeacherClassSubject(
                    teacher_id=teacher_id,
                    class_id=class_id,
                    subject_id=subject_id,
                )
            )
            inserted += 1
            print(f"  ✅ Inserted: class={class_id}, subject={subject_id}")

        await session.commit()
        print(f"\n🎉 Successfully inserted {inserted} teacher_class_subject assignments!")

        if create_schedule and pairs:
            # create a basic schedule row per class if teacher has no schedules at all
            existing_sched = await session.execute(select(Schedule).where(Schedule.teacher_id == teacher_id).limit(1))
            if existing_sched.scalar_one_or_none() is None:
                # Spread lessons across week periods
                from datetime import time
                days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY']
                period = 1
                day_idx = 0
                created = 0
                for class_id, subject_id in sorted(pairs, key=lambda x: str(x[0])):
                    session.add(
                        Schedule(
                            day_of_week=days[day_idx % len(days)],
                            period_number=period,
                            start_time=time(8 + (period - 1), 0),
                            end_time=time(8 + (period - 1), 45),
                            room=None,
                            class_id=class_id,
                            subject_id=subject_id,
                            teacher_id=teacher_id,
                        )
                    )
                    created += 1
                    period += 1
                    if period > 6:
                        period = 1
                        day_idx += 1

                await session.commit()
                print(f"🗓️ Created {created} schedule rows (dev seed)")
            else:
                print('🗓️ Schedule already exists; not creating dev schedules')


if __name__ == '__main__':
    asyncio.run(populate())
