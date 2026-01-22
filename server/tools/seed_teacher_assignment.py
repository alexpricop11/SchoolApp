"""Seed teacher->class->subject assignment.

Usage (PowerShell):
  .\.venv\Scripts\python.exe tools\seed_teacher_assignment.py --teacher <TEACHER_USER_ID> --class <CLASS_ID> --subject <SUBJECT_ID>

This inserts into teacher_subjects and teacher_class_subjects.
"""

import argparse
import asyncio
import sys
import uuid
from pathlib import Path

from sqlalchemy import select

# Ensure project root is importable when running from tools/
PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from config.database import AsyncSession as AsyncSessionFactory  # noqa: E402
from app.users.models.teacher_subjects import TeacherClassSubject, TeacherSubject  # noqa: E402


async def main():
    p = argparse.ArgumentParser()
    p.add_argument("--teacher", required=True)
    p.add_argument("--class", dest="class_id", required=True)
    p.add_argument("--subject", required=True)
    args = p.parse_args()

    teacher_id = uuid.UUID(args.teacher)
    class_id = uuid.UUID(args.class_id)
    subject_id = uuid.UUID(args.subject)

    async with AsyncSessionFactory() as session:
        # Ensure teacher has subject in teacher_subjects
        res = await session.execute(
            select(TeacherSubject).where(
                TeacherSubject.teacher_id == teacher_id,
                TeacherSubject.subject_id == subject_id,
            )
        )
        if res.scalars().first() is None:
            session.add(TeacherSubject(teacher_id=teacher_id, subject_id=subject_id))

        # Ensure assignment exists
        res2 = await session.execute(
            select(TeacherClassSubject).where(
                TeacherClassSubject.teacher_id == teacher_id,
                TeacherClassSubject.class_id == class_id,
                TeacherClassSubject.subject_id == subject_id,
            )
        )
        if res2.scalars().first() is None:
            session.add(
                TeacherClassSubject(
                    teacher_id=teacher_id,
                    class_id=class_id,
                    subject_id=subject_id,
                )
            )

        await session.commit()
        print("OK")


if __name__ == "__main__":
    asyncio.run(main())
